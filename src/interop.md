# Interop with other languages (FFI)

Nim comes with powerful interoperability options, both when integrating Nim code in other languages and vice versa.

Acting as a complement to the [manual](https://nim-lang.org/docs/manual.html#foreign-function-interface), this section of the book covers interoperability / [FFI](https://en.wikipedia.org/wiki/Foreign_function_interface): how to integrate Nim into other languages and how to use libraries from other languages in Nim.

While it is possible to automate many things related to FFI, this guide focuses on core functionality - while tooling, macros and helpers can simplify the process, they remain a cosmetic layer on top of the fundamentals presented here.

The focus of this guide is on pragmatic solutions available for the currently supported versions of Nim - 1.6 at the time of writing - the recommendations may change as new libraries and Nim versions become available.

## Basics

In interop, we rely on a lowest common denominator of features between languages - for compiled languages, this is typically the mutually overlapping part of the [ABI](https://en.wikipedia.org/wiki/Application_binary_interface).

Nim is unique in that it also allows interoperability at the API level with C/C++ - however, this guide focuses on interoperability via ABI since this is more general and broadly useful.

Most languages define their FFI in terms of a simplified version of the C ABI - thus, the process of using code from one language in another typically consists of two steps:

* exporting the source library functions and types as "simple C"
* importing the "simple C" functions and types in the target language

We'll refer to this part of the process as ABI wrapping.

Since libraries tend to use the full feature set of their native language, we can see two additional steps:

* exposing the native library code in a "simple C" variant via a wrapper
* adding a wrapper around the "simple C" variant to make the foreign library feel "native"

We'll call this API wrapping - the API wrapper takes care of:

* conversions to/from Nim integer types
* introducing Nim idioms such as generics
* adapting the [error handling](./errors.md) model

The C ABI serves as the "lingua franca" of interop - the [C guide](./interop.c.md) in particular can be studied for topics not covered in the other language-specific sections.

## Calling Nim code from other languages

Nim code can be compiled both as shared and static libraries and thus used from other languages.

When calling Nim from other languages, care must be taken to first initialize the garbage collector, at least once for every thread.

Garbage collector initialization is a two-step process:

* the garbage collector itself must be inititialized with a call to `setupForeignThreadGc`
* `nimGC_setStackBottom` must be called to establish the starting point of the stack
  * this function must be called in all places where it is possible that the exported function is being called from a "shorter" stack frame

Typically, this is solved with a "library initialization" call that users of the library should call near the beginning of every thread (ie in their `main` or thread entry point function):

```nim
var initialized {.threadvar.}: bool

proc initializeMyLibrary() {.exportc.} =
  when declared(setupForeignThreadGc): setupForeignThreadGc()

proc exportedFunction {.exportc, raises: [].} =
  assert initialized, "You forgot to call `initializeMyLibrary"

  echo "Hello from Nim
```

In some languages such as [Go](./interop.go.md), it is hard to anticipate which thread code will be called from - in such cases, you can safely initialize the garbage collector in every exported function instead:

```nim
template initializeMyLibrary() =
  when declared(setupForeignThreadGc): setupForeignThreadGc()
  when declared(nimGC_setStackBottom):
    var locals {.volatile, noinit.}: pointer
    locals = addr(locals)
    nimGC_setStackBottom(locals)

# Always safe to call
proc exportedFunction {.exportc, raises: [].} =
  initializeMyLibrary()
  echo "Hello from Nim
```

See also the [Nim documentation](https://nim-lang.org/docs/backends.html#interfacing-backend-code-calling-nim) on this topic.

### Globals and top-level code

Code written outside of a `proc` / `func` is executed as part of `import`:ing the module, or, in the case of the "main" module of the program, as part of executing the module itself similar to the `main` function in C.

Nim puts this code in a function called `NimMain` and it serves a complement to the "library intialization function": it must only be called once!

## Exceptions

You must ensure that no exceptions pass to the foreign language - instead, catch all exceptions and covert them to a different [error handling mechanism](./errors.md), annotating the exported function with `{.raises: [].}`.

## Memory

Nim is generally a GC-first language meaning that memory is typically managed via a thread-local garbage collector.

Nim also supports manual memory management - this is most commonly used for threading and FFI.

### Garbage-collected types

Garbage-collection applies to the following types which are allocated from a thread-local heap:

* `string` and `seq` - these are value types that underneath use the GC heap for the payload
  * the `string` uses a dedicated length field but _also_ ensures NULL-termination which makes it easy to pass to C
  * `seq` uses a similar in-memory layout without the NULL termination
  * addresses to elements are stable as long as as elements are not added
* `ref` types
  * types that are declared as `ref object`
  * non-ref types that are allocated on the heap with `new` (and thus become `ref T`)

### `ref` types and pointers

The lifetime of garbage-collected types is undefined - the garbage collector generally runs during memory allocation but this should not be relied upon - instead, lifetime can be extended by calling `GC_ref` and `GC_unref`.

`ref` types have a stable memory address - to pass the address of a `ref` instance via FFI, care must be taken to extend the lifetime of the instance so that it is not garbage-collected

```nim
proc register(v: ptr cint) {.importc.}
proc unregister(v: ptr cint) {.importc.}

# Allocate a `ref cint` instance
let number = new cint
# Let the garbage collector know we'll be creating a long-lived pointer for FFI
GC_ref(number)
# Pass the address of the instance to the FFI function
register(addr number[])

# ... later, in reverse order:

# Stop using the instance in FFI - address is guaranteed to be stable
unregister(addr number[])
# Let the garbage collector know we're done
GC_unref(number)
```

### Manual memory management

Manual memory management is done with [`create`](https://nim-lang.org/docs/system.html#create%2Ctypedesc) (by type), [`alloc`](https://nim-lang.org/docs/system.html#alloc.t%2CNatural) (by size) and [`dealloc`](https://nim-lang.org/docs/system.html#dealloc%2Cpointer):

```nim
proc register(v: ptr cint) {.importc.}
proc unregister(v: ptr cint) {.importc.}

# Allocate a `ptr cint` instance
let number = create cint
# Pass the address of the instance to the FFI function
register(number)

# ... later, in reverse order:

# Stop using the instance in FFI - address is guaranteed to be stable
unregister(number)
# Free the instance
dealloc(number)
```

To allocate memory for cross-thread usage, ie allocating in one thread and deallocating in the other, use `createShared` / `allocShared` and `deallocShared` instead.

## Threads

Threads in Nim are created with [`createThread`](https://nim-lang.org/docs/threads.html) which creates the thread and prepares the garbage collector for use on that thread.

See [above](#calling-nim-code-from-other-languages) for how to initialize the garbage collector when calling Nim from threads created in other languages.

### Passing data between threads

The primary method of passing data between threads is to encode the data into a shared memory section then transfer ownership of the memory section to the receiving thread either via a thread-safe queue, channel, socket or pipe.

The queue itself can be passed to thread either at creation or via a global variable, though we generally seek to avoid global variables.

```nim
# TODO pick a queue

type ReadStatus = enum
  Empty
  Ok
  Done

proc read(queue: ptr Queue[pointer], var data: seq[byte]): ReadStatus =
  var p: pointer
  if queue.read(p):
    if isNil(p):
      ReadStatus.Done
    else:
      var len: int
      copyMem(addr len, p, sizeof(len))
      data = newSeqUninitalized[byte](len)
      copyMem(addr data[0], cast[pointer](cast[uint](data) + sizeof(len)), len)
    ReadStatus.Ok
  else:
    ReadStatus.Empty

proc write(queue: ptr Queue[pointer], data: openArray[byte]) =
  # Copy data to a shared length-prefixed buffer
  let
    copy = allocShared(int(len) + sizeof(len))
  copyMem(copy, addr len, sizeof(len))
  copyMem(cast[pointer](cast[uint](copy) + sizeof(len)), v, len)

  # Put the data on a thread-safe queue / list
  queue.add(copy)

proc reader(queue: ptr Queue[pointer]):
  var data: seq[byte]
  while true:
    case queue.read(data)
    of Done: return
    of Ok: process(data)
    of Empty:
      # Polling should usually be replaced with an appropriate "wake-up" mechanism
      sleep(100)
```

### async / await

When `chronos` is used, execution is typically controlled by the `chronos` per-thread dispatcher - passing data to `chronos` is done either via a pipe / socket or by polling a thread-safe queue.

## Resources

* [Nim backends documentation](https://nim-lang.org/1.6.0/backends.html)

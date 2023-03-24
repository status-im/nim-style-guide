# Go interop

`Nim` and `go` are both statically typed, compiled languages capable of interop via a simplifed C ABI, making interop between the two languages simple.

## Threads

`go` includes a native `M:N` scheduler for running `go` tasks - because of this, care must be taken both when calling Nim code from `go`: the thread from which the call will happen is controlled by `go` and  we must initialise the Nim garbage collector in every function exposed to `go`, as documented in the [main guide](./interop.md#calling-nim-code-from-other-languages):

```nim
template initializeMyLibrary() =
  when declared(setupForeignThreadGc): setupForeignThreadGc()
  when declared(nimGC_setStackBottom):
    var locals {.volatile, noinit.}: pointer
    locals = addr(locals)
    nimGC_setStackBottom(locals)

# Safe to call from go
proc exportedFunction {.exportc, raises: [].} =
  initializeMyLibrary()
  echo "Hello from Nim
```

As an alternative, we can pass the work to a dedicated thread instead - this works well for asynchronous code that reports the result via a callback mechanism:

```nim
{.pragma callback, cdecl, gcsafe, raises: [].}

type
  MyAPI = object
    queue: ThreadSafeQueue[ExportedFunctionData] # TODO document where to find a thread safe queue

  ExportedFunctionCallback = proc(result: cint) {.callback.}
  ExportedFunctionData =
    v: cint
    callback: ExportedFunctionCallback

proc runner(api: ptr MyAPI) =
  while true:
    processQueue(api[].queue)

proc initMyAPI(): ptr MyAPI {.exportc, raises: [].}=
  let api = createShared(MyAPI)
  # Shutdown / cleanup omitted for brevity
  discard createThread(runner, api)
  api

proc exportedFunction(api: ptr MyAPI, v: cint, callback: ExportedFunctionCallback) =
  # By not allocating any garbage-collected data, we avoid the need to initialize the garbage collector
  queue.add(ExportedFunctionData(v: cint, callback: callback))
```

## Variables

When calling Nim code from go, care must be taken that instances of [garbage-collected types](./interop.md#garbage-collected-types) don't pass between threads - this means process-wide globals and other forms of shared-memory apporaches of GC types must be avoided.

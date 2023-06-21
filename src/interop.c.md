# C / General wrapping

ABI wrapping is the process describing the low-level interface of a library in an interop-friendly way using the lowest common denominator between the languages. For interop, we typically separate the "raw" ABI wrapper from higher-level code that adds native-language conveniece.

When importing foreign libraries in Nim, the ABI wrapper can be thought of as a C "header" file: it describes to the compiler what code and data types are available in the library and how to encode them.

Conversely, exporting Nim code typically consists of creating special functions in Nim using the C-compatible subset of the langauge then creating a corrsponding ABI description in the target language.

Typical of the ABI wrapper is the use of the [FFI](https://nim-lang.org/docs/manual.html#foreign-function-interface) pragmas (`importc`, `exportc` etc) and, depending on the library, C types such as `cint`, `csize_t` as well as manual memory management directives such as `pointer`, `ptr`.

In some cases, it may be necessary to write an "export wrapper" in C - this happens in particular when the library was not written with ineroperability in mind, for example when there is heavy C pre-processor use or function implementations are defined in the C header file.

## Exporting

Exporting Nim code is done by creating an export module that presents the Nim code as a simplified C interface:

```nim
import mylibrary

# either `c`-prefixed types (`cint` etc) or explicitly sized types (int64 etc) work well
proc function(arg: int64): cint {.exportc: "function", dynlib, raises: [].} =
  # Validate incoming arguments before converting them to Nim equivalents
  if arg >= int64(int.high) or arg <= int64(int.low):
    return 0 # Expose error handling
  mylibrary.function(int(arg))
```

## Importing

### Build process

To import a library into Nim, it must first be built by its native compiler - depending on the complexity of the library, this can be done in several ways.

The preferred way of compiling a native library is it include it in the Nim build process via `{.compile.}` directives:

```nim
{.compile: "somesource.c".}
```

This ensures that the library is built together with the Nim code using the same C compiler as the rest of the build, automatically passing compilation flags and using the expected version of the library.

Alterantives include:

* build the library as a static or shared library, then make it part of the Nim compilation via `{.passL.}`
  * difficult to ensure version compatiblity
  * shared library requires updating dynamic library lookup path when running the binary
* build the library as a shared library, then make it part of the Nim compilation via `{.dynlib.}`
  * nim will load the library via `dlopen` (or similar)
  * easy to run into ABI / version mismatches
  * no record in binary about the linked library - tools like `ldd` will not display the dependencies correctly

### Naming

ABI wrappers are identified by `abi` in their name, either as a suffix or as the module name itself:

* [secp256k1](https://github.com/status-im/nim-secp256k1/blob/master/secp256k1/abi.nim)
* [bearssl](https://github.com/status-im/nim-bearssl/blob/master/bearssl/abi/bearssl_rand.nim)
* [sqlite3](https://github.com/arnetheduck/nim-sqlite3-abi/blob/master/sqlite3_abi.nim)

### Functions and types

Having created a separate module for the type, create definitions for each function and type that is meant to be used from Nim:

```nim
# Create a helper pragma that describes the ABI of typical C functions:
# * No Nim exceptions
# * No GC interation

{.pragma imported, importc, cdecl, raises: [], gcsafe.}

proc function(arg: int64): cint {.imported.}
```

### Callbacks

Callbacks are functions in the Nim code that are registered with the imported library and called from the library:

```nim
# The "callback" helper pragma:
#
# * sets an explicit calling convention to match C
# * ensures no exceptions leak from Nim to the caller of the callback
{.pragma: callback, cdecl, raises: [], gcsafe.}

import strutils
proc mycallback(arg: cstring) {.callback.} =
  # Write nim code as usual
  echo "hello from nim: ", arg

  # Don't let exceptions escape the callback
  try:
    echo "parsed: ", parseInt($arg)
  except ValueError:
    echo "couldn't parse"

proc registerCallback(callback: proc(arg: cstring) {.callback.}) {.imported.}

registerCallback(mycallback)
```

Care must be taken that the callback is called from a Nim thread - if the callback is called from a thread controlled by the library, the thread might need to be [initialized](./interop.md#calling-nim-code-from-other-languages) first.

### Memory allocation

Nim supports both garbage-collected, stack-based and manually managed memory allocation.

When using garbage-collected types, care must be taken to extend the lifetime of objects passed to C code whose lifetime extends beyond the function call:

```nim
# Register a long-lived instance with C library
proc register(arg: ptr cint) {.imported.}

# Unregister a previously registered instance
proc unregister(arg: ptr cint) {.imported.}

proc setup(): ref cint =
  let arg = new cint

  # When passing garbage-collected types whose lifetime extends beyond the
  # function call, we must first protect the them from collection:
  GC_ref(arg)
  register(addr arg[])
  arg

proc teardown(arg: ref cint) =
  # ... later
  unregister(addr arg[])
  GC_unref(arg)
```

## C wrappers

Sometimes, C headers contain not only declarations but also definitions and / or macros. Such code, when exported to Nim, can cause build problems, symbol duplication and other related issues.

The easiest way to expose such code to Nim is to create a plain C file that re-exports the functionality as a normal function:

```c
#include <inlined_code.h>

/* Reexport `function` using a name less likely to conflict with other "global" symbols */
int library_function() {
  /* function() is either a macro or an inline funtion defined in the header */
  return function();
}
```

## Tooling

* [`c2nim`](https://github.com/nim-lang/c2nim) - translate C header files to Nim, providing a starting place for wrappers

## References

* [Nim manual, FFI](https://nim-lang.org/docs/manual.html#foreign-function-interface)
* [Nim for C programmers](https://github.com/nim-lang/Nim/wiki/Nim-for-C-programmers)
* [Nim backend reference](https://nim-lang.org/docs/backends.html)

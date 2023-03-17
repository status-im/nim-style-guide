# C / General wrapping

ABI wrapping is the process describing the low-level interface of a library in an interop-friendly way using the lowest common denominator between the languages. For interop, we typically separate the "raw" ABI wrapper from higher-level code that adds native-language conveniece.

When importing foreign libraries to Nim, the ABI wrapper can be thought of as a C "header" file: it describes to the compiler what code and data types are available in the library and how to encode them.

Conversely, exporting Nim code typically consists of creating special functions using the C-compatible subset of the langauge, then creating a corrsponding ABI file in the target language.

Typical of the ABI wrapper is the use of the [FFI](https://nim-lang.org/docs/manual.html#foreign-function-interface) pragmas (`importc`, `exportc` etc) and, depending on the library, the use of "C" types such as `cint`, `csize_t` as well as manual memory management directives such as `pointer`, `ptr`.

In some cases, in order to successfully use a library from another language, it may be necessary to write the ABI wrapper in that language first - this happens when the library was not written with ineroperability in mind.

## Exporting

Exporting Nim code is done by creating an export module that presents the Nim code as a simplified C interface:

```nim
import mylibrary

proc function(arg: int64): cint {.exportc: "function".} =
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

This ensures that the library is built together with the Nim code using the same C compiler as the rest of the build, automatically passing compilation flags and using the expected version of the library

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
proc function(arg: int64): cint {.importc: "function"}
```

### Callbacks

Callbacks are functions in the Nim code that are registered with the imported library and called from the library.

```nim
# Take care not to raise exceptions from callbacks
proc mycallback(arg: cstring) {.cdecl, raises: [].} =
  # Setup the GC - safe to call multiple times
  when declared(setupForeignThreadGc): setupForeignThreadGc()

  # Write nim code as usual
  echo "hello from nim: ", arg

  # Don't let exceptions escape the callback
  try:
    echo "parsed: ", parseInt($arg)
  except ValueError:
    echo "couldn't parse"

proc registerCallback(callback: proc(arg: cstring, raises:[])) {.importc.}

registerCallback(mycallback)
```

### Memory access

Nim supports both garbage-collected, local and mannually managed memory allocation.

When using garbage-collected types, care must be taken to extend the lifetime of objects passed to C code whose lifetime extends beyond the function call:

```nim
proc register(arg: ptr cint) {.importc.}
proc unregister(arg: ptr cint) {.importc.}

proc caller():
  let arg = (ref int)()

  # When passing garbage-collected types whose lifetime extends beyond the
  # function call, we must first protect the memory:
  GC_ref(arg)
  register(addr arg[])


  # ... later

  unregister(addr arg[])
  GC_unref(arg)
```

### Tooling

* [`c2nim`](https://github.com/nim-lang/c2nim) - translate C header files to Nim, providing a starting place for wrappers

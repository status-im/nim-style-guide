---
name: nim-interop
description: FFI and interop patterns for Nim — C, Rust, Go, and general ABI wrapping
paths:
  - "*.nim"
  - "*.c"
  - "*.h"
---

# Nim Interop / FFI Skill

## When to Use

Use this skill when writing FFI wrappers, exporting Nim to foreign code, or importing foreign libraries.

## Architecture

Two layers:

1. **ABI wrapper** — lowest common denominator, C-compatible types. Module: `xxx_abi.nim`.
2. **API wrapper** — Nim idioms, generics, error handling adaptation.

## Importing C Libraries

### Pragma

```nim
{.pragma imported, importc, cdecl, raises: [], gcsafe.}
```

### Function Import

```nim
proc function(arg: int64): cint {.imported.}
```

### Build Process

- Prefer `{.compile: "source.c".}` to build inline with Nim.
- Avoid shared libraries (ABI/version mismatches).
- Avoid `dynlib` (no `ldd` visibility).

### Callbacks

```nim
{.pragma: callback, cdecl, raises: [], gcsafe.}

proc mycallback(arg: cstring) {.callback.} =
  try:
    echo "parsed: ", parseInt($arg)
  except ValueError:
    echo "couldn't parse"

proc registerCallback(callback: proc(arg: cstring) {.callback.}) {.imported.}
```

- Never let exceptions escape callbacks.
- Ensure callbacks run on Nim threads — foreign threads need GC init.

## Exporting Nim Code

### Pragma

```nim
{.pragma: exported, exportc, cdecl, raises: [].}
```

### Function Export

```nim
proc function(arg: int64): cint {.exportc: "function", cdecl, raises: [].} =
  if arg >= int64(int.high) or arg <= int64(int.low):
    return 0
  mylibrary.function(int(arg))
```

- Validate arguments before converting to Nim types.
- No exceptions — catch all and return error codes.

## Runtime Initialization

For exported Nim libraries:

```nim
proc NimMain() {.importc.}

var initialized: Atomic[bool]

proc initializeMyLibrary() {.exported.} =
  if not initialized.exchange(true):
    NimMain()
  when declared(setupForeignThreadGc): setupForeignThreadGc()
  when declared(nimGC_setStackBottom):
    var locals {.volatile, noinit.}: pointer
    locals = addr(locals)
    nimGC_setStackBottom(locals)
```

- Compile with `--nimMainPrefix:your_prefix`.
- Initialize GC per thread for foreign callers.
- Go scheduler: GC init in every exported function (can't predict thread).

## Memory Management

### GC-Protected (long-lived FFI)

```nim
proc register(v: ptr cint) {.importc.}
proc unregister(v: ptr cint) {.importc.}

proc setup(): ref cint =
  let arg = new cint
  GC_ref(arg)
  register(addr arg[])
  arg

proc teardown(arg: ref cint) =
  unregister(addr arg[])
  GC_unref(arg)
```

### Manual Memory

```nim
let number = create cint
register(number)
# ...
unregister(number)
dealloc(number)
```

- Cross-thread: use `createShared` / `allocShared` + `deallocShared`.
- `string` is GC-protected and NULL-terminated — easy to pass to C.

## Naming

- ABI modules: suffix or prefix `abi` (e.g., `xxx_abi.nim`).
- Types: `cint`, `csize_t`, `int64`, `cchar` for C interop.

## Resources

- `c2nim` — translate C headers to Nim.
- `nbindgen` — generate Nim ABI from Rust exports.

## Rust and Go

- Both use C ABI — same patterns as C interop.
- Rust: use `Box`/`Rc`/`Arc` for ownership; Nim side uses `GC_ref`/`GC_unref`.
- Go: use `createShared` for thread-safe queues; avoid GC types in shared globals.

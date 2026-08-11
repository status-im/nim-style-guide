---
name: nim-interop
description: FFI and interop patterns for Nim — C, Rust, Go, and general ABI wrapping
---

# Nim Interop / FFI Skill

## When to Use

Use this skill when working on FFI wrappers, exporting Nim to foreign code, or importing foreign libraries (C, Rust, Go). Activate for scenarios involving:
- Importing C libraries or headers (`*.h`, `*.c`)
- Exporting Nim symbols for foreign callers
- Writing ABI-compatible glue layers between Nim and other languages
- Setting up callbacks across FFI boundaries
- Managing GC initialization for foreign threads
- Handling memory management across process/language boundaries

## Judicious Application

These rules are strong defaults, not absolute mandates. Apply them with judgment:

- If a rule produces compiler errors requiring complex workarounds, do not follow it. Write the more readable code instead.
- If following a rule significantly hurts readability, prefer readability.
- If a rule conflicts with the specific requirements of a function or module, the local context wins.
- If a deviation is necessary, add a brief comment explaining why the rule was bent.

## Architecture

Two layers:

1. **ABI wrapper** — lowest common denominator, C-compatible types. Module: `xxx_abi.nim`.
2. **API wrapper** — Nim idioms, generics, error handling adaptation.

## Importing C Libraries

### Pragma

```nim
{.pragma: imported, importc, cdecl, raises: [], gcsafe.}
```

### Function Import

```nim
proc function(arg: int64): cint {.imported.} =
  ## The proc body is empty for imports — it's filled by the compiler.
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

## Avoid

- Shared libraries and `dynlib` — ABI/version mismatches, no `ldd` visibility.
- Letting exceptions escape callbacks — crashes foreign code.
- Using Nim GC types across threads without GC initialization.
- Passing `string` for binary data across FFI boundaries.

## Rust and Go

- Both use C ABI — same patterns as C interop.
- Rust: use `Box`/`Rc`/`Arc` for ownership; Nim side uses `GC_ref`/`GC_unref`.
- Go: use `createShared` for thread-safe queues; avoid GC types in shared globals.

## Resources

- `c2nim` — translate C headers to Nim.
- `nbindgen` — generate Nim ABI from Rust exports.

## Verification

- Compile check ABI wrapper: `nim c -c xxx_abi.nim`
- Verify exported symbols with `nm` or `objdump`
- Test callbacks with foreign test harness ensuring no exceptions escape

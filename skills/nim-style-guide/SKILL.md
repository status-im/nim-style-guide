---
name: nim-style-guide
description: Writing idiomatic Nim code, error handling, and build tooling — coding conventions, Result types, compiler flags, debugging, profiling, and editor setup
paths:
  - "*.nim"
  - "*.nimble"
---

# Nim Style Guide Skill

## When to Use

Use this skill when writing, reviewing, or refactoring Nim source code — covering idiomatic coding conventions, error handling patterns, build tooling, compiler flags, debugging, profiling, and editor setup.

## Judicious Application

These rules are strong defaults, not absolute mandates. Apply them with judgment:

- If a rule produces compiler errors requiring complex workarounds, do not follow it. Write the more readable code instead.
- If following a rule significantly hurts readability, prefer readability.
- If a rule conflicts with the specific requirements of a function or module, the local context wins.
- If a deviation is necessary, add a brief comment explaining why the rule was bent.

---

## Coding Conventions

### Procedure Declaration

- Prefer `func` over `proc`. Use `proc` only when side effects are unavoidable.
- Avoid the use explicit of `{.inline.}` pragmas.
- Prefer `openArray[T]` over `seq[T]` for traversal parameters.

### Return Values

- **Expression returns** for balanced exit points:
  ```nim
  func f(b: bool): int =
    if b: 1
    else: 2
  ```
- **Explicit `return`** for early exits:
  ```nim
  func parse(s: string): Result[int, cstring] =
    if s.len == 0: return err "empty"
    ...
  ```
- **Avoid `result`** — no compiler diagnostics for missing branches.

### Variable Declaration

- Most restrictive first: `const` → `let` → `var`.
- Prefer expression initialization:
  ```nim
  let x = if a > 4: 5 else: 6
  ```
- Avoid `var x: int; x = ...` pattern.

### Object Construction

- Use field-style init: `Xxx(field: value, other: 42)`
- Or `init` function: `Xxx.init(a, b)`
- Constructors for value types: `func init(T: type Xxx, a, b: int): T`
- Constructors for ref types: `func new(T: type Xxx, a, b: int): ref T`
- Ref-type constructors: `func init(T: type (ref Xxx), a, b: int): T`

### Memory Management

- Core/low-level: prefer stack-based and statically sized types.
- Glue layers: heap allocation via `ref`.
- Avoid `alloca`.

### Types to Avoid

- `ref object` — prefer explicit `ref Xxx` unless for handles, shared ownership, reference structures, or FFI.
- Converters — cause ambiguous overload resolution.
- `range` types — design issues, implicit conversions raise `Defect`.
- Finalizers — buggy, cause GC crashes.
- `Natural` — implicit conversion to signed may raise `Defect`.

### Integers

- Counting/indexing: use signed `int`.
- Binary/bit/hardware: use sized unsigned (`uint8`, `uint16`, `uint32`, `uint64`).
- Don't cast pointers to `int`.

### Binary Data

- Use `byte` and `seq[byte]`.
- Never use `string` for binary data.
- Convert stdlib strings to `seq[byte]` early.
- Print hex lowercase.

### Macros

- Avoid unless clearly necessary.
- Templates are 10× harder than code; macros are 100× harder.
- Never generate public API functions with macros.

### General Proc Types

- Prefer `{.closure.}` over `{.nimcall.}` for internal callbacks.
- Use `{.gcsafe.}` only when crossing thread boundaries.
- Avoid `{.threadvar.}` — prefer explicit parameter passing.

## Error Handling

### Prefer Result Types

- Return `Result[T, Error]` for explicit error signaling.
- Use `cstring` errors when the caller doesn't need to differentiate error kinds.
- Use `enum` errors when callers must act on specific error types.
- Use complex types when additional error info is needed.
- Use `Opt` (`Result`-based `Option`) for simple fail-or-succeed functions.

### Result Type Patterns

```nim
# Stringly typed — diagnostics only, no comparison
func f(): Result[int, cstring] = ...

# Enum errors — caller differentiates
func f2(): Result[int, SomeEnum] = ...
if f2.isErr and f2.error == SomeEnum.value: ...

# Exception transport
func f3(): Result[int, ref SomeError] = ...
```

### Exception Hierarchy

```nim
# Inherit from CatchableError — named XxxError
type MyLibraryError = object of CatchableError
type MySpecificError = object of MyLibraryError

# Inherit from Defect — named XxxDefect
type SomeDefect = object of Defect
```

### Module-Level Exception Annotations

Every module starts with:
```nim
{.push raises: [], gcsafe.}
```

Public functions annotate explicitly:
```nim
func f() {.raises: [MySpecificError]} = discard
```

### Raising Errors

```nim
# Contextual error data
raise (ref MyError)(msg: "description", data: value)

# Defect for panics — precondition violations, logic errors
# Catching Defect is undefined behavior; re-raise or quit
try: ..
except Defect as exc:
  debugEcho "oh no! ", exc.msg
  raise exc
```

### Catching Exceptions

- Catch the most specific error type.
- Use expression-based `try`:
  ```nim
  let x =
    try: ...
    except MyError as exc: ...
  ```
- Inside loops, wrap `try` per-iteration to avoid partial evaluations.
- `except:` (bare) is like `except CatchableError` — use sparingly.

### Avoid

- Status codes — verbose, mutable vars in scope during error branches.
- Exception translation across layers — leaks information, high visual overhead.
- Catching `CatchableError` broadly — type erasure, hard to maintain.

### Key Types

- `Defect` — NOT tracked by `raises`. Sources: signed overflow, `[]` indexing, `range` conversions.
- `CatchableError` — all catchable errors funnel through this.
- `Exception` — broader category.

### Result Library

- Use `results` module (`nimble` dependency).
- Export `results` when used in public symbols.

### Porting Legacy Code

- Bottom up: fix the underlying library/code.
- Top down: isolate with `try/except` and note where the exception comes from.

## Naming Conventions

- Match declaration casing/underscores exactly. Enable `--styleCheck:usages`.
- `XxxRef` for `ref object` types.
- `XxxError` for `CatchableError` exceptions.
- `XxxDefect` for `Defect` exceptions.

## Formatting

- 2 spaces indent.
- Use `nph` for formatting — never `nimpretty`.
- Hanging double indent for multiline args/conditions.
- 80-char line limit (88 allowed by `nph` default).

## Build System

- Use `make` + `git` submodules. **No `nimble`**.
- Dependencies tracked via submodules, including the Nim compiler itself.
- Source `env.sh` after checkout to enter the build environment.

## Compiler Configuration (config.nims)

Harden the build by promoting warnings/hints to errors:

```nim
# Warnings → errors
switch("warningAsError", "BareExcept:on")
switch("warningAsError", "CaseTransition:on")
switch("warningAsError", "CStringConv:on")
switch("warningAsError", "ImplicitDefaultValue:on")
switch("warningAsError", "LongLiterals:on")
switch("warningAsError", "ResultShadowed:on")
switch("warningAsError", "UnreachableCode:on")
switch("warningAsError", "UnreachableElse:on")
switch("warningAsError", "UnusedImport:on")
switch("warningAsError", "UseBase:on")

# Hints → errors
switch("hintAsError", "ConvFromXtoItselfNotNeeded:on")
switch("hintAsError", "DuplicateModuleImport:on")
switch("hintAsError", "XCannotRaiseY:on")
```

- Library `config.nims` only affects the library itself, not downstream projects.
- Omit `XCannotRaiseY` if situationally impractical.

## Style Checking

```
--styleCheck:usages
--styleCheck:error  # where feasible
```

## Compilation Commands

| Command | Purpose |
|---------|---------|
| `nim c -c file.nim` | Compile check (no linking) |
| `nim c -r test.nim` | Compile and run |
| `nim c -r --opt:none --debugger:native test.nim` | Debug run |
| `nim c -d:release -d:lto binary` | Release with LTO |

## Debugging

- Use `gdb` — Nim compiles to C under the hood.
- Flags: `--opt:none --debugger:native`.
- Configure in VSCode following the [C/C++ debugging guide](https://code.visualstudio.com/docs/cpp/cpp-debug).
- Run Nim files in VSCode with `F6`.
- Use `./env.sh code` to start VSCode with the correct compiler.

## Profiling

- Linux: `perf`
- Cross-platform: Intel VTune
- Compile with: `-d:release -d:lto --debugger:native`
- Use `libbacktrace` or `--stacktrace:off` — Nim's default stack trace algorithm is too slow.

## Editor Setup

### VSCode

- Extension: [Nim Extension](https://marketplace.visualstudio.com/items?itemName=NimLang.nimlang)
- Supports `nph` formatting.
- `nimsuggest` may hang — `killall nimsuggest` if needed.

## Dependencies

- Pin library code via submodules or amalgamation.
- Build from source via `{.compile.}` where possible.
- Fork upstream only when urgent patches are needed — pass fixes upstream.

## Verification

- Compile check: `nim c -c file.nim`
- Run tests: `nim c -r test_file.nim`
- Run with individual test files, not batches.

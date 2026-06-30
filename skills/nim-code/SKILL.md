---
name: nim-code
description: Writing idiomatic Nim code following the Status style guide
paths:
  - "*.nim"
  - "*.nimble"
---

# Nim Code Writing Skill

## When to Use

Use this skill when writing, reviewing, or refactoring Nim source code.

## Core Rules

### Procedure Declaration

- Prefer `func` over `proc`. Use `proc` only when side effects are unavoidable.
- Never use explicit `{.inline.}` pragmas.
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

## Verification

- Compile check: `nim c -c file.nim`
- Run tests: `nim c -r test_file.nim`
- Run with individual test files, not batches.

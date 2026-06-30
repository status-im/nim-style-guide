---
name: nim-errors
description: Error handling patterns for Nim — Result types, exceptions, status codes
paths:
  - "*.nim"
---

# Nim Error Handling Skill

## When to Use

Use this skill when writing functions that may fail, designing error types, or refactoring error handling.
## Judicious Application

These rules are strong defaults, not absolute mandates. Apply them with judgment:

- If a rule produces compiler errors requiring complex workarounds, do not follow it. Write the more readable code instead.
- If following a rule significantly hurts readability, prefer readability.
- If a rule conflicts with the specific requirements of a function or module, the local context wins.
- If a deviation is necessary, add a brief comment explaining why the rule was bent.

## Core Rules

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

### Porting Legacy Code

- Bottom up: fix the underlying library/code.
- Top down: isolate with `try/except` and note where the exception comes from.

### Key Types

- `Defect` — NOT tracked by `raises`. Sources: signed overflow, `[]` indexing, `range` conversions.
- `CatchableError` — all catchable errors funnel through this.
- `Exception` — broader category.

### Result Library

- Use `results` module (`nimble` dependency).
- Export `results` when used in public symbols.

## `return` keyword `[language.return]`

Use `return` for returning early from a function, for example to reduce nesting.

In other cases, prefer implicit expressions.

```nim
func f(v: ref Xxx): int =
  if v == nil:
    # early return to reduce nesting of happy case
    return 0
  ...

  # However, if we're at the end of the function, prefer implicit expressions
  if conditions:
    v[].value # avoid `return` in complex control flow, like here where else exists
  else:
    0

func short(): int =
  42 # avoid `return` for last expression
```

### Pros

* Explicitly shows where return happens
* Can simplify complex conditions and nesting

### Cons

* Can be confused with an early return, when used at the end of a function
* When nested deeply in control flow, can make conditions for early return difficult to understand

### Practical notes

* beware of `return` in `template`s since the `return` happens after template expansion!
  * ...specially when changing a `proc` _to_ a `template`
* `return` deep inside a complex set of conditionals indicates that the function likely needs refactoring
* `return` of a `var` risks returning instances that have not been fully initialized - this in particular applies to the implicit [`result`](./language.result.md) variable.
* expression style forces each branch of control-flow statements to end in a value, proving a compiler-enforced safety net that typically results in better error messages than `return`, specially when maintaining existing code

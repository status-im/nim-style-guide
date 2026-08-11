## `return` keyword `[language.return]`

Use `return` for returning early from a function, for example to reduce nesting.

In other cases, prefer implicit return expressions.

```nim
func f(v: ref Xxx): int =
  if v == nil:
    # early return to reduce nesting of happy case
    return 0
  ...

  # Prefer implicit return expressions in most other cases
  if conditions:
    v[].value
  else:
    0

func short(): int =
  42 # simple expressions also qualify
```

### Pros

* Can simplify complex conditions and nesting
* Explicitly shows where return control flow hapens

### Cons

* Brittle due to lack of compile-time enforcement of exhaustiveness of control flow and initialization
* When nested deeply, can make conditions for early return difficult to understand
* Surprising semantics in templates and macros

### Practical notes

* beware of `return` in `template`s since the `return` happens after template expansion!
  * ...especially when changing a `proc` _to_ a `template`
* `return` deep inside a complex set of conditionals indicates that the function likely needs refactoring
* `return` of a `var` risks returning instances that have not been fully initialized
  * this in particular applies to the implicit [`result`](./language.result.md) variable.
* `return expr` is shorthand for `result = expr; return result` - this reduces to `return result` when there is no expression

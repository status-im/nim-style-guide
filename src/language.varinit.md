## Variable initialization `[language.varinit]`

Prefer expressions to initialize variables and return values

```
let x =
  if a > 4: 5
  else: 6

func f(b: bool): int =
  if b: 1
  else: 2

# Avoid - `x` is not guaranteed to be initialized by all branches and in correct order (for composite types)
var x: int
if a > 4: x = 5
else: x = 6
```

### Pros

* Stronger compile-time checks
* Lower risk of uninitialized variables even after refactoring

### Cons

* Becomes hard to read when deeply nested


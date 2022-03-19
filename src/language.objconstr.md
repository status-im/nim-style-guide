## Object construction `[language.objconstr]`

Use `Xxx(x: 42, y: Yyy(z: 54))` style, or if type has an `init` function, `Type.init(a, b, c)`.

Prefer that the default 0-initialization is a valid state for the type.

```nim
# `init` functions are a convention for constructors - they are not enforced by the language
func init(T: type Xxx, a, b: int): T = T(
  x: a,
  y: OtherType(s: b) # Prefer Type(field: value)-style initialization
)

let m = Xxx.init(1, 2)

# `new` returns a reference to the given type:
func new(T: type Xxx, a, b: int ): ref T = ...

# ... or `init` when used with a `ref Xxx`:
func init(T: type (ref Xxx), a, b: int ): T = ...
```

### Pros

* Correct order of initialization enforced by compiler / code structure
* Dedicated syntax constructs a clean instance resetting all fields
* Possible to build static analysis tools to detect uninitialized fields
* Works for both `ref` and non-`ref` types

### Cons

* Sometimes inefficient compared to updating an existing `var` instance, since all fields must be re-initialized

### Practical notes

* The default, 0-initialized state of the object often gets constructed in the language - avoiding a requirement that a magic `init` function be called makes the type more ergonomic to use
* Avoid using `result` or `var instance: Type` which disable several compiler diagnostics

## Methods `[language.methods]`

[Manual](https://nim-lang.org/docs/manual.html#methods)

Use `method` sparingly - consider a "manual" vtable with `proc` closures instead.

### Pros

* Compiler-implemented way of doing dynamic dispatch

### Cons

* Poor implementation
  * Implemented using `if` tree
  * Require full program view to "find" all implementations
* Poor discoverability - hard to tell which `method`'s belong together and form a virtual interface for a type
  * All implementations must be public (`*`)!

### Practical notes

* Does not work with generics
* No longer does multi-dispatch


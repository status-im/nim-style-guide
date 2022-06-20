## Inline functions `[language.inline]`

Avoid using explicit `{.inline.}` functions.

### Pros

* Sometimes give performance advantages

### Cons

* Adds clutter to function definitions
* Larger code size, longer compile times
* Prevent certain LTO optimizations

### Practical notes

* `{.inline.}` does not inline code - rather it copies the function definition into every `C` module making it available for the `C` compiler to inline
* Compilers can use contextual information to balance inlining
* LTO achieves a similar end result without the cons

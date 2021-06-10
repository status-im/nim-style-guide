## Results `[libraries.results]`

[Manual](https://github.com/status-im/nim-stew/blob/master/stew/results.nim#L19)

Use `Result` to document all outcomes of functions.

Use `cstring` errors to provide diagnostics without expectation of error differentiation.

Use `enum` errors when error kind matters.

Use complex types when additional error information needs to be included.

Use `Opt` (`Result`-based `Option`) for simple functions that fail only in trivial ways.

```
# Stringly errors - the cstring is just for information and
# should not be used for comparisons! The expectation is that
# the caller doesn't have to differentiate between different
# kinds of errors and uses the string as a print-only diagnostic.
func f(): Result[int, cstring] = ...

# Calling code acts on error specifics - use an enum
func f2(): Result[int, SomeEnum] = ...
if f2.isErr and f2.error == SomeEnum.value: ...

# Transport exceptions - Result has special support for this case
func f3(): Result[int, ref SomeError] = ...
```

### Pros

* Give equal consideration to normal and error case
* Easier control flow vulnerability analysis
* Good for "binary" cases that either fail or not
* No heap allocations for simple errors

### Cons

* Visual overhead and poor language integration in `Nim` - ugly `if` trees grow
* Nim compiler generates ineffient code for complex types due to how return values are 0-intialized
* Lack of pattern matching makes for inconvenient code
* Standard library raises many exceptions, hard to use cleanly

### Practical notes

* When converting modules, isolate errors from legacy code with `try/except`
  * Common helpers may be added at some point to deal with third-party dependencies that are hard to change - see `stew/shims`


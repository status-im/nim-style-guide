## `result` return `[language.result]`

Avoid using `result` for returning values.

Prefer expression-based return or in some cases, explicit [`return`](./language.return.md)

### Pros

* Recommended by NEP-1
* Used in standard library
* Saves a line of code avoiding an explicit `var` declaration
* Accumulation-style functions that gradually build up a return value gain consistency

### Cons

* No visual (or compiler) help when a branch is missing a value, or overwrites a previous value
* Disables compiler diagnostics for code branches that forget to set result
* Risk of using partially initialized instances due to `result` being default-initialized
    * For `ref` types, `result` starts out as `nil` which accidentally might be returned
    * Helpers may accidentally use `result` before it was fully initialized
    * Async/await using result prematurely due to out-of-order execution
* Partially initialized instances lead to exception-unsafe code where resource leaks happen
    * RVO causes observable stores in the left-hand side of assignments when exceptions are raised after partially modifying `result`
* Confusing to people coming from other languages
* Confusing semantics in templates and macros

### Practical notes

Nim has 3 ways to assign a return value to a function: `result`, `return` and "expressions".

Of the three:

* "expression" returns guarantee that all code branches produce one (and only one) value to be returned
  * Used mainly when exit points are balanced and not deeply nested
* Explicit `return` can simplify conditional expressions
  * Used to avoid deep nesting and early exit, above all when returning early due to errors
* `result` is used to accumulate / build up return value, allowing it to take on invalid values in the interim
* the usage of `result` is sometimes necessary to aid the compiler in Return-Value-Optimization analysis - if this is the case, use `result` but report a bug

Multiple security issues, `nil` reference crashes and wrong-init-order issues have been linked to the use of `result` and lack of assignment in branches.

In general, the use of accumulation-style initialization is discouraged unless made necessary by the data type - see [Variable initialization](language.varinit.md) - this also applies to the implict `result` variable.

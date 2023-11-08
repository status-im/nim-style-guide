## Callbacks, closures and forward declarations `[language.proctypes]`

Annotate `proc` type definitions and forward declarations with `{.raises [], gcsafe.}` or specific exception types.

```nim
# By default, Nim assumes closures may raise any exception and are not gcsafe
# By annotating the callback with raises and gcsafe, the compiler ensures that
# any functions assigned to the closure fit the given constraints
type Callback = proc(...) {.raises: [], gcsafe.}
```

### Practical notes

* Without annotations, `{.raises [Exception].}` and no GC-safety is assumed by the compiler, infecting deduction in the whole call stack
* Annotations constrain the functions being assigned to the callback to follow its declaration, simplifying calling the callback safely
  * In particular, callbacks are difficult to reason about when they raise exceptions - what should the caller of the callback do?

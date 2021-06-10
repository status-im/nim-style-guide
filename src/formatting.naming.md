## Naming conventions `[formatting.naming]`

Always use the same identifier style (case, underscores) as the declaration.

* `Ref` for `ref object` types, which have surprising semantics
    * `type XxxRef = ref Xxx`
    * `type XxxRef = ref object ...`
* `func init(T: type Xxx, params...): T` for "constructors"
* `func new(T: type XxxRef, params...): T` for "constructors" of `ref object` types
* `XxxError` for exceptions inheriting from `CatchableError`
* `XxxDefect` for exceptions inheriting from `Defect`

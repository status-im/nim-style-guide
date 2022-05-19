## Naming conventions `[formatting.naming]`

Always use the same identifier style (case, underscores) as the declaration.

Enable `--styleCheck:usages`.

* `Ref` for `ref object` types, which have surprising semantics
  * `type XxxRef = ref Xxx`
  * `type XxxRef = ref object ...`
* `func init(T: type Xxx, params...): T` for "constructors"
  * `func init(T: type ref Xxx, params...): T` when `T` is a `ref`
* `func new(T: type Xxx, params...): ref T` for "constructors" that return a `ref T`
  * `new` introduces `ref` to a non-`ref` type
* `XxxError` for exceptions inheriting from `CatchableError`
* `XxxDefect` for exceptions inheriting from `Defect`

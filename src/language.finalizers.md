## Finalizers `[language.finalizers]`

[Manual](https://nim-lang.org/docs/system.html#new%2Cref.T%2Cproc%28ref.T%29)

Don't use finalizers.

### Pros

* Work around missing manual cleanup

### Cons

* [Buggy](https://github.com/nim-lang/Nim/issues/4851), cause random GC crashes
* Calling `new` with finalizer for one instance infects all instances with same finalizer
* Newer Nim versions migrating new implementation of finalizers that are sometimes deterministic (aka destructors)

## `range` `[language.range]`

Avoid `range` types.

### Pros

* Range-checking done by compiler
* More accurate bounds than `intXX`
* Communicates intent

### Cons

* Implicit conversions to "smaller" ranges may raise `Defect`
* Language feature has several fundamental design and implementation issues
  * https://github.com/nim-lang/Nim/issues/16839
  * https://github.com/nim-lang/Nim/issues/16744
  * https://github.com/nim-lang/Nim/issues/13618
  * https://github.com/nim-lang/Nim/issues/12780
  * https://github.com/nim-lang/Nim/issues/10027
  * https://github.com/nim-lang/Nim/issues?page=1&q=is%3Aissue+is%3Aopen+range

## Style `[formatting.style]`

We strive to follow [NEP-1](https://nim-lang.org/docs/nep1.html) for style matters - naming, capitalization, 80-character limit etc. Common places where deviations happen include:

* Code based on external projects
    * Wrappers / FFI
    * Implementations of specs that have their own naming convention
    * Ports from other languages
* Small differences due to manual formatting
* Aligned indents - we prefer python-style hanging indent for in multiline code

```
func someLongFunctinName(
    alsoLongVariableName: int) = # Double-indent
  discard # back to normal indent
```

### Practical notes

* We do not use `nimpretty` - as of writing (nim 1.2), it is not stable enough for daily use:
    * Can break working code
    * Naive formatting algorithm
* We do not make use of Nim's "flexible" identifier names - all uses of an identifier should match the declaration in capitalization and underscores

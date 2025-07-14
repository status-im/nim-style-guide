## Style `[formatting.style]`

We strive to follow [NEP-1](https://nim-lang.org/docs/nep1.html) for style matters - naming, capitalization, 80-character limit etc. Common places where deviations happen include:

* Code based on external projects
    * Wrappers / FFI
    * Implementations of specs that have their own naming convention
    * Ports from other languages
* Small differences due to manual formatting
* Aligned indents - we prefer python-style hanging indent for in multiline code
    * This is to avoid realignments when changes occur on the first line. The extra level of indentation is there to clearly distinguish itself as a continuation line.
* Line length limit
  * `nph` uses an [88-character](https://arnetheduck.github.io/nph/faq.html#why-88-characters) line width which results in the occasional line exceeding the usual 80-character limit

```nim
func someLongFunctinName(
    alsoLongVariableName: int # Hanging double indent
) =
  discard # back to normal indent

  if someLongCondition and
      moreLongConditions: # Hanging double indent
    discard # back to normal indent
```

### Practical notes

* We do not use `nimpretty` - as of writing (Nim 2.0), it is not stable enough for daily use
  * Use [nph](./formatting.md) instead!
* We do not make use of Nim's "flexible" identifier names - all uses of an identifier should match the declaration in capitalization and underscores
    * Enable `--styleCheck:usages` and, where feasible, `--styleCheck:error`

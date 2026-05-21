## Compiler `[tooling.compiler]`


### config.nims

Use `config.nims` to harden your build by promoting selected warnings (and hints) to errors, forcing safer, cleaner code to pass compilation.


A `config.nims` snippet which can be copy/pasted follows; it converts certain compile-time warnings and hints to errors.

```nim
# turn warnings into compile errors
switch("warningAsError", "BareExcept:on")
switch("warningAsError", "CaseTransition:on")
switch("warningAsError", "CStringConv:on")
switch("warningAsError", "ImplicitDefaultValue:on")
switch("warningAsError", "LongLiterals:on")
switch("warningAsError", "ResultShadowed:on")
switch("warningAsError", "UnreachableCode:on")
switch("warningAsError", "UnreachableElse:on")
switch("warningAsError", "UnusedImport:on")
switch("warningAsError", "UseBase:on")

# turn hints into compile errors
switch("hintAsError", "ConvFromXtoItselfNotNeeded:on")
switch("hintAsError", "DuplicateModuleImport:on")
switch("hintAsError", "XCannotRaiseY:on")
```

Note that if some of above does not work for your project, such as `XCannotRaiseY`, feel free to leave it out.

### Scope of config.nims

A library’s `config.nims` file usually does not affect projects that depend on the library. It is typically applied only when the library itself is the active project or when the library is included as a subdirectory of another project.

This is generally beneficial: it allows the library’s own CI and development setup to use stricter checks without causing unexpected effects in downstream projects.
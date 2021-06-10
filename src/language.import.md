## Import, export `[language.import]`

[Manual](https://nim-lang.org/docs/manual.html#modules-import-statement)

`import` a minimal set of modules using explicit paths.

`export` all modules whose types appear in public symbols of the current module.

Prefer specific imports. Avoid `include`.

```nim
# Group by std, external then internal imports
import
  # Standard library imports are prefixed with `std/`
  std/[options, sets],
  # use full name for "external" dependencies (those from other packages)
  package/[a, b],
  # use relative path for "local" dependencies
  ./c, ../d

# export modules whose types are used in public symbols in the current module
export options
```

### Practical notes

Modules in Nim share a global namespace, both for the module name itself and for all symbols contained therein - because of this, your code might break because a dependency introduces a module or symbol with the same name - using prefixed imports (relative or package) helps mitigate some of these conflicts.

Because of overloading and generic catch-alls, the same code can behave differently depending on which modules have been imported and in which order - reexporting modules that are used in public symbols helps avoid some of these differences.

See also: [sandwich problem](https://github.com/nim-lang/Nim/issues/11225)


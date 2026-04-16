## Compiler `[tooling.compiler]`


### config.nims

Use `config.nims` to harden your build by promoting selected warnings (and hints) to errors, forcing safer, cleaner code to pass compilation.

**Treat Selected Warnings as Errors**

Consider promoting certain warnings to errors to enforce stricter code quality:
```nim
switch("warningAsError", "UnreachableCode:on")
```

- `UnreachableCode:on` → Catches code that can never execute
- `UnreachableElse:on` → Detects else branches that are never reachable
- `UnusedImport:on` → Keeps the codebase clean by removing unused imports
- `UseBase:on` → Ensures correct use of base methods in inheritance
- `ResultShadowed:on` → Prevents accidentally redefining result, which can hide return values.

**Treat Selected Hints as Errors**

You can also promote certain hints to errors:
```nim
switch("hintAsError", "XCannotRaiseY:on")
```

- `XCannotRaiseY:on` → Flags invalid exception declarations for cleaner interaces and simplier error handling
- `DuplicateModuleImport:on` → Prevents importing the same module multiple times unnecessarily.
- `ConvFromXtoItselfNotNeeded:on` → Avoids pointless type conversions that add noise.

---
name: nim-tooling
description: Build system, compiler flags, config.nims, debugging, and profiling for Nim projects
paths:
  - "config.nims"
  - "Makefile"
  - "*.nim"
---

# Nim Tooling Skill

## When to Use

Use this skill when setting up Nim build configurations, adding compiler flags, debugging, or profiling.

## Build System

- Use `make` + `git` submodules. **No `nimble`**.
- Dependencies tracked via submodules, including the Nim compiler itself.
- Source `env.sh` after checkout to enter the build environment.

## Compiler Configuration (config.nims)

Harden the build by promoting warnings/hints to errors:

```nim
# Warnings → errors
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

# Hints → errors
switch("hintAsError", "ConvFromXtoItselfNotNeeded:on")
switch("hintAsError", "DuplicateModuleImport:on")
switch("hintAsError", "XCannotRaiseY:on")
```

- Library `config.nims` only affects the library itself, not downstream projects.
- Omit `XCannotRaiseY` if situationally impractical.

## Style Checking

```
--styleCheck:usages
--styleCheck:error  # where feasible
```

## Compilation Commands

| Command | Purpose |
|---------|---------|
| `nim c -c file.nim` | Compile check (no linking) |
| `nim c -r test.nim` | Compile and run |
| `nim c -r --opt:none --debugger:native test.nim` | Debug run |
| `nim c -d:release -d:lto binary` | Release with LTO |

## Debugging

- Use `gdb` — Nim compiles to C under the hood.
- Flags: `--opt:none --debugger:native`.
- Configure in VSCode following the [C/C++ debugging guide](https://code.visualstudio.com/docs/cpp/cpp-debug).
- Run Nim files in VSCode with `F6`.
- Use `./env.sh code` to start VSCode with the correct compiler.

## Profiling

- Linux: `perf`
- Cross-platform: Intel VTune
- Compile with: `-d:release -d:lto --debugger:native`
- Use `libbacktrace` or `--stacktrace:off` — Nim's default stack trace algorithm is too slow.

## Editor Setup

### VSCode

- Extension: [Nim Extension](https://marketplace.visualstudio.com/items?itemName=NimLang.nimlang)
- Supports `nph` formatting.
- `nimsuggest` may hang — `killall nimsuggest` if needed.

## Formatting

- Use `nph` (https://github.com/arnetheduck/nph).
- Pin `nph` version in CI (https://github.com/arnetheduck/nph-action).
- Do **not** use `nimpretty` — not stable.
- `nph` default line width: 88 chars (occasional 80-char overflow).

## Dependencies

- Pin library code via submodules or amalgamation.
- Build from source via `{.compile.}` where possible.
- Fork upstream only when urgent patches are needed — pass fixes upstream.

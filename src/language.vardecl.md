## Variable declaration `[language.vardecl]`

Use the most restrictive of `const`, `let` and `var` that the situation allows.

```nim
# Group related variables
const
  a = 10
  b = 20
```

### Practical notes

`const` and `let` each introduce compile-time constraints that help limit the scope of bugs that must be considered when reading and debugging code.

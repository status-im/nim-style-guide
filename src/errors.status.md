## Status codes `[errors.status]`

Avoid status codes.

```nim

type StatusCode = enum
  Success
  Error1
  ...

func f(output: var Type): StatusCode
```

### Pros

* Interop with `C`

### Cons

* `output` undefined in case of error
* Verbose to use, must first declare mutable variable then call function and check result - mutable variable remains in scope even in "error" branch leading to bugs

### Practical notes

Unlike "Error Enums" used with `Result`, status codes mix "success" and "error" returns in a single enum, making it hard to detect "successful" completion of a function in a generic way.

## Result `[errors.result]`

Prefer `bool`, `Opt` or `Result` to signal failure outcomes explicitly. Avoid using the [`result` identifier](language.result.md).

Prefer the use of `Result` when multiple failure paths exist and the calling code might need to differentiate between them.

Raise `Defect` to signal panics such as logic errors or preconditions being violated.

Make error handling explicit and visible at call site using explicit control flow (`if`, `try`, `results.?`).

Handle errors locally at each abstraction level, avoiding spurious abstraction leakage.

Isolate legacy code with explicit exception handling, converting the errors to `Result` or handling them locally, as appropriate.

```nim
# Enable exception tracking for all functions in this module
`{.push raises: [Defect].}` # Always at start of module

import stew/results
export results # Re-export modules used in public symbols

# Use `Result` to propagate additional information expected errors
# See `Result` section for specific guidlines for errror type
func f*(): Result[void, cstring]

# In special cases that warrant the use of exceptions, list these explicitly using the `raises` pragma.
func parse(): Type {.raises: [Defect, ParseError]}
```

See also [Result](libraries.result.md) for more recommendations about `Result`.

See also [Error handling helpers](https://github.com/status-im/nim-stew/pull/26) in stew that may change some of these guidelines.

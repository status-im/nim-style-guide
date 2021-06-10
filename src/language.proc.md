## Functions and procedures `[language.proc]`

Prefer `func` - use `proc` when side effects cannot conveniently be avoided.

Avoid public functions and variables (`*`) that don't make up an intended part of public API.

### Practical notes

* Public functions are not covered by dead-code warnings and contribute to overload resolution in the the global namespace
* Prefer `openArray` as argument type over `seq` for traversals

## Converters `[language.converters]`

[Manual](https://nim-lang.org/docs/manual.html#converters)

Avoid using converters.

### Pros

* Implicit conversions lead to low visual overhead of converting types

### Cons

* Surprising conversions lead to ambiguous calls:
  ```nim
  converter toInt256*(a: int{lit}): Int256 = a.i256
  if stringValue.len > 32:
    ...
  ```
  ```
  Error: ambiguous call; both constants.>(a: Int256, b: int)[declared in constants.nim(76, 5)] and constants.>(a: UInt256, b: int)[declared in constants.nim(82, 5)] match for: (int, int literal(32))
  ```

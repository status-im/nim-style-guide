## Integers `[language.integers]`

Prefer signed integers for counting, lengths, array indexing etc.

Prefer unsigned integers of specified size for interfacing with binary data, bit manipulation, low-level hardware access and similar contexts.

Don't cast pointers to `int`.

### Practical notes

* Signed integers are overflow-checked and raise an untracked `Defect` on overflow, unsigned integers wrap
* `int` and `uint` vary depending on platform pointer size - use judiciously
* Perform range checks before converting to `int`, or convert to larger type
  * Conversion to signed integer raises untracked `Defect` on overflow
  * When comparing lengths to unsigned integers, convert the length to unsigned
* Pointers may overflow `int` when used for arithmetic
* Avoid `Natural` - implicit conversion from `int` to `Natural` can raise a `Defect`
  * see [`range`](./language.range.md)

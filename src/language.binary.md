## Binary data `[language.binary]`

Use `byte` to denote binary data. Use `seq[byte]` for dynamic byte arrays.

Avoid `string` for binary data. If stdlib returns strings, [convert](https://github.com/status-im/nim-stew/blob/76beeb769e30adc912d648c014fd95bf748fef24/stew/byteutils.nim#L141) to `seq[byte]` as early as possible

### Pros

* Explicit type for binary data helps convey intent

### Cons

* `char` and `uint8` are common choices often seen in `Nim`
* hidden assumption that 1 byte == 8 bits
* language still being developed to handle this properly - many legacy functions return `string` for binary data
  * [Crypto API](https://github.com/nim-lang/Nim/issues/7337)

### Practical notes

* [stew](https://github.com/status-im/nim-stew) contains helpers for dealing with bytes and strings


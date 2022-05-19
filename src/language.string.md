## `string` `[language.string]`

The `string` type in Nim represents text in an unspecified encoding, typically UTF-8 on modern systems.

Avoid `string` for binary data (see [language.binary](./language.binary.md))

### Practical notes

* The text encoding is undefined for `string` types and is instead determined by the source of the data (usually UTF-8 for terminals and text files)
  * When dealing with passwords, differences in encoding between platforms may lead to key loss


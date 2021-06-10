## Hex output `[libraries.hex]`

Print hex output in lowercase. Accept upper and lower case.

### Pros

* Single case helps tooling
* Arbitrary choice, aim for consistency

### Cons

* No community consensus - some examples in the wild use upper case

### Practical notes

[byteutils](https://github.com/status-im/nim-stew/blob/76beeb769e30adc912d648c014fd95bf748fef24/stew/byteutils.nim#L129) contains a convenient hex printer.


## Standard library usage `[libraries.std]`

Use the Nim standard library judiciously. Prefer smaller, separate packages that implement similar functionality, where available.

### Pros

* Using components from the standard library increases compatibility with other Nim projects
* Fewer dependencies in general

### Cons

* Large, monolithic releases make upgrading difficult - bugs, fixes and improvements are released together causing upgrade churn
* Many modules in the standard library are unmaintained and don't use state-of-the-art features of Nim
* Long lead times for getting fixes and improvements to market
* Often not tailored for specific use cases
* Stability and backwards compatibility requirements prevent fixing poor and unsafe API

### Practical notes

Use the following stdlib replacements that offer safer API (allowing more issues to be detected at compile time):

* async -> chronos
* bitops -> stew/bitops2
* endians -> stew/endians2
* exceptions -> results
* io -> stew/io2
* sqlite -> nim-sqlite3-abi
* streams -> nim-faststreams


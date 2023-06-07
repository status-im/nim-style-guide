## Wrappers `[libraries.wrappers]`

Prefer native `Nim` code when available.

`C` libraries and libraries that expose a `C` API may be used (including `rust`, `C++`, `go`).

Avoid `C++` libraries.

Prefer building the library on-the-fly from source using `{.compile.}`. Pin the library code using a submodule or amalgamation.

The [interop](./interop.md) guide contains more information about foreing language interoperability.

### Pros

* Wrapping existing code can improve time-to-market for certain features
* Maintenance is shared with upstream
* Build simplicity is maintained when `{.compile.}` is used

### Cons

* Often leads to unnatural API for `Nim`
* Constrains platform support
* Nim and `nimble` tooling poorly supports 3rd-party build systems making installation difficult
* Nim `C++` support incomplete
  * Less test suite coverage - most of `Nim` test suite uses `C` backend
  * Many core `C++` features like `const`, `&` and `&&` difficult to express - in particular post-`C++11` code has a large semantic gap compared to Nim
  * Different semantics for exceptions and temporaries compared to `C` backend
  * All-or-nothing - can't use `C++` backend selectively for `C++` libraries
* Using `{.compile.}` increases build times, specially for multi-binary projects - use judiciously for large dependencies

### Practical notes

* Consider tooling like `c2nim` and `nimterop` to create initial wrapper
* Generate a `.nim` file corresponding to the `.h` file of the C project
  * preferably avoid the dependency on the `.h` file (avoid `{.header.}` directives unless necessary)
* Write a separate "raw" interface that only imports `C` names and types as they're declared in `C`, then do convenience accessors on the Nim side
  * Name it `xxx_abi.nim`
* To use a `C++` library, write a `C` wrapper first
  * See `llvm` for example
* When wrapping a `C` library, consider ABI, struct layout etc

### Examples

* [nim-secp256k1](https://github.com/status-im/nim-secp256k1)
* [nim-sqlite3-abi](https://github.com/arnetheduck/nim-sqlite3-abi)
* [nim-bearssl](https://github.com/status-im/nim-bearssl/)
* [nim-blscurve](https://github.com/status-im/nim-blscurve/)

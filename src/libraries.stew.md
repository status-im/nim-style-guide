## `stew` `[libraries.stew]`

`stew` contains small utilities and replacements for `std` libraries.

If similar libraries exist in `std` and `stew`, prefer [stew](https://github.com/status-im/nim-stew).

### Pros

* `stew` solves bugs and practical API design issues in stdlib without having to wait for nim release
* Fast development cycle
* Allows battle-testing API before stdlib consideration (think boost)
* Encourages not growing nim stdlib further, which helps upstream maintenance

### Cons

* Less code reuse across community
* More dependencies that are not part of nim standard distribution

### Practical notes

`nim-stew` exists as a staging area for code that could be considered for future inclusion in the standard library or, preferably, a separate package, but that has not yet been fully fleshed out as a separate and complete library.

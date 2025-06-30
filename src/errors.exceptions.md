## Exceptions `[errors.exceptions]`

In general, prefer [explicit error handling mechanisms](errors.result.md).

Annotate each module at top-level (before imports):

```nim
{.push raises: [], gcsafe.}
```

Use explicit `{.raises.}` annotation for each public (`*`) function.

Raise `Defect` to signal panics and undefined behavior that the code is not prepared to handle.

```nim
# Enable exception and gcsafe tracking for all functions in this module
`{.push raises: [], gcsafe.}` # Always at start of module

# Inherit from CatchableError and name XxxError
type MyLibraryError = object of CatchableError

# Raise Defect when panicking - this crashes the application (in different ways
# depending on Nim version and compiler flags) - name `XxxDefect`
type SomeDefect = object of Defect

# Use hierarchy for more specific errors
type MySpecificError = object of MyLibraryError

# Explicitly annotate functions with raises - this replaces the more strict
# module-level push declaration on top
func f() {.raises: [MySpecificError]} = discard

# Isolate code that may generate exceptions using expression-based try:
let x =
  try: ...
  except MyError as exc: ... # use the most specific error kind possible

# Be careful to catch excpetions inside loops, to avoid partial loop evaluations:
for x in y:
  try: ..
  except MyError: ..

# Provide contextual data when raising specific errors
raise (ref MyError)(msg: "description", data: value)

# Quit or reraise if you're interacting with `Defect` - the exception handler
# will not always be invoked
try: ..
except Defect as exc:
  debugEcho "oh no! ", exc.msg
  raise exc
```

### Pros

* Used by `Nim` standard library
* Good for quick prototyping without error handling
* Good performance on happy path without `try`
  * Compatible with RVO

### Cons

* Poor readability - exceptions not part of API / signatures by default
    * Have to assume every line may fail
* Poor maintenance / refactoring support - compiler can't help detect affected code because they're not part of API
* Nim exception hierarchy unclear and changes between versions
    * The distinction between `Exception`, `CatchableError` and `Defect` is inconsistently implemented
        * [Exception hierarchy RFC not being implemented](https://github.com/nim-lang/Nim/issues/11776)
    * `Defect` is [not tracked](https://github.com/nim-lang/Nim/pull/13626)
* Without translation, exceptions leak information between abstraction layers
* Writing exception-safe code in Nim impractical due to missing critical features present in C++
    * No RAII - resources often leak in the presence of exceptions
    * Destructors incomplete / unstable and thus not usable for safe EH
        * No constructors, thus no way to force particular object states at construction
    * `ref` types incompatible with destructors, even if they worked
* Poor performance of error path
    * Several heap allocations for each `Exception` (exception, stack trace, message)
    * Expensive stack trace
* Poor performance on happy path
    * Every `try` and `defer` has significant performance overhead due to `setjmp` exception handling implementation

### Practical notes

The use of exceptions in Nim has significantly contributed to resource leaks, deadlocks and other difficult bugs. The various exception handling proposals aim to alleviate some of the issues but have not found sufficient grounding in the Nim community to warrant the language changes necessary to proceed.

### `Defect`

`Defect` does [not cause](https://github.com/nim-lang/Nim/issues/12862) a `raises` effect - code must be manually verified - common sources of `Defect` include:

* Over/underflows in signed arithmetic
* `[]` operator for indexing arrays/seqs/etc (but not tables!)
* accidental/implicit conversions to `range` types

Catching `Defect` is undefined behavior - do not rely on it being caught outside of tests and/or re-raise it or `quit`.

### `CatchableError`

Catching `CatchableError` implies that all errors are funnelled through the same exception handler. When called code starts raising new exceptions, it becomes difficult to find affected code - catching more specific errors avoids this maintenance problem.

Frameworks may catch `CatchableError` to forward exceptions through layers. Doing so leads to type erasure of the actual raised exception type in `raises` tracking.

### `except:`

`except:`, following a [changed semantics](https://github.com/nim-lang/RFCs/issues/557) is similar in behavior to `catch CatchableError` and should be used judiciously.

The change is available from Nim [v2.2.4](https://github.com/nim-lang/Nim/pull/24821) - portable code should prefer `catch CatchableError`.

### Open questions

* Should a hierarchy be used?
    * Why? It's rare that calling code differentiates between errors
    * What to start the hierarchy with? Unclear whether it should be a global type (like `CatchableError` or `ValueError`, or a module-local type
* Should exceptions be translated?
    * Leaking exception types between layers means no isolation, joining all modules in one big spaghetti bowl
    * Translating exceptions has high visual overhead, specially when hierachy is used - not practical, all advantages lost
* Should `raises` be used?
    * Equivalent to `Result[T, SomeError]` but lacks generics
    * Additive - asymptotically tends towards `raises: [CatchableError]`, losing value unless exceptions are translated locally
    * No way to transport accurate raises type information across Future/async/generic code boundaries - no `raisesof` equivalent of `typeof`

### Background

* [Stew EH helpers](https://github.com/status-im/nim-stew/pull/26) - Helpers that make working with checked exceptions easier
* [Nim Exception RFC](https://github.com/nim-lang/Nim/issues/8363) - seeks to differentiate between recoverable and unrecoverable errors
* [Zahary's handling proposal](https://gist.github.com/zah/d2d729b39d95a1dfedf8183ca35043b3) - seeks to handle any kind of error-generating API
* [C++ proposal](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p0709r0.pdf) - After 25 years of encouragement, half the polled C++ developers continue avoiding exceptions and Herb Sutter argues about the consequences of doing so
* [Google](https://google.github.io/styleguide/cppguide.html#Exceptions) and [llvm](https://llvm.org/docs/CodingStandards.html#id22) style guides on exceptions

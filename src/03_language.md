# Language features

Nim is a language that organically has grown to contain many advanced features and constructs. These features allow you to express your intent with great creativity, but often come with significant stability, simplicity and correctness caveats when combined.

<!-- toc -->

## Import, export

[Manual](https://nim-lang.org/docs/manual.html#modules-import-statement)

`import` a minimal set of modules using explicit paths.

`export` all modules whose types appear in public symbols of the current module.

Prefer specific imports. Avoid `include`.

```nim
# Group by std, external then internal imports
import
  # Standard library imports are prefixed with `std/`
  std/[options, sets],
  # use full name for "external" dependencies (those from other packages)
  package/[a, b],
  # use relative path for "local" dependencies
  ./c, ../d

# export modules whose types are used in public symbols in the current module
export options
```

### Practical notes

Modules in Nim share a global namespace, both for the module name itself and for all symbols contained therein - because of this, your code might break because a dependency introduces a module or symbol with the same name - using prefixed imports (relative or package) helps mitigate some of these conflicts.

Because of overloading and generic catch-alls, the same code can behave differently depending on which modules have been imported and in which order - reexporting modules that are used in public symbols helps avoid some of these differences.

See also: [sandwich problem](https://github.com/nim-lang/Nim/issues/11225)

## Macros

[Manual](https://nim-lang.org/docs/manual.html#macros)

Be judicious in macro usage - prefer more simple constructs.
Avoid generating public API functions with macros.

### Pros

* Concise domain-specific languages precisely convey the central idea while hiding underlying details
* Suitable for cross-cutting libraries such as logging and serialization, that have a simple public API
* Prevent repetition, sometimes
* Encode domain-specific knowledge that otherwise would be hard to express

### Cons

* Easy to write, hard to understand
  * Require extensive knowledge of the `Nim` AST
  * Code-about-code requires tooling to turn macro into final execution form, for audit and debugging
  * Unintended macro expansion costs can surprise even experienced developers
* Unsuitable for public API
  * Nowhere to put per-function documentation
  * Tooling needed to discover API - return types, parameters, error handling
* Obfuscated data and control flow
* Poor debugging support
* Surprising scope effects on identifier names

### Practical notes

* Consider a more specific, non-macro version first
* Use a difficulty multiplier to weigh introduction of macros:
  * Templates are 10x harder to understand than plain code
  * Macros are 10x harder than templates, thus 100x harder than plain code
* Write as much code as possible in templates, and glue together using macros

See also: [macro defense](https://github.com/status-im/nimbus-eth2/wiki/The-macro-skeptics-guide-to-the-p2pProtocol-macro)

## `ref object` types

Avoid `ref object` types, except:

* for "handle" types that manage a resource and thus break under value semantics
* where shared ownership is intended
* in reference-based data structures (trees, linked lists)
* where a stable pointer is needed for 3rd-party compatibility

Prefer explicit `ref MyType` where reference semantics are needed, allowing the caller to choose where possible.

```nim
# prefer explicit ref modifiers at usage site
func f(v: ref Xxx) = discard
let x: ref Xxx = new Xxx

# Consider using Hungarian naming convention with `ref object` - this makes it clear at usage sites that the type follows the unusual `ref` semantics
type XxxRef = ref object
  # ...
```

### Pros

* `ref object` types useful to prevent unintended copies
* Limits risk of accidental stack allocation for large types
  * This commonly may lead to stack overflow, specially when RVO is missed
* Garbage collector simplifies some algorithms

### Cons

* `ref object` types have surprising semantics - the meaning of basic operations like `=` changes
* Shared ownership leads to resource leaks and data races
* `nil` references cause runtime crashes
* Semantic differences not visible at usage site
* Always mutable - no way to express immutability
* Cannot be stack-allocated
* Hard to emulate value semantics

### Notes

`XxxRef = ref object` is a syntactic shortcut that hides the more explicit `ref Xxx` where the type is used - by explicitly spelling out `ref`, readers of the code become aware of the alternative reference / shared ownership semantics, which generally allows a deeper understanding of the code without having to look up the type declaration.

## Heap / garbage collected memory

Prefer to use stack-based and statically sized data types in core/low-level libraries.
Use heap allocation in glue layers.

Avoid `alloca`.

```
func init(T: type Yyy, a, b: int): T = ...

# Heap allocation as a local decision
let x = (ref Xxx)(
  field: Yyy.init(a, b) # In-place initialization using RVO
)
```

### Pros

* RVO can be used for "in-place" initialization of value types
* Better chance of reuse on embedded systems
  * https://barrgroup.com/Embedded-Systems/How-To/Malloc-Free-Dynamic-Memory-Allocation
  * http://www.drdobbs.com/embedded-systems/embedded-memory-allocation/240169150
  * https://www.quora.com/Why-is-malloc-harmful-in-embedded-systems
* Allows consumer of library to decide on memory handling strategy
    * It's always possible to turn plain type into `ref`, but not the other way around

### Cons

* Stack space limited - large types on stack cause hard-to-diagnose crashes
* Hard to deal with variable-sized data correctly

### Practical notes

`alloca` has confusing semantics that easily cause stack overflows - in particular, memory is released when function ends which means that in a loop, each iteration will add to the stack usage. Several `C` compilers implement `alloca` incorrectly, specially when inlining.

## Finalizers

[Manual](https://nim-lang.org/docs/system.html#new%2Cref.T%2Cproc%28ref.T%29)

Don't use finalizers.

### Pros

* Work around missing manual cleanup

### Cons

* [Buggy](https://github.com/nim-lang/Nim/issues/4851), cause random GC crashes
* Calling `new` with finalizer for one instance infects all instances with same finalizer
* Newer Nim versions migrating new implementation of finalizers that are sometimes deterministic (aka destructors)

## Inline functions

Avoid using explicit `{.inline.}` functions.

### Pros

* Sometimes give performance advantages

### Cons

* Adds clutter to function definitions
* Larger code size, longer compile times
* Prevent certain LTO optimizations

### Practical notes

* `{.inline.}` does not inline code - rather it copies the function definition into every `C` module making it available for the `C` compiler to inline
* Compilers can use contextual information to balance inlining
* LTO achieves the same end result without the cons

## Converters

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

## Object initialization

Use `Xxx(x: 42, y: Yyy(z: 54))` style, or if type has an `init` function, `Type.init(a, b, c)`.

Make the default 0-initialization a valid state for the type.

```nim
# `init` functions are a convention for constructors - they are not enforced by the language
func init(T: type Xxx, a, b: int): T = T(
  x: a,
  y: OtherType(s: b) # Prefer Type(field: value)-style initialization
)

let m = Xxx.init(1, 2)

# For ref types, name the constructor `new`:
func new(T: type XxxRef): T = ...
```

### Pros

* Correct order of initialization enforced by compiler / code structure
* Dedicated syntax constructs a clean instance resetting all fields
* Possible to build static analysis tools to detect uninitialized fields
* Works for both `ref` and non-`ref` types

### Cons

* Sometimes inefficient compared to updating an existing `var` instance, since all fields must be re-initialized

### Practical notes

* The default, 0-initialized state of the object often gets constructed in the language - avoiding a requirement that a magic `init` function be called makes the type more ergonomic to use
* Avoid using `result` (see below) or `var instance: Type` which disable several compiler diagnostics

## `result` return

Avoid using `result` for returning values.

Use expression-based return or explicit `return` keyword with a value

### Pros

* Recommended by NEP-1
* Used in standard library
* Saves a line of code avoiding an explicit `var` declaration
* Accumulation-style functions that gradually build up a return value gain consistency

### Cons

* No visual (or compiler) help when a branch is missing a value, or overwrites a previous value
* Disables compiler diagnostics for code branches that forget to set result
* Risk of using partially initialized instances due to `result` being default-initialized
    * For `ref` types, `result` starts out as `nil` which accidentally might be returned
    * Helpers may accidentally use `result` before it was fully initialized
    * Async/await using result prematurely due to out-of-order execution
* Partially initialized instances lead to exception-unsafe code where resource leaks happen
    * RVO causes observable stores in the left-hand side of assignments when exceptions are raised after partially modifying `result`
* Confusing to people coming from other languages
* Confusing semantics in templates and macros

### Practical notes

Nim has 3 ways to assign a return value to a function: `result`, `return` and "expressions".

Of the three:

* "expression" returns guarantee that all code branches produce one (and only one) value to be returned
  * Used mainly when exit points are balanced and not deeply nested
* Explict `return` with a value make explicit what value is being returned in each branch
  * Used to avoid deep nesting and early exit, above all when returning early due to errors
* `result` is used to accumulate / build up return value, allowing it to take on invalid values in the interim

Multiple security issues, `nil` reference crashes and wrong-init-order issues have been linked to the use of `result` and lack of assignment in branches.

In general, the use of accumulation-style initialization is discouraged unless made necessary by the data type - see [Variable initialization](#variable-initialization)

## Variable declarations

Use the most restrictive of `const`, `let` and `var` that the situation allows.

```nim
# Group related variables
const
  a = 10
  b = 20
```

### Practical notes

`const` and `let` each introduce compile-time constraints that help limit the scope of bugs that must be considered when reading and debugging code.

## Variable initialization

Prefer expressions to initialize variables and return values

```
let x =
  if a > 4: 5
  else: 6

func f(b: bool): int =
  if b: 1
  else: 2

# Avoid - `x` is not guaranteed to be initialized by all branches and in correct order (for composite types)
var x: int
if a > 4: x = 5
else: x = 6
```

### Pros

* Stronger compile-time checks
* Lower risk of uninitialized variables even after refactoring

### Cons

* Becomes hard to read when deeply nested

## Functions and procedures

Prefer `func` - use `proc` when side effects cannot conveniently be avoided.

Avoid public functions and variables (`*`) that don't make up an intended part of public API.

### Practical notes

* Public functions are not covered by dead-code warnings and contribute to overload resolution in the the global namespace
* Prefer `openArray` as argument type over `seq` for traversals

## Methods

[Manual](https://nim-lang.org/docs/manual.html#methods)

Use `method` sparingly - consider a "manual" vtable with `proc` closures instead.

### Pros

* Compiler-implemented way of doing dynamic dispatch

### Cons

* Poor implementation
  * Implemented using `if` tree
  * Require full program view to "find" all implementations
* Poor discoverability - hard to tell which `method`'s belong together and form a virtual interface for a type
  * All implementations must be public (`*`)!

### Practical notes

* Does not work with generics
* No longer does multi-dispatch

## Callbacks, closures and forward declarations

Annotate `proc` type definitions and forward declarations with `{.raises [Defect], gcsafe.}` or specific exception types.

```nim
# By default, Nim assumes closures may raise any exception and are not gcsafe
# By annotating the callback with raises and gcsafe, the compiler ensures that
# any functions assigned to the closure fit the given constraints
type Callback = proc(...) {.raises: [Defect], gcsafe.}
```

### Practical notes

* Without annotations, `raises Exception` and no GC-safety is assumed by the compiler, infecting deduction in the whole call stack
* Annotations constrain the functions being assigned to the callback to follow its declaration, simplifying calling the callback safely
  * In particular, callbacks are difficult to reason about when they raise exceptions - what should the caller of the callback do?

## Binary data

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

## Integers

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
* An alternative to `int` for non-negative integers such as lengths is `Natural`
  * `Natural` is a `range` type and therefore [unreliable](#range) - it generally avoids the worst problems owing to its simplicity but may require additional casts to work around bugs
  * Better models length, but is not used by `len`

## `range`

Avoid `range` types.

### Pros

* Range-checking done by compiler
* More accurate bounds than `intXX`
* Communicates intent

### Cons

* Implicit conversions to "smaller" ranges may raise `Defect`
* Language feature has several fundamental design and implementation issues
  * https://github.com/nim-lang/Nim/issues/16839
  * https://github.com/nim-lang/Nim/issues/16744
  * https://github.com/nim-lang/Nim/issues/13618
  * https://github.com/nim-lang/Nim/issues/12780
  * https://github.com/nim-lang/Nim/issues/10027
  * https://github.com/nim-lang/Nim/issues?page=1&q=is%3Aissue+is%3Aopen+range

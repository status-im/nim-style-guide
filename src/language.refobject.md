## `ref object` types `[language.refobject]`

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

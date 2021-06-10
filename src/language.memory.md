## Memory allocation `[language.memory]`

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


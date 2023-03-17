# Interop with other languages (FFI)

Nim comes with powerful interoperability options, both when integrating Nim code in other languages and vice versa.

This section of the book covers interoperability / [FFI](https://en.wikipedia.org/wiki/Foreign_function_interface) in both directions: how to integrate Nim into other languages and how to use libraries from other languages in Nim.

While it is possible to automate many things related to FFI, this guide focuses on simplicity and fundamentals - while tooling, macros and helpers can simplify the process, they remain a cosmetic layer on top of the fundamentals presented here.

In general, this guide focuses on pragmatic solutions available for the currently released versions of Nim - 1.6 at the time of writing - the recommendations may change as new libraries and Nim versions become available.

Since C serves as the "lingua franca" of interop, the [C guide](./interop.c.md) in particular servers as a useful starting point for any language.

## Basics

In order for interoperability to happen, we rely on a lowest common denominator of features between the two languages - typically, this is defined by the overlapping parts of the [ABI](https://en.wikipedia.org/wiki/Application_binary_interface) of the two languages. Nim is unique in that it also allows interoperability at the API level with C - however, this guide focuses on interoperability via ABI since this is more general and broadly useful.

Most languages define their FFI in terms of a simplified version of the C ABI - thus, the process of using code from one language in another typically consists of two steps:

* exporting the source library functions and types as "simple C"
* importing the "simple C" functions and types in the target language

We'll refer to this part of the process as ABI wrapping.

Since libraries tend to use the full feature set of their native language, we can see two additional steps:

* exposing the native library code in a "simple C" variant via a wrapper
* adding a wrapper around the "simple C" variant to make the foreign library feel "native"

We'll call this API wrapping - the API wrapper takes care of:

* conversions to/from Nim integer types
* introducing Nim idioms such as generics
* adapting the [error handling](./errors.md) model

### Memory

Nim is generally a GC-first language meaning that memory is typically managed via a thread-local garbage collector.

Nim also supports manual memory management - this is most commonly used for threading and FFI.

Garbage-collection applies to the following types which are allocated from a thread-local heap:

* `string` and `seq` - these are value types that underneath use the GC heap
  * the `string` uses a dedicated length field but _also_ ensures NULL-termination which makes it easy to pass to C
  * `seq` uses a similar in-memory layout without the NULL termination
  * addresses to elements are stable as long as as elements are not added
* `ref` types

The lifetime of garbage-collected types is undefined - the garbage collector generally runs during memory allocation but this should not be relied upon - instead, lifetime can be extended by calling `GC_ref` and `GC_unref`.

When using garbage-collected types in FFI, one must be careful to not let the references cross between threads - such usage will cause memory corruption and crashes. `allocShared` and `deallocShared` is used for cross-thread communication.

### Threads

Because Nim  relies on a garbage collector, care must be taken when calling Nim code from threads other than the "main" application thread and when passing data between threads.

In general, to use a garbage collected type in a thread created in a different language, `setupForeignThreadGc` must be called from within that thread first.

### async / await

When `chronos` is used, execution is typically controlled by the `chronos` per-thread dispatcher - passing data to `chronos` is done either via a pipe / socket or by polling a thread-safe queue.

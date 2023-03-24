# C++

Nim has two modes of interoperability with C++: API and ABI.

The API interoperability works by compiling Nim to C++ and using the C++ compiler to compile the result - this mode gives direct access to C++ library code without any intermediate wrappers, which is excellent for exploratory and scripting work.

However, this mode also comes with several restrictions:

* the feature gap between Nim and C++ is wider: C++ has many features that cannot be represented in Nim and vice versa
  * while "simple C++" can be wrapped this way, libraries using modern C++ features are unlikely to work or may only be wrapped partially
* C++-generated Nim code is more likely to run into cross-library issues in applications using multiple wrapped libraries
  * this is due to C++'s increased strictness around const-correctness and other areas where Nim, C and C++ differ in capabilities
* a single library that uses Nim's C++ API features forces the entire application to be compiled with the C++ backend
  * the C++ backend receives less testing overall and therefore is prone to stability issues

Thus, for C++ the recommened way of creating wrappers is similar to other languages: write an export library in C++ that exposes the C++ library via the C ABI then import the C code in Nim - this future-proofs the wrapper against the library starting to use C++ features that cannot be wrapped.

## Qt

[Qt](https://www.qt.io/) takes control of the main application thread to run the UI event loop. Blocking this thread means that the UI becomes unresponsive, thus it is recommended to run any compution in separate threads.

For cross-thread communication, the recommended way of sending information to the Qt thread is via a [queued signal/slot connection](https://doc.qt.io/qt-6/threads-qobject.html#signals-and-slots-across-threads).

For sending information from the Qt thread to other Nim threads, encode the data into a buffer allocated with `allocShared` and use a thread-safe queue such as `std/sharedlists`:

## Examples

* [nimqml](https://github.com/filcuc/nimqml) - exposes the Qt C++ library via a [C wrapper](https://github.com/filcuc/dotherside)
* [nlvm](https://github.com/arnetheduck/nlvm/tree/master/llvm) - imports the [LLVM C API]() which wraps the LLVM compiler written in C++
* [godot](https://github.com/pragmagic/godot-nim) - imports `godot` via its exported [C API](https://docs.godotengine.org/de/stable/tutorials/scripting/gdnative/what_is_gdnative.html)

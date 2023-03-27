# Rust interop

Nim and Rust are both statically typed, compiled languages capable of "systems programming".

Because of these similarities, interop between Nim and [`rust`](https://doc.rust-lang.org/nomicon/ffi.html) is generally straightforward and handled the same way as [C interop](./interop.c.md) in both languages: Rust code is exported to C then imported in Nim as C code and vice versa.

## Memory

While Nim is a GC-first language, `rust` in general uses lifetime tracking (via `Box`) and / or reference counting (via `Rc`/`Arc`) outside of "simple" memory usage.

When used with Nim, care must be taken to extend the lifetimes of Nim objects via `GC_ref` / `GC_unref`.

## Tooling

* [`nbindgen`](https://github.com/arnetheduck/nbindgen/) - create Nim ["ABI headers"](./interop.md#basics) from exported `rust` code

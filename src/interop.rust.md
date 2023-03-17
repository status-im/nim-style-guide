# Rust interop

`Nim` and `rust` are both statically typed, compiled languages capable of "systems programming".

Because of these similarities, interop between Nim and `rust` is generally very simple and handled the same way as C interop in both languages: `rust` code is exported to `C` then imported in Nim as `C` code and vice versa.

## Memmory

While Nim is a GC-first language, `rust` in general uses reference counting (via `Rc`/`Arc`) paired with lifetime tracking outside of "simple" memory usage.

When used with Nim, care must be taken to extend the lifetimes of Nim objects via `GC_ref` / `GC_unref` and manually reference count on the `rust` side.

## Tooling

* [`nbindgen`](https://github.com/arnetheduck/nbindgen/) - create Nim headers from exported `rust` code

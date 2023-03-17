# Go interop

`Nim` and `go` are both statically typed, compiled languages capable of interop via a simplifed C ABI, making interop between the two languages simple.

## Threads

`go` includes a native `M:N` scheduler for running `go` tasks - because of this, care must be taken both when calling Nim code from `go`: the thread from which the call will happen is controlled by `go` and  we must initialise the Nim garbage collector in every function exposed to go:

```nim
# Export our function to go
proc f() {.exportc.} =
  when declared(setupForeignThreadGc): setupForeignThreadGc()
  echo "hello from nim"
```

As an alternative, we can pass the work to a Nim thread instead - this works well for asynchronous code that reports the result via a callback mechanism:


```nim
import std/sharedlist

var list: SharedList[pointer]

proc f(v: pointer, len: csize_t) {.exportc.} =
  # copy data to a shared buffer
  let
    copy = allocShared(int(len) + sizeof(len))
  copyMem(copy, addr len, sizeof(len))
  copyMem(cast[pointer](cast[uint](copy) + sizeof(len)), v, len)

  # Put the data on a thread-safe queue / list
  list.add(copy)

  # Normally, we would notify the consumer here!

proc reader() {.thread.} =
  while true:
    var items: seq[pointer]
    list[].iterAndMutate do (item: pointer) -> bool:
      items.add $item
      deallocShared(item)
      true
    for item in items:
      var len: int
      copyMem(addr len, v, sizeof(len))
      let
        data = cast[pointer](cast[uint](item) + sizeof(int))

      echo "got " len, " bytes"

    sleep(100) # poll every 100ms
```

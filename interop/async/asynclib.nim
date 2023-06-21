{.push raises: [].}

{.pragma: exported, exportc, dynlib, cdecl, raises: [].}
{.pragma: callback, cdecl, raises: [], gcsafe.}

import std/atomics
import chronos, chronos/apps/http/httpserver

# Every Nim library must have this function called - the name is derived from
# the `--nimMainPrefix` command line option
proc asynclibNimMain() {.importc.}

var initialized: Atomic[bool]

proc initLib() {.gcsafe.} =
  if not initialized.exchange(true):
    asynclibNimMain() # Every Nim library needs to call `NimMain` once exactly
  when declared(setupForeignThreadGc): setupForeignThreadGc()
  when declared(nimGC_setStackBottom):
    var locals {.volatile, noinit.}: pointer
    locals = addr(locals)
    nimGC_setStackBottom(locals)

type
  Callback = proc(user: pointer, data: pointer, len: csize_t) {.callback.}

  Context = object
    thread: Thread[(ptr Context, cstring)]
    callback: Callback
    user: pointer
    stop: Atomic[bool]

  Node = object
    server: HttpServerRef

proc runContext(args: tuple[ctx: ptr Context, ipPort: cstring]) {.thread.} =
  let
    node = (ref Node)()
    ctx = args.ctx
    ipPort = $args.ipPort

  deallocShared(args.ipPort) # Don't forget to release memory manually!

  proc process(r: RequestFence): Future[HttpResponseRef] {.async.} =
    if r.isOk():
      let
        req = r.get()
      await req.consumeBody()
      let headers = $req.headers
      if headers.len > 0:
        ctx[].callback(ctx[].user, unsafeAddr headers[0], csize_t headers.len)
      await req.respond(Http200, "Hello from Nim")
    else:
      dumbResponse()

  try:
    let
      socketFlags = {ServerFlags.TcpNoDelay, ServerFlags.ReuseAddr}
    node.server = HttpServerRef.new(
      initTAddress(ipPort), process, socketFlags = socketFlags).expect("working server")

    node.server.start()

    while not args.ctx[].stop.load():
      let timeout = sleepAsync(100.millis)
      waitFor timeout
  except CatchableError as exc:
    echo "Shutting down because of error", exc.msg

proc startNode*(ipPort: cstring, user: pointer, callback: Callback): ptr Context {.exported.} =
  initLib()

  let
    # createShared for allocating plain Nim types
    ctx = createShared(Context, 1)
    # allocShared0 for allocating zeroed bytes - note +1 for cstring NULL terminator!
    ipPortCopy = cast[cstring](allocShared0(len(ipPort) + 1))

  copyMem(ipPortCopy, ipPort, len(ipPort))

  # We can pass simple data to the thread using the context
  ctx.callback = callback
  ctx.user = user

  try:
    createThread(ctx.thread, runContext, (ctx, ipPortCopy))
    ctx
  except ResourceExhaustedError:
    # deallocShared for byte allocations
    deallocShared(ipPortCopy)
    # and freeShared for typed allocations!
    freeShared(ctx)
    nil

proc stopNode*(ctx: ptr ptr Context) {.exported.} =
  if ctx == nil or ctx[] == nil: return

  ctx[][].stop.store(true)
  ctx[][].thread.joinThread()
  freeShared(ctx[])
  ctx[] = nil

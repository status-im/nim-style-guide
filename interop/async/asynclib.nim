{.push raises: [].}

{.pragma: exported, exportc, cdecl, raises: [].}
{.pragma: callback, cdecl, raises: [], gcsafe.}
{.passc: "-fPIC".}

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
  OnHeaders = proc(user: pointer, data: pointer, len: csize_t) {.callback.}

  Context = object
    thread: Thread[(ptr Context, cstring)]
    onHeaders: OnHeaders
    user: pointer
    stop: Atomic[bool]

  Node = object
    server: HttpServerRef

proc runContext(args: tuple[ctx: ptr Context, address: cstring]) {.thread.} =
  let
    node = (ref Node)()
    ctx = args.ctx
    address = $args.address

  deallocShared(args.address) # Don't forget to release memory manually!

  proc process(r: RequestFence): Future[HttpResponseRef] {.async.} = return
    if r.isOk():
      let
        req = r.get()
      await req.consumeBody()
      let headers = $req.headers
      if headers.len > 0:
        ctx[].onHeaders(ctx[].user, unsafeAddr headers[0], csize_t headers.len)
      await req.respond(Http200, "Hello from Nim")
    else:
      dumbResponse()

  try:
    let
      socketFlags = {ServerFlags.TcpNoDelay, ServerFlags.ReuseAddr}
    node.server = HttpServerRef.new(
      initTAddress(address), process, socketFlags = socketFlags).expect("working server")

    node.server.start()
    defer:
      waitFor node.server.closeWait()

    while not args.ctx[].stop.load():
      # Keep running until we're asked not to, by polling `stop`
      # TODO A replacement for the polling mechanism is being developed here:
      #      https://github.com/status-im/nim-chronos/pull/406
      #      Once it has been completed, it should be used instead.
      waitFor sleepAsync(100.millis)

  except CatchableError as exc:
    echo "Shutting down because of error", exc.msg

proc startNode*(
    address: cstring, onHeaders: OnHeaders, user: pointer): ptr Context {.exported.} =
  initLib()

  let
    # createShared for allocating plain Nim types
    ctx = createShared(Context, 1)
    # allocShared0 for allocating zeroed bytes - note +1 for cstring NULL terminator!
    addressCopy = cast[cstring](allocShared(len(address) + 1))

  copyMem(addressCopy, address, len(address) + 1)

  # We can pass simple data to the thread using the context
  ctx.onHeaders = onHeaders
  ctx.user = user

  try:
    createThread(ctx.thread, runContext, (ctx, addressCopy))
    ctx
  except ResourceExhaustedError:
    # deallocShared for byte allocations
    deallocShared(addressCopy)
    # and freeShared for typed allocations!
    freeShared(ctx)
    nil

proc stopNode*(ctx: ptr ptr Context) {.exported.} =
  if ctx == nil or ctx[] == nil: return

  ctx[][].stop.store(true)
  ctx[][].thread.joinThread()
  freeShared(ctx[])
  ctx[] = nil

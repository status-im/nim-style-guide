# Chronos HTTP server FFI

This folder contains a simple `chronos`-based http server serving requests on a given port.

The server runs on a separate thread and makes a callback into the host language for every request it responds to.

Notable features:

* The server runs in a separate thread created by Nim as part of the `startNode` function
* A `Context` object is passed to the host language and used in interactions with the node
* Callbacks are executed from the Nim thread into the host language
* The library initializes itself the first time a node is started
* For cross-thread communication, manual memory management is used


package main

/*
	#cgo LDFLAGS: -L./ -lasynclib

	#include <stdio.h>

	// Import functions from Nim
	void* startNode(const char* url, void* onHeader, void* user);
	void stopNode(void** ctx);

	typedef const char cchar_t;
	extern void callback(void* user, cchar_t* headers, size_t len);
*/
import "C"

import (
	"fmt"
	"runtime"
	"unsafe"
)

//export callback
func callback(user *C.void, headers *C.cchar_t, len C.size_t) {
	fmt.Println("Callback! ", uint64(len))
	fmt.Println(C.GoStringN(headers, C.int(len)))
}

func main() {
  runtime.LockOSThread()

  fmt.Println("Starting node")

  user := 23

  ctx := C.startNode(C.CString("127.0.0.1:60000"),
					 unsafe.Pointer(C.callback),
					 unsafe.Pointer(&user))
  fmt.Println(`
Node is listening on http://127.0.0.1:60000
Type 'q' and press enter to stop
`)

  for {
	if C.getchar() == 'q' {
		break
	}
  }

  fmt.Println("Stopping node")

  C.stopNode(&ctx)
}

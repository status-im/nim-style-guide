## Debugging `[tooling.debugging]`

* Debugging can be done with `gdb` just as if `C` was being debugged
  * Follow the [C/C++ guide](https://code.visualstudio.com/docs/cpp/cpp-debug) for setting it up in `vscode`
  * Pass `--opt:none --debugger:native` to disable optimizations and enable debug symbols

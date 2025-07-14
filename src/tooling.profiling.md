## Profiling

* Linux: `perf`
* Anywhere: [vtune](https://software.intel.com/content/www/us/en/develop/tools/oneapi/components/vtune-profiler.html)


When profiling, make sure to compile your code with:
* `-d:release` to turn on optimizations
* `-d:lto` to enable LTO which significantly helps Nim in general
* `--debugger:native` to enable native debug symbols
* [libbacktrace](https://github.com/status-im/nim-libbacktrace)
  * the stack trace algorithm that comes with nim is too slow for practical use
  * `--stacktrace:off` as an alternative

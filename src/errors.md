# Error handling

Error handling in Nim is a subject under constant re-evaluation - similar to C++, several paradigms are supported leading to confusion as to which one to choose.

In part, the confusion stems from the various contexts in which Nim can be used: when executed as small, one-off scripts that can easily be restarted, exceptions allow low visual overhead and ease of use.

When faced with more complex and long-running programs where errors must be dealt with as part of control flow, the use of exceptions can directly be linked to issues like resource leaks, security bugs and crashes.

Likewise, when preparing code for refactoring, the compiler offers little help in exception-based code: although raising a new exception breaks ABI, there is no corresponding change in the API: this means that changes deep inside dependencies silently break dependent code until the issue becomes apparent at runtime (often under exceptional circumstances).

A final note is that although exceptions may have been used successfully in some languages, these languages typically offer complementary features that help manage the complexities introduced by exceptions - RAII, mandatory checking of exceptions, static analysis etc - these have yet to be developed for Nim.

Because of the controversies and changing landscape, the preference for Status projects is to avoid the use of exceptions unless specially motivated, if only to maintain consistency and simplicity.

## Porting legacy code

When dealing with legacy code, there are several common issues, most often linked to abstraction and effect leaks. In Nim, exception effects are part of the function signature but deduced based on code. Sometimes the deduction must make a conservative estimate, and these estimates infect the entire call tree until neutralised with a `try/except`.

When porting code, there are two approaches:

* Bottom up - fix the underlying library / code
* Top down - isolate the legacy code with `try/except`
  * In this case, we note where the Exception effect is coming from, should it be fixed in the future

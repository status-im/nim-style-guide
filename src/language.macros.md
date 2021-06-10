## Macros `[language.macros]`

[Manual](https://nim-lang.org/docs/manual.html#macros)

Be judicious in macro usage - prefer more simple constructs.
Avoid generating public API functions with macros.

### Pros

* Concise domain-specific languages precisely convey the central idea while hiding underlying details
* Suitable for cross-cutting libraries such as logging and serialization, that have a simple public API
* Prevent repetition, sometimes
* Encode domain-specific knowledge that otherwise would be hard to express

### Cons

* Easy to write, hard to understand
  * Require extensive knowledge of the `Nim` AST
  * Code-about-code requires tooling to turn macro into final execution form, for audit and debugging
  * Unintended macro expansion costs can surprise even experienced developers
* Unsuitable for public API
  * Nowhere to put per-function documentation
  * Tooling needed to discover API - return types, parameters, error handling
* Obfuscated data and control flow
* Poor debugging support
* Surprising scope effects on identifier names

### Practical notes

* Consider a more specific, non-macro version first
* Use a difficulty multiplier to weigh introduction of macros:
  * Templates are 10x harder to understand than plain code
  * Macros are 10x harder than templates, thus 100x harder than plain code
* Write as much code as possible in templates, and glue together using macros

See also: [macro defense](https://github.com/status-im/nimbus-eth2/wiki/The-macro-skeptics-guide-to-the-p2pProtocol-macro)


# Introduction

> "With great power comes great responsibility" - Spiderman (or Voltaire, for the so culturally inclined)

This text is an ever evolving collection of conventions, idioms and tricks that reflects the experience of developing a production-grade application in Nim with a small team of developers.

The guide is a living document to help manage the complexities of using an off-the-beaten-track language and environment to produce a stable product ready for an adverserial internet.

Each guideline starts with a general recommendation to use or not use a particular feature, this recommendation represents a safe "default" choice. It is followed by a rationale to help you decide when and how to apply the guideline with nuance - it will not be right for every situation out there but all other things being equal, following the guideline will make life easier for others, your future self included.

Following the principles and defaults set out here helps newcomers to familiarise themselves with the codebase more quickly, while experienced developers will appreciate the consistency when deciphering the intent behind a specific passage of code -- above all when trying to debug production issues under pressure.

The `pros` and `cons` sections are based on bugs, confusions and security issues that have been found in real-life code and that could easily have been avoided with.. a bit of style. The objective of this section is to pass the experience on to you, dear reader!

In particular when coming from a different language, experience with features like exception handling, generics and compile-time guarantees may not carry over due to subtle, and sometimes surprising, differences in semantics.

Much Nim code "out there" hails from past times when certain language features were not yet developed and best practices not yet established - this also applies to this guide, which will change over time as the practice and language evolves.

When in doubt:

* Read your code
* Deal with errors
* Favour simplicity
* Default to safety
* Consider the adversary
* Pay back your debt regularly
* Correct, readable, elegant, efficient, in that order

The latest version of this book can be found [online](https://status-im.github.io/nim-style-guide/) or on [GitHub](https://github.com/status-im/nim-style-guide/).

This guide currently targets Nim v2.0.

At the time of writing, v2.0 has been released but its new garbage collector is not yet stable enough for production use. It is advisable to test new code with both `--mm:refc` and `--mm:orc` (the default) in the transition period.

<!-- toc -->

## Practical notes

* When deviating from the guide, document the rationale in the module, allowing the next developer to understand the motivation behind the deviation
* When encountering code that does not follow this guide, follow its local conventions or refactor it
* When refactoring code, ensure good test coverage first to avoid regressions
* Strive towards the guidelines where practical
* Consider backwards compatibility when changing code
* Good code usually happens after several rewrites: on the first pass, the focus is on the problem, not the code - when the problem is well understood, the code can be rewritten

## Updates to this guide

Updates to this guide go through review as usual for code - ultimately, some choices in style guides come down to personal preference and contributions of that nature may end up being rejected.

In general, the guide will aim to prioritise:

* safe defaults - avoid footguns and code that is easily abused
* secure practices - assume code is run in an untrusted environment
* compile-time strictness - get the most out of the compiler and language before it hits the user
* readers over writers - only others can judge the quality of your code

## Useful resources

While this book covers Nim at Status in general, there are other resources available that partially may overlap with this guide:

* [Nim language manual](https://nim-lang.org/docs/manual.html) - the authorative source for understanding the features of the language
* [Nim documentation](https://nim-lang.org/documentation.html) - other official Nim documentation, including its standard library and toolchain
* [Nim by Example](https://nim-by-example.github.io/getting_started/) - Nim tutorials to start with
* [Chronos guides](https://github.com/status-im/nim-chronos/blob/master/docs/src/SUMMARY.md)
* [nim-libp2p docs](https://vacp2p.github.io/nim-libp2p/docs/)

## Workflow

### Pull requests

* One PR, one feature or fix
  * Avoid mixing refactoring with features and bugfixes
  * Post refactoring PR:s early, while working on feature that benefits from them
* Rebase on top of target branch
* Squash-merge the PR branch for easy rollback
  * Since branches contain only _one_ logical change, there's usually no need for more than one target branch commit
* Revert work that causes breakage and investigate in new PR

### Contributing

We welcome code contributions and welcome our code being used in other projects.

Generally, all significant code changes are reviewed by at least one team member and must pass CI.

* For style and other trivial fixes, no review is needed (passing CI is sufficent)
* For small ideas, use a PR
* For big ideas, use an RFC issue

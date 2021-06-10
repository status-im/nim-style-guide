## Build system `[tooling.build]`

We use a build system with `make` and `git` submodules. The long term plan is to move to a dedicated package and build manager once one becomes available.

### Pros

* Reproducible build environment
* Fewer disruptions due to mismatching versions of compiler and dependencies

### Cons

* Increased build system complexity with tools that may not be familiar to `nim` developers
* Build system dependencies hard to use on Windows and constrained environments

### nimble

We do not use `nimble`, due to the lack of build reproducibility and other team-oriented features. We sometimes provide `.nimble` packages but these may be out of date and/or incomplete.


## Dependency management `[tooling.deps]`

We track dependencies using `git` submodules to ensure a consistent build environment for all development. This includes the Nim compiler, which is treated like just another dependency - when checking out a top-level project, it comes with an `env.sh` file that allows you to enter the build environment, similar to python `venv`.

When working with upstream projects, it's sometimes convenient to _fork_ the project and submodule the fork, in case urgent fixes / patches are needed. These patches should be passed on to the relevant upstream.

### Pros

* Reproducible build environment ensures that developers and users talk about the same code
    * dependencies must be audited for security issues
* Easier for community to understand exact set of dependencies
* Fork enables escape hatch for critical issues

### Cons

* Forking incurs overhead when upgrading
* Transitive dependencies are difficult to coordinate
* Cross-project commits hard to orchestrate

### Practical notes

* All continuous integration tools build using the same Nim compiler and dependencies
* When a `Nim` or other upstream issue is encountered, consider project priorities:
  * Use a work-around, report issue upstream and leave a note in code so that the work-around can be removed when a fix is available
  * Patch our branch after achieving team consensus


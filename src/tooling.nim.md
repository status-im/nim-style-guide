## Nim version

We support a single Nim version that is upgraded between release cycles of our own projects. Individual projects and libraries may choose to support multiple Nim versions, though this involves significant overhead.

### Pros

* Nim `devel` branch, as well as feature and bugfix releases often break the codebase due to subtle changes in the language and code generation which are hard to diagnose - each upgrade requires extensive testing
* Easier for community to understand exact set of dependencies
* Balance between cutting edge and stability
* Own branch enables escape hatch for critical issues

### Cons

* Work-arounds in our code for `Nim` issues add technical debt
* Compiler is rebuilt in every clone

### Practical notes

* Following Nim `devel`, from experience, leads to frequent disruptions as "mysterious" issues appear
* To support multiple Nim versions in a project, the project should be set up to run CI with all supported versions


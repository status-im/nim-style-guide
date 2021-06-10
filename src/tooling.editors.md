## Editors `[tooling.editors]`

### `vscode`

Most `nim` developers use `vscode`.

* [Nim Extension](https://marketplace.visualstudio.com/items?itemName=nimsaem.nimvscode) gets you syntax highlighting, goto definition and other modernities
  * The older, but less maintained [Nim plugin](https://marketplace.visualstudio.com/items?itemName=kosz78.nim) is an alternative
* To start `vscode` with the correct Nim compiler, run it with `./env.sh code`
* Run nim files with `F6`
* Suggestions, goto and similar features mostly work, but sometimes hang
  * You might need to `killall nimsuggest` occasionally

### Other editors with Nim integration

* Sublime text
* `vim`

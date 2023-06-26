main-c: asynclib.nim main.c
	nim c --debuginfo --app:staticlib --noMain asynclib
	gcc -pthread -g main.c -L. -lasynclib -o main-c

main-rs: asynclib.nim main.rs
	nim c --debuginfo --app:staticlib --noMain asynclib
	rustc main.rs -L. -lasynclib -o main-rs

prepare:
	nimble install -y chronos

main-c: asynclib.nim main.c
	nim c --debuginfo --app:staticlib --nimMainPrefix:asynclib --noMain --threads:on --tlsEmulation:off asynclib
	gcc -pthread -g main.c -L. -lasynclib -o main-c

main-rs: asynclib.nim main.rs
	nim c --debuginfo --app:staticlib --nimMainPrefix:asynclib --noMain --threads:on --tlsEmulation:off asynclib
	rustc main.rs -L. -lasynclib -o main-rs

prepare:
	nimble install -y chronos@#master

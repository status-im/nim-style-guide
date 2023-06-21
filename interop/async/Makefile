all:
	nim c --debuginfo --app:staticlib --nimMainPrefix:asynclib --noMain --threads:on asynclib
	gcc -g main.c libasynclib.a -o main
	./main

prepare:
	nimble install chronos

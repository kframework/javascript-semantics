.PHONY: all
all: build run

.PHONY: build
build:
	kompile -d . --no-prelude --backend java --transition "getOwnProperty toBoolean pseudoIf" ../js.k

.PHONY: run
run:
	krun --smt none --search send.js

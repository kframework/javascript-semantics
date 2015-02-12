.PHONY: all
all: build run

.PHONY: build
build: js.k
	kompile --no-prelude --backend java --transition "getOwnProperty toBoolean pseudoIf" js.k

js.k: ../js.k
	cp -f ../js.k .
	patch -p1 <js.k.patch
	ln -s ../js-trans.k
	ln -s ../js-str-numeric-literal.k
	ln -s ../js-prelude.k

.PHONY: run
run:
	krun -w none --smt none --search send.js >send.js.out

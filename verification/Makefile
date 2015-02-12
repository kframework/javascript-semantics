SHELL=/bin/bash

K?=../k
K_Z3=$(K)/k-distribution/include/z3

.PHONY: all
all: build prove

.PHONY: build
build: clean
	kompile -d patterns/tree_string --no-prelude --backend java --main-module JS-VERIFIER --syntax-module JS-SYNTAX patterns/tree_string/js-verifier.k
	kompile -d patterns/tree_float  --no-prelude --backend java --main-module JS-VERIFIER --syntax-module JS-SYNTAX patterns/tree_float/js-verifier.k
	kompile -d patterns/list        --no-prelude --backend java --main-module JS-VERIFIER --syntax-module JS-SYNTAX patterns/list/js-verifier.k 

.PHONY: prove
prove:
	@echo "List"
	krun -d patterns/list        --smt none                        --prove list/reverse_spec.k       list/reverse.js 
	krun -d patterns/list        --smt none                        --prove list/append_spec.k        list/append.js
	@echo "BST String"
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove bst/string_find_spec.k    bst/find.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove bst/string_insert_spec.k  bst/insert.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove bst/string_delete_spec.k  bst/delete.js 
	@echo "BST OOP String"
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove bst-oop/bst_find_spec.k   bst-oop/bst.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove bst-oop/bst_insert_spec.k bst-oop/bst.js 
	@echo "BST Float"
	krun -d patterns/tree_float  --smt_prelude $(K_Z3)/float.smt2  --prove bst/float_find_spec.k     bst/find.js 
	krun -d patterns/tree_float  --smt_prelude $(K_Z3)/float.smt2  --prove bst/float_insert_spec.k   bst/insert.js 
	krun -d patterns/tree_float  --smt_prelude $(K_Z3)/float.smt2  --prove bst/float_delete_spec.k   bst/delete.js 
	@echo "AVL String"
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove avl/avl_find_spec.k       avl/avl.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove avl/avl_insert_spec.k     avl/avl.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove avl/avl_delete_spec.k     avl/avl.js 

.PHONY: clean
clean:
	rm -rf patterns/tree_string/js-verifier-kompiled
	rm -rf patterns/tree_float/js-verifier-kompiled
	rm -rf patterns/list/js-verifier-kompiled

SHELL=/bin/bash

K?=../k
K_Z3=$(K)/k-distribution/include/z3

.PHONY: build_verifier
build_verifier:
	kompile -d patterns/tree_string --no-prelude --backend java --main-module JS-VERIFIER --syntax-module JS-SYNTAX patterns/tree_string/js-verifier.k
	kompile -d patterns/tree_float  --no-prelude --backend java --main-module JS-VERIFIER --syntax-module JS-SYNTAX patterns/tree_float/js-verifier.k
	kompile -d patterns/list        --no-prelude --backend java --main-module JS-VERIFIER --syntax-module JS-SYNTAX patterns/list/js-verifier.k 

.PHONY: prove_all
prove_all:
	krun -d patterns/list        --smt none                        --prove list/reverse_spec.k       list/reverse.js 
	krun -d patterns/list        --smt none                        --prove list/append_spec.k        list/append.js
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove bst/string_find_spec.k    bst/find.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove bst/string_insert_spec.k  bst/insert.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove bst/string_delete_spec.k  bst/delete.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove avl/avl_find_spec.k       avl/avl.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove avl/avl_insert_spec.k     avl/avl.js 
	krun -d patterns/tree_string --smt_prelude $(K_Z3)/string.smt2 --prove avl/avl_delete_spec.k     avl/avl.js 

SHELL=/bin/bash

.PHONY: all
all: build prove

.PHONY: prove
prove: list list-smt sorting tree

.PHONY: build
build: clean
	kompile -d patterns/tree_string --no-prelude --backend java --main-module JS-VERIFIER --syntax-module JS-SYNTAX patterns/tree_string/js-verifier.k
#	kompile -d patterns/tree_float  --no-prelude --backend java --main-module JS-VERIFIER --syntax-module JS-SYNTAX patterns/tree_float/js-verifier.k
	kompile -d patterns/list        --no-prelude --backend java --main-module JS-VERIFIER --syntax-module JS-SYNTAX patterns/list/js-verifier.k

.PHONY: list
list:
#	@echo "List"
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/head_spec.k          list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/tail_spec.k          list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/add_spec.k           list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/swap_spec.k          list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/length_recursive_spec.k       list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/length_iterative_spec.k       list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/sum_recursive_spec.k          list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/sum_iterative_spec.k          list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/reverse_spec.k       list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/append_spec.k        list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none          --prove list/copy_spec.k          list/list.js

.PHONY: list-smt
list-smt:
	@echo "List"
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/head_spec.k          list/list.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/tail_spec.k          list/list.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/add_spec.k           list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/swap_spec.k          list/list.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/length_recursive_spec.k       list/list.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/length_iterative_spec.k       list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/sum_recursive_spec.k          list/list.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/sum_iterative_spec.k          list/list.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/reverse_spec.k       list/list.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/append_spec.k        list/list.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/list.smt2          --prove list/copy_spec.k          list/list.js

.PHONY: sorting
sorting:
	@echo "Sorting"
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/sorted_list.smt2          --prove sorting/bubble_sort_spec.k             sorting/bubble_sort.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/sorted_list.smt2          --prove sorting/insertion_sort_spec.k          sorting/insertion_sort.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/sorted_list.smt2          --prove sorting/quicksort_spec.k               sorting/quicksort.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt_prelude patterns/list/sorted_list.smt2          --prove sorting/merge_sort_spec.k              sorting/merge_sort.js

.PHONY: tree
tree:
#	@echo "List"
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none                                     --prove list/reverse_spec.k       list/reverse.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/list        --smt none                                     --prove list/append_spec.k        list/append.js
	@echo "BST String"
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_string --smt_prelude patterns/tree_string/string.smt2 --prove bst/string_find_spec.k    bst/find.js 
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_string --smt_prelude patterns/tree_string/string.smt2 --prove bst/string_insert_spec.k  bst/insert.js 
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_string --smt_prelude patterns/tree_string/string.smt2 --prove bst/string_delete_spec.k  bst/delete.js 
	@echo "BST OOP String"
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_string --smt_prelude patterns/tree_string/string.smt2 --prove bst-oop/bst_find_spec.k   bst-oop/bst.js 
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_string --smt_prelude patterns/tree_string/string.smt2 --prove bst-oop/bst_insert_spec.k bst-oop/bst.js 
#	@echo "BST Float"
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_float  --smt_prelude patterns/tree_float/float.smt2   --prove bst/float_find_spec.k     bst/find.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_float  --smt_prelude patterns/tree_float/float.smt2   --prove bst/float_insert_spec.k   bst/insert.js
#	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_float  --smt_prelude patterns/tree_float/float.smt2   --prove bst/float_delete_spec.k   bst/delete.js
	@echo "AVL String"
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_string --smt_prelude patterns/tree_string/string.smt2 --prove avl/avl_find_spec.k       avl/avl.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_string --smt_prelude patterns/tree_string/string.smt2 --prove avl/avl_insert_spec.k     avl/avl.js
	K_OPTS=-Xmx4096m krun --z3-executable -d patterns/tree_string --smt_prelude patterns/tree_string/string.smt2 --prove avl/avl_delete_spec.k     avl/avl.js

.PHONY: clean
clean:
	rm -rf patterns/tree_string/js-verifier-kompiled
#	rm -rf patterns/tree_float/js-verifier-kompiled
	rm -rf patterns/list/js-verifier-kompiled

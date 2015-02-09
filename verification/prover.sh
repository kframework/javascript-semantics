#!/bin/bash

dir="$(cd `dirname $0`; pwd)"

# Set K repository
k="$dir"/../k

set -x

# java -Xmx4024m

# Basic
# "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/min_spec.k                  "$dir"/min.js

# BST in C-like style
  "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/bst/string_find_spec.k      "$dir"/bst/find.js 
  "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/bst/string_insert_spec.k    "$dir"/bst/insert.js 
  "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/bst/string_delete_spec.k    "$dir"/bst/delete.js 

# BST in OOP style
# "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/bst/bst_find_spec.k         "$dir"/bst/bst3.js 
# "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/bst/bst_insert_spec.k       "$dir"/bst/bst3.js 
# "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/bst/bst_delete_spec.k       "$dir"/bst/bst3.js 

# AVL in C-like style
  "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/avl/avl_find_spec.k         "$dir"/avl/avl.js 
  "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/avl/avl_insert_spec.k       "$dir"/avl/avl.js 
  "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/avl/avl_delete_spec.k       "$dir"/avl/avl.js 

# List in C-like style
  "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/list/reverse_spec.k        "$dir"/list/reverse.js 
  "$k"/k-distribution/target/release/k/bin/krun -v --debug -d "$dir"/../ --smt_prelude "$k"/k-distribution/include/z3/string.smt2 --prove "$dir"/list/append_spec.k         "$dir"/list/append.js

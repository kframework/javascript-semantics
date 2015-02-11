## JavaScript Program Verification

You can verify a JavaScript program by using the semantics and the K verifier.

All you need to do is to write a specification and run `krun` with `--prove` option:
```
$ krun --prove <specification.k> <program.js>
```
The specification `<specification.k>` essentially describes a pre-/post-condition,
and it should be given as a reachability rule written in K.

You can prove all the example programs by using `prover.sh`:
```
$ ./prover.sh
```

### Programs to be verified

We have the following example programs to be verified:

| Programs     | Source Codes                         | Specifications                                       |
|--------------|--------------------------------------|------------------------------------------------------|
| List reverse | [list/reverse.js](list/reverse.js)   | [list/reverse_spec.k](list/reverse_spec.k)           |
| List append  | [list/append.js](list/append.js)     | [list/append_spec.k](list/append_spec.k)             |
| BST find     | [bst/find.js](bst/find.js)           | [bst/string_find_spec.k](bst/string_find_spec.k)     |
| BST insert   | [bst/insert.js](bst/insert.js)       | [bst/string_insert_spec.k](bst/string_insert_spec.k) |
| BST delete   | [bst/delete.js](bst/delete.js)       | [bst/string_delete_spec.k](bst/string_delete_spec.k) |
| AVL find     | [avl/avl.js:find](avl/avl.js#L90)    | [avl/avl_find_spec.k](avl/avl_find_spec.k)           |
| AVL insert   | [avl/avl.js:insert](avl/avl.js#L102) | [avl/avl_insert_spec.k](avl/avl_insert_spec.k)       |
| AVL delete   | [avl/avl.js:delete](avl/avl.js#L120) | [avl/avl_delete_spec.k](avl/avl_delete_spec.k)       |



### Specifications

The specifications are given as reachability rules using the K syntax and are
located in `*_spec.k` files.
For example, the rule below from the
[`avl_insert_spec.k`](avl/avl_insert_spec.k)
file captures the behavior of the avl insert routine:
```
rule
  <ctrl>
    <ctx>
      <activeStack> ACTIVESTACK:List ...</activeStack>
      <running>
        <lexicalEnv> EID:Eid </lexicalEnv>
        <thisBinding> THISBINDING:Val </thisBinding>
        <lastNonEmptyValue> LASTNONEMPTYVALUE:Val </lastNonEmptyValue>
      </running>
    </ctx>
    <excStack> EXCSTACK:List </excStack>
    <pseudoStack> PSEUDOSTACK:List </pseudoStack>
  </ctrl>
  <envs>...
    <env>
      <eid> EID </eid>
      <outer> @GlobalEid </outer>
      <strict> false </strict>
      <declEnvRec> Record:Map </declEnvRec>
    </env>
    <env>
      <eid> @GlobalEid </eid>
      <outer> @NullEid </outer>
      <strict> false </strict>
      <objEnvRec>
        <bindingObj> @GlobalOid </bindingObj>
        <provideThis> false </provideThis>
      </objEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    OBJS:Bag
    (string_htree(O1)(T1:StringTree) => string_htree(?O2)(?T2:StringTree))
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %call(
      %var("insert"),
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires ("insert" in keys(Record) ==K false) andBool (EID =/=K @NullEid) andBool string_avl(T1)
    andBool (string_tree_height(T1) <Int (4294967296 -Int 1))
  ensures string_avl(?T2) andBool string_tree_keys(?T2) ==K { V } U string_tree_keys(T1)
    andBool string_tree_height(T1) <=Int  string_tree_height(?T2)
    andBool string_tree_height(?T2) <=Int string_tree_height(T1) +Int 1
```

While the rule is fairly verbose (due to operating on the configuration used to
give semantics to JavaScript), most of it can be automatically generated.
Specifically
 * the variables with the same names as cells but with capital letters (e.g.
   `OBJS:Bag`) are placeholders for the parts of the configuration that are
   statically computed by running the semantics on the functions being verified
   (e.g. `OBJS:Bags` stands for all the builtin objects and the objects associated
   to the functions being verified).
 * the parts that are needed for the symbolic execution of any code fragment,
   regardless of what the code the code does; e.g. the global environment:
```
  <env>
    <eid> @GlobalEid </eid>
    <outer> @NullEid </outer>
    <strict> false </strict>
    <objEnvRec>
      <bindingObj> @GlobalOid </bindingObj>
      <provideThis> false </provideThis>
    </objEnvRec>
  </env>
```
 * the parts that captures general JavaScript behavior; e.g. the line
   `(.Bag => ?_:Bag)`
   in the `<objs>` cell that says that after a function call there may be some
   dead objects left over, since the semantics does not garbage collect (`?\_` is a
   existentially quantified anonymous variable)

The parts of this rule specific to the avl insert routine are
 * the `<k>` cell, which says that the call to insert takes a string `V` and an
   object reference O1 and returns another object reference `?O2`
 * the line
   `(string_htree(O1)(T1:StringTree) => string_htree(?O2)(?T2:StringTree))`
   in the `<objs>` cell which says that before the call to insert, there is a tree
   rooted at `O1` which represent the algebraic tree `T1` in the heap, and after the
   call there is another tree rooted at `?O2` which represents the tree `?T2`
 * the requires clause, which i) states that `T1` is an avl, ii) bounds the height
   of `T1` to ensure there is no precision loss when computing the height of `?T2`
   (the tree after the insertion), and iii) states that insert has not been
   redefined between the global declaration and the call site
 * the ensures clause which states that i) `?T2` is an avl, ii) they keys of `?T2`
   are the union of the keys of `T1` and `{ V }`, and iii) the height of `?T2`
   increases by at most one

With that in mind, we could generate the rule above from a more compact
annotation
```
function insert(v, t)
//@requires string_htree(t)(T1) /\ string_avl(T1)
         /\ string_tree_height(T1) < 4294967295
//@ensures string_htree(t)(?T2) /\ string_avl(?T2)
        /\ string_tree_keys(?T2) == { V } U string_tree_keys(T1)
        /\ | string_tree_height(?T2) - string_tree_height(T1) | <  1
```

We did not implement this transformation yet. However a similar transformation
(albeit for a simpler language) is implemented in the MatchC tool, which is
available online at
    http://fsl.cs.illinois.edu/index.php/Special:MatchCOnline 

### Run

The following bash command verifies the avl insert example:

```
$ krun --prove verification/avl/insert_spec.k verification/avl/insert.js --smt_prelude=<k_root>/include/z3/string.smt2
```


### Directory Structure

 * [patterns](patterns) - definitions of the abstractions used in the specifications (list, tree, etc) given in K syntax
 * [list](list)     - the source code and specifications for the list examples
 * [bst](bst)      - the source code and specifications for the bst example
 * [avl](avl)      - the source code and specifications for the avl example

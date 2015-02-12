## JavaScript Program Verification

You can verify a JavaScript program by using the semantics and the K verifier.

All you need to do is to write a specification and run `krun` with `--prove` option:
```
$ krun --prove <specification.k> <program.js>
```
The specification `<specification.k>` essentially describes a pre-/post-condition,
and it should be given as a reachability rule written in K.

You can quickly run all of the verification examples using the [Makefile](Makefile):
```
$ make
```

We provide the verification results, [verification.out](verification.out).
For each program, the verifier simply outputs the following triple when it succeeds in verifying the program:
```
true
[]
true
```
Note that the verifier will simply crash or not terminate when the program is not correct. We will improve usability of the verifier.


### List of Programs and Specifications

We have the following example programs and specifications to be verified:

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
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (string_htree(O1)(T1:StringTree) => string_htree(?O2)(?T2:StringTree))
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("insert"),
      @o(19),
      Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires string_avl(T1) andBool string_tree_height(T1) <Int (4294967296 -Int 1)
  ensures string_avl(?T2) andBool string_tree_keys(?T2) ==K { V } U string_tree_keys(T1)
    andBool string_tree_height(T1) <=Int  string_tree_height(?T2)
    andBool string_tree_height(?T2) <=Int string_tree_height(T1) +Int 1
```

While the rule is fairly verbose (due to operating on the configuration used to
give semantics to JavaScript), most of it can be automatically generated.
Specifically
 * the variables with the same names as cells but with capital letters (e.g.
   `ENVS:Bag` and `OBJS:Bag`) are placeholders for the parts of the configuration that are
   statically computed by running the semantics on the functions being verified
   (e.g. `OBJS:Bags` stands for all the builtin objects and the objects associated
   to the functions being verified).
 * the parts that captures general JavaScript behavior; e.g. the line
   `(.Bag => ?_:Bag)`
   in the `<objs>` cell that says that after a function call there may be some
   dead objects left over, since the semantics does not garbage collect (`?\_` is a
   existentially quantified anonymous variable)
 * the internal reference to the `insert` function, `@o(19)`, will be automatically generated.

The parts of this rule specific to the avl insert routine are
 * the `<k>` cell, which says that the call to insert takes a string `V` and an
   object reference `O1` and returns another object reference `?O2`
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


### Wrapper Module for Verification

The K verifier requires a wrapper module that combines the original language semantics with several verification specific libraries. A wrapper module can be written by simply importing several sub-modules such as the JavaScript semantics `JS`, verification lemmas `VERIFICATION_LEMMAS`, and a data type abstraction `<PATTERN>`, as follows:
```
require "js.k"
require "modules/verification_lemmas.k"
require "<pattern.k>"

module JS-VERIFIER

  imports JS
  imports VERIFICATION_LEMMAS
  imports <PATTERN>

endmodule
```

### Directory Structure

 * [patterns](patterns) - definitions of the abstractions used in the specifications (list, tree, etc) given in K syntax
 * [list](list)     - the source code and specifications for the list examples
 * [bst](bst)      - the source code and specifications for the bst example
 * [avl](avl)      - the source code and specifications for the avl example


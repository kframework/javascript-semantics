require "../patterns/tree_string/js-verifier.k"

module BST-SPEC
imports JS-VERIFIER

rule
  <envs>
    ...
    ENVS:Bag
    (.Bag => ?_:Bag)
    ...
  </envs>
  <objs>
    ...
    OBJS:Bag
    tree(O)(T:StringTree)(@o(10))
    (.Bag => ?_:Bag)
    ...
  </objs>
  <k>
    Call(@o(5), O:Oid, @Cons(V:String, @Nil))
  =>
    V inStringSet tree_keys(T)
    ...
  </k>
  requires bst(T)

// @o(10): BST.Node.prototype
// @o(5) : BST.prototype.find

endmodule

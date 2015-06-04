require "../../js.k"

module BST-SPEC

imports JS

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
    tree(O)(T:StringTree)(@o(7))
    (.Bag => ?_:Bag)
    ...
  </objs>
  <k>
    Call(@o(12), O:Oid, @Cons(V:String, @Nil))
  =>
    V inStringSet tree_keys(T)
    ...
  </k>
  requires bst(T)

// @o(7)  : BST.Node.prototype
// @o(12) : BST.Node.prototype.find

endmodule

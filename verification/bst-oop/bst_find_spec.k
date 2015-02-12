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
    tree(O)(T:StringTree)(@o(8))
    (.Bag => ?_:Bag)
    ...
  </objs>
  <k>
    Call(@o(11), O:Oid, @Cons(V:String, @Nil))
  =>
    V inStringSet tree_keys(T)
    ...
  </k>
  requires bst(T)

// @o(8)  : BST.Node.prototype
// @o(11) : BST.Node.prototype.find

endmodule

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
  (
    tree(O1)(T1:StringTree)(@o(8))
  =>
    tree(O1)(?T2:StringTree)(@o(8))
    ?_:Bag
  )
    ...
  </objs>
  <k>
    Call(@o(9), O1:Oid, @Cons(V:String, @Nil))
  =>
    Undefined
    ...
  </k>
  requires bst(T1)
  ensures bst(?T2) andBool tree_keys(?T2) ==K { V } U tree_keys(T1)

// @o(8)  : BST.Node.prototype
// @o(9)  : BST.Node.prototype.insert

endmodule

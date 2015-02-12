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
    string_tree(O1)(T1:StringTree)(@o(8))
  =>
    string_tree(O1)(?T2:StringTree)(@o(8))
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
  requires string_bst(T1)
  ensures string_bst(?T2) andBool string_tree_keys(?T2) ==K { V } U string_tree_keys(T1)

// @o(8)  : BST.Node.prototype
// @o(9)  : BST.Node.prototype.insert

endmodule

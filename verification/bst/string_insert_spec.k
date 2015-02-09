require "../../js.k"

module BST-SPEC
imports JS

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    OBJS:Bag
    string_tree(O1)(T1:StringTree)(P:Oid)
  =>
    OBJS:Bag
    string_tree(?O2)(?T2:StringTree)(P:Oid)
    ?_:Bag
  ...</objs>
  <k>
    Call(
      // %var("insert"),
      @o(4),
      Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires string_bst(T1)
  ensures string_bst(?T2) andBool string_tree_keys(?T2) ==K { V } U string_tree_keys(T1)
endmodule


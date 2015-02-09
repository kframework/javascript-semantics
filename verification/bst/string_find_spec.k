require "../../js.k"

module BST-SPEC
imports JS

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    string_tree(O)(T:StringTree)(_:Oid)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("find"),
      @o(2),
      Undefined,
      @Cons(V:String, @Cons(O:NullableObject, @Nil)))
  =>
    V inStringSet string_tree_keys(T)
  ...</k>
  requires string_bst(T)
endmodule

require "../patterns/tree_string/js-verifier.k"

module BST-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    tree(O)(T:StringTree)(_:Oid)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("find"),
      @o(1),
      Undefined,
      @Cons(V:String, @Cons(O:NullableObject, @Nil)))
  =>
    V inStringSet tree_keys(T)
  ...</k>
  requires bst(T)
endmodule

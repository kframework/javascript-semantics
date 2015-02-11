require "../patterns/tree_string/js-verifier.k"

module AVL-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    OBJS:Bag
    string_htree(O)(T:StringTree)
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("find"),
      @o(17),
      Undefined,
      @Cons(V:String, @Cons(O:NullableObject, @Nil)))
  =>
    V inStringSet string_tree_keys(T)
  ...</k>
  requires string_avl(T)
endmodule

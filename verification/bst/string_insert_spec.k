require "../patterns/tree_string/js-verifier.k"

module BST-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (tree(O1)(T1:StringTree)(P:Oid) => tree(?O2)(?T2:StringTree)(P:Oid))
    OBJS:Bag
    (.Bag => ?_:Bag)
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
  requires bst(T1)
  ensures bst(?T2) andBool tree_keys(?T2) ==K { V } U tree_keys(T1)
endmodule


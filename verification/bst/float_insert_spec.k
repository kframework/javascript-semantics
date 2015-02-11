require "../patterns/tree_string/js-verifier.k"

module BST-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (float_tree(O1)(T1:FloatTree) => float_tree(?O2)(?T2:FloatTree))
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("insert"),
      @o(4),
      Undefined,
      @Cons(V:Float{exponent(11), significand(53)}, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires float_bst(T1) andBool (notBool isNaN(V))
  ensures float_bst(?T2) andBool float_tree_keys(?T2) ==K { V } U float_tree_keys(T1)
endmodule


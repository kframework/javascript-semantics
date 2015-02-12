require "../patterns/tree_float/js-verifier.k"

module BST-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    tree(O)(T:FloatTree)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("find"),
      @o(2),
      Undefined,
      @Cons(V:Float{exponent(11), significand(53)}, @Cons(O:NullableObject, @Nil)))
  =>
    V inFloatSet tree_keys(T)
  ...</k>
  requires bst(T) andBool (notBool isNaN(V)) 
endmodule


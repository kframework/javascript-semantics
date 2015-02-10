require "../../js.k"

module BST-SPEC
imports JS

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    float_tree(O)(T:FloatTree)
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
    V inFloatSet float_tree_keys(T)
  ...</k>
  requires float_bst(T) andBool (notBool isNaN(V)) 
endmodule


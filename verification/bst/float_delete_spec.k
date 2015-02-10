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
      // %var("find_min"),
      @o(2),
      Undefined,
      @Cons(O:Oid, @Nil))
  =>
    ?M:Float{exponent(11), significand(53)}
  ...</k>
  requires float_bst(T)
  ensures (?M inFloatSet float_tree_keys(T)) andBool ({ ?M } <=FloatSet float_tree_keys(T)) andBool (notBool isNaN(?M))

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
      // %var("remove"),
      @o(4),
      Undefined,
      @Cons(V:Float{exponent(11), significand(53)}, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires float_bst(T1) andBool (notBool isNaN(V))
  ensures float_bst(?T2) andBool float_tree_keys(?T2) ==K float_tree_keys(T1) -FloatSet { V }
endmodule


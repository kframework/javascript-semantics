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
      // %var("find_min"),
      @o(2),
      Undefined,
      @Cons(O:Oid, @Nil))
  =>
    ?M:Float{exponent(11), significand(53)}
  ...</k>
  requires bst(T)
  ensures (?M inFloatSet tree_keys(T)) andBool ({ ?M } <=FloatSet tree_keys(T)) andBool (notBool isNaN(?M))

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (tree(O1)(T1:FloatTree) => tree(?O2)(?T2:FloatTree))
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
  requires bst(T1) andBool (notBool isNaN(V))
  ensures bst(?T2) andBool tree_keys(?T2) ==K tree_keys(T1) -FloatSet { V }
endmodule


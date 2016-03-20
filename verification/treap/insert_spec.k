require "../patterns/tree_priority/js-verifier.k"

module TREAP-INSERT-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
  (
    ptree(O1)(T1:PTree)
  =>
    ptree(?O2)(pnode(?I2:String,?Z2:Int,?L2:PTree,?R2:PTree))
  )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("insert"),
      @o(10),
      Undefined,
      @Cons(V:String, @Cons(Z:Int, @Cons(O1:NullableObject, @Nil))))
  =>
    ?O2:NullableObject
  ...</k>
requires treap(T1)
  andBool Z >=Int 0
ensures treap(pnode(?I2,?Z2,?L2,?R2))
  andBool ptree_keys(pnode(?I2,?Z2,?L2,?R2)) ==K { V } U ptree_keys(T1)
  andBool ?O2 =/=K @NullVal
  andBool ptree_max_priority(T1) >=Int ptree_max_priority(?L2)
  andBool ptree_max_priority(T1) >=Int ptree_max_priority(?R2)

endmodule

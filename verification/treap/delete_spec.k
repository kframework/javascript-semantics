require "../patterns/tree_priority/js-verifier.k"

module TREAP-DELETE-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
  (
    ptree( O1)(pnode(I1:String,Z1:Int,L1:PTree,R1:PTree))
  =>
    ptree(?O2)(?T2:PTree)
  )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("remove_root"),
      @o(12),
      Undefined,
      @Cons(O1:NullableObject, @Nil))
  =>
    ?O2:NullableObject
  ...</k>
requires treap(pnode(I1,Z1,L1,R1))
  andBool O1 =/=K @NullVal
ensures treap(?T2)
  andBool ptree_keys(?T2) ==K ptree_keys(L1) U ptree_keys(R1)
  andBool ptree_max_priority(?T2) ==Int maxInt(ptree_max_priority(L1), ptree_max_priority(R1))

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
  (
    ptree( O1)( T1:PTree)
  =>
    ptree(?O2)(?T2:PTree)
  )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("remove"),
      @o(14),
      Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
requires treap(T1)
ensures treap(?T2)
  andBool ptree_keys(?T2) ==K (ptree_keys(T1) -StringSet { V })
  andBool ptree_max_priority(?T2) <=Int ptree_max_priority(T1)

endmodule

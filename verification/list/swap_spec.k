require "../patterns/list/js-verifier.k"

module SWAP-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      list(O)(StringSeqItem(V1:String) @ StringSeqItem(V2:String) @ L:StringSeq)
    =>
      list(?O2)(StringSeqItem(V2) @ StringSeqItem(V1) @ L)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(8), // %var("swap"),
      Undefined,
      @Cons(O:NullableObject, @Nil)
    )
  =>
    ?O2:NullableObject
  ...</k>

endmodule

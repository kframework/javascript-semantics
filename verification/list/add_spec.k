require "../patterns/list/js-verifier.k"

module ADD-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (list(O)(L:StringSeq) => list(?O2)(StringSeqItem(V) @ L))
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(6), // %var("add"),
      Undefined,
      @Cons(V:String, @Cons(O:NullableObject, @Nil))
    )
  =>
    ?O2:NullableObject
  ...</k>

endmodule

require "../patterns/list/js-verifier.k"

module SUM-RECURSIVE-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    list(X)(L:StringSeq)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(14), // %var("sum_recursive"),
      Undefined,
      @Cons(X:NullableObject, @Nil)
    )
  =>
    sum(L)
  ...</k>

endmodule

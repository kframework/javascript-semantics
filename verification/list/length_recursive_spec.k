require "../patterns/list/js-verifier.k"

module LENGTH-RECURSIVE-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    list(O)(L:List)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(10), // %var("length_recursive"),
      Undefined,
      @Cons(O:NullableObject, @Nil)
    )
  =>
    size(L)
  ...</k>
  requires size(L) <Int (@MAX_INT -Int 1)

endmodule

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
      list(O)(ListItem(V1:String) ListItem(V2:String) L:List)
    =>
      list(?O2)(ListItem(V2) ListItem(V1) L)
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

require "../patterns/list/js-verifier.k"

module HEAD-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    list(@o(O:Int))(ListItem(V:String) _:List)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("head"),
      @o(2),
      Undefined,
      @Cons(@o(O:Int), @Nil))
  =>
    V
  ...</k>

endmodule

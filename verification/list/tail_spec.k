require "../patterns/list/js-verifier.k"

module TAIL-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    <obj>
      <oid> @o(O:Int) </oid>
      <properties>
        "value" |-> @desc("Value" |-> _:String          "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "next"  |-> @desc("Value" |-> Tail:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
      </properties>
      <internalProperties>
        "Class"      |-> "Object"
        "Extensible" |-> true
        "Prototype"  |-> @ObjectProtoOid
      </internalProperties>
    </obj>
    list(Tail)(L:List)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("tail"),
      @o(4),
      Undefined,
      @Cons(@o(O:Int), @Nil))
  =>
    Tail
  ...</k>

endmodule

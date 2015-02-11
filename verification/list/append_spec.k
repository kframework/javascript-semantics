require "../patterns/tree_string/js-verifier.k"

module APPEND-SPEC
imports JS-VERIFIER

rule [loop-inv]:
  <lexicalEnv> @e(I:Int) </lexicalEnv>
  <lastNonEmptyValue> _:Val => ?_:Val </lastNonEmptyValue>
  <envs>...
    <env>
      <eid> @e(I) </eid>
      <outer> _:Eid </outer>
      <strict> _:Bool </strict>
      <declEnvRec>...
        "x" |-> @ve(OX:NullableObject,         true, true, false)
        "p" |-> @ve(@o(P1:Int) => @o(?P2:Int), true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(OX, @o(P1:Int))(A:List)
      lseg(@o(P1:Int), @NullVal)(B:List)
    =>
      lseg(OX, @o(?P2:Int))(?C:List)
      <obj>
        <oid> @o(?P2:Int) </oid>
        <properties>
          "value" |-> @desc("Value" |-> ?V:Val   "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> @NullVal "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %neqs , %mem ( %var ( "p" ) , %con ( "next" ) ) , %con ( %null ) ) , %seq ( %exp ( %bop ( %assign , %var ( "p" ) , %mem ( %var ( "p" ) , %con ( "next" ) ) ) ) , %labelContinue ( "" ) ) )
  =>
    @Normal
  ...</k>
  requires EID =/=K @NullEid
  ensures A B ==K ?C ListItem(?V)

rule [func-spec]:
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(OX, @NullVal)(A:List)
      lseg(OY, @NullVal)(B:List)
    =>
      lseg(?OP, @NullVal)(A B)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("append"),
      @o(2),
      Undefined,
      @Cons(OX:NullableObject, @Cons(OY:NullableObject, @Nil)))
  =>
    ?OP:NullableObject
  ...</k>
endmodule


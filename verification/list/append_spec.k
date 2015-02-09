require "../../js.k"

module APPEND-SPEC
imports JS

rule [loop-inv]:
  <ctrl>
    <ctx>
      <activeStack>... ACTIVESTACK:List </activeStack>
      <running>
        <lexicalEnv> EID:Eid </lexicalEnv>
        <thisBinding> THISBINDING:Val </thisBinding>
        <lastNonEmptyValue> LASTNONEMPTYVALUE:Val </lastNonEmptyValue>
      </running>
    </ctx>
    <excStack> EXCSTACK:List </excStack>
    <pseudoCtx>
      <pseudoStack> _:List </pseudoStack>
      <pseudoEnv> PSEUDOENV:Map </pseudoEnv>
    </pseudoCtx>
  </ctrl>
  <envs>...
    <env>
      <eid> EID </eid>
      <outer> _:Eid </outer>
      <strict> false </strict>
      <declEnvRec>...
        "x" |-> @ve(OX:NullableObject,         true, true, false)
        "p" |-> @ve(@o(P1:Int) => @o(?P2:Int), true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    OBJS:Bag
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
  <ctrl>
    <ctx>
      <activeStack> ACTIVESTACK:List ...</activeStack>
      <running>
        <lexicalEnv> EID:Eid </lexicalEnv>
        <thisBinding> THISBINDING:Val </thisBinding>
        <lastNonEmptyValue> LASTNONEMPTYVALUE:Val </lastNonEmptyValue>
      </running>
    </ctx>
    <excStack> EXCSTACK:List </excStack>
    <pseudoCtx>
      <pseudoStack> _:List </pseudoStack>
      <pseudoEnv> PSEUDOENV:Map </pseudoEnv>
    </pseudoCtx>
  </ctrl>
  <envs>...
    <env>
      <eid> @GlobalEid </eid>
      <outer> @NullEid </outer>
      <strict> false </strict>
      <objEnvRec>
        <bindingObj> @GlobalOid </bindingObj>
        <provideThis> false </provideThis>
      </objEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    OBJS:Bag
    (
      lseg(OX, @NullVal)(A:List)
      lseg(OY, @NullVal)(B:List)
    =>
      lseg(?OP, @NullVal)(A B)
    )
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %call(
      %var("append"),
      @Cons(OX:NullableObject, @Cons(OY:NullableObject, @Nil)))
  =>
    ?OP:NullableObject
  ...</k>
  requires EID =/=K @NullEid

endmodule


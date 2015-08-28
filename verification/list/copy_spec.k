require "../patterns/list/js-verifier.k"

module COPY-SPEC
imports JS-VERIFIER

rule [loop-inv]:
  <lexicalEnv> @e(E:Int) </lexicalEnv>
  <lastNonEmptyValue> _:Val => ?_:Val </lastNonEmptyValue>
  <envs>...
    <env>
      <eid> @e(E) </eid>
      <outer> _:Eid </outer>
      <strict> _:Bool </strict>
      <declEnvRec>...
            "x" |-> @ve(       X:NullableObject,                      true, true, false)
            "y" |-> @ve(       Y:NullableObject,                      true, true, false)
        "iterx" |-> @ve(   ITERX:NullableObject => ?_:NullableObject, true, true, false)
        "itery" |-> @ve(@o(ITERY:Int)           => @o(?_:Int),        true, true, false)
        "node"  |-> @ve(_:NullableObject        => ?_:NullableObject, true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(    X, ITERX)(A:StringSeq @ StringSeqItem(V:String))
      lseg(ITERX, @NullVal)(B:StringSeq)
      lseg(    Y, @o(ITERY))(A)
      <obj>
        <oid> @o(ITERY) </oid>
        <properties>
          "value" |-> @desc("Value" |-> V        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> @NullVal "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
    =>
      lseg(X, @NullVal)(A @ StringSeqItem(V) @ B)
      lseg(Y, @NullVal)(A @ StringSeqItem(V) @ B)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %neqs , %var ( "iterx" ) , %con ( %null) ) , 
             %seq (                         // dummy 
                    %seq ( %exp ( %bop ( %assign , %var ( "node" ) , %obj ( %cons ( %prop ( "value" , %mem ( %var ( "iterx" ) , %con ( "value" ) ) ) , 
                                                                            %cons ( %prop ( "next" , %con ( %null ) ) , %nil ) ) ) ) ) , 
                    %seq ( %exp ( %bop ( %assign , %mem ( %var ( "itery" ) , %con ( "next" ) ) , %var ( "node" ) ) ) , 
                    %seq ( %exp ( %bop ( %assign , %var ( "iterx" ) , %mem ( %var ( "iterx" ) , %con ( "next" ) ) ) ) , 
                           %exp ( %bop ( %assign , %var ( "itery" ) , %mem ( %var ( "itery" ) , %con ( "next" ) ) ) ) ) ) ) 
                  ,                         // dummy
                    %labelContinue ( "" )   // dummy
                  )                         // dummy
           )
  =>
    @Normal
  ...</k>

rule [func-spec]:
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    lseg(X, @NullVal)(L:StringSeq)
    OBJS:Bag
    (.Bag => lseg(?Y, @NullVal)(L) ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(22), // %var("copy"),
      Undefined,
      @Cons(X:NullableObject, @Nil)
    )
  =>
    ?Y:NullableObject
  ...</k>

endmodule

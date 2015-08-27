require "../patterns/list/js-verifier.k"

module QUICKSORT-SPEC
imports JS-VERIFIER

rule [append-loop-inv]:
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
      lseg(OX, @o(P1:Int))(A:StringSeq)
      lseg(@o(P1:Int), @NullVal)(B:StringSeq)
    =>
      lseg(OX, @o(?P2:Int))(?C:StringSeq)
      <obj>
        <oid> @o(?P2:Int) </oid>
        <properties>
          "value" |-> @desc("Value" |-> ?V:String "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> @NullVal  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
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
  ensures A @ B ==K ?C @ StringSeqItem(?V)

rule [append-func-spec]:
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(OX, @NullVal)(A:StringSeq)
      lseg(OY, @NullVal)(B:StringSeq)
    =>
      lseg(?OP, @NullVal)(A @ B)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(2), // %var("append"),
      Undefined,
      @Cons(OX:NullableObject, @Cons(OY:NullableObject, @Nil)))
  =>
    ?OP:NullableObject
  ...</k>



rule [quicksort-loop-inv]:
  <lexicalEnv> @e(E:Int) </lexicalEnv>
  <lastNonEmptyValue> _:Val => ?_:Val </lastNonEmptyValue>
  <envs>...
    <env>
      <eid> @e(E) </eid>
      <outer> _:Eid </outer>
      <strict> _:Bool </strict>
      <declEnvRec>...
        "x" |-> @ve(X:NullableObject  => @NullVal,           true, true, false)
        "p" |-> @ve(@o(P:Int),                               true, true, false)
        "y" |-> @ve(Y1:NullableObject => ?Y2:NullableObject, true, true, false)
        "z" |-> @ve(Z1:NullableObject => ?Z2:NullableObject, true, true, false)
        // dummy
        "t" |-> @ve(_:NullableObject  => ?_:NullableObject,  true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
      <obj>
        <oid> @o(P) </oid>
        <properties>
          "value" |-> @desc("Value" |-> V:String  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> @NullVal  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
    (
      lseg(X,  @NullVal)(A:StringSeq)
      lseg(Y1, @NullVal)(B1:StringSeq)
      lseg(Z1, @NullVal)(C1:StringSeq)
    =>
      lseg(?Y2,@NullVal)(?B2:StringSeq)
      lseg(?Z2,@NullVal)(?C2:StringSeq)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %neqs , %var ( "x" ) , %con ( %null ) ) , 
             %seq (                         // dummy
                    %seq ( %exp ( %bop ( %assign , %var ( "t" ) , %var ( "x" ) ) ) ,
                    %seq ( %exp ( %bop ( %assign , %var ( "x" ) , %mem ( %var ( "x" ) , %con ( "next" ) ) ) ) , 
                           %if ( %bop ( %lt , %mem ( %var ( "t" ) , %con ( "value" ) ) , %mem ( %var ( "p" ) , %con ( "value" ) ) ) , 
                                 %seq ( %exp ( %bop ( %assign , %mem ( %var ( "t" ) , %con ( "next" ) ) , %var ( "y" ) ) ) , 
                                        %exp ( %bop ( %assign , %var ( "y" ) , %var ( "t" ) ) ) ) , 
                                 %seq ( %exp ( %bop ( %assign , %mem ( %var ( "t" ) , %con ( "next" ) ) , %var ( "z" ) ) ) , 
                                        %exp ( %bop ( %assign , %var ( "z" ) , %var ( "t" ) ) ) ) ) ) )
                  ,                         // dummy
                    %labelContinue ( "" )   // dummy
                  )                         // dummy
           )
  =>
    @Normal
  ...</k>
  requires list2set(B1) <=StringSet { V } andBool { V } <=StringSet list2set(C1)
  ensures  list2set(?B2) <=StringSet { V } andBool { V } <=StringSet list2set(?C2)
    andBool list2set(A) U list2set(B1) U list2set(C1) ==K list2set(?B2) U list2set(?C2)

rule [quicksort-func-spec]:
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(X1, @NullVal)(L1:StringSeq)
    =>
      lseg(?X2,@NullVal)(?L2:StringSeq)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(4), // %var("quicksort"),
      Undefined,
      @Cons(X1:NullableObject, @Nil))
  =>
    ?X2:NullableObject
  ...</k>
  ensures  sorted(?L2)
   andBool list2set(L1) ==K list2set(?L2)

endmodule

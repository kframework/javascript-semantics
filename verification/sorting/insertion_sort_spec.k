require "../patterns/list/js-verifier.k"

module INSERTION-SORT-SPEC
imports JS-VERIFIER

rule [inner-loop-inv]:
  <lexicalEnv> @e(E:Int) </lexicalEnv>
  <lastNonEmptyValue> _:Val => ?_:Val </lastNonEmptyValue>
  <envs>...
    <env>
      <eid> @e(E) </eid>
      <outer> _:Eid </outer>
      <strict> _:Bool </strict>
      <declEnvRec>...
        "z" |-> @ve(@o(Z1:Int) => @o(?Z2:Int), true, true, false)
        "n" |-> @ve(@o(N:Int),                      true, true, false)
        "x" |-> @ve(_:NullableObject,               true, true, false)
        "y" |-> @ve(Y:NullableObject,               true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(Y, @o(Z1))(L1a:StringSeq)
      <obj>
        <oid> @o(Z1) </oid>
        <properties>
          "value" |-> @desc("Value" |-> V1:String         "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> O1:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      lseg(O1, @NullVal)(L1b:StringSeq)
    =>
      lseg(Y, @o(?Z2))(?L2a:StringSeq)
      <obj>
        <oid> @o(?Z2) </oid>
        <properties>
          "value" |-> @desc("Value" |-> ?V2:String         "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> ?O2:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      lseg(?O2, @NullVal)(?L2b:StringSeq)
    )
    <obj>
      <oid> @o(N) </oid>
      <properties>
        "value" |-> @desc("Value" |-> NV:String  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "next"  |-> @desc("Value" |-> @NullVal   "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
      </properties>
      <internalProperties>
        "Class"      |-> "Object"
        "Extensible" |-> true
        "Prototype"  |-> @ObjectProtoOid
      </internalProperties>
    </obj>
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %and , %bop ( %neqs , %mem ( %var ( "z" ) , %con ( "next" ) ) , %con ( %null ) ) , 
                           %bop ( %lt , %mem ( %mem ( %var ( "z" ) , %con ( "next" ) ) , %con ( "value" ) ) , %mem ( %var ( "n" ) , %con ( "value" ) ) ) ) , 
             %seq (                         // dummy
                    %exp ( %bop ( %assign , %var ( "z" ) , %mem ( %var ( "z" ) , %con ( "next" ) ) ) ) 
                  ,                         // dummy
                    %labelContinue ( "" )   // dummy
                  )                         // dummy
           )
  =>
    @Normal
  ...</k>
  requires sorted( L1a @ StringSeqItem( V1) @  L1b) andBool  V1 <String NV
  ensures  sorted(?L2a @ StringSeqItem(?V2) @ ?L2b) andBool ?V2 <String NV
   andBool list2set( L1a) U {  V1 } U list2set( L1b) ==K
           list2set(?L2a) U { ?V2 } U list2set(?L2b)
   andBool list2set(?L2a) <StringSet { NV } andBool { NV } <=StringSet list2set(?L2b) 


rule [outer-loop-inv]:
  <lexicalEnv> @e(E:Int) </lexicalEnv>
  <lastNonEmptyValue> _:Val => ?_:Val </lastNonEmptyValue>
  <envs>...
    <env>
      <eid> @e(E) </eid>
      <outer> _:Eid </outer>
      <strict> _:Bool </strict>
      <declEnvRec>...
        "x" |-> @ve(X:NullableObject  => @NullVal,           true, true, false)
        "y" |-> @ve(Y1:NullableObject => ?Y2:NullableObject, true, true, false)
        // dummy
        "n" |-> @ve(_:NullableObject  => ?_:NullableObject,  true, true, false)
        "z" |-> @ve(_:NullableObject  => ?_:NullableObject,  true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(Y1, @NullVal)(L1a:StringSeq)
      lseg(X,  @NullVal)(L1b:StringSeq)
    =>
      lseg(?Y2,@NullVal)(?L2:StringSeq)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %neqs , %var ( "x" ) , %con ( %null ) ) , 
             %seq (                         // dummy
                    %seq ( %exp ( %bop ( %assign , %var ( "n" ) , %var ( "x" ) ) ) , 
                    %seq ( %exp ( %bop ( %assign , %var ( "x" ) , %mem ( %var ( "x" ) , %con ( "next" ) ) ) ) , 
                    %seq ( %exp ( %bop ( %assign , %mem ( %var ( "n" ) , %con ( "next" ) ) , %con ( %null ) ) ) , 
                           %if ( %bop ( %neqs , %var ( "y" ) , %con ( %null ) ) , 
                                 %if ( %bop ( %lt , %mem ( %var ( "y" ) , %con ( "value" ) ) , %mem ( %var ( "n" ) , %con ( "value" ) ) ) , 
                                       %seq ( %exp ( %bop ( %assign , %var ( "z" ) , %var ( "y" ) ) ) , 
                                       %seq ( %label ( "" , 
    // inner loop start
    %while ( %bop ( %and , %bop ( %neqs , %mem ( %var ( "z" ) , %con ( "next" ) ) , %con ( %null ) ) , 
                           %bop ( %lt , %mem ( %mem ( %var ( "z" ) , %con ( "next" ) ) , %con ( "value" ) ) , %mem ( %var ( "n" ) , %con ( "value" ) ) ) ) , 
             %exp ( %bop ( %assign , %var ( "z" ) , %mem ( %var ( "z" ) , %con ( "next" ) ) ) ) 
           ) 
    // inner loop end
                                                     ) , 
                                       %seq ( %exp ( %bop ( %assign , %mem ( %var ( "n" ) , %con ( "next" ) ) , %mem ( %var ( "z" ) , %con ( "next" ) ) ) ) , 
                                              %exp ( %bop ( %assign , %mem ( %var ( "z" ) , %con ( "next" ) ) , %var ( "n" ) ) ) ) ) ) , 
                                       %seq ( %exp ( %bop ( %assign , %mem ( %var ( "n" ) , %con ( "next" ) ) , %var ( "y" ) ) ) , 
                                              %exp ( %bop ( %assign , %var ( "y" ) , %var ( "n" ) ) ) ) ) , 
                                 %exp ( %bop ( %assign , %var ( "y" ) , %var ( "n" ) ) ) ) ) ) )
                  ,                         // dummy
                    %labelContinue ( "" )   // dummy
                  )                         // dummy
           )
  =>
    @Normal
  ...</k>
  requires sorted(L1a)
  ensures  sorted(?L2)
   andBool list2set(L1a) U list2set(L1b) ==K list2set(?L2)


rule [func-spec]:
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (lseg(X1,@NullVal)(L1:StringSeq) => lseg(?X2,@NullVal)(?L2:StringSeq))
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(2), // %var("insertion_sort"),
      Undefined,
      @Cons(X1:NullableObject, @Nil))
  =>
    ?X2:NullableObject
  ...</k>
  ensures  sorted(?L2)
   andBool list2set(L1) ==K list2set(?L2)

endmodule

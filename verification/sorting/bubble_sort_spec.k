require "../patterns/list/js-verifier.k"

module BUBBLE-SORT-SPEC
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
        "x"      |-> @ve(X:NullableObject ,               true, true, false)
        "y"      |-> @ve(@o(Y:Int)        => @o(?_:Int),  true, true, false)
        "change" |-> @ve(C1:Bool          => ?C2:Bool,    true, true, false)
        "temp"   |-> @ve(_:String         => ?_:String,   true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(X, @o(Y))(L1a:StringSeq)
      <obj>
        <oid> @o(Y) </oid>
        <properties>
          "value" |-> @desc("Value" |-> V:String         "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> O:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      lseg(O, @NullVal)(L1b:StringSeq)
    =>
      lseg(X, @NullVal)(?L2:StringSeq)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %neqs , %mem ( %var ( "y" ) , %con ( "next" ) ) , %con ( %null ) ) , 
             %seq (                         // dummy
                    %seq ( %if ( %bop ( %gt , %mem ( %var ( "y" ) , %con ( "value" ) ) , %mem ( %mem ( %var ( "y" ) , %con ( "next" ) ) , %con ( "value" ) ) ) ,
                                 %seq ( %exp ( %bop ( %assign , %var ( "change" ) , %con ( true ) ) ) , 
                                 %seq ( %exp ( %bop ( %assign , %var ( "temp" ) , %mem ( %var ( "y" ) , %con ( "value" ) ) ) ) ,
                                 %seq ( %exp ( %bop ( %assign , %mem ( %var ( "y" ) , %con ( "value" ) ) , %mem ( %mem ( %var ( "y" ) , %con ( "next" ) ) , %con ( "value" ) ) ) ) , 
                                        %exp ( %bop ( %assign , %mem ( %mem ( %var ( "y" ) , %con ( "next" ) ) , %con ( "value" ) ) , %var ( "temp" ) ) ) ) ) ) , 
                                 %emptyStmt ) , 
                           %exp ( %bop ( %assign , %var ( "y" ) , %mem ( %var ( "y" ) , %con ( "next" ) ) ) ) )
                  ,                         // dummy
                    %labelContinue ( "" )   // dummy
                  )                         // dummy
           )
  =>
    @Normal
  ...</k>
  requires sorted(L1a @ StringSeqItem(V)) orBool C1 =/=K false
  ensures  (sorted(?L2) orBool ?C2 =/=K false)
   andBool list2set(L1a) U list2set(L1b) U { V } ==K list2set(?L2)


rule [outer-loop-inv]:
  <lexicalEnv> @e(E:Int) </lexicalEnv>
  <lastNonEmptyValue> _:Val => ?_:Val </lastNonEmptyValue>
  <envs>...
    <env>
      <eid> @e(E) </eid>
      <outer> _:Eid </outer>
      <strict> _:Bool </strict>
      <declEnvRec>...
        "x"      |-> @ve(X:NullableObject ,                     true, true, false)
        "change" |-> @ve(C:Bool           => ?_:Bool,           true, true, false)
        "y"      |-> @ve(_:NullableObject => ?_:NullableObject, true, true, false)
        "temp"   |-> @ve(_:String         => ?_:String,         true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(X, @NullVal)(L1:StringSeq)
    =>
      lseg(X, @NullVal)(?L2:StringSeq)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %var ( "change" ) , 
             %seq (                         // dummy
                    %seq ( %exp ( %bop ( %assign , %var ( "change" ) , %con ( false ) ) ) , 
                    %seq ( %exp ( %bop ( %assign , %var ( "y" ) , %var ( "x" ) ) ) , 
                           %label ( "" , 
    // inner loop start
    %while ( %bop ( %neqs , %mem ( %var ( "y" ) , %con ( "next" ) ) , %con ( %null ) ) , 
                    %seq ( %if ( %bop ( %gt , %mem ( %var ( "y" ) , %con ( "value" ) ) , %mem ( %mem ( %var ( "y" ) , %con ( "next" ) ) , %con ( "value" ) ) ) ,
                                 %seq ( %exp ( %bop ( %assign , %var ( "change" ) , %con ( true ) ) ) , 
                                 %seq ( %exp ( %bop ( %assign , %var ( "temp" ) , %mem ( %var ( "y" ) , %con ( "value" ) ) ) ) ,
                                 %seq ( %exp ( %bop ( %assign , %mem ( %var ( "y" ) , %con ( "value" ) ) , %mem ( %mem ( %var ( "y" ) , %con ( "next" ) ) , %con ( "value" ) ) ) ) , 
                                        %exp ( %bop ( %assign , %mem ( %mem ( %var ( "y" ) , %con ( "next" ) ) , %con ( "value" ) ) , %var ( "temp" ) ) ) ) ) ) , 
                                 %emptyStmt ) , 
                           %exp ( %bop ( %assign , %var ( "y" ) , %mem ( %var ( "y" ) , %con ( "next" ) ) ) ) )
           )
    // inner loop end
                                  ) ) )
                  ,                         // dummy
                    %labelContinue ( "" )   // dummy
                  )                         // dummy
           ) 
  =>
    @Normal
  ...</k>
  requires X =/=K @NullVal
   andBool (sorted(L1) orBool C =/=K false)
  ensures  sorted(?L2)
   andBool list2set(L1) ==K list2set(?L2)


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
      @o(2), // %var("bubble_sort"),
      Undefined,
      @Cons(X1:NullableObject, @Nil))
  =>
    ?X2:NullableObject
  ...</k>
  ensures  sorted(?L2)
   andBool list2set(L1) ==K list2set(?L2)

endmodule

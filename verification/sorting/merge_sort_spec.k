require "../patterns/list/js-verifier.k"

module MERGESORT-SPEC
imports JS-VERIFIER

rule [first-loop-inv]:
  <lexicalEnv> @e(E:Int) </lexicalEnv>
  <lastNonEmptyValue> _:Val => ?_:Val </lastNonEmptyValue>
  <envs>...
    <env>
      <eid> @e(E) </eid>
      <outer> _:Eid </outer>
      <strict> _:Bool </strict>
      <declEnvRec>...
        "x" |-> @ve(X:NullableObject => @NullVal,          true, true, false)
        "y" |-> @ve(@o(Y1:Int)       => @o(?Y2:Int),       true, true, false)
        "z" |-> @ve(@o(Z1:Int)       => @o(?Z2:Int),       true, true, false)
        // dummy
        "p" |-> @ve(_:NullableObject,                      true, true, false)
        "t" |-> @ve(_:NullableObject => ?_:NullableObject, true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(X,@NullVal)(A:List)
      lseg(@o( Y1),@NullVal)( B1:List)
      lseg(@o( Z1),@NullVal)( C1:List)
    =>
      lseg(@o(?Y2),@NullVal)(?B2:List)
      lseg(@o(?Z2),@NullVal)(?C2:List)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %neqs , %var ( "x" ) , %con ( %null ) ) , 
             %seq (                         // dummy
                    %seq ( %exp ( %bop ( %assign , %var ( "t" ) , %var ( "x" ) ) ) , 
                    %seq ( %exp ( %bop ( %assign , %var ( "x" ) , %mem ( %var ( "x" ) , %con ( "next" ) ) ) ) , 
                    %seq ( %exp ( %bop ( %assign , %mem ( %var ( "t" ) , %con ( "next" ) ) , %var ( "y" ) ) ) , 
                    %seq ( %exp ( %bop ( %assign , %var ( "y" ) , %var ( "t" ) ) ) , 
                           %if ( %bop ( %neqs , %var ( "x") , %con ( %null ) ) , 
                                 %seq ( %exp ( %bop ( %assign , %var ( "t" ) , %var ( "x" ) ) ) , 
                                 %seq ( %exp ( %bop ( %assign , %var ( "x" ) , %mem ( %var ( "x" ) , %con ( "next" ) ) ) ) , 
                                 %seq ( %exp ( %bop ( %assign , %mem ( %var ( "t" ) , %con ( "next" ) ) , %var ( "z" ) ) ) , 
                                        %exp ( %bop ( %assign , %var ( "z" ) , %var ( "t" ) ) ) ) ) ) , 
                                 %emptyStmt ) ) ) ) )
                  ,                         // dummy
                    %labelContinue ( "" )   // dummy
                  )                         // dummy
           )
  =>
    @Normal
  ...</k>
  ensures list2set(A) U list2set(B1) U list2set(C1) ==K list2set(?B2) U list2set(?C2)
[trusted]


rule [second-loop-inv]:
  <lexicalEnv> @e(E:Int) </lexicalEnv>
  <lastNonEmptyValue> _:Val => ?_:Val </lastNonEmptyValue>
  <envs>...
    <env>
      <eid> @e(E) </eid>
      <outer> _:Eid </outer>
      <strict> _:Bool </strict>
      <declEnvRec>...
        "x" |-> @ve(X :NullableObject,                       true, true, false)
        "y" |-> @ve(Y1:NullableObject => ?Y2:NullableObject, true, true, false)
        "z" |-> @ve(Z1:NullableObject => ?Z2:NullableObject, true, true, false)
        "p" |-> @ve(@o(P1:Int)        => @o(?P2:Int),        true, true, false)
        // dummy
        "t" |-> @ve(_:NullableObject,                        true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg( X, @o(P1)  )( LX1:List)
      <obj>
        <oid> @o(P1) </oid>
        <properties>
          "value" |-> @desc("Value" |-> V1:String        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> _:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      lseg( Y1,@NullVal)( LY1:List)
      lseg( Z1,@NullVal)( LZ1:List)
    =>
      lseg( X, @o(?P2) )(?LX2:List)
      <obj>
        <oid> @o(?P2) </oid>
        <properties>
          "value" |-> @desc("Value" |-> ?V2:String        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> ?_:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      lseg(?Y2,@NullVal)(?LY2:List)
      lseg(?Z2,@NullVal)(?LZ2:List)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %and , %bop ( %neqs , %var ( "y" ) , %con ( %null ) ) , %bop ( %neqs , %var ( "z" ) , %con ( %null ) ) ) , 
             %seq (                         // dummy
                    %seq ( %if ( %bop ( %lt , %mem ( %var ( "y" ) , %con ( "value" ) ) , %mem ( %var ( "z" ) , %con ( "value" ) ) ) , 
                                 %seq ( %exp ( %bop ( %assign , %mem ( %var ( "p" ) , %con ( "next" ) ) , %var ( "y" ) ) ) , 
                                        %exp ( %bop ( %assign , %var ( "y" ) , %mem ( %var ( "y" ) , %con ( "next" ) ) ) ) ) , 
                                 %seq ( %exp ( %bop ( %assign , %mem ( %var ( "p" ) , %con ( "next" ) ) , %var ( "z" ) ) ) , 
                                        %exp ( %bop ( %assign , %var ( "z" ) , %mem ( %var ( "z" ) , %con ( "next" ) ) ) ) ) ) , 
                           %exp ( %bop ( %assign , %var ( "p" ) , %mem ( %var ( "p" ) , %con ( "next" ) ) ) ) ) 
                  ,                         // dummy
                    %labelContinue ( "" )   // dummy
                  )                         // dummy
           )
  =>
    @Normal
  ...</k>
  requires sorted(LX1 ListItem(V1)) andBool sorted(LY1) andBool sorted(LZ1)
   andBool list2set(LX1) U {V1} <=StringSet list2set(LY1) U list2set(LZ1)
  ensures  sorted(?LX2 ListItem(?V2)) andBool sorted(?LY2) andBool sorted(?LZ2)
   andBool list2set(?LX2) U {?V2} <=StringSet list2set(?LY2) U list2set(?LZ2)
           /*
   andBool sorted(?LX2 ListItem(?V2) ?LY2 ?LZ2)
   andBool list2set(LX1) U {V1} U list2set(LY1) U list2set(LZ1) ==K
           list2set(?LX2 ListItem(?V2) ?LY2 ?LZ2)
           */
   andBool 
   (
     ( ?Z2 ==K @NullVal
       andBool sorted(?LX2 ListItem(?V2) ?LY2)
       andBool list2set(LX1) U {V1} U list2set(LY1) U list2set(LZ1) ==K
               list2set(?LX2 ListItem(?V2) ?LY2)
     )
     orBool 
     ( ?Y2 ==K @NullVal
       andBool sorted(?LX2 ListItem(?V2) ?LZ2)
       andBool list2set(LX1) U {V1} U list2set(LY1) U list2set(LZ1) ==K
               list2set(?LX2 ListItem(?V2) ?LZ2)
     )
   )
  [trusted] 


rule [func-spec]:
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg( X1,@NullVal)( L1:List)
    =>
      lseg(?X2,@NullVal)(?L2:List)
    )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(2), // %var("merge_sort"),
      Undefined,
      @Cons(X1:NullableObject, @Nil))
  =>
    ?X2:NullableObject
  ...</k>
  ensures  sorted(?L2)
   andBool list2set(L1) ==K list2set(?L2)
  [trusted] 

endmodule

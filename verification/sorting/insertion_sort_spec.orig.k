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
        "z" |-> @ve(@o(Z:Int) => ?_:NullableObject, true, true, false)
        "n" |-> @ve(@o(N:Int),                      true, true, false)
        "x" |-> @ve(_:NullableObject,               true, true, false)
        "y" |-> @ve(Y:NullableObject,               true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (
      lseg(Y, @o(Z))(L1a:List)
      <obj>
        <oid> @o(Z) </oid>
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
      lseg(O, @NullVal)(L1b:List)
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
    =>
      lseg(Y, @NullVal)(?L2:List)
    )
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
    ~>
    //( #freezer 
    %seq ( HOLE ,
           %labelBreak ( "" )
         )
    //)(.KList)
    ~>
    //( #freezer 
    %seq ( HOLE ,
           %seq ( %exp ( %bop ( %assign , %mem ( %var ( "n" ) , %con ( "next" ) ) , %mem ( %var ( "z" ) , %con ( "next" ) ) ) ) , 
                  %exp ( %bop ( %assign , %mem ( %var ( "z" ) , %con ( "next" ) ) , %var ( "n" ) ) ) )
         )
    //)(.KList)
/*
    '%while(_,_)('%bop(_,_,_)('%and(.KList),, '%bop(_,_,_)('%neqs(.KList),, '%mem(_,_)('%var(_)(String(#""z"")),, '%con(_)(String(#""next""))),, '%con(_)('%null(.KList))),, 
                                              '%bop(_,_,_)('%lt(.KList),, '%mem(_,_)('%mem(_,_)('%var(_)(String(#""z"")),, '%con(_)(String(#""next""))),, '%con(_)(String(#""value""))),, '%mem(_,_)('%var(_)(String(#""n"")),, '%con(_)(String(#""value""))))),,
                 '%seq(_,_)(
                             '%exp(_)('%bop(_,_,_)('%assign(.KList),, '%var(_)(String(#""z"")),, '%mem(_,_)('%var(_)(String(#""z"")),, '%con(_)(String(#""next"")))))
                           ,, 
                             '%labelContinue(_)(String(#""""))
                           )
                )
    ~> (# '%seq(_,_)(HOLE,, '%labelBreak(_)(String(#""""))))(.KList)
    ~> (# '%seq(_,_)(HOLE,, '%seq(_,_)('%exp(_)('%bop(_,_,_)('%assign(.KList),, '%mem(_,_)('%var(_)(String(#""n"")),, '%con(_)(String(#""next""))),, '%mem(_,_)('%var(_)(String(#""z"")),, '%con(_)(String(#""next""))))),, 
                                       '%exp(_)('%bop(_,_,_)('%assign(.KList),, '%mem(_,_)('%var(_)(String(#""z"")),, '%con(_)(String(#""next""))),, '%var(_)(String(#""n"")))))))(.KList)
*/
  =>
    @Normal
  ...</k>
  requires sorted(L1a ListItem(V) L1b) andBool V <String NV
  ensures  sorted(?L2)
   andBool list2set(L1a) U list2set(L1b) U { V } U { NV } ==K list2set(?L2)


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
      lseg(Y1, @NullVal)(L1a:List)
      lseg(X,  @NullVal)(L1b:List)
    =>
      lseg(?Y2,@NullVal)(?L2:List)
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
    (lseg(X1,@NullVal)(L1:List) => lseg(?X2,@NullVal)(?L2:List))
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

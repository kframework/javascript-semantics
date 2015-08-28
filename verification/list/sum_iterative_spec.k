require "../patterns/list/js-verifier.k"

module SUM-ITERATIVE-SPEC
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
        "x" |-> @ve(X:NullableObject  => @NullVal,            true, true, false)
        "s" |-> @ve(S:String          => S +String sum(L),    true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    list(X)(L:StringSeq)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %neqs , %var ( "x" ) , %con ( %null) ) , 
             %seq ( 
                    %seq ( %exp ( %bop ( %assign , %var ( "s" ) , %bop ( %plus , %var ( "s" ) , %mem ( %var ( "x" ) , %con ( "value" ) ) ) ) ) , 
                           %exp ( %bop ( %assign , %var ( "x" ) , %mem ( %var ( "x" ) , %con ( "next" ) ) ) ) )
                  ,
                    %labelContinue ( "" )  // dummy
                  )
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
    list(X)(L:StringSeq)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      @o(16), // %var("sum_iterative"),
      Undefined,
      @Cons(X:NullableObject, @Nil)
    )
  =>
    sum(L)
  ...</k>

endmodule

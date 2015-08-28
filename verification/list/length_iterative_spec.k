require "../patterns/list/js-verifier.k"

module LENGTH-ITERATIVE-SPEC
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
        "y" |-> @ve(Y:Int             => Y +Int size(L),      true, true, false)
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
                    %seq ( %exp ( %bop ( %assign , %var ( "y" ) , %bop ( %plus , %var ( "y" ) , %con ( 1 ) ) ) ) , 
                           %exp ( %bop ( %assign , %var ( "x" ) , %mem ( %var ( "x" ) , %con ( "next" ) ) ) ) )
                  ,
                    %labelContinue ( "" )  // dummy
                  )
           )
  =>
    @Normal
  ...</k>
  requires Y +Int size(L) <Int @MAX_INT
   andBool Y >=Int 0

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
      @o(12), // %var("length_iterative"),
      Undefined,
      @Cons(X:NullableObject, @Nil)
    )
  =>
    size(L)
  ...</k>
  requires size(L) <Int (@MAX_INT -Int 1)

endmodule

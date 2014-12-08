require "../../js.k"

module REVERSE-SPEC
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
    <pseudoStack> PSEUDOSTACK:List </pseudoStack>
  </ctrl>
  <envs>...
    <env>
      <eid> EID </eid>
      <outer> _:Eid </outer>
      <strict> false </strict>
      <declEnvRec>...
        "x" |-> @ve(OX:NullableObject  => @NullVal,            true, true, false)
        "p" |-> @ve(OP1:NullableObject => ?OP2:NullableObject, true, true, false)
        "y" |-> @ve(_:Val              => ?_:Val,              true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    OBJS:Bag
    (list(OX)(B:List) list(OP1)(C:List) => list(?OP2)(rev(B) C))
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %neqs , %var ( "x" ) , %con ( %null ) ) , %seq ( %seq ( %exp ( %bop ( %assign , %var ( "y" ) , %mem ( %var ( "x" ) , %con ( "next" ) ) ) ) , %seq ( %exp ( %bop ( %assign , %mem ( %var ( "x" ) , %con ( "next" ) ) , %var ( "p" ) ) ) , %seq ( %exp ( %bop ( %assign , %var ( "p" ) , %var ( "x" ) ) ) , %exp ( %bop ( %assign , %var ( "x" ) , %var ( "y" ) ) ) ) ) ) , %labelContinue ( "" )) )
  =>
    @Normal
  ...</k>
  requires EID =/=K @NullEid

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
    <pseudoStack> PSEUDOSTACK:List </pseudoStack>
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
    (list(O1)(A:List) => list(?O2)(rev(A)))
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %call(%var("reverse"), @Cons(O1:NullableObject, @Nil))
  =>
    ?O2:NullableObject
  ...</k>

endmodule


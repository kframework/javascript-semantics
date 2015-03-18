require "../patterns/list/js-verifier.k"

module REVERSE-SPEC
imports JS-VERIFIER

rule [loop-inv]:
  <lexicalEnv> @e(I:Int) </lexicalEnv>
  <lastNonEmptyValue> _:Val => ?_:Val </lastNonEmptyValue>
  <envs>...
    <env>
      <eid> @e(I) </eid>
      <outer> _:Eid </outer>
      <strict> _:Bool </strict>
      <declEnvRec>...
        "x" |-> @ve(OX:NullableObject  => @NullVal,            true, true, false)
        "p" |-> @ve(OP1:NullableObject => ?OP2:NullableObject, true, true, false)
        "y" |-> @ve(_:Val              => ?_:Val,              true, true, false)
      ...</declEnvRec>
    </env>
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (list(OX)(B:List) list(OP1)(C:List) => list(?OP2)(rev(B) C))
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %while ( %bop ( %neqs , %var ( "x" ) , %con ( %null ) ) , %seq ( %seq ( %exp ( %bop ( %assign , %var ( "y" ) , %mem ( %var ( "x" ) , %con ( "next" ) ) ) ) , %seq ( %exp ( %bop ( %assign , %mem ( %var ( "x" ) , %con ( "next" ) ) , %var ( "p" ) ) ) , %seq ( %exp ( %bop ( %assign , %var ( "p" ) , %var ( "x" ) ) ) , %exp ( %bop ( %assign , %var ( "x" ) , %var ( "y" ) ) ) ) ) ) , %labelContinue ( "" )) )
  =>
    @Normal
  ...</k>

rule [func-spec]:
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (list(O1)(A:List) => list(?O2)(rev(A)))
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("reverse"),
      @o(18),
      Undefined,
      @Cons(O1:NullableObject, @Nil))
  =>
    ?O2:NullableObject
  ...</k>
endmodule


require "../../js.k"

module BST-SPEC
imports JS

rule
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
      <eid> EID </eid>
      <outer> @GlobalEid </outer>
      <strict> false </strict>
      <declEnvRec> Record:Map </declEnvRec>
    </env>
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
  <in> IN:List </in>
  <out> OUT:List </out>
  <log> LOG:List </log>
  <objs>...
    OBJS:Bag
    float_tree(O)(T:FloatTree)
  =>
    OBJS:Bag
    float_tree(O)(T:FloatTree)
    ?_:Bag
  ...</objs>
  <k>
    %call(
      %var("find"),
      @Cons(V:Float{exponent(11), significand(53)}, @Cons(O:NullableObject, @Nil)))
  =>
    V inFloatSet float_tree_keys(T)
  ...</k>
  requires ("find" in keys(Record) ==K false) andBool (EID =/=K @NullEid) andBool float_bst(T) andBool (notBool isNaN(V)) 
endmodule


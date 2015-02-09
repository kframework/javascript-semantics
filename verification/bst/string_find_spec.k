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
    <pseudoCtx>
      <pseudoStack> _:List </pseudoStack>
      <pseudoEnv> PSEUDOENV:Map </pseudoEnv>
    </pseudoCtx>
  </ctrl>
  <envs>...
    <env>
      <eid> EID </eid>
      <outer> @GlobalEid </outer>
      <strict> STRICT1:Bool </strict>
      <declEnvRec> Record:Map </declEnvRec>
    </env>
    <env>
      <eid> @GlobalEid </eid>
      <outer> @NullEid </outer>
      <strict> STRICT0:Bool </strict>
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
    string_tree(O)(T:StringTree)(_:Oid)
  (.Bag => ?_:Bag)
  ...</objs>
  <k>
    %call(
      %var("find"),
      @Cons(V:String, @Cons(O:NullableObject, @Nil)))
  =>
    V inStringSet string_tree_keys(T)
  ...</k>
  requires ("find" in keys(Record) ==K false) andBool (EID =/=K @NullEid) andBool string_bst(T)
endmodule

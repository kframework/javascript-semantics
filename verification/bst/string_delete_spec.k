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
    string_tree(O)(T:StringTree)(P:Oid)
  =>
    OBJS:Bag
    string_tree(O)(T:StringTree)(P:Oid)
    ?_:Bag
  ...</objs>
  <k>
    Call(
      // %var("find_min"),
      @o(2), Undefined,
      @Cons(O:Oid, @Nil))
  =>
    ?M:String
  ...</k>
  requires ("find_min" in keys(Record) ==K false) andBool (EID =/=K @NullEid) andBool string_bst(T)
  ensures (?M inStringSet string_tree_keys(T)) andBool ({ ?M } <=StringSet string_tree_keys(T))

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
    string_tree(O1)(T1:StringTree)(P:Oid)
  =>
    OBJS:Bag
    string_tree(?O2)(?T2:StringTree)(P:Oid)
    ?_:Bag
  ...</objs>
  <k>
    Call(
      // %var("remove"),
      @o(4), Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires ("remove" in keys(Record) ==K false) andBool ("find_min" in keys(Record) ==K false) andBool (EID =/=K @NullEid) andBool string_bst(T1)
  ensures string_bst(?T2) andBool string_tree_keys(?T2) ==K string_tree_keys(T1) -StringSet { V }
endmodule


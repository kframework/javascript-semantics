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
    %call(%var("find_min"), @Cons(O:Oid, @Nil))
  =>
    ?M:Float{exponent(11), significand(53)}
  ...</k>
  requires ("find_min" in keys(Record) ==K false) andBool (EID =/=K @NullEid) andBool float_bst(T)
  ensures (?M inFloatSet float_tree_keys(T)) andBool ({ ?M } <=FloatSet float_tree_keys(T)) andBool (notBool isNaN(?M))

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
    float_tree(O1)(T1:FloatTree)
  =>
    OBJS:Bag
    float_tree(?O2)(?T2:FloatTree)
    ?_:Bag
  ...</objs>
  <k>
    %call(
      %var("remove"),
      @Cons(V:Float{exponent(11), significand(53)}, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires ("remove" in keys(Record) ==K false) andBool ("find_min" in keys(Record) ==K false) andBool (EID =/=K @NullEid) andBool float_bst(T1) andBool (notBool isNaN(V))
  ensures float_bst(?T2) andBool float_tree_keys(?T2) ==K float_tree_keys(T1) -FloatSet { V }
endmodule


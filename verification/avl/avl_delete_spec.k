require "../../js.k"

module AVL-SPEC
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
  =>
    OBJS:Bag
    ?_:Bag
  ...</objs>
  <k>
    Call(
      // %var("max"),
      @o(4), Undefined,
      @Cons(X:Int, @Cons(Y:Int, @Nil)))
  =>
    maxInt(X,Y)
  ...</k>
  requires ("max" in keys(Record) ==K false) andBool (EID =/=K @NullEid)
    andBool
    (X <Int 4294967296) andBool (Y <Int 4294967296) andBool (X >Int -4294967296) andBool (Y >Int -4294967296)

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
    string_htree(O)(T:StringTree)
  =>
    OBJS:Bag
    string_htree(O)(T:StringTree)
    ?_:Bag
  ...</objs>
  <k>
    Call(
      // %var("height"),
      @o(6), Undefined,
      @Cons(O:NullableObject, @Nil))
  =>
    string_tree_height(T)
  ...</k>
  requires ("height" in keys(Record) ==K false) andBool (EID =/=K @NullEid)
    andBool string_avl(T)
    andBool (string_tree_height(T) <Int 4294967296 )

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
    <obj>
      <oid> O </oid>
      <properties>
        "value"  |-> @desc("Value" |-> S:String                                                                                           "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "height" |-> @desc((("Value" |-> _:Int) => ("Value" |-> string_tree_height(string_node(S:String, TL:StringTree, TR:StringTree)))) "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "left"   |-> @desc("Value" |-> OL:NullableObject                                                                                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "right"  |-> @desc("Value" |-> OR:NullableObject                                                                                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
      </properties>
      <internalProperties>
        "Class"      |-> "Object"
        "Extensible" |-> true
        "Prototype"  |-> @ObjectProtoOid
      </internalProperties>
    </obj>
    string_htree(OL)(TL:StringTree)
    string_htree(OR)(TR:StringTree)
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("update_height"),
      @o(8), Undefined,
      @Cons(O:Oid, @Nil))
  =>
    Undefined
  ...</k>
  requires ("update_height" in keys(Record) ==K false) andBool (EID =/=K @NullEid)
    andBool (string_avl(TL))
    andBool (string_avl(TR))
    andBool (string_tree_height(TL) <Int (4294967296 -Int 1))
    andBool (string_tree_height(TR) <Int (4294967296 -Int 1))

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
    string_htree(O)(T:StringTree)
  =>
    OBJS:Bag
    string_htree(O)(T:StringTree)
    ?_:Bag
  ...</objs>
  <k>
    Call(
      // %var("find_min"),
      @o(10), Undefined,
      @Cons(O:Oid, @Nil))
  =>
    ?M:String
  ...</k>
  requires ("find_min" in keys(Record) ==K false) andBool (EID =/=K @NullEid) andBool string_avl(T)
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
    string_htree(O1)(T1:StringTree)
  =>
    OBJS:Bag
    string_htree(?O2)(?T2:StringTree)
    ?_:Bag
  ...</objs>
  <k>
    Call(
      // %var("remove"),
      @o(22), Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires ("remove" in keys(Record) ==K false) andBool (EID =/=K @NullEid) andBool string_avl(T1)
    andBool (string_tree_height(T1) <Int (4294967296 ))
  ensures string_avl(?T2) andBool string_tree_keys(?T2) ==K string_tree_keys(T1) -StringSet { V }
    andBool string_tree_height(T1) -Int 1 <=Int  string_tree_height(?T2)
    andBool string_tree_height(?T2) <=Int string_tree_height(T1)
endmodule


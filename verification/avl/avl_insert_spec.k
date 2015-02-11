
module AVL-SPEC

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("max"),
      @o(3),
      Undefined,
      @Cons(X:Int, @Cons(Y:Int, @Nil)))
  =>
    maxInt(X,Y)
  ...</k>
  requires (X <Int 4294967296) andBool (Y <Int 4294967296) andBool (X >Int -4294967296) andBool (Y >Int -4294967296)

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    string_htree(O)(T:StringTree)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("height"),
      @o(5),
      Undefined,
      @Cons(O:NullableObject, @Nil))
  =>
    string_tree_height(T)
  ...</k>
  requires string_avl(T) andBool (string_tree_height(T) <Int 4294967296)

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    <obj>
      <oid> O </oid>
      <properties>
        "value"  |-> @desc("Value" |-> S:String                                                                                                                                     "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "height" |-> @desc((("Value" |-> _:Int) => ("Value" |-> string_tree_height(string_node(S:String, TL:StringTree, TR:StringTree)))) "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "left"   |-> @desc("Value" |-> OL:NullableObject                                                                                                                             "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "right"  |-> @desc("Value" |-> OR:NullableObject                                                                                                                             "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
      </properties>
      <internalProperties>
        "Class"      |-> "Object"
        "Extensible" |-> true
        "Prototype"  |-> @ObjectProtoOid
      </internalProperties>
    </obj>
    string_htree(OL)(TL:StringTree)
    string_htree(OR)(TR:StringTree)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("update_height"),
      @o(7),
      Undefined,
      @Cons(O:Oid, @Nil))
  =>
    Undefined
  ...</k>
  requires (string_avl(TL)) andBool (string_avl(TR))
    andBool (string_tree_height(TL) <Int (4294967296 -Int 1))
    andBool (string_tree_height(TR) <Int (4294967296 -Int 1))

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
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
      // %var("insert"),
      @o(19),
      Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires string_avl(T1) andBool (string_tree_height(T1) <Int (4294967296 -Int 1))
  ensures string_avl(?T2) andBool string_tree_keys(?T2) ==K { V } U string_tree_keys(T1)
    andBool string_tree_height(T1) <=Int  string_tree_height(?T2)
    andBool string_tree_height(?T2) <=Int string_tree_height(T1) +Int 1
endmodule


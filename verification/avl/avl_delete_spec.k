require "../patterns/tree_string/js-verifier.k"

module AVL-SPEC
imports JS-VERIFIER

rule
  <k>
    MakeFullyPopulatedDataDescriptor2(@desc("Value" |-> V:Val), @desc("Value" |-> _:Val "Writable" |-> W:Bool "Enumerable" |-> E:Bool "Configurable" |-> C:Bool))
  =>
    @desc("Value" |-> V:Val "Writable" |-> W:Bool "Enumerable" |-> E:Bool "Configurable" |-> C:Bool)
  ...</k>

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
      @o(4),
      Undefined,
      @Cons(X:Int, @Cons(Y:Int, @Nil)))
  =>
    maxInt(X,Y)
  ...</k>
  requires (X <Int @MAX_INT) andBool (Y <Int @MAX_INT) andBool (X >Int @MIN_INT) andBool (Y >Int @MIN_INT)

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    htree(O)(T:StringTree)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("height"),
      @o(6),
      Undefined,
      @Cons(O:NullableObject, @Nil))
  =>
    tree_height(T)
  ...</k>
  requires avl(T) andBool (tree_height(T) <Int @MAX_INT)

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    <obj>
      <oid> O </oid>
      <properties>
        "value"  |-> @desc("Value" |-> S:String                                                                             "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "height" |-> @desc((("Value" |-> _:Int) => ("Value" |-> tree_height(node(S:String, TL:StringTree, TR:StringTree)))) "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "left"   |-> @desc("Value" |-> OL:NullableObject                                                                    "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        "right"  |-> @desc("Value" |-> OR:NullableObject                                                                    "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
      </properties>
      <internalProperties>
        "Class"      |-> "Object"
        "Extensible" |-> true
        "Prototype"  |-> @ObjectProtoOid
      </internalProperties>
    </obj>
    htree(OL)(TL:StringTree)
    htree(OR)(TR:StringTree)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("update_height"),
      @o(8),
      Undefined,
      @Cons(O:Oid, @Nil))
  =>
    Undefined
  ...</k>
  requires avl(TL) andBool avl(TR)
    andBool (tree_height(TL) <Int (@MAX_INT -Int 1))
    andBool (tree_height(TR) <Int (@MAX_INT -Int 1))

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    htree(O)(T:StringTree)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("find_min"),
      @o(10),
      Undefined,
      @Cons(O:Oid, @Nil))
  =>
    ?M:String
  ...</k>
  requires avl(T)
  ensures (?M inStringSet tree_keys(T)) andBool ({ ?M } <=StringSet tree_keys(T))

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (htree(O1)(T1:StringTree) => htree(?O2)(?T2:StringTree))
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("remove"),
      @o(22),
      Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires avl(T1) andBool (tree_height(T1) <Int @MAX_INT)
  ensures avl(?T2) andBool tree_keys(?T2) ==K tree_keys(T1) -StringSet { V }
    andBool tree_height(T1) -Int 1 <=Int  tree_height(?T2)
    andBool tree_height(?T2) <=Int tree_height(T1)
endmodule


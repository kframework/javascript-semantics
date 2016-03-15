require "../patterns/tree_color/js-verifier.k"

module RBT-INSERT-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    ctree(O)(T:CTree)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("color"),
      @o(4),
      Undefined,
      @Cons(O:NullableObject, @Nil))
  =>
    ctree_color(T)
  ...</k>
ensures ctree_color(T) ==K 1 orBool ctree_color(T) ==K 0

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
  (
    ctree(O1)(T1:CTree)
  =>
    ctree(@o(?O2))(cnode(?I2:String,?C2:Int,?L2:CTree,?R2:CTree))
  )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("insert_aux"),
      @o(12),
      Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    @o(?O2:Int)
  ...</k>
requires rbt(T1)
ensures rbt(?L2) andBool rbt(?R2)
  andBool ctree_keys(?L2) <StringSet { ?I2 } andBool { ?I2 } <StringSet ctree_keys(?R2)
  andBool ctree_height(?L2) ==Int ctree_height(?R2)
  andBool ( ?C2 ==K 1 orBool ?C2 ==K 0 )
  andBool (
            ?C2 ==K 1
          orBool
            (
              ( ctree_color(?L2) ==K 1 andBool ctree_color(?R2) ==K 1 )
            orBool
              ( 
                ctree_color(T1) =/=K 1
              andBool
                ( ctree_color(?L2) ==K 1 orBool ctree_color(?R2) ==K 1 )
              )
            )
          )
  andBool ctree_keys(cnode(?I2,?C2,?L2,?R2)) ==K { V } U ctree_keys(T1)
  andBool ctree_height(T1) ==Int ctree_height(cnode(?I2,?C2,?L2,?R2))

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
  (
    ctree(O1)(T1:CTree)
  =>
    ctree(?O2)(?T2:CTree)
  )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("insert"),
      @o(14),
      Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
requires rbt(T1)
ensures rbt(?T2)
  andBool ctree_keys(?T2) ==K { V } U ctree_keys(T1)
  andBool ctree_height(T1) <=Int ctree_height(?T2)
  andBool ctree_height(?T2) <=Int ctree_height(T1) +Int 1

endmodule

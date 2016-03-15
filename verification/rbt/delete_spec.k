require "../patterns/tree_color/js-verifier.k"

module RBT-DELETE-SPEC
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
    ctree(@o(O))(T:CTree)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("find_min"),
      @o(6),
      Undefined,
      @Cons(@o(O:Int), @Nil))
  =>
    ?M:String
  ...</k>
requires rbt(T)
ensures ?M inStringSet ctree_keys(T) andBool { ?M } <=StringSet ctree_keys(T)

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    <obj>
      <oid> @o(CTX) </oid>
      <properties>
        "fixed" |-> @desc((("Value" |-> F1:Int) => ("Value" |-> ?F2:Int)) "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
      </properties>
      <internalProperties>
        "Class"      |-> "Object"
        "Extensible" |-> true
        "Prototype"  |-> @ObjectProtoOid
      </internalProperties>
    </obj>
  (
    ctree(@o( O1))(cnode( I1:String, C1:Int, L1:CTree,cnode(RI1:String,RC1:Int,RL1:CTree,RR1:CTree)))
  =>
    ctree(@o(?O2))(cnode(?I2:String,?C2:Int,?L2:CTree,?R2:CTree))
  )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("left_remove_fixup"),
      @o(12),
      Undefined,
      @Cons(@o(CTX:Int), @Cons(@o(O1:Int), @Nil)))
  =>
    @o(?O2:Int)
  ...</k>
requires F1 =/=K 1
  andBool rbt(L1) andBool rbt(cnode(RI1,RC1,RL1,RR1))
  andBool ctree_keys(L1) <StringSet { I1 } andBool { I1 } <StringSet ctree_keys(cnode(RI1,RC1,RL1,RR1))
  andBool ctree_height(L1) ==Int ctree_height(cnode(RI1,RC1,RL1,RR1)) -Int 1
  andBool ctree_color(L1) ==K 1 andBool ( C1 ==K 1 orBool RC1 ==K 1 )
  andBool ( C1 ==K 1 orBool C1 ==K 0 )
ensures rbt(cnode(?I2,?C2,?L2,?R2))
  andBool ctree_keys(cnode(?I2,?C2,?L2,?R2)) ==K ctree_keys(cnode(I1,C1,L1,cnode(RI1,RC1,RL1,RR1)))
  andBool (
            ?C2 ==K 1
          orBool
            ?C2 ==K C1
          )
  andBool (
            (
              ?F2 ==K 1
            andBool ctree_height(cnode(?I2,?C2,?L2,?R2)) ==Int ctree_height(L1) +Int C1 +Int 1
            )
          orBool
            (
              ?F2 =/=K 1
            andBool C1 ==K 1
            andBool ?C2 ==K 1
            andBool ctree_height(cnode(?I2,?C2,?L2,?R2)) ==Int ctree_height(L1) +Int C1
            )
          )
  andBool ( C1 =/=K 1 impliesBool ?F2 ==K 1 )

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    <obj>
      <oid> @o(CTX) </oid>
      <properties>
        "fixed" |-> @desc((("Value" |-> F1:Int) => ("Value" |-> ?F2:Int)) "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
      </properties>
      <internalProperties>
        "Class"      |-> "Object"
        "Extensible" |-> true
        "Prototype"  |-> @ObjectProtoOid
      </internalProperties>
    </obj>
  (
    ctree(@o( O1))(cnode( I1:String, C1:Int,cnode(LI1:String,LC1:Int,LL1:CTree,LR1:CTree), R1:CTree))
  =>
    ctree(@o(?O2))(cnode(?I2:String,?C2:Int,?L2:CTree,                                    ?R2:CTree))
  )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("right_remove_fixup"),
      @o(14),
      Undefined,
      @Cons(@o(CTX:Int), @Cons(@o(O1:Int), @Nil)))
  =>
    @o(?O2:Int)
  ...</k>
requires F1 =/=K 1
  andBool rbt(cnode(LI1,LC1,LL1,LR1)) andBool rbt(R1)
  andBool ctree_keys(cnode(LI1,LC1,LL1,LR1)) <StringSet { I1 } andBool { I1 } <StringSet ctree_keys(R1)
  andBool ctree_height(R1) ==Int ctree_height(cnode(LI1,LC1,LL1,LR1)) -Int 1
  andBool ctree_color(R1) ==K 1 andBool ( C1 ==K 1 orBool LC1 ==K 1 )
  andBool ( C1 ==K 1 orBool C1 ==K 0 )
ensures rbt(cnode(?I2,?C2,?L2,?R2))
  andBool ctree_keys(cnode(?I2,?C2,?L2,?R2)) ==K ctree_keys(cnode(I1,C1,cnode(LI1,LC1,LL1,LR1),R1))
  andBool (
            ?C2 ==K 1
          orBool
            ?C2 ==K C1
          )
  andBool (
            (
              ?F2 ==K 1
            andBool ctree_height(cnode(?I2,?C2,?L2,?R2)) ==Int ctree_height(R1) +Int C1 +Int 1
            )
          orBool
            (
              ?F2 =/=K 1
            andBool C1 ==K 1
            andBool ?C2 ==K 1
            andBool ctree_height(cnode(?I2,?C2,?L2,?R2)) ==Int ctree_height(R1) +Int C1
            )
          )
  andBool ( C1 =/=K 1 impliesBool ?F2 ==K 1 )

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    <obj>
      <oid> @o(CTX) </oid>
      <properties>
        "fixed" |-> @desc((("Value" |-> F1:Int) => ("Value" |-> ?F2:Int)) "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
      </properties>
      <internalProperties>
        "Class"      |-> "Object"
        "Extensible" |-> true
        "Prototype"  |-> @ObjectProtoOid
      </internalProperties>
    </obj>
  (
    ctree( O1)( T1:CTree)
  =>
    ctree(?O2)(?T2:CTree)
  )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("remove_aux"),
      @o(16),
      Undefined,
      @Cons(@o(CTX:Int), @Cons(V:String, @Cons(O1:NullableObject, @Nil))))
  =>
    ?O2:NullableObject
  ...</k>
requires rbt(T1)
ensures rbt(?T2)
  andBool ctree_keys(?T2) ==K (ctree_keys(T1) -StringSet { V })
  andBool (
            ctree_color(?T2) ==K 1
          orBool
            ctree_color(?T2) ==K ctree_color(T1)
          )
  andBool (
            (
              ?F2 ==K 1
            andBool ctree_height(?T2) ==Int ctree_height(T1)
            )
          orBool
            (
              ?F2 =/=K 1
            andBool ctree_height(?T2) ==Int ctree_height(T1) -Int 1
            andBool ctree_color(?T2) ==K 1
            )
          )

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
  (
    ctree( O1)( T1:CTree)
  =>
    ctree(?O2)(?T2:CTree)
  )
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("remove"),
      @o(18),
      Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
requires rbt(T1)
ensures rbt(?T2)
  andBool ctree_keys(?T2) ==K (ctree_keys(T1) -StringSet { V })
  andBool ctree_height(T1) -Int 1 <=Int ctree_height(?T2)
  andBool ctree_height(?T2) <=Int ctree_height(T1)

endmodule

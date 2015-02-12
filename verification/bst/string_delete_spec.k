require "../patterns/tree_string/js-verifier.k"

module BST-SPEC
imports JS-VERIFIER

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    tree(O)(T:StringTree)(P:Oid)
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("find_min"),
      @o(1),
      Undefined,
      @Cons(O:Oid, @Nil))
  =>
    ?M:String
  ...</k>
  requires bst(T)
  ensures (?M inStringSet tree_keys(T)) andBool ({ ?M } <=StringSet tree_keys(T))

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (tree(O1)(T1:StringTree)(P:Oid) => tree(?O2)(?T2:StringTree)(P:Oid))
    OBJS:Bag
    (.Bag => ?_:Bag)
  ...</objs>
  <k>
    Call(
      // %var("remove"),
      @o(3),
      Undefined,
      @Cons(V:String, @Cons(O1:NullableObject, @Nil)))
  =>
    ?O2:NullableObject
  ...</k>
  requires bst(T1)
  ensures bst(?T2) andBool tree_keys(?T2) ==K tree_keys(T1) -StringSet { V }
endmodule


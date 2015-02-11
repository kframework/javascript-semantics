
module BST-SPEC

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    string_tree(O)(T:StringTree)(P:Oid)
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
  requires string_bst(T)
  ensures (?M inStringSet string_tree_keys(T)) andBool ({ ?M } <=StringSet string_tree_keys(T))

rule
  <envs>...
    ENVS:Bag
    (.Bag => ?_:Bag)
  ...</envs>
  <objs>...
    (string_tree(O1)(T1:StringTree)(P:Oid) => string_tree(?O2)(?T2:StringTree)(P:Oid))
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
  requires string_bst(T1)
  ensures string_bst(?T2) andBool string_tree_keys(?T2) ==K string_tree_keys(T1) -StringSet { V }
endmodule


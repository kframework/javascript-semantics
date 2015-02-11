module STRING-TREE-PATTERN
  imports MAP
  imports JS
  imports STRING-SET

  syntax StringTree ::= "string_node" "(" String "," StringTree "," StringTree ")"
                      | "string_leaf"

  syntax StringSet ::= "string_tree_keys" "(" StringTree ")"    [function, smtlib(smt_string_tree_keys)]
  rule string_tree_keys(string_node(S:String, TL:StringTree, TR:StringTree))
    => { S } U (string_tree_keys(TL) U string_tree_keys(TR))
  rule string_tree_keys(string_leaf) => .StringSet

  syntax Int ::= "string_tree_height" "(" StringTree ")"     [function, smtlib(smt_string_tree_height)]
  rule string_tree_height(string_node(S:String, TL:StringTree, TR:StringTree))
    => 1 +Int maxInt(string_tree_height(TL), string_tree_height(TR))
  rule string_tree_height(string_leaf) => 0

  syntax Bag ::= "string_tree" "(" Val ")" "(" StringTree ")" "(" Oid ")"  [pattern(1)]
  rule
    <objs>...
      string_tree(@o(O:Int))(string_node(S:String, TL:StringTree, TR:StringTree))(P:Oid)
    =>
      <obj>
        <oid> @o(O) </oid>
        <properties>
          "value" |-> @desc("Value" |-> S                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "left"  |-> @desc("Value" |-> ?OL:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "right" |-> @desc("Value" |-> ?OR:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> P // @ObjectProtoOid
        </internalProperties>
      </obj>
      string_tree(?OL)(TL:StringTree)(P)
      string_tree(?OR)(TR:StringTree)(P)
    ...</objs>
    [pattern]
  rule <objs>... string_tree(@NullVal)(string_leaf)(_:Oid) => .Bag ...</objs>
    [pattern]

  syntax Bool ::= "string_bst" "(" StringTree ")"   [function, smtlib(smt_string_bst)]
  rule string_bst(string_node(S:String, TL:StringTree, TR:StringTree))
    => string_tree_keys(TL) <StringSet { S } andBool { S } <StringSet string_tree_keys(TR)
       andBool string_bst(TL) andBool string_bst(TR)
  rule string_bst(string_leaf) => true

  syntax Bag ::= "string_htree" "(" Val ")" "(" StringTree ")"  [pattern(1)]
  rule
    <objs>...
      string_htree(@o(O:Int))(string_node(S:String, TL:StringTree, TR:StringTree))
    =>
      <obj>
        <oid> @o(O) </oid>
        <properties>
          "value"  |-> @desc("Value" |-> S                                                                          "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "height" |-> @desc("Value" |-> string_tree_height(string_node(S:String, TL:StringTree, TR:StringTree))    "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "left"   |-> @desc("Value" |-> ?OL:NullableObject                                                         "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "right"  |-> @desc("Value" |-> ?OR:NullableObject                                                         "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      string_htree(?OL)(TL:StringTree)
      string_htree(?OR)(TR:StringTree)
    ...</objs>
    [pattern]
  rule <objs>... string_htree(@NullVal)(string_leaf) => .Bag ...</objs>
    [pattern]

  syntax Bool ::= "string_avl" "(" StringTree ")"   [function, smtlib(smt_string_avl)]
  rule string_avl(string_node(S:String, TL:StringTree, TR:StringTree))
    => string_tree_keys(TL) <StringSet { S } andBool { S } <StringSet string_tree_keys(TR)
       andBool absInt(string_tree_height(TL) -Int string_tree_height(TR)) <=Int 1
       andBool string_avl(TL) andBool string_avl(TR)
  rule string_avl(string_leaf) => true

  rule string_tree_height(T:StringTree) >=Int 0 => true    [smt-lemma]

endmodule

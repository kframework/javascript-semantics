module STRING-TREE-PATTERN
  imports MAP
  imports JS
  imports STRING-SET

  syntax StringTree ::= "node" "(" String "," StringTree "," StringTree ")"
                      | "leaf"

  syntax StringSet ::= "tree_keys" "(" StringTree ")"   [function, smtlib(smt_tree_keys)]
  rule tree_keys(node(S:String, TL:StringTree, TR:StringTree))
    => { S } U (tree_keys(TL) U tree_keys(TR))
  rule tree_keys(leaf) => .StringSet

  syntax Int ::= "tree_height" "(" StringTree ")"       [function, smtlib(smt_tree_height)]
  rule tree_height(node(S:String, TL:StringTree, TR:StringTree))
    => 1 +Int maxInt(tree_height(TL), tree_height(TR))
  rule tree_height(leaf) => 0

  syntax Bag ::= "tree" "(" Val ")" "(" StringTree ")" "(" Oid ")"    [pattern(1)]
  rule
    <objs>...
      tree(@o(O:Int))(node(S:String, TL:StringTree, TR:StringTree))(P:Oid)
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
      tree(?OL)(TL:StringTree)(P)
      tree(?OR)(TR:StringTree)(P)
    ...</objs>
    [pattern]
  rule <objs>... tree(@NullVal)(leaf)(_:Oid) => .Bag ...</objs>
    [pattern]

  syntax Bool ::= "bst" "(" StringTree ")"    [function, smtlib(smt_bst)]
  rule bst(node(S:String, TL:StringTree, TR:StringTree))
    => tree_keys(TL) <StringSet { S } andBool { S } <StringSet tree_keys(TR)
       andBool bst(TL) andBool bst(TR)
  rule bst(leaf) => true

  syntax Bag ::= "htree" "(" Val ")" "(" StringTree ")"   [pattern(1)]
  rule
    <objs>...
      htree(@o(O:Int))(node(S:String, TL:StringTree, TR:StringTree))
    =>
      <obj>
        <oid> @o(O) </oid>
        <properties>
          "value"  |-> @desc("Value" |-> S                                                         "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "height" |-> @desc("Value" |-> tree_height(node(S:String, TL:StringTree, TR:StringTree)) "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "left"   |-> @desc("Value" |-> ?OL:NullableObject                                        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "right"  |-> @desc("Value" |-> ?OR:NullableObject                                        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      htree(?OL)(TL:StringTree)
      htree(?OR)(TR:StringTree)
    ...</objs>
    [pattern]
  rule <objs>... htree(@NullVal)(leaf) => .Bag ...</objs>
    [pattern]

  syntax Bool ::= "avl" "(" StringTree ")"    [function, smtlib(smt_avl)]
  rule avl(node(S:String, TL:StringTree, TR:StringTree))
    => tree_keys(TL) <StringSet { S } andBool { S } <StringSet tree_keys(TR)
       andBool absInt(tree_height(TL) -Int tree_height(TR)) <=Int 1
       andBool avl(TL) andBool avl(TR)
  rule avl(leaf) => true

  rule tree_height(T:StringTree) >=Int 0 => true    [smt-lemma]
endmodule


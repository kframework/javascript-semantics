module FLOAT-TREE-PATTERN
  imports MAP
  imports JS
  imports FLOAT-SET

  syntax FloatTree ::= "node" "(" Float "," FloatTree "," FloatTree ")"
                     | "leaf"

  syntax FloatSet ::= "tree_keys" "(" FloatTree ")"   [function, smtlib(smt_tree_keys)]
  rule tree_keys(node(F:Float, TL:FloatTree, TR:FloatTree))
    => { F } U (tree_keys(TL) U tree_keys(TR))
  rule tree_keys(leaf) => .FloatSet

  syntax Bag ::= "tree" "(" Val ")" "(" FloatTree ")"   [pattern(1)]
  rule
    <objs>...
      tree(@o(P:Int))(node(F:Float{exponent(11), significand(53)}, TL:FloatTree, TR:FloatTree))
    =>
      <obj>
        <oid> @o(P) </oid>
        <properties>
          "value" |-> @desc("Value" |-> F                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "left"  |-> @desc("Value" |-> ?OL:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "right" |-> @desc("Value" |-> ?OR:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      tree(?OL)(TL:FloatTree)
      tree(?OR)(TR:FloatTree)
    ...</objs>
    ensures notBool isNaN(F)
    [pattern]
  rule <objs>... tree(@NullVal)(leaf) => .Bag ...</objs>
    [pattern]

  syntax Bool ::= "bst" "(" FloatTree ")"   [function, smtlib(smt_bst)]
  rule bst(node(F:Float{exponent(11), significand(53)}, TL:FloatTree, TR:FloatTree))
    => tree_keys(TL) <FloatSet { F } andBool { F } <FloatSet tree_keys(TR)
       andBool bst(TL) andBool bst(TR)
  rule bst(leaf) => true
endmodule

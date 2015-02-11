module FLOAT-TREE-PATTERN
  imports MAP
  imports JS
  imports FLOAT-SET

  syntax FloatTree ::= "node" "(" Float "," FloatTree "," FloatTree ")"
                     | "leaf"

  syntax FloatSet ::= "float_tree_keys" "(" FloatTree ")"   [function, smtlib(smt_float_tree_keys)]
  rule float_tree_keys(node(F:Float, TL:FloatTree, TR:FloatTree))
    => { F } U (float_tree_keys(TL) U float_tree_keys(TR))
  rule float_tree_keys(leaf) => .FloatSet

  syntax Bag ::= "float_tree" "(" Val ")" "(" FloatTree ")"   [pattern(1)]
  rule
    <objs>...
      float_tree(@o(P:Int))(node(F:Float{exponent(11), significand(53)}, TL:FloatTree, TR:FloatTree))
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
      float_tree(?OL)(TL:FloatTree)
      float_tree(?OR)(TR:FloatTree)
    ...</objs>
    ensures notBool isNaN(F)
    [pattern]
  rule <objs>... float_tree(@NullVal)(leaf) => .Bag ...</objs>
    [pattern]

  syntax Bool ::= "float_bst" "(" FloatTree ")"   [function, smtlib(smt_float_bst)]
  rule float_bst(node(F:Float{exponent(11), significand(53)}, TL:FloatTree, TR:FloatTree))
    => float_tree_keys(TL) <FloatSet { F } andBool { F } <FloatSet float_tree_keys(TR)
       andBool float_bst(TL) andBool float_bst(TR)
  rule float_bst(leaf) => true
endmodule

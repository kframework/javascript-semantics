module PRIORITY-TREE-PATTERN
  imports MAP
  imports JS
  imports STRING-SET

  syntax PTree ::= "pnode" "(" String /* Key */ "," Int /* Priority */ "," PTree "," PTree ")"
                 | "pleaf"

  syntax StringSet ::= "ptree_keys" "(" PTree ")"   [function, smtlib(smt_ptree_keys)]
  rule ptree_keys(pnode(S:String, _, TL:PTree, TR:PTree)) => { S } U (ptree_keys(TL) U ptree_keys(TR))
  rule ptree_keys(pleaf) => .StringSet

  syntax Int ::= "ptree_max_priority" "(" PTree ")"    [function, smtlib(smt_ptree_max_priority)]
  rule ptree_max_priority(pnode(_, Z:Int, TL:PTree, TR:PTree)) => maxInt(Z, maxInt(ptree_max_priority(TL), ptree_max_priority(TR)))
  rule ptree_max_priority(pleaf) => 0
  //
  rule ptree_max_priority(_:PTree) >=Int 0 => true    [smt-lemma]

  syntax Int ::= "ptree_priority" "(" PTree ")"    [function, smtlib(smt_ptree_priority)]
  rule ptree_priority(pnode(_, Z:Int, _, _)) => Z
  rule ptree_priority(pleaf) => 0
  //
  rule ptree_priority(_:PTree) >=Int 0 => true    [smt-lemma]

  syntax Bool ::= "treap" "(" PTree ")"   [function, smtlib(smt_treap)]
  rule treap(pnode(I:String, Z:Int, TL:PTree, TR:PTree))
    => treap(TL) andBool treap(TR)
       andBool ptree_keys(TL) <StringSet { I } andBool { I } <StringSet ptree_keys(TR)
       andBool Z >=Int ptree_max_priority(TL) andBool Z >=Int ptree_max_priority(TR)
       andBool Z >=Int 0
  rule treap(pleaf) => true
  //
  rule treap(T:PTree) impliesBool ptree_max_priority(T) ==K ptree_priority(T) => true    [smt-lemma]

  syntax Bag ::= "ptree" "(" Val ")" "(" PTree ")"    [pattern(1)]
  rule
    <objs>...
      ptree(@o(O:Int))(pnode(S:String, Z:Int, TL:PTree, TR:PTree))
    =>
      <obj>
        <oid> @o(O) </oid>
        <properties>
          "value"    |-> @desc("Value" |-> S                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "priority" |-> @desc("Value" |-> Z                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "left"     |-> @desc("Value" |-> ?OL:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "right"    |-> @desc("Value" |-> ?OR:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      ptree(?OL)(TL:PTree)
      ptree(?OR)(TR:PTree)
    ...</objs>
  ensures Z >=Int 0
    [pattern]
  rule <objs>... ptree(@NullVal)(pleaf) => .Bag ...</objs>
    [pattern]

endmodule

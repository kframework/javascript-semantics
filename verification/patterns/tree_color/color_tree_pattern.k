module COLOR-TREE-PATTERN
  imports MAP
  imports JS
  imports STRING-SET

  syntax CTree ::= "cnode" "(" String "," Int /* Color */ "," CTree "," CTree ")" // Red=0, Black=1
                 | "cleaf"

  syntax StringSet ::= "ctree_keys" "(" CTree ")"   [function, smtlib(smt_ctree_keys)]
  rule ctree_keys(cnode(S:String, _, TL:CTree, TR:CTree)) => { S } U (ctree_keys(TL) U ctree_keys(TR))
  rule ctree_keys(cleaf) => .StringSet

  syntax Int ::= "ctree_height" "(" CTree ")"       [function, smtlib(smt_ctree_height)]
  rule ctree_height(cnode(_, C:Int, TL:CTree, TR:CTree)) => C +Int maxInt(ctree_height(TL), ctree_height(TR))
  rule ctree_height(cleaf) => 0
  //
  rule ctree_height(T:CTree) >=Int 0 => true    [smt-lemma]

  syntax Int ::= "ctree_color" "(" CTree ")"      [function, smtlib(smt_ctree_color)]
  rule ctree_color(cnode(_, C:Int, _, _)) => C
  rule ctree_color(cleaf) => 1
  //
  rule ctree_color(T:CTree) ==K 1 orBool ctree_color(T) ==K 0 => true  [smt-lemma]

  syntax Bool ::= "rbt" "(" CTree ")"   [function, smtlib(smt_rbt)]
  rule rbt(cnode(I:String, C:Int, TL:CTree, TR:CTree))
    => rbt(TL) andBool rbt(TR)
       andBool ctree_keys(TL) <StringSet { I } andBool { I } <StringSet ctree_keys(TR)
       andBool ctree_height(TL) ==Int ctree_height(TR)
       andBool ( C ==K 1 orBool C ==K 0 )
       andBool (
                 C ==K 1
               orBool
                 (ctree_color(TL) ==K 1 andBool ctree_color(TR) ==K 1)
               )
  rule rbt(cleaf) => true

  syntax Bag ::= "ctree" "(" Val ")" "(" CTree ")"    [pattern(1)]
  rule
    <objs>...
      ctree(@o(O:Int))(cnode(S:String, C:Int, TL:CTree, TR:CTree))
    =>
      <obj>
        <oid> @o(O) </oid>
        <properties>
          "value" |-> @desc("Value" |-> S                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "color" |-> @desc("Value" |-> C                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "left"  |-> @desc("Value" |-> ?OL:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "right" |-> @desc("Value" |-> ?OR:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      ctree(?OL)(TL:CTree)
      ctree(?OR)(TR:CTree)
    ...</objs>
    [pattern]
  rule <objs>... ctree(@NullVal)(cleaf) => .Bag ...</objs>
    [pattern]

endmodule

module LIST-PATTERN
  imports MAP
  imports JS

  rule size(L1:List L2:List) => size(L1) +Int size(L2)    [lemma]
  rule size(ListItem(_)) => 1                             [lemma]
  rule size(.List) => 0                                   [lemma]

  syntax Int ::= sum(List)                            [function, smtlib(smt_seq_sum)]
/*
  rule sum(L1:List L2:List) => sum(L1) +Int sum(L2)   [lemma]
  rule sum(ListItem(I:Int)) => I                      [lemma]
  rule sum(.List) => 0                                [lemma]
*/

  syntax List ::= rev(List)                       [function]
  rule rev(L1:List L2:List) => rev(L2) rev(L1)    [lemma]
  rule rev(ListItem(V:UserVal)) => ListItem(V)        [lemma]
  rule rev(.List) => .List                        [lemma]

/*
  syntax IntSet ::= list2set(List)   [function, smtlib(smt_seq2set)]
  rule list2set(L1:List L2:List) => list2set(L1) U list2set(L2)
    [lemma, smt-lemma]
  rule list2set(ListItem(V:UserVal)) => { V }   [lemma, smt-lemma]
  rule list2set(.List) => .IntSet           [lemma, smt-lemma]
*/

  syntax Bool ::= sorted(List)    [function, smtlib(smt_seq_sorted)]
/*
  // TODO(AndreiS): add support for specifying Z3 triggers
  //rule sorted(L1 @ L2)
  //  => intseq2intset(L1) <=IntSet intseq2intset(L2) andBool sorted(L1) andBool sorted(L2)
  //  [smt-lemma]
  rule sorted(ListItem(I)) => true    [smt-lemma]
  rule sorted(.List) => true          [smt-lemma]
*/


  /* list pattern */
  syntax Bag ::= "list" "(" Val ")" "(" List ")"    [pattern(1)]
  rule
    <objs>...
      list(@o(O:Int))(ListItem(V:UserVal) L:List)
    =>
      <obj>
        <oid> @o(O) </oid>
        <properties>
          "value" |-> @desc("Value" |-> V                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> ?ON:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      list(?ON)(L)
    ...</objs>
    [pattern]
  rule <objs>... list(@NullVal)(.List) => .Bag ...</objs>
    [pattern]

  /* lseg pattern */
  syntax Bag ::= "lseg" "(" Val "," Val ")" "(" List ")"    [pattern(2)]
  rule
    <objs>...
      lseg(@o(O:Int), P:NullableObject)(ListItem(V:UserVal) L:List)
    =>
      <obj>
        <oid> @o(O) </oid>
        <properties>
          "value" |-> @desc("Value" |-> V                  "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> ?ON:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
      lseg(?ON, P)(L)
    ...</objs>
    requires @o(O) =/=K P
    [pattern]
  rule <objs>... lseg(O:NullableObject, O)(.List) => .Bag ...</objs>
    [pattern]

  rule
    <objs>...
       <obj>
        <oid> O:NullableObject </oid>
        <properties>
          "value" |-> @desc("Value" |-> V        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> @NullVal "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
    =>
      lseg(O, @NullVal)(ListItem(V))
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        <obj>
          <oid> O:NullableObject </oid>
          <properties>
            "value" |-> @desc("Value" |-> V                "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
            "next"  |-> @desc("Value" |-> P:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          </properties>
          <internalProperties>
            "Class"      |-> "Object"
            "Extensible" |-> true
            "Prototype"  |-> @ObjectProtoOid
          </internalProperties>
        </obj>
      =>
        lseg(O, P)(ListItem(V))
      )
      <obj>... <oid> P </oid> ...</obj>
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        <obj>
          <oid> O:NullableObject </oid>
          <properties>
            "value" |-> @desc("Value" |-> V                "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
            "next"  |-> @desc("Value" |-> P:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          </properties>
          <internalProperties>
            "Class"      |-> "Object"
            "Extensible" |-> true
            "Prototype"  |-> @ObjectProtoOid
          </internalProperties>
        </obj>
      =>
        lseg(O, P)(ListItem(V))
      )
      lseg(P, @NullVal)(_:List)
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        <obj>
          <oid> O:NullableObject </oid>
          <properties>
            "value" |-> @desc("Value" |-> V                "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
            "next"  |-> @desc("Value" |-> P:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          </properties>
          <internalProperties>
            "Class"      |-> "Object"
            "Extensible" |-> true
            "Prototype"  |-> @ObjectProtoOid
          </internalProperties>
        </obj>
      =>
        lseg(O, P)(ListItem(V))
      )
      lseg(P, Q:NullableObject)(_:List)
      <obj>... <oid> Q </oid> ...</obj>
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      lseg(O:NullableObject, P:NullableObject)(L1:List)
      lseg(P, @NullVal)(L2:List)
    =>
      lseg(O, @NullVal)(L1 L2)
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        lseg(O:NullableObject, P:NullableObject)(L1:List)
        lseg(P, Q:NullableObject)(L2:List)
      =>
        lseg(O, Q)(L1 L2)
      )
      <obj>... <oid> Q </oid> ...</obj>
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        lseg(O:NullableObject, P:NullableObject)(L1:List)
        lseg(P, Q:NullableObject)(L2:List)
      =>
        lseg(O, Q)(L1 L2)
      )
      lseg(Q, @NullVal)(_:List)
    ...</objs>
    [pattern-folding]
endmodule


// from kernelc/patterns/list_pattern.k

module LIST-PATTERN
  imports MAP
  imports JS
  imports STRING-LIST

  /* list pattern */
  syntax Bag ::= "list" "(" NullableObject ")" "(" StringSeq ")"    [pattern(1)]
  rule
    <objs>...
      list(@o(O:Int))(StringSeqItem(V:String) @ L:StringSeq)
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
  rule <objs>... list(@NullVal)(.StringSeq) => .Bag ...</objs>
    [pattern]

  /* lseg pattern */
  syntax Bag ::= "lseg" "(" NullableObject "," NullableObject ")" "(" StringSeq ")"    [pattern(2)]
  rule
    <objs>...
      lseg(@o(O:Int), P:NullableObject)(StringSeqItem(V:String) @ L:StringSeq)
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
  rule <objs>... lseg(O:NullableObject, O)(.StringSeq) => .Bag ...</objs>
    [pattern]

  rule
    <objs>...
       <obj>
        <oid> @o(O:Int) </oid>
        <properties>
          "value" |-> @desc("Value" |-> V:String "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          "next"  |-> @desc("Value" |-> @NullVal "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
        </properties>
        <internalProperties>
          "Class"      |-> "Object"
          "Extensible" |-> true
          "Prototype"  |-> @ObjectProtoOid
        </internalProperties>
      </obj>
    =>
      lseg(@o(O), @NullVal)(StringSeqItem(V))
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        <obj>
          <oid> @o(O:Int) </oid>
          <properties>
            "value" |-> @desc("Value" |-> V:String         "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
            "next"  |-> @desc("Value" |-> @o(P:Int)        "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          </properties>
          <internalProperties>
            "Class"      |-> "Object"
            "Extensible" |-> true
            "Prototype"  |-> @ObjectProtoOid
          </internalProperties>
        </obj>
      =>
        lseg(@o(O), @o(P))(StringSeqItem(V))
      )
      <obj>... <oid> @o(P) </oid> ...</obj>
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        <obj>
          <oid> @o(O:Int) </oid>
          <properties>
            "value" |-> @desc("Value" |-> V:String         "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
            "next"  |-> @desc("Value" |-> P:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          </properties>
          <internalProperties>
            "Class"      |-> "Object"
            "Extensible" |-> true
            "Prototype"  |-> @ObjectProtoOid
          </internalProperties>
        </obj>
      =>
        lseg(@o(O), P)(StringSeqItem(V))
      )
      lseg(P, @NullVal)(_:StringSeq)
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        <obj>
          <oid> @o(O:Int) </oid>
          <properties>
            "value" |-> @desc("Value" |-> V:String         "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
            "next"  |-> @desc("Value" |-> P:NullableObject "Writable" |-> true "Enumerable" |-> true "Configurable" |-> true)
          </properties>
          <internalProperties>
            "Class"      |-> "Object"
            "Extensible" |-> true
            "Prototype"  |-> @ObjectProtoOid
          </internalProperties>
        </obj>
      =>
        lseg(@o(O), P)(StringSeqItem(V))
      )
      lseg(P, @o(Q:Int))(_:StringSeq)
      <obj>... <oid> @o(Q) </oid> ...</obj>
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      lseg(O:NullableObject, P:NullableObject)(L1:StringSeq)
      lseg(P, @NullVal)(L2:StringSeq)
    =>
      lseg(O, @NullVal)(L1 @ L2)
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        lseg(O:NullableObject, P:NullableObject)(L1:StringSeq)
        lseg(P, @o(Q:Int))(L2:StringSeq)
      =>
        lseg(O, @o(Q))(L1 @ L2)
      )
      <obj>... <oid> @o(Q) </oid> ...</obj>
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        lseg(O:NullableObject, P:NullableObject)(L1:StringSeq)
        lseg(P, Q:NullableObject)(L2:StringSeq)
      =>
        lseg(O, Q)(L1 @ L2)
      )
      lseg(Q, @NullVal)(_:StringSeq)
    ...</objs>
    [pattern-folding]
endmodule


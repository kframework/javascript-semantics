// from kernelc/patterns/list_pattern.k

module LIST-PATTERN
  imports MAP
  imports JS
  imports STRING-LIST

  /* list pattern */
  syntax Bag ::= "list" "(" NullableObject ")" "(" List ")"    [pattern(1)]
  rule
    <objs>...
      list(@o(O:Int))(ListItem(V:String) L:List)
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
  syntax Bag ::= "lseg" "(" NullableObject "," NullableObject ")" "(" List ")"    [pattern(2)]
  rule
    <objs>...
      lseg(@o(O:Int), P:NullableObject)(ListItem(V:String) L:List)
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
      lseg(@o(O), @NullVal)(ListItem(V))
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
        lseg(@o(O), @o(P))(ListItem(V))
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
        lseg(@o(O), P)(ListItem(V))
      )
      lseg(P, @NullVal)(_:List)
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
        lseg(@o(O), P)(ListItem(V))
      )
      lseg(P, @o(Q:Int))(_:List)
      <obj>... <oid> @o(Q) </oid> ...</obj>
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
        lseg(P, @o(Q:Int))(L2:List)
      =>
        lseg(O, @o(Q))(L1 L2)
      )
      <obj>... <oid> @o(Q) </oid> ...</obj>
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


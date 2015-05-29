// from kernelc/patterns/list_pattern.k

module LIST-PATTERN
  imports MAP
  imports JS
  imports STRING-LIST

  /* list pattern */
  syntax Bag ::= "list" "(" Val ")" "(" List ")"    [pattern(1)]
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
  syntax Bag ::= "lseg" "(" Val "," Val ")" "(" List ")"    [pattern(2)]
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
        <oid> O:NullableObject </oid>
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
      lseg(O, @NullVal)(ListItem(V))
    ...</objs>
    [pattern-folding]
  rule
    <objs>...
      (
        <obj>
          <oid> O:NullableObject </oid>
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


//Common parts of JSON and JS syntaxes

module JS-ON-COMMON

  syntax JValue ::= ArrayLiteral
		 |  ObjectLiteral
		 |  JNumber

  syntax JNumber ::= Int | Float
//		     JInt
//		  |  JFloat
//		  |  JZero

//  syntax JInt ::= Token{"^[-+]?[1-9]+[0-9]*$"}
//  syntax JFloat ::= Token{"^[-+]?[1-9]+[0-9]*.[0-9]*$"}
//  syntax JZero ::= Token{"^[-+]?0(.0)?$"}

  syntax #Null ::= "null"
  syntax Null ::= #Null

//ARRAYNOTATION---------------------
//Array Initializer - Ecma262-11.1.4
//--introduces amb with Exp,Exp --find a better way!
  syntax ArrayLiteral ::= "[" "]"
		       |  "[" Elision "]"
		       |  "[" ElementList "]"
		       |  "[" ElementList "," Elision "]"
		       |  "[" ElementList "," "]"

  syntax ElementList ::= Elision Expression
		      |  Expression
		      |  ElementList "," Elision Expression
		      |  ElementList "," Expression

  syntax Elision ::= ","
		  |  Elision ","
//ARRAYNOTATION---------------------

//OBJECTNOTATION--------------------
//Object Initializer - Ecma262-11.1.5
//check if works!
  syntax ObjectLiteral ::= "{" "}"
			|  "{" PropertyNameAndValueList "}"
			|  "{" PropertyNameAndValueList "," "}"

  syntax PropertyNameAndValueList ::= PropertyAssignment
				   |  PropertyNameAndValueList "," PropertyAssignment

  syntax PropertyAssignment ::= PropertyName ":" Expression  //Field
			     |  "get" PropertyName "(" ")" "{" FuncBody "}"  //GetProp
			     |  "set" PropertyName "(" Id ")" "{" FuncBody "}"  //SetProp

  syntax PropertyName ::= Id
		       |  String
		       |  JNumber
//OBJECTNOTATION--------------------


endmodule

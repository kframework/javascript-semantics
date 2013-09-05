//JavaScript types module

module JS-TYPES

//TYPES - Ecma262-8
  syntax Types ::= Undefined
		|  Null
		|  Boolean
		|  String
		|  Number
		|  Object
		|  ReferenceSpecification
		|  ListSpecification
		|  CompletionSpecification
		|  PropertyDescriptor
		|  PropertyIdentifierSpecification  //together w/ descriptor?
		|  LexicalEnvironment
		|  EnvironmentRecordSpecification
		|  ObjectInternalMethods //?
//----------------------------------------

//The Undefined Type - Ecma262-8.1
  syntax Undefined ::= "undefined"
//----------------------------------------

//The Null Type - Ecma262-8.2
  syntax Null ::= "null"
//----------------------------------------

//The Boolean Type - Ecma262-8.3
  syntax Boolean ::= Bool
//----------------------------------------

//The String Type - Ecma262-8.4
  syntax String ::= String
//----------------------------------------

//The Number Type - Ecma262-8.5
//TODO: positive/negative infinity and zeroes!!
//	NaN!!
  syntax Number ::= Int | Float
//----------------------------------------

//The Object Type - Ecma262-8.6
//  syntax Object ::= 
//----------------------------------------

endmodule

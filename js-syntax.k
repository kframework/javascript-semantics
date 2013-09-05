//JavaScript syntax module

require "js-statements.k"
require "js-expressions.k"
//require "js-types.k"
//require "js-objects.k"
require "js-lexicals.k"

module JS-SYNTAX
  imports JS-STATEMENTS
  imports JS-EXPRESSIONS
//  imports JS-TYPES
//  imports JS-OBJECTS
  imports JS-LEXICALS

//Program - Ecma262-14
  syntax Program ::= SourceElements //opt?

  syntax SourceElements ::= SourceElement
			 |  SourceElements SourceElement

  syntax SourceElement ::= Statement
//			|  FunctionDeclaration
//----------------------------------------


/*
TypeConversion and Testing ? Ecma262-9
FunctionDefinition ? Ecma262-13
Program ? Ecma262-14
*/

/*
Positive and Negative Infinity?
NaN?
*/

//LEXICAL CONVENTIONS - Ecma262-7

//TYPES - Ecma262-8

//EXPRESSIONS - Ecma262-11

//STATEMENTS - Ecma262-12
//The result of evaluating a Statement is always a Completion value.

//OBJECTS - Ecma262-15

endmodule

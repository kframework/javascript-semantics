//JavaScript syntax module

require "json-to-js/js-on-common.k"

module JS-SYNTAX
  imports JS-ON-COMMON

//Program - Ecma262-14---------------
  syntax Program ::= SourceElements  //using List causes the listing of .SourceElements

  syntax SourceElements ::= List{SourceElement, ""}
  rule .SourceElements => .

//  syntax SourceElements ::= SourceElement
//			 |  SourceElements SourceElement

  syntax SourceElement ::= Statement
			|  FuncDecl
//Program - Ecma262-14---------------

//Function Definition - Ecma262-13---
  syntax FuncDecl ::= "function" Id "(" ParameterList ")" "{" FuncBody "}"
		   |  "function" Id "(" ")" "{" FuncBody "}"

  syntax FuncExpr ::= "function" Id "(" ParameterList ")" "{" FuncBody "}"
		   |  "function" Id "(" ")" "{" FuncBody "}"
		   |  "function" "(" ParameterList ")" "{" FuncBody "}"
		   |  "function" "(" ")" "{" FuncBody "}"

  syntax ParameterList ::= Id
			|  ParameterList "," Id

  syntax FuncBody ::= SourceElements
//Function Definition - Ecma262-13---


//check if works!!
  syntax VarDecl ::= Id
		  |  Id "=" Expression  [strict(2)]  //!!!!

  syntax VarDecls ::= VarDecl
		   |  VarDecls "," VarDecl  //List can't be empty


  syntax Statements ::= Statement 
		     |  Statements Statement

  syntax Block ::= "{" "}" | "{" Statements "}"
  syntax Statement ::= Block
		    |  "var" VarDecls ";"
		    |  ";"  //Empty statement
		    |  Expression ";"
		    |  "if" "(" Expression ")" Statement
		    |  "if" "(" Expression ")" Statement "else" Statement
		    |  "switch" "(" Expression ")" CaseBlock
		    |  "do" Statement "while" "(" Expression ")" ";"
		    |  "while" "(" Expression ")" Statement
		    |  "for" "(" ";" ";" ")" Statement
		    |  "for" "(" Expression ";" Expression ";" Expression ")" Statement
		    |  "for" "(" ";" Expression ";" Expression ")" Statement
		    |  "for" "(" Expression ";" ";" ")" Statement
		    |  "for" "(" Expression ";" ";" Expression ")" Statement
		    |  "for" "(" ";" Expression ";" ")" Statement
		    |  "for" "(" Expression ";" Expression ";" ")" Statement
		    |  "for" "(" ";" ";" Expression ")" Statement
		    |  "for" "(" LHS "in" Expression ")" Statement
		    |  "for" "(" "var" VarDecls ";" Expression ";" Expression ")" Statement
		    |  "for" "(" "var" VarDecls ";" ";" Expression ")" Statement
		    |  "for" "(" "var" VarDecls ";" Expression ";" ")" Statement
		    |  "for" "(" "var" VarDecls ";" ";" ")" Statement
		    |  "for" "(" "var" VarDecl "in" Expression ")" Statement
		    |  "continue" ";"
		    |  "continue" Id ";"
		    |  "break" ";"
		    |  "break" Id ";"
		    |  "return" ";"
		    |  "return" Expression ";"
		    |  "with" "(" Expression ")" Statement
		    |  Id ":" Statement  //Labelled statement
		    |  "throw" Expression ";"
		    |  "try" Block Catch
		    |  "try" Block Finally
		    |  "try" Block Catch Finally
		    |  "debugger" ";"

  //reference: SAFE framework AST
  syntax Expression ::= Expression "," Expression  //Expression List  --CommaOp?
		     |  Expression "?" Expression ":" Expression  //Conditional
		     |  Expression Infix Expression  //Infix Op
		     |  Prefix Expression  //Prefix Op
		     |  LHS Unary  //Unary Assignment Op
		     |  LHS Asgn Expression  //Assignment Op
		     |  LHS  //LeftHandSide

  syntax LHS ::= Literal
	      |  Id  //VarRef  ---check
	      |  ArrayLiteral  //ARRAYNOTATION!
	      |  ObjectLiteral  //OBJECTNOTATION!
	      |  "(" Expression ")"  [bracket]  //Grouping
	      |  FuncExpr  //FUNCTIONEXPR!
	      |  LHS "[" Expression "]"  //Bracket
	      |  LHS "." Id  //Dot  ---first VarRef!
	      |  "new" LHS  //New
	      |  LHS "(" ")"  //FUNCTIONAPPLICATION!
	      |  LHS "(" Arguments ")"  //FUNCTIONAPPLICATION!

//FUNCTIONAPPLICATION!
  syntax Arguments ::= Expression
		    |  Arguments "," Expression  //List can't be empty
//FUNCTIONAPPLICATION!

  syntax Literal ::= "this"
		  |  Null		  
		  |  Bool
		  |  JNumber
		  |  String  //check
//		  |  RegExp  //check

  syntax Infix ::= "&&" | "||" | "|" | "&" | "ˆ" | "<<" | ">>" | ">>>" | "+" | "-" | "*" | "/" 
                | "%" | "==" | "!=" | "===" | "!==" | "<" | ">" | "<=" | ">=" | "instanceof" | "in"

  syntax Prefix ::= "++" | "--" | "~" | "!" | "+" | "-" | "delete" | "void" | "typeof"

  syntax Unary ::= "++" | "--"

  syntax Asgn ::= "=" | "*=" | "/=" | "%=" | "+=" | "-=" | "<<=" | ">>=" | ">>>=" | "&=" | "ˆ=" | "|="

//CASEBLOCK-------------------------
//The switch Statement - Ecma262-12.11
  syntax CaseBlock ::= "{" "}"
		    |  "{" CaseClause "}"
		    |  "{" CaseClause DefaultClause CaseClause "}"
		    |  "{" DefaultClause "}"
		    |  "{" DefaultClause CaseClause "}"
		    |  "{" CaseClause DefaultClause "}"

  syntax CaseClauses ::= CaseClause
		      |  CaseClauses CaseClause

  syntax CaseClause ::= "case" Expression ":" Statements
		     |  "case" Expression ":" 

  syntax DefaultClause ::= "default" ":" Statements
			|  "default" ":"

//CASEBLOCK-------------------------

//TRYCATCHFINALLY-------------------
  syntax Catch ::= "catch" "(" Id ")" Block

  syntax Finally ::= "finally" Block
//TRYCATCHFINALLY-------------------


endmodule

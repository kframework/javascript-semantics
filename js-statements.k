//JavaScript statements module

require "js-expressions.k"

module JS-STATEMENTS
  imports JS-EXPRESSIONS

//STATEMENTS - Ecma262-12
//The result of evaluating a Statement is always a Completion value.
  syntax Statement ::= Block
		    |  VariableStatement
		    |  EmptyStatement
		    |  ExpressionStatement
		    |  IfStatement
		    |  IterationStatement
		    |  ContinueStatement
		    |  BreakStatement
		    |  ReturnStatement
		    |  WithStatement
		    |  SwitchStatement
		    |  LabelledStatement
		    |  ThrowStatement
		    |  TryStatement
//		    |  debuggerStatement  //Not in section 12 ??
//----------------------------------------

//Block - Ecma262-12.1
  syntax Block ::= "{" "}"
		|  "{" StatementList "}"

  syntax StatementList ::= Statement
			|  StatementList Statement
//----------------------------------------

//Variable Statement - Ecma262-12.2
  syntax VariableStatement ::= "var" VariableDeclarationList ";"

  syntax VariableDeclarationList ::= VariableDeclaration
				  |  VariableDeclarationList "," VariableDeclaration // use List{.., ","} ??

  syntax VariableDeclarationListNoIn ::= VariableDeclarationNoIn
				      |  VariableDeclarationListNoIn "," VariableDeclarationNoIn

  syntax VariableDeclaration ::= Identifier
			      |  Identifier Initializer

  syntax VariableDeclarationNoIn ::= Identifier
				  |  Identifier InitializerNoIn

  syntax Initializer ::= "=" AssignmentExpression  // AssignmentOperators ??

  syntax InitializerNoIn ::= "=" AssignmentExpressionNoIn  // AssignmentOperators ??
//----------------------------------------

//Empty Statement - Ecma262-12.3
  syntax EmptyStatement ::= ";"
//----------------------------------------

//Expression Statement - Ecma262-12.4
//TODO
  syntax ExpressionStatement ::= /*[lookahead exluding {{, function}]*/ Expression ";"
//----------------------------------------

//The if Statement - Ecma262-12.5
  syntax IfStatement ::= "if" "(" Expression ")" Statement "else" Statement
		      |  "if" "(" Expression ")" Statement
//----------------------------------------

//Iteration Statements - Ecma262-12.6
  syntax IterationStatement ::= "do" Statement "while" "(" Expression ")" ";"
			     |  "while" "(" Expression ")" Statement
//for (ExpressionNoInopt; Expressionopt ; Expressionopt ) Statement
			     |  "for" "(" ";" ";" ")" Statement
			     |  "for" "(" ExpressionNoIn ";" Expression ";" Expression ")" Statement
			     |  "for" "(" ";" Expression ";" Expression ")" Statement
			     |  "for" "(" ExpressionNoIn ";" ";" ")" Statement
			     |  "for" "(" ExpressionNoIn ";" ";" Expression ")" Statement
			     |  "for" "(" ";" Expression ";" ")" Statement
			     |  "for" "(" ExpressionNoIn ";" Expression ";" ")" Statement
			     |  "for" "(" ";" ";" Expression ")" Statement
//for ( var VariableDeclarationListNoIn; Expressionopt ; Expressionopt ) Statement
			     |  "for" "(" "var" VariableDeclarationListNoIn ";" Expression ";" Expression ")" Statement
			     |  "for" "(" "var" VariableDeclarationListNoIn ";" ";" Expression ")" Statement
			     |  "for" "(" "var" VariableDeclarationListNoIn ";" Expression ";" ")" Statement
			     |  "for" "(" "var" VariableDeclarationListNoIn ";" ";" ")" Statement
//for ( LeftHandSideExpression in Expression ) Statement 
			     |  "for" "(" LeftHandSideExpression "in" Expression ")" Statement
//for ( var VariableDeclarationNoIn in Expression ) Statement
			     |  "for" "(" "var" VariableDeclarationNoIn "in" Expression ")" Statement
//----------------------------------------

//The continue Statement - Ecma262-12.7
  syntax ContinueStatement ::= "continue" ";"
		     	    |  "continue" /*No line terminator here*/ Identifier ";"
//----------------------------------------
 
//The break Statement - Ecma262-12.8
  syntax BreakStatement ::= "break" ";"
		     	 |  "break" /*No line terminator here*/ Identifier ";"
//----------------------------------------

//The return Statement - Ecma262-12.9
  syntax ReturnStatement ::= "return" ";"
		     	  |  "return" /*No line terminator here*/ Expression ";"
//----------------------------------------

//The with Statement - Ecma262-12.10
  syntax WithStatement ::= "with" "(" Expression ")" Statement
//----------------------------------------

//The switch Statement - Ecma262-12.11
  syntax SwitchStatement ::= "switch" "(" Expression ")" CaseBlock

  syntax CaseBlock ::= "{" "}"
		    |  "{" CaseClause "}"
		    |  "{" CaseClause DefaultClause CaseClause "}"
		    |  "{" DefaultClause "}"
		    |  "{" DefaultClause CaseClause "}"
		    |  "{" CaseClause DefaultClause "}"

  syntax CaseClauses ::= CaseClause
		      |  CaseClauses CaseClause

  syntax CaseClause ::= "case" Expression ":" StatementList
		     |  "case" Expression ":" 

  syntax DefaultClause ::= "default" ":" StatementList
			|  "default" ":"
//----------------------------------------

//Labelled Statements - Ecma262-12.12
  syntax LabelledStatement ::= Identifier ":" Statement
//----------------------------------------

//The throw Statement - Ecma262-12.13
  syntax ThrowStatement ::= "throw" /*No line terminator here*/ Expression ";"
//----------------------------------------

//The try Statement - Ecma262-12.14
  syntax TryStatement ::= "try" Block Catch
		       |  "try" Block Finally
		       |  "try" Block Catch Finally

  syntax Catch ::= "catch" "(" Identifier ")" Block

  syntax Finally ::= "finally" Block
//----------------------------------------


endmodule

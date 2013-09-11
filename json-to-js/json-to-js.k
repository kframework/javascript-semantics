//JSON-TO-JAVASCRIPT

require "json.k"
require "../js-syntax.k"

module JSON-TO-JS
  imports JSON
  imports JS-SYNTAX

//HOW TO GET RID OF QUOTES IN STRINGS?


  rule { "type" : "Program" , "body" : ([Es]):ArrayLiteral } => Es  [macro]  //array notation?

//var / multipvar
//HOW TO PARSE THE ARRAY ELEMENTS? --WORKS BUT AMBIGUITIES!
  rule { "type": "VariableDeclaration" , "declarations": [Es] , "kind": "var" } => var (Es)::VarDecls;  [macro]
  rule { "type": "VariableDeclarator" , "id": O , "init": N:Null } => O  [macro]
  rule { "type": "Identifier" , "name": V } => String2Id(V)  [macro]

//bool
  rule { "type": "VariableDeclarator", "id": O1, "init": O2 } => (O1 = O2):VarDecl  [macro]
//  rule { "type": "Literal", "value": B:Bool } => B  [macro]

//null / asgn
  rule { "type": "ExpressionStatement", "expression": O } => (O;):Statement  [macro]
//HOW TO TYPE IT??
  rule { "type": "AssignmentExpression", "operator": V, "left": O1, "right": O2 } => O1 (V)::Asgn O2  [macro]
//  rule { "type": "Literal", "value": N:Null } => N  [macro]

//if
  rule { "type": "IfStatement", "test": O1, "consequent": O2, "alternate": O3 } => if (O1) O2 else O3  [macro]
  rule { "type": "BlockStatement", "body": ([Es]):ArrayLiteral } => Es  [macro]

//float
  rule { "type": "Literal", "value": V } => V  [macro]

//post
  rule { "type": "UpdateExpression", "operator": V, "argument": O, "prefix": false } => O (V)::Unary  [macro]

//pre
  rule { "type": "UpdateExpression", "operator": V, "argument": O, "prefix": true } => (V)::Prefix O  [macro]

//while
  rule { "type": "WhileStatement", "test": O1, "body": O2 } => while (O1) O2  [macro]
//!!!!!!!!!!!!! var type = (operator === '||' || operator === '&&') ? Syntax.LogicalExpression :
//                        Syntax.BinaryExpression;
  rule { "type": "BinaryExpression", "operator": V, "left": O1, "right": O2 } => O1 (V)::Infix O2  [macro]
            
endmodule

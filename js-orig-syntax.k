require "builtins/bool.k"
require "builtins/int.k"

module JS-ORIG-SYNTAX

imports BOOL-SYNTAX-HOOKS
imports INT-SYNTAX-HOOKS

// Based on ECMA-262, 5.1 Edition, June 2011

// A.5 Programs
syntax Program ::= SourceElements

syntax SourceElements ::= List{SourceElement, ""}       [klabel('__::SourceElement*SourceElements->SourceElements)]
syntax SourceElement ::= Statement
                       | FunctionExpression

// A.5 Functions
syntax FunctionExpression ::= "function" Name "(" Parameters ")" "{" FunctionBody "}"
                            | "function"      "(" Parameters ")" "{" FunctionBody "}"
syntax Parameters ::= List{Name, ","}                   [klabel('_,_::Name*Parameters->Parameters)]
syntax FunctionBody ::= SourceElements

// A.4 Statements
syntax Statements ::= List{Statement, ""}               [klabel('__::Statement*Statements->Statements)]
syntax Statement ::= Block
                   | "var" VariableDeclarationS ";"
                 //| ";"
                   | ExpressionS ";"
                   | "if" "(" ExpressionS ")" Statement
                   | "if" "(" ExpressionS ")" Statement "else" Statement    [prefer]
                   | "do" Statement "while" "(" ExpressionS ")" ";"
                   | "while" "(" ExpressionS ")" Statement
                   | "for" "("                Expressions ";" Expressions ";" Expressions ")" Statement
                   | "for" "(" "var" VariableDeclarationS ";" Expressions ";" Expressions ")" Statement
                   | "for" "("            LeftExpression "in" ExpressionS ")" Statement
                   | "for" "(" "var" VariableDeclaration "in" ExpressionS ")" Statement
                   | "continue" ";"
                   | "continue" Name ";"
                   | "break" ";"
                   | "break" Name ";"
                   | "return" ";"
                   | "return" ExpressionS ";"
                   | "with" "(" ExpressionS ")" Statement
                   | Name ":" Statement                 [klabel('_:_::Name*Statement->Statement)] // label
                   | "switch" "(" ExpressionS ")" CaseBlock
                   | "throw" ExpressionS ";"
                   | "try" Block Catch
                   | "try" Block Finally
                   | "try" Block Catch Finally
                   | "debugger" ";"

syntax Block ::= "{" Statements "}"                     [klabel('{_}::Statements->Block)]

syntax VariableDeclarationS ::= NeList{VariableDeclaration, ","}    [klabel('_,_::VariableDeclaration*VariableDeclarationS->VariableDeclarationS)]
syntax VariableDeclaration ::= Name
                             | Name "=" Expression                  [klabel('_=_::Name*Expression->VariableDeclaration)]

syntax CaseBlock ::= "{" CaseClauses "}"                            [klabel('{_}::CaseClauses->CaseBlock)]
                   | "{" CaseClauses DefaultClause CaseClauses "}"
syntax CaseClauses ::= List{CaseClause, ""}                         [klabel('__::CaseClause*CaseClauses->CaseClauses)]
syntax CaseClause ::= "case" ExpressionS ":" Statements
syntax DefaultClause ::= "default" ":" Statements

syntax Catch ::= "catch" "(" Name ")" Block
syntax Finally ::= "finally" Block

// A.3 Expressionessions
syntax ExpressionS ::= Expression
                     | Expression "," ExpressionS       [klabel('_,_::Expression*ExpressionS->ExpressionS)]
/*
syntax ExpressionS ::= NeList{Expression, ","}
*/
syntax Expressions ::=   List{Expression, ","}          [klabel('_,_::Expression*Expressions->Expressions)]

syntax Literal ::= "this"
                 | Null
                 | Bool
                 | Int
                 | MyFloat
                 | MyString

syntax Null ::= "null"

syntax Name ::= Token{[\_\$A-Za-z][\_\$A-Za-z0-9]*}   [notInRules]

// 7.8.3 Numeric Literals
//
//                                                   // DecimalLiteral
// (0 | [1-9][0-9]*) \. [0-9]* ([eE] [+-]? [0-9]+)?      // DecimalIntegerLiteral . DecimalDigitsopt ExponentPartopt
//                   \. [0-9]+ ([eE] [+-]? [0-9]+)?      //                       . DecimalDigits    ExponentPartopt
// (0 | [1-9][0-9]*)           ([eE] [+-]? [0-9]+)?      // DecimalIntegerLiteral                    ExponentPartopt
// 0[xX] [0-9a-fA-F]+                                // HexIntegerLiteral

syntax MyFloat ::= Token{[\+\-]?[0-9]+"."[0-9]+([eE][\+\-]?[0-9]+)?}
                   [regex("([\\+-]?\\d(\\.\\d*)?|\\.\\d+)([eE][\\+-]?(\\d(\\.\\d*)?|\\.\\d+))?"), notInRules, notInGround]

// 7.8.4 String Literals
//
// SingleStringCharacter ::=
//   [^\'\\\n\r\u2028\u2029] |                       // SourceCharacter but not one of ' or \ or LineTerminator
//                                                   // \ EscapeSequence
//       \\[^0-9xu\n\r\u2028\u2029] |                    // \ CharacterEscapeSequence
//       \\0 [lookahead \not\in DecimalDigit]            // \ 0 [lookahead \not\in DecimalDigit]
//       \\x[0-9a-fA-F]{2} |                             // \ HexEscapeSequence
//       \\u[0-9a-fA-F]{4}                               // \ UnicodeEscapeSequence
//   \\[\n\r\u2028\u2029] | \\\r\n |                 // LineContinuation

// FIXME: consider lookahead symbol for the case:  \ 0 [lookahead \not\in DecimalDigit]
syntax MyString ::= MyString1 | MyString2
syntax MyString1 ::= Token{ "'" ((~[\'\\\n\r]) | (((([\\]~[1-9xu]) | ([\\][\r][\n])) | ([\\][x][0-9a-fA-F][0-9a-fA-F])) | ([\\][u][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))*  "'"}
                           [regex("['](([^'\\\\\\n\\r])|([\\\\][^1-9xu])|([\\\\][\\r][\\n])|([\\\\][x][0-9a-fA-F]{2})|([\\\\][u][0-9a-fA-F]{4}))*[']"), notInRules, notInGround]
syntax MyString2 ::= Token{"\"" ((~[\"\\\n\r]) | (((([\\]~[1-9xu]) | ([\\][\r][\n])) | ([\\][x][0-9a-fA-F][0-9a-fA-F])) | ([\\][u][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))*  "\""}
                     [regex("[\\\"](([^\\\"\\\\\\n\\r])|([\\\\][^1-9xu])|([\\\\][\\r][\\n])|([\\\\][x][0-9a-fA-F]{2})|([\\\\][u][0-9a-fA-F]{4}))*[\\\"]"), notInRules, notInGround]

// 11.1.5 Object Initialiser
// 
// PropertyName ::= IdentifierName
//                | StringLiteral
//                | NumericLiteral
// 
// Note that PropertyName is IdentifierName not Identifier, where Identifier is IdentifierName but not ReservedWord.
// Thus, both Null and Bool also can be PropertyName.

syntax PropertyName ::= Name
                      | Null
                      | Bool
                      | MyString
                      | Int
                      | MyFloat

// syntax ArrayElements ::= List{ExpressionOpt, ","}
// syntax ExpressionOpt ::= Expression /* | "" [avoid, onlyLabel, klabel('epsilonExpression)] */
//                                     /* FIXME: Currently K parser crashes the empty array literal: [ ] */

syntax PropertyAssignments ::= List{PropertyAssignment, ","}                [klabel('_,_::PropertyAssignment*PropertyAssignments->PropertyAssignments)]
syntax PropertyAssignment ::= PropertyName ":" Expression                   [klabel('_:_::PropertyName*Expression->PropertyAssignment)]
                            | Name /* get */ PropertyName "("      ")" "{" FunctionBody "}"
                            | Name /* set */ PropertyName "(" Name ")" "{" FunctionBody "}"

syntax PrimaryExpression ::= Name
                           | Literal
                           | "[" Expressions /* ArrayElements */ "]"
                           | "{" PropertyAssignments "}"                    [klabel('{_}::PropertyAssignments->PrimaryExpression)]
                           | "(" ExpressionS ")"                            [klabel('(_)::ExpressionS->PrimaryExpression)]

syntax MemberExpression ::= PrimaryExpression
                          > FunctionExpression
                          | MemberExpression "[" Expressions "]"            [klabel('_[_]::Expression*Expression->Expression)]
                          | MemberExpression "." Name                       [klabel('_._::Expression*Name->Expression)]
                          | "new" MemberExpression "(" Expressions ")"
//
syntax NewExpression ::= MemberExpression
                       | "new" NewExpression
//
syntax CallExpression ::= MemberExpression "(" Expressions ")"
                        | CallExpression "(" Expressions ")"
                        | CallExpression "[" Expressions "]"                [klabel('_[_]::Expression*Expression->Expression)]
                        | CallExpression "." Name                           [klabel('_._::Expression*Name->Expression)]
//
syntax LeftExpression ::= NewExpression | CallExpression

syntax Expression ::= LeftExpression
                    > Expression "++"
                    | Expression "--"
                    > "delete" Expression
                    | "void" Expression
                    | "typeof" Expression
                    | "++" Expression                               [prefer]
                    | "--" Expression                               [prefer]
                    | "+" Expression
                    | "-" Expression
                    | "~" Expression
                    | "!" Expression
                    > left:
                      Expression "*" Expression                            [left]
                    | Expression "/" Expression                            [left]
                    | Expression "%" Expression                            [left]
                    > left:
                      Expression "+" Expression                            [left]
                    | Expression "-" Expression                            [left]
                    > left:
                      Expression "<<" Expression                           [left]
                    | Expression ">>" Expression                           [left]
                    | Expression ">>>" Expression                          [left]
                    > left:
                      Expression "<" Expression                            [left]
                    | Expression ">" Expression                            [left]
                    | Expression "<=" Expression                           [left]
                    | Expression ">=" Expression                           [left]
                    | Expression "instanceof" Expression                   [left,prefer]
                    | Expression "in" Expression                           [left, klabel('_in_::Expression*Expression->Expression)]
                    > left:
                      Expression "==" Expression                           [left]
                    | Expression "!=" Expression                           [left]
                    | Expression "===" Expression                          [left]
                    | Expression "!==" Expression                          [left]
                    > left:
                      Expression "&" Expression                            [left]
                    > left:
                      Expression "^" Expression                            [left]
                    > left:
                      Expression "|" Expression                            [left]
                    > left:
                      Expression "&&" Expression                           [left]
                    > left:
                      Expression "||" Expression                           [left]
                    > Expression "?" Expression ":" Expression
                    > right:
                      LeftExpression "=" Expression                           [right]
                    | LeftExpression "*=" Expression                          [right]
                    | LeftExpression "/=" Expression                          [right]
                    | LeftExpression "%=" Expression                          [right]
                    | LeftExpression "+=" Expression                          [right]
                    | LeftExpression "-=" Expression                          [right]
                    | LeftExpression "<<=" Expression                         [right]
                    | LeftExpression ">>=" Expression                         [right]
                    | LeftExpression ">>>=" Expression                        [right]
                    | LeftExpression "&=" Expression                          [right]
                    | LeftExpression "^=" Expression                          [right]
                    | LeftExpression "|=" Expression                          [right]

// Internal Semantic Methods API Call

syntax CallExpression ::= APIName "(" Expressions ")"

syntax APIName ::= Token{[\@][\_\$A-Za-z0-9]*}   [notInRules]

endmodule

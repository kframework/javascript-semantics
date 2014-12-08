module JS-ORIG-SYNTAX

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


// Utils
syntax String ::= StringOfName(Name) [function, notInPrograms]
rule StringOfName(N:Name) => #tokenToString(N)
//
syntax Name ::= NameOfString(String) [function, notInPrograms]
rule NameOfString(S:String) => #parseToken("Name", S)

syntax Float ::= "MyFloat2Float" "(" MyFloat ")" [function, notInPrograms]
rule MyFloat2Float(F:MyFloat) => String2Float(#tokenToString(F))

syntax String ::= "MyString2String" "(" MyString ")" [function, notInPrograms]
rule MyString2String(S:MyString) => processEscapes(processBackslashes(processQuotes(#tokenToString(S))))

syntax String ::= "processQuotes" "(" String ")" [function, notInPrograms]
rule processQuotes(S:String) => replaceAll(substrString(S, 1, lengthString(S) -Int 1), "\\\"", "\"") when substrString(S,0,1) ==String "\""
rule processQuotes(S:String) => replaceAll(substrString(S, 1, lengthString(S) -Int 1),  "\\'",  "'") when substrString(S,0,1) ==String "'"

syntax String ::= "processBackslashes" "(" String ")" [function, notInPrograms]
rule processBackslashes(S:String) => substrString(S, 0, findString(S, "\\", 0)) +String processBackslashesAux(substrString(S, findString(S, "\\", 0), lengthString(S))) when findString(S, "\\", 0) =/=Int -1
rule processBackslashes(S:String) => S when findString(S, "\\", 0) ==Int -1

syntax String ::= "processBackslashesAux" "(" String ")" [function, notInPrograms]
rule processBackslashesAux(S:String) => processBackslashesAuxAux(S) when lengthString(S) >Int 1
rule processBackslashesAux(S:String) => S when lengthString(S) ==Int 1

syntax String ::= "processBackslashesAuxAux" "(" String ")" [function, notInPrograms]
rule processBackslashesAuxAux(S:String) =>                             processBackslashes(substrString(S,1,lengthString(S))) when notBool(isEscapeChar(substrString(S,1,2)))
rule processBackslashesAuxAux(S:String) => substrString(S,0,2) +String processBackslashes(substrString(S,2,lengthString(S))) when         isEscapeChar(substrString(S,1,2))

syntax Bool ::= "isEscapeChar" "(" String ")" [function, notInPrograms]
rule isEscapeChar(S:String) => S ==String "b"
                        orBool S ==String "t"
                        orBool S ==String "n"
                        orBool S ==String "v"
                        orBool S ==String "f"
                        orBool S ==String "r"
                        orBool S ==String "\\"
                        //
                        orBool S ==String "0"
                        //
                        orBool S ==String "\n"
                        orBool S ==String "\r"
                        orBool S ==String "\u2028"
                        orBool S ==String "\u2029"
                        //
                        orBool S ==String "x"
                        orBool S ==String "u"

syntax String ::= "processEscapes" "(" String ")" [function, notInPrograms]
rule processEscapes(S:String) => S when findString(S, "\\b"      , 0) ==Int -1
                                andBool findString(S, "\\t"      , 0) ==Int -1
                                andBool findString(S, "\\n"      , 0) ==Int -1
                                andBool findString(S, "\\v"      , 0) ==Int -1
                                andBool findString(S, "\\f"      , 0) ==Int -1
                                andBool findString(S, "\\r"      , 0) ==Int -1
                                andBool findString(S, "\\\\"     , 0) ==Int -1
                                //
                                andBool findString(S, "\\0"      , 0) ==Int -1
                                //
                                andBool findString(S, "\\\n"     , 0) ==Int -1
                                andBool findString(S, "\\\r"     , 0) ==Int -1
                                andBool findString(S, "\\\r\n"   , 0) ==Int -1
                                andBool findString(S, "\\\u2028" , 0) ==Int -1
                                andBool findString(S, "\\\u2029" , 0) ==Int -1
                                //
                                andBool findString(S, "\\x"      , 0) ==Int -1
                                andBool findString(S, "\\u"      , 0) ==Int -1
// \ [one of ' " \ b f n r t v]
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\b"     , "\u0008")) when findString(S, "\\b"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\t"     , "\t"    )) when findString(S, "\\t"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\n"     , "\n"    )) when findString(S, "\\n"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\v"     , "\u000B")) when findString(S, "\\v"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\f"     , "\f"    )) when findString(S, "\\f"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\r"     , "\r"    )) when findString(S, "\\r"     , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\\"    , "\\"    )) when findString(S, "\\\\"    , 0) =/=Int -1
// \ 0 [lookahead \not\in DecimalDigit]
// FIXME: check if lookahead is not a decimal degit.
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\0"     , "\u0000")) when findString(S, "\\0"     , 0) =/=Int -1
// LineContinuation ::= \ LineTerminatorSequence
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\n"    , ""      )) when findString(S, "\\\n"    , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\r"    , ""      )) when findString(S, "\\\r"    , 0) =/=Int -1 andBool findString(S, "\\\r\n", 0) ==Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\r\n"  , ""      )) when findString(S, "\\\r\n"  , 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\u2028", ""      )) when findString(S, "\\\u2028", 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(replaceAll(S, "\\\u2029", ""      )) when findString(S, "\\\u2029", 0) =/=Int -1
// HexEscapeSequence     ::= x HexDigit HexDigit
// UnicodeEscapeSequence ::= u HexDigit HexDigit HexDigit HexDigit
rule processEscapes(S:String) => processEscapes(processHexEscapes    (S, findString(S, "\\x", 0))) when findString(S, "\\x", 0) =/=Int -1
rule processEscapes(S:String) => processEscapes(processUnicodeEscapes(S, findString(S, "\\u", 0))) when findString(S, "\\u", 0) =/=Int -1

syntax String ::= "processHexEscapes" "(" String "," Int ")" [function, notInPrograms]
rule processHexEscapes    (S:String, I:Int) => substrString(S, 0, I) +String chrChar(String2Base(substrString(S, I +Int 2, I +Int 2 +Int 2), 16)) +String substrString(S, I +Int 2 +Int 2, lengthString(S))

syntax String ::= "processUnicodeEscapes" "(" String "," Int ")" [function, notInPrograms]
rule processUnicodeEscapes(S:String, I:Int) => substrString(S, 0, I) +String chrChar(String2Base(substrString(S, I +Int 2, I +Int 2 +Int 4), 16)) +String substrString(S, I +Int 2 +Int 4, lengthString(S))

// Internal Semantic Methods API Call

syntax CallExpression ::= APIName "(" Expressions ")"

syntax APIName ::= Token{[\@][\_\$A-Za-z0-9]*}   [notInRules]

syntax String ::= StringOfAPIName(APIName) [function, notInPrograms]
rule StringOfAPIName(N:APIName) => #tokenToString(N)

endmodule

module JS-ORIG-SYNTAX

// Based on ECMA-262, 5.1 Edition, June 2011

// A.5 Programs
syntax Program ::= SourceElements

syntax SourceElements ::= List{SourceElement, ""}
syntax SourceElement ::= Statement
                       | FunctionExpression

// A.5 Functions
syntax FunctionExpression ::= "function" Name "(" Parameters ")" "{" FunctionBody "}"
                            | "function"      "(" Parameters ")" "{" FunctionBody "}"
syntax Parameters ::= List{Name, ","}
syntax FunctionBody ::= SourceElements

// A.4 Statements
syntax Statements ::= List{Statement, ""}
syntax Statement ::= Block
                   | "var" VariableDeclarationS ";"
                   | ";"
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
                   | Name ":" Statement  // label
                   | "switch" "(" ExpressionS ")" CaseBlock
                   | "throw" ExpressionS ";"
                   | "try" Block Catch
                   | "try" Block Finally
                   | "try" Block Catch Finally
                   | "debugger" ";"
                   | "print" "(" Expression ")" ";"

syntax Block ::= "{" Statements "}"

syntax VariableDeclarationS ::= NeList{VariableDeclaration, ","}
syntax VariableDeclaration ::= Name
                             | Name "=" Expression

syntax CaseBlock ::= "{" CaseClauses "}"
                   | "{" CaseClauses DefaultClause CaseClauses "}"
syntax CaseClauses ::= List{CaseClause, ""}
syntax CaseClause ::= "case" ExpressionS ":" Statements
syntax DefaultClause ::= "default" ":" Statements

syntax Catch ::= "catch" "(" Name ")" Block
syntax Finally ::= "finally" Block

// A.3 Expressionessions
syntax ExpressionS ::= NeList{Expression, ","}
syntax Expressions ::=   List{Expression, ","}

syntax Literal ::= "this"
                 | "null"
                 | Bool
                 | Int
                 | Float
                 | String

syntax Name ::= Token{[\_\$A-Za-z][\_\$A-Za-z0-9]*}   [notInRules]

syntax PropertyName ::= Name
                      | String
                      | Int
                      | Float

syntax ArrayElements ::= List{ExpressionOpt, ","}
syntax ExpressionOpt ::= Expression | "" [onlyLabel, klabel('epsilonExpression)]

syntax PropertyAssignments ::= List{PropertyAssignment, ","}
syntax PropertyAssignment ::= PropertyName ":" Expression
                            | Name /* get */ PropertyName "("      ")" "{" FunctionBody "}"
                            | Name /* set */ PropertyName "(" Name ")" "{" FunctionBody "}"

syntax PrimaryExpression ::= Name
                           | Literal
                           | "[" ArrayElements "]"
                           | "{" PropertyAssignments "}"
                           | "(" ExpressionS ")"

syntax MemberExpression ::= PrimaryExpression
                          > FunctionExpression
                          | MemberExpression "[" Expressions "]"
                          | MemberExpression "." Name
                          | "new" MemberExpression "(" Expressions ")"
//
syntax NewExpression ::= MemberExpression
                       | "new" NewExpression
//
syntax CallExpression ::= MemberExpression "(" Expressions ")"
                        | CallExpression "(" Expressions ")"
                        | CallExpression "[" Expressions "]"
                        | CallExpression "." Name
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
                    | Expression "in" Expression                           [left]
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
syntax String ::= StringOfName(Name) [function]
rule StringOfName(N:Name) => #tokenToString(N)
//
syntax Name ::= NameOfString(String) [function]
rule NameOfString(S:String) => #parseToken("Name", S)

endmodule

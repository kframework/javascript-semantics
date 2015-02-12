require "js-orig-syntax.k"
require "js-orig-syntax-util.k"
require "js-core-syntax.k"

module JS-TRANS

imports JS-ORIG-SYNTAX
imports JS-CORE-SYNTAX

imports JS-ORIG-SYNTAX-UTIL

// top-level
syntax Stmt ::= "^SourceElements" "(" SourceElements ")" [function]
rule ^SourceElements(S:SourceElement Ss:SourceElements) => %seq(^SourceElement(S), ^SourceElements(Ss)) when Ss =/=K .SourceElements
rule ^SourceElements(S:SourceElement   .SourceElements) =>      ^SourceElement(S)
rule ^SourceElements(                  .SourceElements) =>                         %emptyStmt
//
syntax Stmt ::= "^SourceElement" "(" SourceElement ")" [function]
rule ^SourceElement(S:Statement)          => ^Statement(S)
rule ^SourceElement(F:FunctionExpression) => ^FunctionDeclaration(F)

// function declaration
syntax Stmt ::= "^FunctionDeclaration" "(" FunctionExpression ")" [function]
rule ^FunctionDeclaration(function F:Name ( Ps:Parameters ) { Ss:SourceElements }) => %fdecl(^Name(F), ^Parameters(Ps), ^SourceElements(Ss))
//
syntax Exps ::= "^Parameters" "(" Parameters ")" [function]
rule ^Parameters(X:Name, Xs:Parameters) => %cons(%var(^Name(X)), ^Parameters(Xs))
rule ^Parameters(          .Parameters) =>                       %nil

// statements block
syntax Stmt ::= "^Statements" "(" Statements ")" [function]
rule ^Statements(S:Statement Ss:Statements) => %seq(^Statement(S), ^Statements(Ss)) when Ss =/=K .Statements
rule ^Statements(S:Statement   .Statements) =>      ^Statement(S)
rule ^Statements(              .Statements) =>                     %emptyStmt
//
rule ^Statement({ Ss:Statements }) => ^Statements(Ss)

// statement
syntax Stmt ::= "^Statement" "(" Statement ")" [function]

// variable declaration
rule ^Statement(var VD:VariableDeclaration, VDs:VariableDeclarationS ;) => %seq(^VariableDeclaration(VD), ^Statement(var VDs ;)) when VDs =/=K .VariableDeclarationS
rule ^Statement(var VD:VariableDeclaration,    .VariableDeclarationS ;) =>      ^VariableDeclaration(VD)
rule ^Statement(var                            .VariableDeclarationS ;) =>                                %emptyStmt
//
syntax Stmt ::= "^VariableDeclaration" "(" VariableDeclaration ")" [function]
rule ^VariableDeclaration(X:Name               ) =>      %vdecl(^Name(X))
rule ^VariableDeclaration(X:Name = E:Expression) => %seq(%vdecl(^Name(X)), %exp(%bop(%assign, %var(^Name(X)), ^Expression(E))))

// empty statement
//rule ^Statement(;) => %emptyStmt

// expression statement
rule ^Statement(Es:ExpressionS ;) => %exp(^ExpressionS2Comma(Es))

// if
rule ^Statement(if ( Es:ExpressionS ) S1:Statement                  ) => %if(^ExpressionS2Comma(Es), ^Statement(S1), %emptyStmt)
rule ^Statement(if ( Es:ExpressionS ) S1:Statement else S2:Statement) => %if(^ExpressionS2Comma(Es), ^Statement(S1), ^Statement(S2))

// do-while
rule ^Statement(do S:Statement while ( Es:ExpressionS ) ;) => %label("", %do(^Statement(S), ^ExpressionS2Comma(Es)))

// while
rule ^Statement(while ( Es:ExpressionS ) S:Statement) => %label("", %while(^ExpressionS2Comma(Es), ^Statement(S)))

// for
rule ^Statement(for (              Es0:Expressions ; Es1:Expressions ; Es2:Expressions ) S:Statement) => %label("", %for(%exp(^Expressions2Comma(Es0)), ^Expressions2Comma(Es1), ^Expressions2Comma(Es2), ^Statement(S)))
rule ^Statement(for ( var VDs:VariableDeclarationS ; Es1:Expressions ; Es2:Expressions ) S:Statement) => %label("", %for(^Statement(var VDs ;),         ^Expressions2Comma(Es1), ^Expressions2Comma(Es2), ^Statement(S)))

// for-in
rule ^Statement(for (          E:LeftExpression in Es:ExpressionS ) S:Statement) => %label("", %forin(%emptyStmt,                  ^Expression(E), ^ExpressionS2Comma(Es), ^Statement(S)))
rule ^Statement(for ( var N:Name                in Es:ExpressionS ) S:Statement) => %label("", %forin(^VariableDeclaration(N    ), %var(^Name(N)), ^ExpressionS2Comma(Es), ^Statement(S)))
rule ^Statement(for ( var N:Name = E:Expression in Es:ExpressionS ) S:Statement) => %label("", %forin(^VariableDeclaration(N = E), %var(^Name(N)), ^ExpressionS2Comma(Es), ^Statement(S)))

// continue
rule ^Statement(continue        ;) => %continue("")
rule ^Statement(continue L:Name ;) => %continue(^Name(L))

// break
rule ^Statement(break        ;) => %break("")
rule ^Statement(break L:Name ;) => %break(^Name(L))

// return
rule ^Statement(return                ;) => %return(%emptyExp)
rule ^Statement(return Es:ExpressionS ;) => %return(^ExpressionS2Comma(Es))

// with
rule ^Statement(with ( Es:ExpressionS ) S:Statement) => %with(^ExpressionS2Comma(Es), ^Statement(S))

// label
rule ^Statement(L:Name : S:Statement) => %label(^Name(L), ^Statement(S))

// switch
rule ^Statement(switch ( Es:ExpressionS ) { CCs1:CaseClauses                                   }) => %label("", %switch(^ExpressionS2Comma(Es), ^CaseClauses(CCs1), %emptyStmt,         %emptyStmt        ))
rule ^Statement(switch ( Es:ExpressionS ) { CCs1:CaseClauses DC:DefaultClause CCs2:CaseClauses }) => %label("", %switch(^ExpressionS2Comma(Es), ^CaseClauses(CCs1), ^DefaultClause(DC), ^CaseClauses(CCs2)))
//
syntax Stmt ::= "^CaseClauses" "(" CaseClauses ")" [function]
rule ^CaseClauses(CC:CaseClause CCs:CaseClauses) => %seq(^CaseClause(CC), ^CaseClauses(CCs))
rule ^CaseClauses(                 .CaseClauses) =>                       %emptyStmt
//
syntax Stmt ::= "^CaseClause" "(" CaseClause ")" [function]
rule ^CaseClause(case Es:ExpressionS : Ss:Statements) => %case(^ExpressionS2Comma(Es), ^Statements(Ss))
//
syntax Stmt ::= "^DefaultClause" "(" DefaultClause ")" [function]
rule ^DefaultClause(default : Ss:Statements) => %default(^Statements(Ss))

// throw
rule ^Statement(throw Es:ExpressionS ;) => %throw(^ExpressionS2Comma(Es))

// try
rule ^Statement(try { Ss1:Statements } catch ( X:Name ) { Ss2:Statements } finally { Ss3:Statements }) => %try(^Statements(Ss1), ^Name(X), ^Statements(Ss2), ^Statements(Ss3))
rule ^Statement(try { Ss1:Statements } catch ( X:Name ) { Ss2:Statements }                           ) => %try(^Statements(Ss1), ^Name(X), ^Statements(Ss2), %emptyStmt      )
rule ^Statement(try { Ss1:Statements }                                     finally { Ss3:Statements }) => %try(^Statements(Ss1),                             ^Statements(Ss3))

// debugger
rule ^Statement(debugger ;) => %debugger

// comma expressions
syntax Exp ::= "^ExpressionS2Comma" "(" ExpressionS ")" [function]
rule ^ExpressionS2Comma(E:Expression, Es:ExpressionS) => %comma(^Expression(E), ^ExpressionS2Comma(Es))
rule ^ExpressionS2Comma(E:Expression                ) =>        ^Expression(E)
//
syntax Exp ::= "^Expressions2Comma" "(" Expressions ")" [function]
rule ^Expressions2Comma(E:Expression, Es:Expressions) => %comma(^Expression(E), ^Expressions2Comma(Es)) when Es =/=K .Expressions
rule ^Expressions2Comma(E:Expression,   .Expressions) =>        ^Expression(E)
rule ^Expressions2Comma(                .Expressions) =>                        %emptyExp
/*
syntax Exp ::= "^Expressions2Comma" "(" ExpressionS ")" [function]
             | "^Expressions2Comma" "(" Expressions ")"
rule ^Expressions2Comma(E:Expression, Es:ExpressionS) => %comma(^Expression(E), ^Expressions2Comma(Es)) when Es =/=K .ExpressionS
rule ^Expressions2Comma(E:Expression, Es:Expressions) => %comma(^Expression(E), ^Expressions2Comma(Es)) when Es =/=K .Expressions
rule ^Expressions2Comma(E:Expression,   .ExpressionS) =>        ^Expression(E)
rule ^Expressions2Comma(E:Expression,   .Expressions) =>        ^Expression(E)
rule ^Expressions2Comma(                .ExpressionS) =>                        %emptyExp
rule ^Expressions2Comma(                .Expressions) =>                        %emptyExp
*/

// list expressions
syntax Exps ::= "^Expressions2List" "(" Expressions ")" [function]
rule ^Expressions2List(E:Expression, Es:Expressions) => %cons(^Expression(E), ^Expressions2List(Es))
rule ^Expressions2List(                .Expressions) =>                       %nil
/*
syntax Exps ::= "^Expressions2List" "(" ExpressionS ")" [function]
              | "^Expressions2List" "(" Expressions ")"
rule ^Expressions2List(E:Expression, Es:ExpressionS) => %cons(^Expression(E), ^Expressions2List(Es))
rule ^Expressions2List(E:Expression, Es:Expressions) => %cons(^Expression(E), ^Expressions2List(Es))
rule ^Expressions2List(                .ExpressionS) =>                       %nil
rule ^Expressions2List(                .Expressions) =>                       %nil
*/

// expression
syntax Exp ::= "^Expression" "(" Expression ")" [function]

// atomic expression
rule ^Expression(X:Name)   => %var(^Name(X))
rule ^Expression(this)     => %con(%this)
rule ^Expression(null)     => %con(%null)
rule ^Expression(B:Bool)   => %con(B)
rule ^Expression(I:Int)    => %con(I)
// FIXME: Hack: conflict with built-in float and string
rule ^Expression(F:MyFloat)  => %con(MyFloat2Float(F))
rule ^Expression(S:MyString) => %con(^String(MyString2String(S)))

// array
rule ^Expression([ Es:Expressions ]) => %arr(^Expressions2List(Es))
/*
rule ^Expression([ AEs:ArrayElements ]) => %arr(^ArrayElements(AEs))
//
syntax Exps ::= "^ArrayElements" "(" ArrayElements ")" [function]
rule ^ArrayElements(AE:ExpressionOpt, AEs:ArrayElements) => %cons(^ArrayElement(AE), ^ArrayElements(AEs))
rule ^ArrayElements(                     .ArrayElements) =>                          %nil
//
syntax Exp ::= "^ArrayElement" "(" ExpressionOpt ")" [function]
rule ^ArrayElement(E:Expression) => ^Expression(E)
//rule ^ArrayElement('epsilonExpression(.KList)) => %emptyExp
*/

// object
rule ^Expression({ PAs:PropertyAssignments }) => %obj(^PropertyAssignments(PAs))
//
syntax Exps ::= "^PropertyAssignments" "(" PropertyAssignments ")" [function]
rule ^PropertyAssignments(PA:PropertyAssignment, PAs:PropertyAssignments) => %cons(^PropertyAssignment(PA), ^PropertyAssignments(PAs))
rule ^PropertyAssignments(                          .PropertyAssignments) =>                                %nil
//
syntax Exp ::= "^PropertyAssignment" "(" PropertyAssignment ")" [function]
rule ^PropertyAssignment(P:PropertyName : E:Expression) => %prop(^PropertyName(P), ^Expression(E))
rule ^PropertyAssignment(G:Name P:PropertyName (        ) { Ss:SourceElements }) => %get(^PropertyName(P),           ^SourceElements(Ss)) when StringOfName(G) ==K "get"
rule ^PropertyAssignment(S:Name P:PropertyName ( X:Name ) { Ss:SourceElements }) => %set(^PropertyName(P), ^Name(X), ^SourceElements(Ss)) when StringOfName(S) ==K "set"
//
syntax String ::= "^PropertyName" "(" PropertyName ")" [function]
rule ^PropertyName(N:Name)   => StringOfName(N)
rule ^PropertyName(S:MyString) => ^String(MyString2String(S))
rule ^PropertyName(I:Int)    => Int2String(I)
rule ^PropertyName(F:MyFloat)  => Float2String(MyFloat2Float(F))

// comma
rule ^Expression(( Es:ExpressionS )) => ^ExpressionS2Comma(Es)

// function expression
rule ^Expression(function F:Name ( Ps:Parameters ) { Ss:SourceElements }) => %fun(^Name(F), ^Parameters(Ps), ^SourceElements(Ss))
rule ^Expression(function        ( Ps:Parameters ) { Ss:SourceElements }) => %fun(          ^Parameters(Ps), ^SourceElements(Ss))

// member, new, call
rule ^Expression('_`[_`]::Expression*Expression->Expression(E:MemberExpression,,Es:Expressions)) => %mem(^Expression(E), ^Expressions2Comma(Es))
rule ^Expression('_`[_`]::Expression*Expression->Expression(E:CallExpression  ,,Es:Expressions)) => %mem(^Expression(E), ^Expressions2Comma(Es))
rule ^Expression(       '_._::Expression*Name->Expression(E:MemberExpression,,X:Name        )) => %mem(^Expression(E), %con(StringOfName(X)))
rule ^Expression(       '_._::Expression*Name->Expression(E:CallExpression  ,,X:Name        )) => %mem(^Expression(E), %con(StringOfName(X)))
//
rule ^Expression(new E:MemberExpression ( Es:Expressions )) => %new(^Expression(E), ^Expressions2List(Es))
rule ^Expression(new E:NewExpression                      ) => %new(^Expression(E), %nil)
//
rule ^Expression(    E:MemberExpression ( Es:Expressions )) => %call(^Expression(E), ^Expressions2List(Es))
rule ^Expression(    E:CallExpression   ( Es:Expressions )) => %call(^Expression(E), ^Expressions2List(Es))

// op
rule ^Expression(E:Expression ++) => %post(^Expression(E), %inc)
rule ^Expression(E:Expression --) => %post(^Expression(E), %dec)
//
rule ^Expression(delete E:Expression) => %pre(%delete, ^Expression(E))
rule ^Expression(void   E:Expression) => %pre(%void,   ^Expression(E))
rule ^Expression(typeof E:Expression) => %pre(%typeof, ^Expression(E))
rule ^Expression(++     E:Expression) => %pre(%inc,    ^Expression(E))
rule ^Expression(--     E:Expression) => %pre(%dec,    ^Expression(E))
rule ^Expression(+      E:Expression) => %pre(%plus,   ^Expression(E))
rule ^Expression(-      E:Expression) => %pre(%minus,  ^Expression(E))
rule ^Expression(~      E:Expression) => %pre(%tilde,  ^Expression(E))
rule ^Expression(!      E:Expression) => %pre(%bang,   ^Expression(E))
//
rule ^Expression(E1:Expression *          E2:Expression) => %bop(%times,       ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression /          E2:Expression) => %bop(%div,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression %          E2:Expression) => %bop(%mod,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression +          E2:Expression) => %bop(%plus,        ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression -          E2:Expression) => %bop(%minus,       ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression <<         E2:Expression) => %bop(%lshift,      ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression >>         E2:Expression) => %bop(%rshift,      ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression >>>        E2:Expression) => %bop(%rshiftshift, ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression <          E2:Expression) => %bop(%lt,          ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression >          E2:Expression) => %bop(%gt,          ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression <=         E2:Expression) => %bop(%le,          ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression >=         E2:Expression) => %bop(%ge,          ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression instanceof E2:Expression) => %bop(%instanceof,  ^Expression(E1), ^Expression(E2))
rule ^Expression('_in_::Expression*Expression->Expression(E1:Expression,,E2:Expression)) => %bop(%in, ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression ==         E2:Expression) => %bop(%eq,          ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression !=         E2:Expression) => %bop(%neq,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression ===        E2:Expression) => %bop(%eqs,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression !==        E2:Expression) => %bop(%neqs,        ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression &          E2:Expression) => %bop(%amp,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression ^          E2:Expression) => %bop(%caret,       ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression |          E2:Expression) => %bop(%bar,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression &&         E2:Expression) => %bop(%and,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:Expression ||         E2:Expression) => %bop(%or,          ^Expression(E1), ^Expression(E2))
//
rule ^Expression(E1:Expression ? E2:Expression : E3:Expression) => %cond(^Expression(E1), ^Expression(E2), ^Expression(E3))
//
rule ^Expression(E1:LeftExpression =    E2:Expression) => %bop(%assign,            ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression *=   E2:Expression) => %bopassign(%times,       ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression /=   E2:Expression) => %bopassign(%div,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression %=   E2:Expression) => %bopassign(%mod,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression +=   E2:Expression) => %bopassign(%plus,        ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression -=   E2:Expression) => %bopassign(%minus,       ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression <<=  E2:Expression) => %bopassign(%lshift,      ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression >>=  E2:Expression) => %bopassign(%rshift,      ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression >>>= E2:Expression) => %bopassign(%rshiftshift, ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression &=   E2:Expression) => %bopassign(%amp,         ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression ^=   E2:Expression) => %bopassign(%caret,       ^Expression(E1), ^Expression(E2))
rule ^Expression(E1:LeftExpression |=   E2:Expression) => %bopassign(%bar,         ^Expression(E1), ^Expression(E2))

// identifier
syntax Var ::= "^Name" "(" Name ")" [function]
rule ^Name(X:Name) => StringOfName(X)

syntax String ::= "^String" "(" String ")" [function]
rule ^String(S:String) => processWhiteSpaces(S)

syntax String ::= "processWhiteSpaces" "(" String ")" [function]

rule processWhiteSpaces(S) => S when findString(S, "\r"    , 0) ==Int -1
                           //andBool findString(S, "\n"    , 0) ==Int -1
                             andBool findString(S, "\u2028", 0) ==Int -1
                             andBool findString(S, "\u2029", 0) ==Int -1
                             andBool findString(S, "\t"    , 0) ==Int -1
                             andBool findString(S, "\u000B", 0) ==Int -1
                             andBool findString(S, "\f"    , 0) ==Int -1
                           //andBool findString(S, "\u0020", 0) ==Int -1
                             andBool findString(S, "\u00A0", 0) ==Int -1
                             andBool findString(S, "\uFEFF", 0) ==Int -1
                             andBool findString(S, "\u1680", 0) ==Int -1
                             andBool findString(S, "\u180E", 0) ==Int -1
                             andBool findString(S, "\u2000", 0) ==Int -1
                             andBool findString(S, "\u2001", 0) ==Int -1
                             andBool findString(S, "\u2002", 0) ==Int -1
                             andBool findString(S, "\u2003", 0) ==Int -1
                             andBool findString(S, "\u2004", 0) ==Int -1
                             andBool findString(S, "\u2005", 0) ==Int -1
                             andBool findString(S, "\u2006", 0) ==Int -1
                             andBool findString(S, "\u2007", 0) ==Int -1
                             andBool findString(S, "\u2008", 0) ==Int -1
                             andBool findString(S, "\u2009", 0) ==Int -1
                             andBool findString(S, "\u200A", 0) ==Int -1
                             andBool findString(S, "\u202F", 0) ==Int -1
                             andBool findString(S, "\u205F", 0) ==Int -1
                             andBool findString(S, "\u3000", 0) ==Int -1

// Table 3 — Line Terminator Characters
/*
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\n"    , "\n")) when findString(S, "\n"    , 0) =/=Int -1  // \u000A Line Feed           <LF>
*/
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\r"    , "\n")) when findString(S, "\r"    , 0) =/=Int -1  // \u000D Carriage Return     <CR>
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2028", "\n")) when findString(S, "\u2028", 0) =/=Int -1  // \u2028 Line separator      <LS>
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2029", "\n")) when findString(S, "\u2029", 0) =/=Int -1  // \u2029 Paragraph separator <PS>

// Table 2 — Whitespace Characters
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\t"    , " " )) when findString(S, "\t"    , 0) =/=Int -1  // \u0009                Tab                                  <TAB>
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u000B", " " )) when findString(S, "\u000B", 0) =/=Int -1  // \u000B                Vertical Tab                         <VT>
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\f"    , " " )) when findString(S, "\f"    , 0) =/=Int -1  // \u000C                Form Feed                            <FF>
/*
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u0020", " " )) when findString(S, "\u0020", 0) =/=Int -1  // \u0020                Space                                <SP>
*/
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u00A0", " " )) when findString(S, "\u00A0", 0) =/=Int -1  // \u00A0                No-break space                       <NBSP>
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\uFEFF", " " )) when findString(S, "\uFEFF", 0) =/=Int -1  // \uFEFF                Byte Order Mark                      <BOM>
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u1680", " " )) when findString(S, "\u1680", 0) =/=Int -1  // Other category "Zs"   Any other Unicode "space separator"  <USP>
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u180E", " " )) when findString(S, "\u180E", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2000", " " )) when findString(S, "\u2000", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2001", " " )) when findString(S, "\u2001", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2002", " " )) when findString(S, "\u2002", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2003", " " )) when findString(S, "\u2003", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2004", " " )) when findString(S, "\u2004", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2005", " " )) when findString(S, "\u2005", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2006", " " )) when findString(S, "\u2006", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2007", " " )) when findString(S, "\u2007", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2008", " " )) when findString(S, "\u2008", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u2009", " " )) when findString(S, "\u2009", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u200A", " " )) when findString(S, "\u200A", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u202F", " " )) when findString(S, "\u202F", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u205F", " " )) when findString(S, "\u205F", 0) =/=Int -1  //
rule processWhiteSpaces(S:String) => processWhiteSpaces(replaceAll(S, "\u3000", " " )) when findString(S, "\u3000", 0) =/=Int -1  //

// Internal Semantic Methods API Call

rule ^Expression(N:APIName ( Es:Expressions )) => %call(%var(^APIName(N)), ^Expressions2List(Es))

syntax Var ::= "^APIName" "(" APIName ")" [function]
rule ^APIName(X:APIName) => StringOfAPIName(X)

endmodule

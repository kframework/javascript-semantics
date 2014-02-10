require "js-orig-syntax.k"
require "js-core-syntax.k"

module JS-TRANS

imports JS-ORIG-SYNTAX
imports JS-CORE-SYNTAX

// top-level
syntax Stmt ::= "^SourceElements" "(" SourceElements ")"
rule ^SourceElements(S:SourceElement Ss:SourceElements) => %seq(^SourceElement(S), ^SourceElements(Ss)) when Ss =/=K .SourceElements [macro]
rule ^SourceElements(S:SourceElement   .SourceElements) =>      ^SourceElement(S) [macro]
rule ^SourceElements(                  .SourceElements) =>                         %emptyStmt [macro]
//
syntax Stmt ::= "^SourceElement" "(" SourceElement ")"
rule ^SourceElement(S:Statement)          => ^Statement(S) [macro]
rule ^SourceElement(F:FunctionExpression) => ^FunctionDeclaration(F) [macro]

// function declaration
syntax Stmt ::= "^FunctionDeclaration" "(" FunctionExpression ")"
rule ^FunctionDeclaration(function F:Name ( Ps:Parameters ) { Ss:SourceElements }) => %fdecl(^Name(F), ^Parameters(Ps), ^SourceElements(Ss)) [macro]
//
syntax Exps ::= "^Parameters" "(" Parameters ")"
rule ^Parameters(X:Name, Xs:Parameters) => %cons(%var(^Name(X)), ^Parameters(Xs)) [macro]
rule ^Parameters(          .Parameters) =>                       %nil [macro]

// statements block
syntax Stmt ::= "^Statements" "(" Statements ")"
rule ^Statements(S:Statement Ss:Statements) => %seq(^Statement(S), ^Statements(Ss)) when Ss =/=K .Statements [macro]
rule ^Statements(S:Statement   .Statements) =>      ^Statement(S) [macro]
rule ^Statements(              .Statements) =>                     %emptyStmt [macro]
//
rule ^Statement({ Ss:Statements }) => ^Statements(Ss) [macro]

// statement
syntax Stmt ::= "^Statement" "(" Statement ")"

// variable declaration
rule ^Statement(var VD:VariableDeclaration, VDs:VariableDeclarationS ;) => %seq(^VariableDeclaration(VD), ^Statement(var VDs ;)) when VDs =/=K .VariableDeclarationS [macro]
rule ^Statement(var VD:VariableDeclaration,    .VariableDeclarationS ;) =>      ^VariableDeclaration(VD) [macro]
rule ^Statement(var                            .VariableDeclarationS ;) =>                                %emptyStmt [macro]
//
syntax Stmt ::= "^VariableDeclaration" "(" VariableDeclaration ")"
rule ^VariableDeclaration(X:Name               ) =>      %vdecl(^Name(X)) [macro]
rule ^VariableDeclaration(X:Name = E:Expression) => %seq(%vdecl(^Name(X)), %exp(%bop(%assign, %var(^Name(X)), ^Expression(E)))) [macro]

// empty statement
rule ^Statement(;) => %emptyStmt [macro]

// expression statement
rule ^Statement(Es:ExpressionS ;) => %exp(^Expressions2Comma(Es)) [macro]

// if
rule ^Statement(if ( Es:ExpressionS ) S1:Statement                  ) => %if(^Expressions2Comma(Es), ^Statement(S1), %emptyStmt) [macro]
rule ^Statement(if ( Es:ExpressionS ) S1:Statement else S2:Statement) => %if(^Expressions2Comma(Es), ^Statement(S1), ^Statement(S2)) [macro]

// do-while
rule ^Statement(do S:Statement while ( Es:ExpressionS ) ;) => %do(^Statement(S), ^Expressions2Comma(Es)) [macro]

// while
rule ^Statement(while ( Es:ExpressionS ) S:Statement) => %while(^Expressions2Comma(Es), ^Statement(S)) [macro]

// for
rule ^Statement(for (              Es0:Expressions ; Es1:Expressions ; Es2:Expressions ) S:Statement) => %for(%exp(^Expressions2Comma(Es0)), ^Expressions2Comma(Es1), ^Expressions2Comma(Es2), ^Statement(S)) [macro]
rule ^Statement(for ( var VDs:VariableDeclarationS ; Es1:Expressions ; Es2:Expressions ) S:Statement) => %for(^Statement(var VDs ;),         ^Expressions2Comma(Es1), ^Expressions2Comma(Es2), ^Statement(S)) [macro]

// for-in
rule ^Statement(for (          E:LeftExpression in Es:ExpressionS ) S:Statement) => %forin(%emptyStmt,                  ^Expression(E), ^Expressions2Comma(Es), ^Statement(S)) [macro]
rule ^Statement(for ( var N:Name                in Es:ExpressionS ) S:Statement) => %forin(^VariableDeclaration(N    ), %var(^Name(N)), ^Expressions2Comma(Es), ^Statement(S)) [macro]
rule ^Statement(for ( var N:Name = E:Expression in Es:ExpressionS ) S:Statement) => %forin(^VariableDeclaration(N = E), %var(^Name(N)), ^Expressions2Comma(Es), ^Statement(S)) [macro]

// continue
rule ^Statement(continue        ;) => %continue("")
rule ^Statement(continue L:Name ;) => %continue(^Name(L))

// break
rule ^Statement(break        ;) => %break("")
rule ^Statement(break L:Name ;) => %break(^Name(L))

// return
rule ^Statement(return                ;) => %return(%emptyExp) [macro]
rule ^Statement(return Es:ExpressionS ;) => %return(^Expressions2Comma(Es)) [macro]

// with
rule ^Statement(with ( Es:ExpressionS ) S:Statement) => %with(^Expressions2Comma(Es), ^Statement(S)) [macro]

// label
rule ^Statement(L:Name : S:Statement) => %label(^Name(L), ^Statement(S)) [macro]

// switch
// TODO:

// throw
rule ^Statement(throw Es:ExpressionS ;) => %throw(^Expressions2Comma(Es)) [macro]

// try
rule ^Statement(try { Ss1:Statements } catch ( X:Name ) { Ss2:Statements } finally { Ss3:Statements }) => %try(^Statements(Ss1), ^Name(X), ^Statements(Ss2), ^Statements(Ss3)) [macro]
rule ^Statement(try { Ss1:Statements } catch ( X:Name ) { Ss2:Statements }                           ) => %try(^Statements(Ss1), ^Name(X), ^Statements(Ss2), %emptyStmt      ) [macro]
rule ^Statement(try { Ss1:Statements }                                     finally { Ss3:Statements }) => %try(^Statements(Ss1),                             ^Statements(Ss3)) [macro]

// debugger
// TODO:

// print
rule ^Statement(print ( E:Expression ) ;) => %print(^Expression(E)) [macro]

// comma expressions
syntax Exp ::= "^Expressions2Comma" "(" ExpressionS ")"
             | "^Expressions2Comma" "(" Expressions ")"
rule ^Expressions2Comma(E:Expression, Es:ExpressionS) => %comma(^Expression(E), ^Expressions2Comma(Es)) when Es =/=K .ExpressionS [macro]
rule ^Expressions2Comma(E:Expression, Es:Expressions) => %comma(^Expression(E), ^Expressions2Comma(Es)) when Es =/=K .ExpressionS [macro]
rule ^Expressions2Comma(E:Expression,   .ExpressionS) =>        ^Expression(E) [macro]
rule ^Expressions2Comma(E:Expression,   .Expressions) =>        ^Expression(E) [macro]
rule ^Expressions2Comma(                .ExpressionS) =>                        %emptyExp [macro]
rule ^Expressions2Comma(                .Expressions) =>                        %emptyExp [macro]

// list expressions
syntax Exps ::= "^Expressions2List" "(" ExpressionS ")"
              | "^Expressions2List" "(" Expressions ")"
rule ^Expressions2List(E:Expression, Es:ExpressionS) => %cons(^Expression(E), ^Expressions2List(Es)) [macro]
rule ^Expressions2List(E:Expression, Es:Expressions) => %cons(^Expression(E), ^Expressions2List(Es)) [macro]
rule ^Expressions2List(                .ExpressionS) =>                       %nil [macro]
rule ^Expressions2List(                .Expressions) =>                       %nil [macro]

// expression
syntax Exp ::= "^Expression" "(" Expression ")"

// atomic expression
rule ^Expression(X:Name)   => %var(^Name(X)) [macro]
rule ^Expression(this)     => %con(%this) [macro]
rule ^Expression(null)     => %con(%null) [macro]
rule ^Expression(B:Bool)   => %con(B) [macro]
rule ^Expression(I:Int)    => %con(I) [macro]
rule ^Expression(F:Float)  => %con(F) [macro]
rule ^Expression(S:String) => %con(S) [macro]

// array
rule ^Expression([ AEs:ArrayElements ]) => %arr(^ArrayElements(AEs)) [macro]
//
syntax Exps ::= "^ArrayElements" "(" ArrayElements ")"
rule ^ArrayElements(AE:ExpressionOpt, AEs:ArrayElements) => %cons(^ArrayElement(AE), ^ArrayElements(AEs)) [macro]
rule ^ArrayElements(                     .ArrayElements) =>                          %nil [macro]
//
syntax Exp ::= "^ArrayElement" "(" ExpressionOpt ")"
rule ^ArrayElement(E:Expression) => ^Expression(E) [macro]
rule ^ArrayElement('epsilonExpression(.KList)) => %emptyExp [macro]

// object
rule ^Expression({ PAs:PropertyAssignments }) => %obj(^PropertyAssignments(PAs)) [macro]
//
syntax Exps ::= "^PropertyAssignments" "(" PropertyAssignments ")"
rule ^PropertyAssignments(PA:PropertyAssignment, PAs:PropertyAssignments) => %cons(^PropertyAssignment(PA), ^PropertyAssignments(PAs)) [macro]
rule ^PropertyAssignments(                          .PropertyAssignments) =>                                %nil [macro]
//
syntax Exp ::= "^PropertyAssignment" "(" PropertyAssignment ")"
rule ^PropertyAssignment(P:PropertyName : E:Expression) => %prop(^PropertyName(P), ^Expression(E)) [macro]
rule ^PropertyAssignment(Get:Name P:PropertyName (        ) { Ss:Statements }) => %get(^PropertyName(P),           ^Statements(Ss)) when StringOfName(Get) ==K "get" [macro]
rule ^PropertyAssignment(Set:Name P:PropertyName ( X:Name ) { Ss:Statements }) => %set(^PropertyName(P), ^Name(X), ^Statements(Ss)) when StringOfName(Set) ==K "set" [macro]
//
syntax String ::= "^PropertyName" "(" PropertyName ")"
rule ^PropertyName(N:Name)   => StringOfName(N) [macro]
rule ^PropertyName(S:String) => S [macro]
rule ^PropertyName(I:Int)    => Int2String(I) [macro]
rule ^PropertyName(F:Float)  => Float2String(F) [macro]

// comma
rule ^Expression(( Es:ExpressionS )) => ^Expressions2Comma(Es) [macro]

// function expression
rule ^Expression(function F:Name ( Ps:Parameters ) { Ss:SourceElements }) => %fun(^Name(F), ^Parameters(Ps), ^SourceElements(Ss)) [macro]
rule ^Expression(function        ( Ps:Parameters ) { Ss:SourceElements }) => %fun(          ^Parameters(Ps), ^SourceElements(Ss)) [macro]

// member, new, call
rule ^Expression(    E:MemberExpression [ Es:Expressions ]) => %mem(^Expression(E), ^Expressions2Comma(Es)) [macro]
rule ^Expression(    E:CallExpression   [ Es:Expressions ]) => %mem(^Expression(E), ^Expressions2Comma(Es)) [macro]
rule ^Expression(    E:MemberExpression . X:Name          ) => %mem(^Expression(E), %con(StringOfName(X))) [macro]
rule ^Expression(    E:CallExpression   . X:Name          ) => %mem(^Expression(E), %con(StringOfName(X))) [macro]
//
rule ^Expression(new E:MemberExpression ( Es:Expressions )) => %new(^Expression(E), ^Expressions2List(Es)) [macro]
rule ^Expression(new E:NewExpression                      ) => %new(^Expression(E), %nil) [macro]
//
rule ^Expression(    E:MemberExpression ( Es:Expressions )) => %call(^Expression(E), ^Expressions2List(Es)) [macro]
rule ^Expression(    E:CallExpression   ( Es:Expressions )) => %call(^Expression(E), ^Expressions2List(Es)) [macro]

// op
rule ^Expression(E:Expression ++) => %post(^Expression(E), %inc) [macro]
rule ^Expression(E:Expression --) => %post(^Expression(E), %dec) [macro]
//
rule ^Expression(delete E:Expression) => %pre(%delete, ^Expression(E)) [macro]
rule ^Expression(void   E:Expression) => %pre(%void,   ^Expression(E)) [macro]
rule ^Expression(typeof E:Expression) => %pre(%typeof, ^Expression(E)) [macro]
rule ^Expression(++     E:Expression) => %pre(%inc,    ^Expression(E)) [macro]
rule ^Expression(--     E:Expression) => %pre(%dec,    ^Expression(E)) [macro]
rule ^Expression(+      E:Expression) => %pre(%plus,   ^Expression(E)) [macro]
rule ^Expression(-      E:Expression) => %pre(%minus,  ^Expression(E)) [macro]
rule ^Expression(~      E:Expression) => %pre(%tilde,  ^Expression(E)) [macro]
rule ^Expression(!      E:Expression) => %pre(%bang,   ^Expression(E)) [macro]
//
rule ^Expression(E1:Expression *          E2:Expression) => %bop(%times,       ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression /          E2:Expression) => %bop(%div,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression %          E2:Expression) => %bop(%mod,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression +          E2:Expression) => %bop(%plus,        ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression -          E2:Expression) => %bop(%minus,       ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression <<         E2:Expression) => %bop(%lshift,      ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression >>         E2:Expression) => %bop(%rshift,      ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression >>>        E2:Expression) => %bop(%rshiftshift, ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression <          E2:Expression) => %bop(%lt,          ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression >          E2:Expression) => %bop(%gt,          ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression <=         E2:Expression) => %bop(%le,          ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression >=         E2:Expression) => %bop(%ge,          ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression instanceof E2:Expression) => %bop(%instanceof,  ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression in         E2:Expression) => %bop(%in,          ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression ==         E2:Expression) => %bop(%eq,          ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression !=         E2:Expression) => %bop(%neq,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression ===        E2:Expression) => %bop(%eqs,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression !==        E2:Expression) => %bop(%neqs,        ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression &          E2:Expression) => %bop(%amp,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression ^          E2:Expression) => %bop(%caret,       ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression |          E2:Expression) => %bop(%bar,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression &&         E2:Expression) => %bop(%and,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:Expression ||         E2:Expression) => %bop(%or,          ^Expression(E1), ^Expression(E2)) [macro]
//
rule ^Expression(E1:Expression ? E2:Expression : E3:Expression) => %cond(^Expression(E1), ^Expression(E2), ^Expression(E3)) [macro]
//
rule ^Expression(E1:LeftExpression =    E2:Expression) => %bop(%assign,            ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression *=   E2:Expression) => %bop(%timesassign,       ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression /=   E2:Expression) => %bop(%divassign,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression %=   E2:Expression) => %bop(%modassign,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression +=   E2:Expression) => %bop(%plusassign,        ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression -=   E2:Expression) => %bop(%minusassign,       ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression <<=  E2:Expression) => %bop(%lshiftassign,      ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression >>=  E2:Expression) => %bop(%rshiftassign,      ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression >>>= E2:Expression) => %bop(%rshiftshiftassign, ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression &=   E2:Expression) => %bop(%ampassign,         ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression ^=   E2:Expression) => %bop(%caretassign,       ^Expression(E1), ^Expression(E2)) [macro]
rule ^Expression(E1:LeftExpression |=   E2:Expression) => %bop(%barassign,         ^Expression(E1), ^Expression(E2)) [macro]

// identifier
syntax Var ::= "^Name" "(" Name ")"
rule ^Name(X:Name) => StringOfName(X) [macro]

endmodule

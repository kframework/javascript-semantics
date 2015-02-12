//////////////////////////////////////////////////////////////////////////////
// Pseudo-code evaluation
//////////////////////////////////////////////////////////////////////////////

syntax PseudoCodes ::= PseudoCode PseudoCodes
                     | PseudoCode
syntax PseudoCode  ::= "Let" Id "=" K ";" [seqstrict(2)]
                     | "Do"  K ";"
                     | "DoI" K ";"
                     | "If" K "=" K "then" "{" PseudoCodes "}" "else" "{" PseudoCodes "}" [seqstrict(1,2)]
                     | "If" K "=" K "then" "{" PseudoCodes "}" ";"                        [seqstrict(1,2)]
                     | "Return" K ";" [seqstrict(1)]
                     | "Return"   ";"
                     | "Nop" ";"
syntax Exp ::= Id

rule PC:PseudoCode PCs:PseudoCodes => PC ~> PCs

//rule Let X:Id = V:KResult; ~> PCs:PseudoCodes => PCs[V / X]

/*
rule Let X:Id = V:KResult; ~> PCs:PseudoCodes => #visit(PCs, '#@Replace`(_`,_`), V, '_==K_, X)
//
syntax KItem ::= "#@Replace" "(" K "," K ")" [function]
rule #@Replace(_, K) => K
*/

rule <k> Let X:Id = V:KResult; => .K ... </k>
     <pseudoEnv> (.Map => X |-> V) _:Map </pseudoEnv>
rule <k> X:Id => V ... </k>
     <pseudoEnv> X |-> V _:Map </pseudoEnv>

rule Do  K; => K
rule DoI K; => K ~> @Ignore
rule If V1:KResult = V2:KResult then { PCs } else { _   } => PCs when V1 ==K  V2 [pseudoIf]
rule If V1:KResult = V2:KResult then { _   } else { PCs } => PCs when V1 =/=K V2 [pseudoIf]
rule If V1:KResult = V2:KResult then { PCs } ;            => PCs when V1 ==K  V2 [pseudoIf]
rule If V1:KResult = V2:KResult then { _   } ;            => .K  when V1 =/=K V2 [pseudoIf]
rule Return V:KResult; => V
rule Return; => .K
rule Nop; => .K

syntax KItem ::= "BEGIN" PseudoCodes "END"
syntax PseudoCode ::= "Exit" ";"

rule <k> BEGIN PCs:PseudoCodes END ~> K => PCs ~> Exit; </k>
     <pseudoCtx>
       <pseudoStack> (.List => ListItem(@pseudo(K,E))) _:List </pseudoStack>
       <pseudoEnv> E:Map => .Map </pseudoEnv>
     </pseudoCtx>

rule <k> V:KResult ~> Exit; ~> _ => V ~> K </k> <pseudoCtx> <pseudoStack> (ListItem(@pseudo(K,E)) => .List) _:List </pseudoStack> <pseudoEnv> _ => E </pseudoEnv> </pseudoCtx>
rule <k>              Exit; ~> _ =>      K </k> <pseudoCtx> <pseudoStack> (ListItem(@pseudo(K,E)) => .List) _:List </pseudoStack> <pseudoEnv> _ => E </pseudoEnv> </pseudoCtx>

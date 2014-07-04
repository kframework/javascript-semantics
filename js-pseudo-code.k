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
rule Let X:Id = V:KResult; ~> PCs:PseudoCodes => PCs[V / X]
rule Do  K; => K
rule DoI K; => K ~> @Ignore
rule If V1:KResult = V2:KResult then { PCs } else { _   } => PCs when V1 ==K  V2
rule If V1:KResult = V2:KResult then { _   } else { PCs } => PCs when V1 =/=K V2
rule If V1:KResult = V2:KResult then { PCs } ;            => PCs when V1 ==K  V2
rule If V1:KResult = V2:KResult then { _   } ;            => .K  when V1 =/=K V2
rule Return V:KResult; => V
rule Return; => .K
rule Nop; => .K

syntax K ::= "BEGIN" PseudoCodes "END"
syntax PseudoCode ::= "Exit" ";"

rule <k> BEGIN PCs:PseudoCodes END ~> K => PCs ~> Exit; </k>
     <pseudoStack> (. => @pseudo(K)) _ </pseudoStack>

rule <k> V:KResult ~> Exit; ~> _ => V ~> K </k> <pseudoStack> (@pseudo(K) => .) _ </pseudoStack>
rule <k>              Exit; ~> _ =>      K </k> <pseudoStack> (@pseudo(K) => .) _ </pseudoStack>

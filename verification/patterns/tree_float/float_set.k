module FLOAT-SET
  imports FLOAT-HOOKS
  syntax FloatSet ::= FloatSet "U" FloatSet           [function, left, smtlib(float_set_cup)]
                  | ".FloatSet"                       [function, smtlib(float_set_emp)]
                  | "{" Float "}"                     [function, smtlib(float_set_ele), klabel(float_set_ele)]
                  | FloatSet "-FloatSet" FloatSet     [function, smtlib(float_set_dif)]
  syntax Bool ::= Float "inFloatSet" FloatSet         [function, smtlib(float_set_mem)]
                | FloatSet  "<FloatSet" FloatSet      [function, smtlib(float_set_lt)]
                | FloatSet "<=FloatSet" FloatSet      [function, smtlib(float_set_le)]
  rule S:FloatSet U .FloatSet => S    [lemma]
  rule .FloatSet U S:FloatSet => S    [lemma]

  rule I:Float inFloatSet (S1:FloatSet U S2:FloatSet)
    => (I inFloatSet S1) orBool (I inFloatSet S2)
    [lemma]
  rule _:Float inFloatSet .FloatSet => false                    [lemma]
  rule I1:Float inFloatSet { I2:Float } => I1 ==K I2            [lemma]

  rule S:FloatSet <FloatSet (S1:FloatSet U S2:FloatSet)
    => (S:FloatSet <FloatSet S1:FloatSet) andBool (S:FloatSet <FloatSet S2:FloatSet)
    [lemma]
  rule (S1:FloatSet U S2:FloatSet) <FloatSet S:FloatSet
    => (S1:FloatSet <FloatSet S:FloatSet) andBool (S2:FloatSet <FloatSet S:FloatSet)
    [lemma]
  rule _:FloatSet <FloatSet .FloatSet => true                   [lemma]
  rule .FloatSet <FloatSet _:FloatSet => true                   [lemma]
  rule { I1:Float } <FloatSet { I2:Float } => I1 <Float I2      [lemma]

  rule S:FloatSet <=FloatSet (S1:FloatSet U S2:FloatSet)
    => (S:FloatSet <=FloatSet S1:FloatSet) andBool (S:FloatSet <=FloatSet S2:FloatSet)
    [lemma]
  rule (S1:FloatSet U S2:FloatSet) <=FloatSet S:FloatSet
    => (S1:FloatSet <=FloatSet S:FloatSet) andBool (S2:FloatSet <=FloatSet S:FloatSet)
    [lemma]
  rule _:FloatSet <=FloatSet .FloatSet => true                  [lemma]
  rule .FloatSet <=FloatSet _:FloatSet => true                  [lemma]
  rule { I1:Float } <=FloatSet { I2:Float } => I1 <=Float I2    [lemma]

  rule S:FloatSet -FloatSet (S1:FloatSet U S2:FloatSet)
    => (S:FloatSet -FloatSet S1:FloatSet) U (S:FloatSet -FloatSet S2:FloatSet)
    [lemma]
  rule (S1:FloatSet U S2:FloatSet) -FloatSet S:FloatSet
    => (S1:FloatSet -FloatSet S:FloatSet) U (S2:FloatSet -FloatSet S:FloatSet)
    [lemma]
  rule .FloatSet -FloatSet _:FloatSet => .FloatSet              [lemma]
endmodule


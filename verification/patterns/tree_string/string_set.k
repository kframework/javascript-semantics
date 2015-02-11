module STRING-SET
  imports STRING-HOOKS
  syntax StringSet ::= StringSet "U" StringSet          [function, left, smtlib(string_set_cup)]
                  | ".StringSet"                        [function, smtlib(string_set_emp)]
                  | "{" String "}"                      [function, smtlib(string_set_ele), klabel(string_set_ele)]
                  | StringSet "-StringSet" StringSet    [function, smtlib(string_set_dif)]
  syntax Bool ::= String "inStringSet" StringSet        [function, smtlib(string_set_mem)]
                | StringSet  "<StringSet" StringSet     [function, smtlib(string_set_lt)]
                | StringSet "<=StringSet" StringSet     [function, smtlib(string_set_le)]
  rule S:StringSet U .StringSet => S    [lemma]
  rule .StringSet U S:StringSet => S    [lemma]

  rule I:String inStringSet (S1:StringSet U S2:StringSet)
    => (I inStringSet S1) orBool (I inStringSet S2)
    [lemma]
  rule _:String inStringSet .StringSet => false                     [lemma]
  rule I1:String inStringSet { I2:String } => I1 ==K I2             [lemma]

  rule S:StringSet <StringSet (S1:StringSet U S2:StringSet)
    => (S:StringSet <StringSet S1:StringSet) andBool (S:StringSet <StringSet S2:StringSet)
    [lemma]
  rule (S1:StringSet U S2:StringSet) <StringSet S:StringSet
    => (S1:StringSet <StringSet S:StringSet) andBool (S2:StringSet <StringSet S:StringSet)
    [lemma]
  rule _:StringSet <StringSet .StringSet => true                    [lemma]
  rule .StringSet <StringSet _:StringSet => true                    [lemma]
  rule { I1:String } <StringSet { I2:String } => I1 <String I2      [lemma]

  rule S:StringSet <=StringSet (S1:StringSet U S2:StringSet)
    => (S:StringSet <=StringSet S1:StringSet) andBool (S:StringSet <=StringSet S2:StringSet)
    [lemma]
  rule (S1:StringSet U S2:StringSet) <=StringSet S:StringSet
    => (S1:StringSet <=StringSet S:StringSet) andBool (S2:StringSet <=StringSet S:StringSet)
    [lemma]
  rule _:StringSet <=StringSet .StringSet => true                   [lemma]
  rule .StringSet <=StringSet _:StringSet => true                   [lemma]
  rule { I1:String } <=StringSet { I2:String } => I1 <=String I2    [lemma]

  rule S:StringSet -StringSet (S1:StringSet U S2:StringSet)
    => (S:StringSet -StringSet S1:StringSet) U (S:StringSet -StringSet S2:StringSet)
    [lemma]
  rule (S1:StringSet U S2:StringSet) -StringSet S:StringSet
    => (S1:StringSet -StringSet S:StringSet) U (S2:StringSet -StringSet S:StringSet)
    [lemma]
  rule .StringSet -StringSet _:StringSet => .StringSet              [lemma]
endmodule


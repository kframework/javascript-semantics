// from kernelc/patterns/int_list.k

module STRING-LIST
  imports STRING-SET

  syntax StringSeq ::= StringSeq "@" StringSeq         [left, function, smtlib(smt_seq_concat)]
  syntax StringSeq ::= ".StringSeq"                 [function, smtlib(smt_seq_nil)]
  syntax StringSeq ::= StringSeqItem(K)             [function, smtlib(smt_seq_elem)]

/*
  rule L:StringSeq @ .StringSeq => L                                   [lemma]
  rule .StringSeq @ L:StringSeq => L                                   [lemma]

  rule (L1:StringSeq @ L2:StringSeq) @ L3:StringSeq => L1:StringSeq @ (L2:StringSeq @ L3:StringSeq) [smt-lemma]
  rule L1:StringSeq @ (L2:StringSeq @ L3:StringSeq) => (L1:StringSeq @ L2:StringSeq) @ L3:StringSeq [smt-lemma]
*/

  syntax Int ::= size(StringSeq)                         [function, smtlib(smt_seq_len)]
  rule size(L1:StringSeq @ L2:StringSeq) => size(L1) +Int size(L2)    [lemma]
  rule size(StringSeqItem(_)) => 1                             [lemma]
  rule size(.StringSeq) => 0                                   [lemma]

  syntax String ::= sum(StringSeq)                            [function, smtlib(smt_seq_sum)]
  rule sum(L1:StringSeq @ L2:StringSeq) => sum(L1) +String sum(L2)   [lemma]
  rule sum(StringSeqItem(I:String)) => I                      [lemma]
  rule sum(.StringSeq) => ""                                [lemma]

// TODO: make it rewrite instead of equality
//rule S:String +String "" => S [lemma]
//rule (S1:String +String S2:String) +String S3:String => S1 +String (S2 +String S3) [lemma]

  syntax StringSeq ::= rev(StringSeq)                       [function, smtlib(smt_seq_rev)]
  rule rev(L1:StringSeq @ L2:StringSeq) => rev(L2) @ rev(L1)    [lemma]
  rule rev(StringSeqItem(I:String)) => StringSeqItem(I)    [lemma]
  rule rev(.StringSeq) => .StringSeq                        [lemma]

/*
  syntax IntSeq ::= filterStringSeq(Int, IntSeq)   [function, smtlib(smt_seq_filter)]
  rule filterIntSeq(V, L1 @ L2) => filterIntSeq(V, L1) @ filterIntSeq(V, L2)    [lemma]
  // TODO(AndreiS): this lemma is put directly in z3 because of ite issue
  //rule filterIntSeq(V, [E]) => #if V =/=K E #then [E] #else [] #fi              [lemma]
  rule filterIntSeq(V, []) => []                                                [lemma]
*/

  syntax StringSet ::= list2set(StringSeq)   [function, smtlib(smt_seq2set)]
  rule list2set(L1:StringSeq @ L2:StringSeq) => list2set(L1) U list2set(L2)
    [lemma, smt-lemma]
  rule list2set(StringSeqItem(I:String)) => { I }   [lemma, smt-lemma]
  rule list2set(.StringSeq) => .StringSet           [lemma, smt-lemma]

  syntax Bool ::= sorted(StringSeq)    [function, smtlib(smt_seq_sorted)]
  // TODO(AndreiS): add support for specifying Z3 triggers
  //rule sorted(L1 @ L2)
  //  => intseq2intset(L1) <=IntSet intseq2intset(L2) andBool sorted(L1) andBool sorted(L2)
  //  [smt-lemma]
  /*
  rule sorted(StringSeqItem(I)) => true    [smt-lemma]
  rule sorted(.StringSeq) => true          [smt-lemma]
  */
endmodule


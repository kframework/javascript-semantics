; from include/z3/list.smt2

(set-option :auto-config false)
(set-option :smt.mbqi false)

; int extra
(define-fun int_max ((x Int) (y Int)) Int (ite (< x y) y x))
(define-fun int_min ((x Int) (y Int)) Int (ite (< x y) x y))
(define-fun int_abs ((x Int)) Int (ite (< x 0) (- 0 x) x))

; bool to int
(define-fun smt_bool2int ((b Bool)) Int (ite b 1 0))

(declare-sort String)

; set axioms
(declare-sort StringSet)

(declare-fun smt_set_cup (StringSet StringSet) StringSet)
(declare-fun smt_set_ele (String) StringSet)
(declare-fun smt_set_emp () StringSet)
(declare-fun smt_set_dif (StringSet StringSet) StringSet)
(declare-fun smt_set_mem (String StringSet) Bool)

(declare-fun smt_set_lt ((StringSet) (StringSet)) Bool)
(declare-fun smt_set_le ((StringSet) (StringSet)) Bool)

; sequence axioms
(declare-sort StringSeq)

(declare-fun smt_seq_concat (StringSeq StringSeq) StringSeq)
(declare-fun smt_seq_elem (String) StringSeq)
(declare-fun smt_seq_nil () StringSeq)
(declare-fun smt_seq_len (StringSeq) Int)

(declare-fun smt_seq_sum (StringSeq) String)
(declare-fun smt_seq2set (StringSeq) StringSet)
(declare-fun smt_seq_sorted (StringSeq) Bool)

(assert (forall ((s1 StringSeq) (s2 StringSeq)) (! (= (smt_seq_sorted (smt_seq_concat s1 s2)) (and (smt_set_le (smt_seq2set s1) (smt_seq2set s2)) (smt_seq_sorted s1) (smt_seq_sorted s2)))
	:pattern ((smt_seq_sorted (smt_seq_concat s1 s2)))
	:pattern ((smt_seq_sorted s1) (smt_seq_sorted s2))
)))

(assert (forall ((e1 String) (e2 String) (s1 StringSeq) (s2 StringSeq)) (= (= (smt_seq_concat (smt_seq_elem e1) s1) (smt_seq_concat (smt_seq_elem e2) s2)) (and (= e1 e2) (= s1 s2)))))

(declare-fun smt_seq_filter (String StringSeq) StringSeq)
(assert (forall ((v String) (e String)) (= (smt_seq_filter v (smt_seq_elem e)) (ite (= v e) smt_seq_nil (smt_seq_elem e)))))

(assert (forall ((s StringSeq)) (>= (smt_seq_len s) 0)))

; end of list.smt2

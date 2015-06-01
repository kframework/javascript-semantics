; from include/z3/sorted_list.smt2

(set-option :auto-config false)
(set-option :smt.mbqi false)

; strings as uninterpreted with a total order relation
(declare-sort String)

(declare-fun string_lt (String String) Bool)
; transitivity
(assert (forall ((x1 String) (x2 String) (x3 String)) (implies (and (string_lt x1 x2) (string_lt x2 x3)) (string_lt x1 x3))))
; irreflexivity
(assert (forall ((x1 String) (x2 String)) (not (and (string_lt x1 x2) (string_lt x2 x1)))))
; total order
(assert (forall ((x1 String) (x2 String)) (or (string_lt x1 x2) (= x1 x2) (string_lt x2 x1))))

(define-fun string_le ((x1 String) (x2 String)) Bool (or (string_lt x1 x2) (= x1 x2)))
(define-fun string_gt ((x1 String) (x2 String)) Bool (string_lt x2 x1))
(define-fun string_ge ((x1 String) (x2 String)) Bool (string_le x2 x1))

; int extra
(define-fun int_max ((x Int) (y Int)) Int (ite (< x y) y x))
(define-fun int_min ((x Int) (y Int)) Int (ite (< x y) x y))
(define-fun int_abs ((x Int)) Int (ite (< x 0) (- 0 x) x))

; bool to int
(define-fun smt_bool2int ((b Bool)) Int (ite b 1 0))

; set axioms
(declare-sort StringSet)

(declare-fun smt_set_cup (StringSet StringSet) StringSet)
(declare-fun smt_set_ele (String) StringSet)
(declare-fun smt_set_emp () StringSet)
(declare-fun smt_set_dif (StringSet StringSet) StringSet)
(declare-fun smt_set_mem (String StringSet) Bool)

(assert (forall ((s1 StringSet) (s2 StringSet) (s3 StringSet)) (= (smt_set_cup (smt_set_cup s1 s2) s3) (smt_set_cup s1 (smt_set_cup s2 s3)))))
(assert (forall ((s1 StringSet) (s2 StringSet)) (= (smt_set_cup s1 s2) (smt_set_cup s2 s1))))
(assert (forall ((e String)) (not (= (smt_set_ele e) smt_set_emp))))

(assert (forall ((s StringSet)) (= (smt_set_cup s s) s)))

(declare-fun smt_set_lt ((StringSet) (StringSet)) Bool)
(declare-fun smt_set_le ((StringSet) (StringSet)) Bool)

(assert (forall ((s1 StringSet) (s2 StringSet) (s3 StringSet)) (= (smt_set_lt (smt_set_cup s1 s2) s3) (and (smt_set_lt s1 s3) (smt_set_lt s2 s3)))))
(assert (forall ((s1 StringSet) (s2 StringSet) (s3 StringSet)) (= (smt_set_lt s1 (smt_set_cup s2 s3)) (and (smt_set_lt s1 s2) (smt_set_lt s1 s3)))))
(assert (forall ((e1 String) (e2 String)) (= (smt_set_lt (smt_set_ele e1) (smt_set_ele e2)) (string_lt e1 e2))))
(assert (forall ((s StringSet)) (smt_set_lt s smt_set_emp)))
(assert (forall ((s StringSet)) (smt_set_lt smt_set_emp s)))

(assert (forall ((s1 StringSet) (s2 StringSet) (s3 StringSet)) (= (smt_set_le (smt_set_cup s1 s2) s3) (and (smt_set_le s1 s3) (smt_set_le s2 s3)))))
(assert (forall ((s1 StringSet) (s2 StringSet) (s3 StringSet)) (= (smt_set_le s1 (smt_set_cup s2 s3)) (and (smt_set_le s1 s2) (smt_set_le s1 s3)))))
(assert (forall ((e1 String) (e2 String)) (= (smt_set_le (smt_set_ele e1) (smt_set_ele e2)) (string_le e1 e2))))
(assert (forall ((s StringSet)) (smt_set_le s smt_set_emp)))
(assert (forall ((s StringSet)) (smt_set_le smt_set_emp s)))

(assert (forall ((e String) (s1 StringSet) (s2 StringSet)) (! (implies (and (smt_set_le s1 (smt_set_ele e)) (smt_set_le (smt_set_ele e) s2)) (smt_set_le s1 s2))
    :pattern ((smt_set_le s1 (smt_set_ele e)) (smt_set_le (smt_set_ele e) s2))
    :pattern ((smt_set_ele e) (smt_set_le s1 s2))
)))
(assert (forall ((e String) (s1 StringSet) (s2 StringSet)) (implies (and (smt_set_lt s1 (smt_set_ele e)) (smt_set_le (smt_set_ele e) s2)) (smt_set_lt s1 s2))))
(assert (forall ((e String) (s1 StringSet) (s2 StringSet)) (implies (and (smt_set_le s1 (smt_set_ele e)) (smt_set_lt (smt_set_ele e) s2)) (smt_set_lt s1 s2))))
(assert (forall ((s1 StringSet) (s2 StringSet)) (implies (smt_set_lt s1 s2) (smt_set_le s1 s2))))

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

; (assert (forall ((e1 String) (e2 String) (s1 StringSeq) (s2 StringSeq)) (= (= (smt_seq_concat (smt_seq_elem e1) s1) (smt_seq_concat (smt_seq_elem e2) s2)) (and (= e1 e2) (= s1 s2)))))
; 
; (declare-fun smt_seq_filter (String StringSeq) StringSeq)
; (assert (forall ((v String) (e String)) (= (smt_seq_filter v (smt_seq_elem e)) (ite (= v e) smt_seq_nil (smt_seq_elem e)))))

; newly added
(assert (forall ((s StringSeq)) (>= (smt_seq_len s) 0)))

; end of list.smt2

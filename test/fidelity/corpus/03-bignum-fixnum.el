;;; 03-bignum-fixnum.el --- Test bignum/fixnum boundaries

(princ "=== Bignum/fixnum boundary tests ===\n")

;; Most-positive-fixnum and most-negative-fixnum
(princ (format "most-positive-fixnum: %S\n" most-positive-fixnum))
(princ (format "most-negative-fixnum: %S\n" most-negative-fixnum))

;; Type checks at boundaries
(princ (format "fixnump most-positive-fixnum: %S\n"
               (fixnump most-positive-fixnum)))
(princ (format "bignump most-positive-fixnum: %S\n"
               (bignump most-positive-fixnum)))

(let ((big-pos (1+ most-positive-fixnum)))
  (princ (format "most-positive-fixnum + 1: %S\n" big-pos))
  (princ (format "fixnump: %S, bignump: %S\n"
                 (fixnump big-pos) (bignump big-pos))))

(let ((big-neg (1- most-negative-fixnum)))
  (princ (format "most-negative-fixnum - 1: %S\n" big-neg))
  (princ (format "fixnump: %S, bignump: %S\n"
                 (fixnump big-neg) (bignump big-neg))))

;; Arithmetic at boundaries
(princ (format "2 * most-positive-fixnum: %S\n" (* 2 most-positive-fixnum)))
(princ (format "most-positive-fixnum + most-negative-fixnum: %S\n"
               (+ most-positive-fixnum most-negative-fixnum)))

;; Large bignum
(let ((huge (expt 2 100)))
  (princ (format "2^100: %S\n" huge))
  (princ (format "bignump: %S\n" (bignump huge))))

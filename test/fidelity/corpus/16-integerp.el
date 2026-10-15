;;; 16-integerp.el --- Test integerp (fourth C→Zig port)

(princ "=== integerp tests (fourth C→Zig leaf port) ===\n")

;; Integer cases (should return t)

;; Fixnums
(princ (format "integerp 42: %S\n" (integerp 42)))
(princ (format "integerp 0: %S\n" (integerp 0)))
(princ (format "integerp -42: %S\n" (integerp -42)))
(princ (format "integerp most-positive-fixnum: %S\n"
               (integerp most-positive-fixnum)))
(princ (format "integerp most-negative-fixnum: %S\n"
               (integerp most-negative-fixnum)))

;; Characters (fixnums)
(princ (format "integerp ?a: %S\n" (integerp ?a)))
(princ (format "integerp ?\\n: %S\n" (integerp ?\n)))

;; Bignums
(princ (format "integerp (expt 2 100): %S\n" (integerp (expt 2 100))))
(princ (format "integerp (1+ most-positive-fixnum): %S\n"
               (integerp (1+ most-positive-fixnum))))
(princ (format "integerp (- (expt 2 100)): %S\n"
               (integerp (- (expt 2 100)))))

;; Floats (CRITICAL: should return nil — NOT integers)
(princ (format "integerp 3.0: %S\n" (integerp 3.0)))
(princ (format "integerp 0.0: %S\n" (integerp 0.0)))
(princ (format "integerp -3.14: %S\n" (integerp -3.14)))
(princ (format "integerp 1.0e10: %S\n" (integerp 1.0e10)))

;; Non-number cases (should return nil)
(princ (format "integerp nil: %S\n" (integerp nil)))
(princ (format "integerp t: %S\n" (integerp t)))
(princ (format "integerp 'x: %S\n" (integerp 'x)))
(princ (format "integerp \"string\": %S\n" (integerp "string")))
(princ (format "integerp \"42\": %S\n" (integerp "42")))
(princ (format "integerp '(1): %S\n" (integerp '(1))))
(princ (format "integerp '(1 2 3): %S\n" (integerp '(1 2 3))))
(princ (format "integerp [1]: %S\n" (integerp [1])))
(princ (format "integerp [1 2 3]: %S\n" (integerp [1 2 3])))

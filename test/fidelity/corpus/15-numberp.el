;;; 15-numberp.el --- Test numberp (third C→Zig port)

(princ "=== numberp tests (third C→Zig leaf port) ===\n")

;; Number cases (should return t)

;; Fixnums
(princ (format "numberp 42: %S\n" (numberp 42)))
(princ (format "numberp 0: %S\n" (numberp 0)))
(princ (format "numberp -42: %S\n" (numberp -42)))
(princ (format "numberp most-positive-fixnum: %S\n"
               (numberp most-positive-fixnum)))
(princ (format "numberp most-negative-fixnum: %S\n"
               (numberp most-negative-fixnum)))

;; Characters (fixnums)
(princ (format "numberp ?a: %S\n" (numberp ?a)))
(princ (format "numberp ?\\n: %S\n" (numberp ?\n)))

;; Bignums
(princ (format "numberp (expt 2 100): %S\n" (numberp (expt 2 100))))
(princ (format "numberp (1+ most-positive-fixnum): %S\n"
               (numberp (1+ most-positive-fixnum))))
(princ (format "numberp (- (expt 2 100)): %S\n"
               (numberp (- (expt 2 100)))))

;; Floats
(princ (format "numberp 3.0: %S\n" (numberp 3.0)))
(princ (format "numberp 0.0: %S\n" (numberp 0.0)))
(princ (format "numberp -3.14: %S\n" (numberp -3.14)))
(princ (format "numberp 1.0e10: %S\n" (numberp 1.0e10)))

;; Non-number cases (should return nil)
(princ (format "numberp nil: %S\n" (numberp nil)))
(princ (format "numberp t: %S\n" (numberp t)))
(princ (format "numberp 'x: %S\n" (numberp 'x)))
(princ (format "numberp \"string\": %S\n" (numberp "string")))
(princ (format "numberp \"42\": %S\n" (numberp "42")))
(princ (format "numberp '(1): %S\n" (numberp '(1))))
(princ (format "numberp '(1 2 3): %S\n" (numberp '(1 2 3))))
(princ (format "numberp [1]: %S\n" (numberp [1])))
(princ (format "numberp [1 2 3]: %S\n" (numberp [1 2 3])))

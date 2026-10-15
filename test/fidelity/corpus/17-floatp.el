;;; 17-floatp.el --- Test floatp (fifth C→Zig port)

(princ "=== floatp tests (fifth C→Zig leaf port) ===\n")

;; Float cases (should return t)

;; Common floats
(princ (format "floatp 3.0: %S\n" (floatp 3.0)))
(princ (format "floatp 3.14: %S\n" (floatp 3.14)))
(princ (format "floatp 0.0: %S\n" (floatp 0.0)))
(princ (format "floatp -1.5: %S\n" (floatp -1.5)))
(princ (format "floatp -3.14: %S\n" (floatp -3.14)))

;; Scientific notation
(princ (format "floatp 1.0e10: %S\n" (floatp 1.0e10)))
(princ (format "floatp 1.0e-10: %S\n" (floatp 1.0e-10)))
(princ (format "floatp -1.0e10: %S\n" (floatp -1.0e10)))

;; Special floats
(princ (format "floatp -0.0: %S\n" (floatp -0.0)))
(princ (format "floatp 1.0e+INF: %S\n" (floatp 1.0e+INF)))
(princ (format "floatp -1.0e+INF: %S\n" (floatp -1.0e+INF)))
(princ (format "floatp 0.0e+NaN: %S\n" (floatp 0.0e+NaN)))

;; Integer cases (CRITICAL: should return nil — integers are NOT floats)

;; Fixnums
(princ (format "floatp 42: %S\n" (floatp 42)))
(princ (format "floatp 0: %S\n" (floatp 0)))
(princ (format "floatp -42: %S\n" (floatp -42)))
(princ (format "floatp most-positive-fixnum: %S\n"
               (floatp most-positive-fixnum)))
(princ (format "floatp most-negative-fixnum: %S\n"
               (floatp most-negative-fixnum)))

;; Characters (fixnums)
(princ (format "floatp ?a: %S\n" (floatp ?a)))
(princ (format "floatp ?\\n: %S\n" (floatp ?\n)))

;; Bignums
(princ (format "floatp (expt 2 100): %S\n" (floatp (expt 2 100))))
(princ (format "floatp (1+ most-positive-fixnum): %S\n"
               (floatp (1+ most-positive-fixnum))))
(princ (format "floatp (- (expt 2 100)): %S\n"
               (floatp (- (expt 2 100)))))

;; Non-number cases (should return nil)
(princ (format "floatp nil: %S\n" (floatp nil)))
(princ (format "floatp t: %S\n" (floatp t)))
(princ (format "floatp 'x: %S\n" (floatp 'x)))
(princ (format "floatp \"string\": %S\n" (floatp "string")))
(princ (format "floatp \"3.14\": %S\n" (floatp "3.14")))
(princ (format "floatp '(1): %S\n" (floatp '(1))))
(princ (format "floatp '(1 2 3): %S\n" (floatp '(1 2 3))))
(princ (format "floatp [1]: %S\n" (floatp [1])))
(princ (format "floatp [3.14]: %S\n" (floatp [3.14])))

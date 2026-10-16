;;; 20-consp.el --- Test consp (eighth C→Zig port)

(princ "=== consp tests (eighth C→Zig leaf port) ===\n")

;; Cons cell cases (should return t)

;; Basic cons cells
(princ (format "consp '(1 . 2): %S\n" (consp '(1 . 2))))
(princ (format "consp (cons 1 2): %S\n" (consp (cons 1 2))))
(princ (format "consp (cons nil nil): %S\n" (consp (cons nil nil))))

;; Lists (built from cons cells)
(princ (format "consp '(1): %S\n" (consp '(1))))
(princ (format "consp '(1 2 3): %S\n" (consp '(1 2 3))))
(princ (format "consp '(a b c): %S\n" (consp '(a b c))))

;; Nested structures
(princ (format "consp '((1 2) (3 4)): %S\n" (consp '((1 2) (3 4)))))
(princ (format "consp '(1 . (2 . 3)): %S\n" (consp '(1 . (2 . 3)))))

;; nil cases (CRITICAL: should return nil)

(princ (format "consp nil: %S\n" (consp nil)))
(princ (format "consp '(): %S\n" (consp '())))

;; Number cases (should return nil)

;; Fixnums
(princ (format "consp 42: %S\n" (consp 42)))
(princ (format "consp 0: %S\n" (consp 0)))
(princ (format "consp -42: %S\n" (consp -42)))
(princ (format "consp most-positive-fixnum: %S\n"
               (consp most-positive-fixnum)))
(princ (format "consp most-negative-fixnum: %S\n"
               (consp most-negative-fixnum)))

;; Characters (fixnums)
(princ (format "consp ?a: %S\n" (consp ?a)))
(princ (format "consp ?\\n: %S\n" (consp ?\n)))

;; Bignums
(princ (format "consp (expt 2 100): %S\n" (consp (expt 2 100))))
(princ (format "consp (1+ most-positive-fixnum): %S\n"
               (consp (1+ most-positive-fixnum))))
(princ (format "consp (- (expt 2 100)): %S\n"
               (consp (- (expt 2 100)))))

;; Floats
(princ (format "consp 3.0: %S\n" (consp 3.0)))
(princ (format "consp 3.14: %S\n" (consp 3.14)))
(princ (format "consp 0.0: %S\n" (consp 0.0)))
(princ (format "consp -3.14: %S\n" (consp -3.14)))
(princ (format "consp 1.0e10: %S\n" (consp 1.0e10)))

;; Symbol cases (should return nil)

;; Basic symbols
(princ (format "consp 'x: %S\n" (consp 'x)))
(princ (format "consp 'foo: %S\n" (consp 'foo)))

;; Keywords
(princ (format "consp :keyword: %S\n" (consp :keyword)))

;; nil and t (symbols, not cons cells)
(princ (format "consp nil (again): %S\n" (consp nil)))
(princ (format "consp t: %S\n" (consp t)))

;; Symbol with string name (still a symbol, not a cons)
(princ (format "consp (intern \"test\"): %S\n" (consp (intern "test"))))

;; String cases (should return nil)

(princ (format "consp \"s\": %S\n" (consp "s")))
(princ (format "consp \"\": %S\n" (consp "")))
(princ (format "consp \"foo\": %S\n" (consp "foo")))
(princ (format "consp \"multi\\nline\": %S\n" (consp "multi\nline")))

;; Vector cases (should return nil)

(princ (format "consp []: %S\n" (consp [])))
(princ (format "consp [1]: %S\n" (consp [1])))
(princ (format "consp [1 2 3]: %S\n" (consp [1 2 3])))

;; Edge cases

;; Cons cells with special values
(princ (format "consp (cons t nil): %S\n" (consp (cons t nil))))
(princ (format "consp (cons nil t): %S\n" (consp (cons nil t))))
(princ (format "consp (cons 'foo 'bar): %S\n" (consp (cons 'foo 'bar))))

;;; 22-listp.el --- Test listp (tenth C→Zig port)

(princ "=== listp tests (tenth C→Zig leaf port) ===\n")

;; List cases (should return t)

;; nil is a list (CRITICAL: opposite of consp)
(princ (format "listp nil: %S\n" (listp nil)))
(princ (format "listp '(): %S\n" (listp '())))

;; Cons cells (all lists)
(princ (format "listp '(1 . 2): %S\n" (listp '(1 . 2))))
(princ (format "listp (cons 1 2): %S\n" (listp (cons 1 2))))
(princ (format "listp (cons nil nil): %S\n" (listp (cons nil nil))))

;; Proper lists
(princ (format "listp '(1): %S\n" (listp '(1))))
(princ (format "listp '(1 2 3): %S\n" (listp '(1 2 3))))
(princ (format "listp '(a b c): %S\n" (listp '(a b c))))

;; Nested structures
(princ (format "listp '((1 2) (3 4)): %S\n" (listp '((1 2) (3 4)))))
(princ (format "listp '(1 . (2 . 3)): %S\n" (listp '(1 . (2 . 3)))))

;; Number cases (should return nil)

;; Fixnums
(princ (format "listp 42: %S\n" (listp 42)))
(princ (format "listp 0: %S\n" (listp 0)))
(princ (format "listp -42: %S\n" (listp -42)))
(princ (format "listp most-positive-fixnum: %S\n"
               (listp most-positive-fixnum)))
(princ (format "listp most-negative-fixnum: %S\n"
               (listp most-negative-fixnum)))

;; Characters (fixnums)
(princ (format "listp ?a: %S\n" (listp ?a)))
(princ (format "listp ?\\n: %S\n" (listp ?\n)))

;; Bignums
(princ (format "listp (expt 2 100): %S\n" (listp (expt 2 100))))
(princ (format "listp (1+ most-positive-fixnum): %S\n"
               (listp (1+ most-positive-fixnum))))
(princ (format "listp (- (expt 2 100)): %S\n"
               (listp (- (expt 2 100)))))

;; Floats
(princ (format "listp 3.0: %S\n" (listp 3.0)))
(princ (format "listp 3.14: %S\n" (listp 3.14)))
(princ (format "listp 0.0: %S\n" (listp 0.0)))
(princ (format "listp -3.14: %S\n" (listp -3.14)))
(princ (format "listp 1.0e10: %S\n" (listp 1.0e10)))

;; Symbol cases (should return nil, except nil which IS a list)

;; Basic symbols
(princ (format "listp 'x: %S\n" (listp 'x)))
(princ (format "listp 'foo: %S\n" (listp 'foo)))

;; Keywords
(princ (format "listp :keyword: %S\n" (listp :keyword)))

;; t (symbol, not a list)
(princ (format "listp t: %S\n" (listp t)))

;; Symbol with string name (still a symbol, not a list)
(princ (format "listp (intern \"test\"): %S\n" (listp (intern "test"))))

;; String cases (should return nil)

(princ (format "listp \"s\": %S\n" (listp "s")))
(princ (format "listp \"\": %S\n" (listp "")))
(princ (format "listp \"foo\": %S\n" (listp "foo")))
(princ (format "listp \"multi\\nline\": %S\n" (listp "multi\nline")))

;; Vector cases (should return nil)

(princ (format "listp []: %S\n" (listp [])))
(princ (format "listp [1]: %S\n" (listp [1])))
(princ (format "listp [1 2 3]: %S\n" (listp [1 2 3])))

;; Edge cases

;; Cons cells with special values (all lists)
(princ (format "listp (cons t nil): %S\n" (listp (cons t nil))))
(princ (format "listp (cons nil t): %S\n" (listp (cons nil t))))
(princ (format "listp (cons 'foo 'bar): %S\n" (listp (cons 'foo 'bar))))

;; Inverse relationship with nlistp
(princ (format "listp vs nlistp on nil: listp=%S nlistp=%S\n"
               (listp nil) (nlistp nil)))
(princ (format "listp vs nlistp on '(1 2): listp=%S nlistp=%S\n"
               (listp '(1 2)) (nlistp '(1 2))))
(princ (format "listp vs nlistp on 42: listp=%S nlistp=%S\n"
               (listp 42) (nlistp 42)))

;;; 18-symbolp.el --- Test symbolp (sixth C→Zig port)

(princ "=== symbolp tests (sixth C→Zig leaf port) ===\n")

;; Symbol cases (should return t)

;; Basic symbols
(princ (format "symbolp 'x: %S\n" (symbolp 'x)))
(princ (format "symbolp 'foo: %S\n" (symbolp 'foo)))
(princ (format "symbolp 'some-symbol: %S\n" (symbolp 'some-symbol)))

;; Keywords (also symbols)
(princ (format "symbolp :keyword: %S\n" (symbolp :keyword)))
(princ (format "symbolp :kw: %S\n" (symbolp :kw)))
(princ (format "symbolp :foo: %S\n" (symbolp :foo)))

;; CRITICAL: nil and t are symbols
(princ (format "symbolp nil: %S\n" (symbolp nil)))
(princ (format "symbolp t: %S\n" (symbolp t)))

;; Number cases (should return nil)

;; Fixnums
(princ (format "symbolp 42: %S\n" (symbolp 42)))
(princ (format "symbolp 0: %S\n" (symbolp 0)))
(princ (format "symbolp -42: %S\n" (symbolp -42)))
(princ (format "symbolp most-positive-fixnum: %S\n"
               (symbolp most-positive-fixnum)))
(princ (format "symbolp most-negative-fixnum: %S\n"
               (symbolp most-negative-fixnum)))

;; Characters (fixnums)
(princ (format "symbolp ?a: %S\n" (symbolp ?a)))
(princ (format "symbolp ?\\n: %S\n" (symbolp ?\n)))

;; Bignums
(princ (format "symbolp (expt 2 100): %S\n" (symbolp (expt 2 100))))
(princ (format "symbolp (1+ most-positive-fixnum): %S\n"
               (symbolp (1+ most-positive-fixnum))))
(princ (format "symbolp (- (expt 2 100)): %S\n"
               (symbolp (- (expt 2 100)))))

;; Floats
(princ (format "symbolp 3.0: %S\n" (symbolp 3.0)))
(princ (format "symbolp 3.14: %S\n" (symbolp 3.14)))
(princ (format "symbolp 0.0: %S\n" (symbolp 0.0)))
(princ (format "symbolp -3.14: %S\n" (symbolp -3.14)))
(princ (format "symbolp 1.0e10: %S\n" (symbolp 1.0e10)))

;; Non-symbol cases (should return nil)

;; Strings
(princ (format "symbolp \"string\": %S\n" (symbolp "string")))
(princ (format "symbolp \"\": %S\n" (symbolp "")))
(princ (format "symbolp \"foo\": %S\n" (symbolp "foo")))

;; Lists
(princ (format "symbolp '(1): %S\n" (symbolp '(1))))
(princ (format "symbolp '(1 2 3): %S\n" (symbolp '(1 2 3))))
(princ (format "symbolp '(x): %S\n" (symbolp '(x))))
(princ (format "symbolp '(1 . 2): %S\n" (symbolp '(1 . 2))))

;; Vectors
(princ (format "symbolp [1]: %S\n" (symbolp [1])))
(princ (format "symbolp [1 2 3]: %S\n" (symbolp [1 2 3])))
(princ (format "symbolp []: %S\n" (symbolp [])))

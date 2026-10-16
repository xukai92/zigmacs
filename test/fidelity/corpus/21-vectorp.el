;;; 21-vectorp.el --- Test vectorp (ninth C→Zig port)

(princ "=== vectorp tests (ninth C→Zig leaf port) ===\n")

;; Vector cases (should return t)

;; Basic vectors
(princ (format "vectorp [1 2 3]: %S\n" (vectorp [1 2 3])))
(princ (format "vectorp []: %S\n" (vectorp [])))
(princ (format "vectorp [1]: %S\n" (vectorp [1])))
(princ (format "vectorp (make-vector 3 0): %S\n" (vectorp (make-vector 3 0))))
(princ (format "vectorp (make-vector 0 nil): %S\n" (vectorp (make-vector 0 nil))))

;; Nested structures
(princ (format "vectorp [[1 2] [3 4]]: %S\n" (vectorp [[1 2] [3 4]])))
(princ (format "vectorp [(1 2) (3 4)]: %S\n" (vectorp [(1 2) (3 4)])))

;; Vectors with special values
(princ (format "vectorp [nil]: %S\n" (vectorp [nil])))
(princ (format "vectorp [t]: %S\n" (vectorp [t])))
(princ (format "vectorp [nil t]: %S\n" (vectorp [nil t])))

;; String cases (CRITICAL: should return nil - strings are NOT vectors)

(princ (format "vectorp \"s\": %S\n" (vectorp "s")))
(princ (format "vectorp \"\": %S\n" (vectorp "")))
(princ (format "vectorp \"foo\": %S\n" (vectorp "foo")))
(princ (format "vectorp \"multi\\nline\": %S\n" (vectorp "multi\nline")))

;; Bool-vector cases (CRITICAL: should return nil - bool-vectors are NOT plain vectors)

(princ (format "vectorp (make-bool-vector 3 t): %S\n"
               (vectorp (make-bool-vector 3 t))))
(princ (format "vectorp (make-bool-vector 0 nil): %S\n"
               (vectorp (make-bool-vector 0 nil))))

;; Char-table cases (CRITICAL: should return nil - char-tables are NOT plain vectors)

(princ (format "vectorp (make-char-table 'test): %S\n"
               (vectorp (make-char-table 'test))))

;; List cases (should return nil)

(princ (format "vectorp '(1 2): %S\n" (vectorp '(1 2))))
(princ (format "vectorp '(1 2 3): %S\n" (vectorp '(1 2 3))))
(princ (format "vectorp nil: %S\n" (vectorp nil)))
(princ (format "vectorp '(): %S\n" (vectorp '())))

;; Number cases (should return nil)

;; Fixnums
(princ (format "vectorp 42: %S\n" (vectorp 42)))
(princ (format "vectorp 0: %S\n" (vectorp 0)))
(princ (format "vectorp -42: %S\n" (vectorp -42)))
(princ (format "vectorp most-positive-fixnum: %S\n"
               (vectorp most-positive-fixnum)))
(princ (format "vectorp most-negative-fixnum: %S\n"
               (vectorp most-negative-fixnum)))

;; Characters (fixnums)
(princ (format "vectorp ?a: %S\n" (vectorp ?a)))
(princ (format "vectorp ?\\n: %S\n" (vectorp ?\n)))

;; Bignums
(princ (format "vectorp (expt 2 100): %S\n" (vectorp (expt 2 100))))
(princ (format "vectorp (1+ most-positive-fixnum): %S\n"
               (vectorp (1+ most-positive-fixnum))))
(princ (format "vectorp (- (expt 2 100)): %S\n"
               (vectorp (- (expt 2 100)))))

;; Floats
(princ (format "vectorp 3.0: %S\n" (vectorp 3.0)))
(princ (format "vectorp 3.14: %S\n" (vectorp 3.14)))
(princ (format "vectorp 0.0: %S\n" (vectorp 0.0)))
(princ (format "vectorp -3.14: %S\n" (vectorp -3.14)))
(princ (format "vectorp 1.0e10: %S\n" (vectorp 1.0e10)))

;; Symbol cases (should return nil)

;; Basic symbols
(princ (format "vectorp 'x: %S\n" (vectorp 'x)))
(princ (format "vectorp 'foo: %S\n" (vectorp 'foo)))

;; Keywords
(princ (format "vectorp :keyword: %S\n" (vectorp :keyword)))

;; nil and t (symbols, not vectors)
(princ (format "vectorp nil (again): %S\n" (vectorp nil)))
(princ (format "vectorp t: %S\n" (vectorp t)))

;; Symbol with string name (still a symbol, not a vector)
(princ (format "vectorp (intern \"test\"): %S\n" (vectorp (intern "test"))))

;; Edge cases

;; Empty vector (still a vector)
(princ (format "vectorp [] (again): %S\n" (vectorp [])))

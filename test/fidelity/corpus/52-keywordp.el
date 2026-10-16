;;; 52-keywordp.el --- Test keywordp (Category A port, fanout round #4)

(princ "=== keywordp tests (Category A port, fanout round #4) ===\n")

;; Keyword cases (should return t)

;; Standard keywords
(princ (format "keywordp :foo: %S\n" (keywordp :foo)))
(princ (format "keywordp :bar: %S\n" (keywordp :bar)))
(princ (format "keywordp :test: %S\n" (keywordp :test)))
(princ (format "keywordp :a: %S\n" (keywordp :a)))
(princ (format "keywordp :some-keyword: %S\n" (keywordp :some-keyword)))
(princ (format "keywordp :another-keyword: %S\n" (keywordp :another-keyword)))

;; Non-keyword cases (should return nil)

;; nil and t
(princ (format "keywordp nil: %S\n" (keywordp nil)))
(princ (format "keywordp t: %S\n" (keywordp t)))

;; Regular symbols (not keywords)
(princ (format "keywordp 'foo: %S\n" (keywordp 'foo)))
(princ (format "keywordp 'bar: %S\n" (keywordp 'bar)))
(princ (format "keywordp 'some-symbol: %S\n" (keywordp 'some-symbol)))
(princ (format "keywordp 'x: %S\n" (keywordp 'x)))

;; Integers
(princ (format "keywordp 42: %S\n" (keywordp 42)))
(princ (format "keywordp 0: %S\n" (keywordp 0)))
(princ (format "keywordp -42: %S\n" (keywordp -42)))

;; Floats
(princ (format "keywordp 3.14: %S\n" (keywordp 3.14)))
(princ (format "keywordp 0.0: %S\n" (keywordp 0.0)))

;; Strings (CRITICAL: ":foo" string is NOT a keyword)
(princ (format "keywordp \"foo\": %S\n" (keywordp "foo")))
(princ (format "keywordp \":foo\": %S\n" (keywordp ":foo")))
(princ (format "keywordp \"\": %S\n" (keywordp "")))

;; Lists
(princ (format "keywordp '(1 2 3): %S\n" (keywordp '(1 2 3))))
(princ (format "keywordp '(:foo): %S\n" (keywordp '(:foo))))

;; Vectors
(princ (format "keywordp []: %S\n" (keywordp [])))
(princ (format "keywordp [1 2 3]: %S\n" (keywordp [1 2 3])))

;; Characters
(princ (format "keywordp ?a: %S\n" (keywordp ?a)))
(princ (format "keywordp ?:: %S\n" (keywordp ?:)))

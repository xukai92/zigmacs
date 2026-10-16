;;; 19-stringp.el --- Test stringp (seventh C→Zig port)

(princ "=== stringp tests (seventh C→Zig leaf port) ===\n")

;; String cases (should return t)

;; Basic strings
(princ (format "stringp \"s\": %S\n" (stringp "s")))
(princ (format "stringp \"\": %S\n" (stringp "")))
(princ (format "stringp \"foo\": %S\n" (stringp "foo")))

;; Multiline strings
(princ (format "stringp \"multi\\nline\": %S\n" (stringp "multi\nline")))

;; Unibyte strings
(princ (format "stringp (string-to-unibyte \"test\"): %S\n"
               (stringp (string-to-unibyte "test"))))
(princ (format "stringp (string-to-unibyte \"\"): %S\n"
               (stringp (string-to-unibyte ""))))

;; Multibyte strings
(princ (format "stringp (string-to-multibyte \"test\"): %S\n"
               (stringp (string-to-multibyte "test"))))

;; Number cases (should return nil)

;; Fixnums
(princ (format "stringp 42: %S\n" (stringp 42)))
(princ (format "stringp 0: %S\n" (stringp 0)))
(princ (format "stringp -42: %S\n" (stringp -42)))
(princ (format "stringp most-positive-fixnum: %S\n"
               (stringp most-positive-fixnum)))
(princ (format "stringp most-negative-fixnum: %S\n"
               (stringp most-negative-fixnum)))

;; Characters (fixnums)
(princ (format "stringp ?a: %S\n" (stringp ?a)))
(princ (format "stringp ?\\n: %S\n" (stringp ?\n)))

;; Bignums
(princ (format "stringp (expt 2 100): %S\n" (stringp (expt 2 100))))
(princ (format "stringp (1+ most-positive-fixnum): %S\n"
               (stringp (1+ most-positive-fixnum))))
(princ (format "stringp (- (expt 2 100)): %S\n"
               (stringp (- (expt 2 100)))))

;; Floats
(princ (format "stringp 3.0: %S\n" (stringp 3.0)))
(princ (format "stringp 3.14: %S\n" (stringp 3.14)))
(princ (format "stringp 0.0: %S\n" (stringp 0.0)))
(princ (format "stringp -3.14: %S\n" (stringp -3.14)))
(princ (format "stringp 1.0e10: %S\n" (stringp 1.0e10)))

;; Symbol cases (should return nil)

;; Basic symbols
(princ (format "stringp 'x: %S\n" (stringp 'x)))
(princ (format "stringp 'foo: %S\n" (stringp 'foo)))

;; Keywords
(princ (format "stringp :keyword: %S\n" (stringp :keyword)))

;; nil and t (symbols, not strings)
(princ (format "stringp nil: %S\n" (stringp nil)))
(princ (format "stringp t: %S\n" (stringp t)))

;; Symbol with string name (still a symbol, not a string)
(princ (format "stringp (intern \"test\"): %S\n" (stringp (intern "test"))))

;; List cases (should return nil)

(princ (format "stringp '(): %S\n" (stringp '())))
(princ (format "stringp '(1): %S\n" (stringp '(1))))
(princ (format "stringp '(1 2 3): %S\n" (stringp '(1 2 3))))
(princ (format "stringp '(1 . 2): %S\n" (stringp '(1 . 2))))

;; Vector cases (should return nil)

(princ (format "stringp []: %S\n" (stringp [])))
(princ (format "stringp [1]: %S\n" (stringp [1])))
(princ (format "stringp [1 2 3]: %S\n" (stringp [1 2 3])))

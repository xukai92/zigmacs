;;; 24-arrayp.el --- Test arrayp (fourteenth C→Zig port)

(princ "=== arrayp tests (fourteenth C→Zig leaf port) ===\n")

;; Array cases (should return t)

;; Strings
(princ (format "arrayp \"string\": %S\n" (arrayp "string")))
(princ (format "arrayp \"\": %S\n" (arrayp "")))
(princ (format "arrayp \"a\": %S\n" (arrayp "a")))
(princ (format "arrayp \"hello world\": %S\n" (arrayp "hello world")))

;; Vectors
(princ (format "arrayp []: %S\n" (arrayp [])))
(princ (format "arrayp [1]: %S\n" (arrayp [1])))
(princ (format "arrayp [1 2 3]: %S\n" (arrayp [1 2 3])))
(princ (format "arrayp [a b c]: %S\n" (arrayp [a b c])))

;; Bool-vectors
(princ (format "arrayp (make-bool-vector 0 nil): %S\n"
               (arrayp (make-bool-vector 0 nil))))
(princ (format "arrayp (make-bool-vector 3 t): %S\n"
               (arrayp (make-bool-vector 3 t))))

;; Char-tables
(princ (format "arrayp (make-char-table nil): %S\n"
               (arrayp (make-char-table nil))))

;; Non-array cases (should return nil)

;; nil and t
(princ (format "arrayp nil: %S\n" (arrayp nil)))
(princ (format "arrayp t: %S\n" (arrayp t)))

;; Integers
(princ (format "arrayp 42: %S\n" (arrayp 42)))
(princ (format "arrayp 0: %S\n" (arrayp 0)))
(princ (format "arrayp -42: %S\n" (arrayp -42)))

;; Floats
(princ (format "arrayp 3.14: %S\n" (arrayp 3.14)))
(princ (format "arrayp 0.0: %S\n" (arrayp 0.0)))

;; Symbols
(princ (format "arrayp 'foo: %S\n" (arrayp 'foo)))
(princ (format "arrayp 'x: %S\n" (arrayp 'x)))

;; Lists (CRITICAL: lists are NOT arrays)
(princ (format "arrayp '(1 2 3): %S\n" (arrayp '(1 2 3))))
(princ (format "arrayp '(1): %S\n" (arrayp '(1))))
(princ (format "arrayp '(): %S\n" (arrayp '())))
(princ (format "arrayp '(1 . 2): %S\n" (arrayp '(1 . 2))))

;; Characters
(princ (format "arrayp ?a: %S\n" (arrayp ?a)))
(princ (format "arrayp ?\\n: %S\n" (arrayp ?\n)))

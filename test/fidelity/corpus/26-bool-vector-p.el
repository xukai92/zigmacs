;;; 26-bool-vector-p.el --- Test bool-vector-p (sixteenth C→Zig port)

(princ "=== bool-vector-p tests (sixteenth C→Zig leaf port) ===\n")

;; Bool-vector cases (should return t)

;; Empty bool-vectors
(princ (format "bool-vector-p (make-bool-vector 0 nil): %S\n"
               (bool-vector-p (make-bool-vector 0 nil))))
(princ (format "bool-vector-p (make-bool-vector 0 t): %S\n"
               (bool-vector-p (make-bool-vector 0 t))))

;; Small bool-vectors
(princ (format "bool-vector-p (make-bool-vector 1 nil): %S\n"
               (bool-vector-p (make-bool-vector 1 nil))))
(princ (format "bool-vector-p (make-bool-vector 3 t): %S\n"
               (bool-vector-p (make-bool-vector 3 t))))
(princ (format "bool-vector-p (make-bool-vector 5 nil): %S\n"
               (bool-vector-p (make-bool-vector 5 nil))))

;; Larger bool-vectors
(princ (format "bool-vector-p (make-bool-vector 10 t): %S\n"
               (bool-vector-p (make-bool-vector 10 t))))
(princ (format "bool-vector-p (make-bool-vector 100 nil): %S\n"
               (bool-vector-p (make-bool-vector 100 nil))))

;; Non-bool-vector cases (should return nil)

;; nil and t
(princ (format "bool-vector-p nil: %S\n" (bool-vector-p nil)))
(princ (format "bool-vector-p t: %S\n" (bool-vector-p t)))

;; Integers
(princ (format "bool-vector-p 42: %S\n" (bool-vector-p 42)))
(princ (format "bool-vector-p 0: %S\n" (bool-vector-p 0)))
(princ (format "bool-vector-p -42: %S\n" (bool-vector-p -42)))

;; Floats
(princ (format "bool-vector-p 3.14: %S\n" (bool-vector-p 3.14)))
(princ (format "bool-vector-p 0.0: %S\n" (bool-vector-p 0.0)))

;; Symbols
(princ (format "bool-vector-p 'foo: %S\n" (bool-vector-p 'foo)))
(princ (format "bool-vector-p 'x: %S\n" (bool-vector-p 'x)))

;; Strings
(princ (format "bool-vector-p \"string\": %S\n" (bool-vector-p "string")))
(princ (format "bool-vector-p \"\": %S\n" (bool-vector-p "")))

;; Regular vectors (CRITICAL: vectors are NOT bool-vectors)
(princ (format "bool-vector-p []: %S\n" (bool-vector-p [])))
(princ (format "bool-vector-p [1 2 3]: %S\n" (bool-vector-p [1 2 3])))
(princ (format "bool-vector-p [t nil t]: %S\n" (bool-vector-p [t nil t])))

;; Lists
(princ (format "bool-vector-p '(1 2 3): %S\n" (bool-vector-p '(1 2 3))))
(princ (format "bool-vector-p '(t nil): %S\n" (bool-vector-p '(t nil))))
(princ (format "bool-vector-p '(): %S\n" (bool-vector-p '())))

;; Characters
(princ (format "bool-vector-p ?a: %S\n" (bool-vector-p ?a)))

;; Records
(princ (format "bool-vector-p (record 'foo): %S\n"
               (bool-vector-p (record 'foo))))

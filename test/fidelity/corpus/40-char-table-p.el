;;; 40-char-table-p.el --- Test char-table-p (Category A fanout round #3)

(princ "=== char-table-p tests (Category A fanout round #3) ===\n")

;; Char-table cases (should return t)

;; Basic char-tables
(princ (format "char-table-p (make-char-table nil): %S\n"
               (char-table-p (make-char-table nil))))
(princ (format "char-table-p (make-char-table 'syntax-table): %S\n"
               (char-table-p (make-char-table 'syntax-table))))
(princ (format "char-table-p (make-char-table 'category-table): %S\n"
               (char-table-p (make-char-table 'category-table))))
(princ (format "char-table-p (make-char-table 'case-table): %S\n"
               (char-table-p (make-char-table 'case-table))))

;; Non-char-table cases (should return nil)

;; nil and t
(princ (format "char-table-p nil: %S\n" (char-table-p nil)))
(princ (format "char-table-p t: %S\n" (char-table-p t)))

;; Integers
(princ (format "char-table-p 42: %S\n" (char-table-p 42)))
(princ (format "char-table-p 0: %S\n" (char-table-p 0)))

;; Floats
(princ (format "char-table-p 3.14: %S\n" (char-table-p 3.14)))

;; Symbols
(princ (format "char-table-p 'foo: %S\n" (char-table-p 'foo)))

;; Strings
(princ (format "char-table-p \"string\": %S\n" (char-table-p "string")))
(princ (format "char-table-p \"\": %S\n" (char-table-p "")))

;; Vectors
(princ (format "char-table-p [1 2 3]: %S\n" (char-table-p [1 2 3])))
(princ (format "char-table-p []: %S\n" (char-table-p [])))

;; Lists
(princ (format "char-table-p '(1 2 3): %S\n" (char-table-p '(1 2 3))))
(princ (format "char-table-p '(): %S\n" (char-table-p '())))

;; Bool-vectors
(princ (format "char-table-p (make-bool-vector 3 t): %S\n"
               (char-table-p (make-bool-vector 3 t))))

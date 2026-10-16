;;; 29-cdr-safe.el --- Test cdr-safe (Category B fanout #2)

(princ "=== cdr-safe tests (Category B fanout #2) ===\n")

;; Cons cell cases (should return cdr)

;; Simple dotted pairs
(princ (format "cdr-safe '(1 . 2): %S\n" (cdr-safe '(1 . 2))))
(princ (format "cdr-safe (cons 'a 'b): %S\n" (cdr-safe (cons 'a 'b))))
(princ (format "cdr-safe '(nil . t): %S\n" (cdr-safe '(nil . t))))
(princ (format "cdr-safe '(t . nil): %S\n" (cdr-safe '(t . nil))))

;; Proper lists (cons cells with list cdrs)
(princ (format "cdr-safe '(1): %S\n" (cdr-safe '(1))))
(princ (format "cdr-safe '(1 2 3): %S\n" (cdr-safe '(1 2 3))))
(princ (format "cdr-safe '(a b c): %S\n" (cdr-safe '(a b c))))

;; Nested structures
(princ (format "cdr-safe '((1 2) 3): %S\n" (cdr-safe '((1 2) 3))))
(princ (format "cdr-safe '(a . (b . c)): %S\n" (cdr-safe '(a . (b . c)))))

;; Non-cons cases (should return nil, not error)

;; nil (empty list, not a cons)
(princ (format "cdr-safe nil: %S\n" (cdr-safe nil)))
(princ (format "cdr-safe '(): %S\n" (cdr-safe '())))

;; Numbers
(princ (format "cdr-safe 42: %S\n" (cdr-safe 42)))
(princ (format "cdr-safe 0: %S\n" (cdr-safe 0)))
(princ (format "cdr-safe -1: %S\n" (cdr-safe -1)))
(princ (format "cdr-safe 3.14: %S\n" (cdr-safe 3.14)))

;; Symbols
(princ (format "cdr-safe 'symbol: %S\n" (cdr-safe 'symbol)))
(princ (format "cdr-safe t: %S\n" (cdr-safe t)))
(princ (format "cdr-safe :keyword: %S\n" (cdr-safe :keyword)))

;; Strings
(princ (format "cdr-safe \"string\": %S\n" (cdr-safe "string")))
(princ (format "cdr-safe \"\": %S\n" (cdr-safe "")))

;; Vectors
(princ (format "cdr-safe [1 2 3]: %S\n" (cdr-safe [1 2 3])))
(princ (format "cdr-safe []: %S\n" (cdr-safe [])))

;; Contrast with cdr (which signals error on non-cons)
(princ (format "cdr '(1 2): %S\n" (cdr '(1 2))))
(princ (format "cdr-safe '(1 2): %S\n" (cdr-safe '(1 2))))
(princ (format "cdr nil: %S\n" (cdr nil)))
(princ (format "cdr-safe nil: %S\n" (cdr-safe nil)))

;; Special cases: nil as cdr
(princ (format "cdr-safe '(1 . nil): %S\n" (cdr-safe '(1 . nil))))
(princ (format "cdr-safe '(a): %S\n" (cdr-safe '(a))))

;;; 30-nth.el --- Test nth (Category B fanout #2)

(princ "=== nth tests (Category B fanout #2) ===\n")

;; Basic cases (valid indices)

;; Zero-based indexing
(princ (format "nth 0 '(a b c): %S\n" (nth 0 '(a b c))))
(princ (format "nth 1 '(a b c): %S\n" (nth 1 '(a b c))))
(princ (format "nth 2 '(a b c): %S\n" (nth 2 '(a b c))))

;; First and last elements
(princ (format "nth 0 '(1 2 3): %S\n" (nth 0 '(1 2 3))))
(princ (format "nth 2 '(1 2 3): %S\n" (nth 2 '(1 2 3))))

;; Single-element list
(princ (format "nth 0 '(x): %S\n" (nth 0 '(x))))

;; Out-of-range indices (returns nil)

;; Index too large
(princ (format "nth 3 '(a b c): %S\n" (nth 3 '(a b c))))
(princ (format "nth 10 '(a b c): %S\n" (nth 10 '(a b c))))
(princ (format "nth 100 '(1 2 3): %S\n" (nth 100 '(1 2 3))))

;; Index on empty list
(princ (format "nth 0 nil: %S\n" (nth 0 nil)))
(princ (format "nth 1 nil: %S\n" (nth 1 nil)))
(princ (format "nth 0 '(): %S\n" (nth 0 '())))

;; Very large index
(princ (format "nth 1000 '(a): %S\n" (nth 1000 '(a))))

;; Special values as elements

;; nil as element
(princ (format "nth 0 '(nil): %S\n" (nth 0 '(nil))))
(princ (format "nth 1 '(a nil b): %S\n" (nth 1 '(a nil b))))

;; t as element
(princ (format "nth 0 '(t): %S\n" (nth 0 '(t))))
(princ (format "nth 1 '(a t b): %S\n" (nth 1 '(a t b))))

;; Keywords
(princ (format "nth 1 '(:foo :bar :baz): %S\n" (nth 1 '(:foo :bar :baz))))

;; Numbers
(princ (format "nth 2 '(10 20 30 40): %S\n" (nth 2 '(10 20 30 40))))
(princ (format "nth 0 '(0): %S\n" (nth 0 '(0))))

;; Improper lists

;; Element found before improper tail (works)
(princ (format "nth 0 '(a . b): %S\n" (nth 0 '(a . b))))
(princ (format "nth 0 '(a b . c): %S\n" (nth 0 '(a b . c))))
(princ (format "nth 1 '(a b . c): %S\n" (nth 1 '(a b . c))))

;; Long lists
(princ (format "nth 5 (number-sequence 0 9): %S\n" (nth 5 (number-sequence 0 9))))
(princ (format "nth 9 (number-sequence 0 9): %S\n" (nth 9 (number-sequence 0 9))))
(princ (format "nth 10 (number-sequence 0 9): %S\n" (nth 10 (number-sequence 0 9))))

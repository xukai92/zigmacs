;;; 31-safe-length.el --- Test safe-length (Category B fanout #2)

(princ "=== safe-length tests (Category B fanout #2) ===\n")

;; Proper lists (returns length)

;; Empty list
(princ (format "safe-length nil: %S\n" (safe-length nil)))
(princ (format "safe-length '(): %S\n" (safe-length '())))

;; Single-element list
(princ (format "safe-length '(a): %S\n" (safe-length '(a))))
(princ (format "safe-length '(1): %S\n" (safe-length '(1))))

;; Multi-element lists
(princ (format "safe-length '(a b c): %S\n" (safe-length '(a b c))))
(princ (format "safe-length '(1 2 3 4 5): %S\n" (safe-length '(1 2 3 4 5))))

;; Nested lists (outer length only)
(princ (format "safe-length '((1 2) (3 4)): %S\n" (safe-length '((1 2) (3 4)))))
(princ (format "safe-length '(a (b c) d): %S\n" (safe-length '(a (b c) d))))

;; Improper lists (counts cons cells before atom)

;; Dotted pair (1 cons cell)
(princ (format "safe-length '(a . b): %S\n" (safe-length '(a . b))))

;; Improper list with multiple elements
(princ (format "safe-length '(a b . c): %S\n" (safe-length '(a b . c))))
(princ (format "safe-length '(a b c . d): %S\n" (safe-length '(a b c . d))))

;; Atoms (returns 0, never errors)

;; Numbers
(princ (format "safe-length 42: %S\n" (safe-length 42)))
(princ (format "safe-length 0: %S\n" (safe-length 0)))
(princ (format "safe-length -1: %S\n" (safe-length -1)))
(princ (format "safe-length 3.14: %S\n" (safe-length 3.14)))

;; Symbols (excluding nil, which is a list)
(princ (format "safe-length 'symbol: %S\n" (safe-length 'symbol)))
(princ (format "safe-length t: %S\n" (safe-length t)))
(princ (format "safe-length :keyword: %S\n" (safe-length :keyword)))

;; Strings
(princ (format "safe-length \"string\": %S\n" (safe-length "string")))
(princ (format "safe-length \"\": %S\n" (safe-length "")))

;; Vectors
(princ (format "safe-length [1 2 3]: %S\n" (safe-length [1 2 3])))
(princ (format "safe-length []: %S\n" (safe-length [])))

;; Circular lists (returns number of distinct elements)

;; Simple circular list: (a b c) → a
(let ((circular (list 'a 'b 'c)))
  (setcdr (last circular) circular)
  (princ (format "safe-length circular-3: %S\n" (safe-length circular))))

;; Single-element circular: (a) → a
(let ((circular (list 'a)))
  (setcdr circular circular)
  (princ (format "safe-length circular-1: %S\n" (safe-length circular))))

;; Two-element circular: (a b) → a
(let ((circular (list 'a 'b)))
  (setcdr (last circular) circular)
  (princ (format "safe-length circular-2: %S\n" (safe-length circular))))

;; Contrast with length (which signals errors)

;; safe-length on proper list (same as length)
(princ (format "length '(a b c): %S\n" (length '(a b c))))
(princ (format "safe-length '(a b c): %S\n" (safe-length '(a b c))))

;; safe-length on improper list (length would error)
(princ (format "safe-length '(a b . c): %S\n" (safe-length '(a b . c))))

;; safe-length on atom (length would error)
(princ (format "safe-length 42: %S\n" (safe-length 42)))

;; Special values

;; List of nils
(princ (format "safe-length '(nil nil nil): %S\n" (safe-length '(nil nil nil))))

;; List of t's
(princ (format "safe-length '(t t): %S\n" (safe-length '(t t))))

;; Mixed special values
(princ (format "safe-length '(nil t nil): %S\n" (safe-length '(nil t nil))))

;; Long lists
(princ (format "safe-length (make-list 100 'x): %S\n" (safe-length (make-list 100 'x))))

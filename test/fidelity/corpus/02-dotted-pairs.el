;;; 02-dotted-pairs.el --- Test dotted pairs and improper lists

(princ "=== Dotted pairs and improper lists ===\n")

;; Basic dotted pair
(let ((pair (cons 'a 'b)))
  (princ (format "dotted pair: %S\n" pair))
  (princ (format "car: %S, cdr: %S\n" (car pair) (cdr pair)))
  (princ (format "consp: %S, listp: %S\n" (consp pair) (listp pair))))

;; Improper list
(let ((improper '(1 2 3 . 4)))
  (princ (format "improper list: %S\n" improper))
  (princ (format "car: %S\n" (car improper)))
  (princ (format "cdr: %S\n" (cdr improper)))
  (princ (format "cadr: %S\n" (cadr improper)))
  (princ (format "cddr: %S\n" (cddr improper)))
  (princ (format "cdddr: %S\n" (cdddr improper))))

;; Nested dotted pairs
(let ((nested '((a . b) . (c . d))))
  (princ (format "nested dotted: %S\n" nested))
  (princ (format "caar: %S\n" (caar nested)))
  (princ (format "cdar: %S\n" (cdar nested))))

;; Equality
(princ (format "equal (1 . 2) (1 . 2): %S\n" (equal '(1 . 2) '(1 . 2))))
(princ (format "equal (1 . 2) (1 2): %S\n" (equal '(1 . 2) '(1 2))))
(princ (format "equal (1 2) (1 . (2)): %S\n" (equal '(1 2) '(1 . (2)))))

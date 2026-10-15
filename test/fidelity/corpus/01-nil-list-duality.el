;;; 01-nil-list-duality.el --- Test nil/() duality

;; Test that nil and () are identical in all contexts

(princ "=== nil/() duality tests ===\n")

;; Identity
(princ (format "nil eq (): %S\n" (eq nil '())))
(princ (format "nil equal (): %S\n" (equal nil '())))

;; Type predicates
(princ (format "null nil: %S\n" (null nil)))
(princ (format "null (): %S\n" (null '())))
(princ (format "consp nil: %S\n" (consp nil)))
(princ (format "listp nil: %S\n" (listp nil)))
(princ (format "listp (): %S\n" (listp '())))

;; List operations
(princ (format "car nil: %S\n" (car nil)))
(princ (format "cdr nil: %S\n" (cdr nil)))
(princ (format "cons 1 nil: %S\n" (cons 1 nil)))
(princ (format "cons 1 (): %S\n" (cons 1 '())))
(princ (format "append nil nil: %S\n" (append nil nil)))

;; Boolean context
(princ (format "if nil then else: %S\n" (if nil 'then 'else)))
(princ (format "if () then else: %S\n" (if '() 'then 'else)))
(princ (format "not nil: %S\n" (not nil)))
(princ (format "not (): %S\n" (not '())))

;; Equality with other types
(princ (format "equal nil '(nil): %S\n" (equal nil '(nil))))
(princ (format "equal () '(nil): %S\n" (equal '() '(nil))))

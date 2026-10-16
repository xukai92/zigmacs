;;; 28-car-safe.el --- Test car-safe (Category B fanout #2)

(princ "=== car-safe tests (Category B fanout #2) ===\n")

;; Cons cell cases (should return car)

;; Simple dotted pairs
(princ (format "car-safe '(1 . 2): %S\n" (car-safe '(1 . 2))))
(princ (format "car-safe (cons 'a 'b): %S\n" (car-safe (cons 'a 'b))))
(princ (format "car-safe '(nil . t): %S\n" (car-safe '(nil . t))))
(princ (format "car-safe '(t . nil): %S\n" (car-safe '(t . nil))))

;; Proper lists (cons cells)
(princ (format "car-safe '(1): %S\n" (car-safe '(1))))
(princ (format "car-safe '(1 2 3): %S\n" (car-safe '(1 2 3))))
(princ (format "car-safe '(a b c): %S\n" (car-safe '(a b c))))

;; Nested structures
(princ (format "car-safe '((1 2) 3): %S\n" (car-safe '((1 2) 3))))
(princ (format "car-safe '((a . b) c): %S\n" (car-safe '((a . b) c))))

;; Non-cons cases (should return nil, not error)

;; nil (empty list, not a cons)
(princ (format "car-safe nil: %S\n" (car-safe nil)))
(princ (format "car-safe '(): %S\n" (car-safe '())))

;; Numbers
(princ (format "car-safe 42: %S\n" (car-safe 42)))
(princ (format "car-safe 0: %S\n" (car-safe 0)))
(princ (format "car-safe -1: %S\n" (car-safe -1)))
(princ (format "car-safe 3.14: %S\n" (car-safe 3.14)))

;; Symbols
(princ (format "car-safe 'symbol: %S\n" (car-safe 'symbol)))
(princ (format "car-safe t: %S\n" (car-safe t)))
(princ (format "car-safe :keyword: %S\n" (car-safe :keyword)))

;; Strings
(princ (format "car-safe \"string\": %S\n" (car-safe "string")))
(princ (format "car-safe \"\": %S\n" (car-safe "")))

;; Vectors
(princ (format "car-safe [1 2 3]: %S\n" (car-safe [1 2 3])))
(princ (format "car-safe []: %S\n" (car-safe [])))

;; Contrast with car (which signals error on non-cons)
(princ (format "car '(1 2): %S\n" (car '(1 2))))
(princ (format "car-safe '(1 2): %S\n" (car-safe '(1 2))))
(princ (format "car nil: %S\n" (car nil)))
(princ (format "car-safe nil: %S\n" (car-safe nil)))

;; Special cases: nil as car
(princ (format "car-safe '(nil . 1): %S\n" (car-safe '(nil . 1))))
(princ (format "car-safe '(nil): %S\n" (car-safe '(nil))))

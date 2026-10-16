;;; 54-closurep.el --- Test closurep (Category A port, fanout round #4)

(princ "=== closurep tests (Category A port, fanout round #4) ===\n")

;; Closure cases (should return t)

;; Basic closures (requires lexical-binding)
(princ (format "closurep (lambda () 1): %S\n"
               (closurep (lambda () 1))))
(princ (format "closurep (lambda (x) x): %S\n"
               (closurep (lambda (x) x))))
(princ (format "closurep (lambda (x y) (+ x y)): %S\n"
               (closurep (lambda (x y) (+ x y)))))

;; Non-closure cases (should return nil)

;; nil and t
(princ (format "closurep nil: %S\n" (closurep nil)))
(princ (format "closurep t: %S\n" (closurep t)))

;; Integers
(princ (format "closurep 42: %S\n" (closurep 42)))
(princ (format "closurep 0: %S\n" (closurep 0)))
(princ (format "closurep -42: %S\n" (closurep -42)))

;; Floats
(princ (format "closurep 3.14: %S\n" (closurep 3.14)))
(princ (format "closurep 0.0: %S\n" (closurep 0.0)))

;; Symbols
(princ (format "closurep 'foo: %S\n" (closurep 'foo)))
(princ (format "closurep 'car: %S\n" (closurep 'car)))

;; Strings
(princ (format "closurep \"foo\": %S\n" (closurep "foo")))
(princ (format "closurep \"\": %S\n" (closurep "")))

;; Lists (CRITICAL: quoted lambda is a list, not a closure)
(princ (format "closurep '(1 2 3): %S\n" (closurep '(1 2 3))))
(princ (format "closurep '(): %S\n" (closurep '())))
(princ (format "closurep '(lambda (x) x): %S\n"
               (closurep '(lambda (x) x))))

;; Vectors
(princ (format "closurep []: %S\n" (closurep [])))
(princ (format "closurep [1 2 3]: %S\n" (closurep [1 2 3])))

;; Characters
(princ (format "closurep ?a: %S\n" (closurep ?a)))

;; Built-in functions (CRITICAL: subrs are NOT closures)
(princ (format "closurep (symbol-function 'car): %S\n"
               (closurep (symbol-function 'car))))
(princ (format "closurep (symbol-function 'cdr): %S\n"
               (closurep (symbol-function 'cdr))))

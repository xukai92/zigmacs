;;; 53-subrp.el --- Test subrp (Category A port, fanout round #4)

(princ "=== subrp tests (Category A port, fanout round #4) ===\n")

;; Subr cases (should return t)

;; Built-in functions
(princ (format "subrp (symbol-function 'car): %S\n"
               (subrp (symbol-function 'car))))
(princ (format "subrp (symbol-function 'cdr): %S\n"
               (subrp (symbol-function 'cdr))))
(princ (format "subrp (symbol-function 'cons): %S\n"
               (subrp (symbol-function 'cons))))
(princ (format "subrp (symbol-function 'list): %S\n"
               (subrp (symbol-function 'list))))
(princ (format "subrp (symbol-function '+): %S\n"
               (subrp (symbol-function '+))))
(princ (format "subrp (symbol-function '-): %S\n"
               (subrp (symbol-function '-))))
(princ (format "subrp (symbol-function 'eq): %S\n"
               (subrp (symbol-function 'eq))))
(princ (format "subrp (symbol-function 'equal): %S\n"
               (subrp (symbol-function 'equal))))

;; Non-subr cases (should return nil)

;; nil and t
(princ (format "subrp nil: %S\n" (subrp nil)))
(princ (format "subrp t: %S\n" (subrp t)))

;; Integers
(princ (format "subrp 42: %S\n" (subrp 42)))
(princ (format "subrp 0: %S\n" (subrp 0)))
(princ (format "subrp -42: %S\n" (subrp -42)))

;; Floats
(princ (format "subrp 3.14: %S\n" (subrp 3.14)))
(princ (format "subrp 0.0: %S\n" (subrp 0.0)))

;; Symbols (CRITICAL: symbol 'car is NOT a subr, but (symbol-function 'car) is)
(princ (format "subrp 'foo: %S\n" (subrp 'foo)))
(princ (format "subrp 'car: %S\n" (subrp 'car)))

;; Strings
(princ (format "subrp \"foo\": %S\n" (subrp "foo")))
(princ (format "subrp \"\": %S\n" (subrp "")))

;; Lists
(princ (format "subrp '(1 2 3): %S\n" (subrp '(1 2 3))))
(princ (format "subrp '(): %S\n" (subrp '())))

;; Vectors
(princ (format "subrp []: %S\n" (subrp [])))
(princ (format "subrp [1 2 3]: %S\n" (subrp [1 2 3])))

;; Characters
(princ (format "subrp ?a: %S\n" (subrp ?a)))

;; Lambda/closures (CRITICAL: closures are NOT subrs)
(princ (format "subrp (lambda () 1): %S\n" (subrp (lambda () 1))))
(princ (format "subrp (lambda (x) x): %S\n" (subrp (lambda (x) x))))

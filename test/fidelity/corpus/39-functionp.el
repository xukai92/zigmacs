;;; 39-functionp.el --- Test functionp (Category A fanout round #3)

(princ "=== functionp tests (Category A fanout round #3) ===\n")

;; Function cases (should return t)

;; Built-in functions
(princ (format "functionp 'car: %S\n" (functionp 'car)))
(princ (format "functionp 'list: %S\n" (functionp 'list)))
(princ (format "functionp '+: %S\n" (functionp '+)))
(princ (format "functionp 'cons: %S\n" (functionp 'cons)))

;; Lambda expressions
(princ (format "functionp (lambda () nil): %S\n" (functionp (lambda () nil))))
(princ (format "functionp (lambda (x) x): %S\n" (functionp (lambda (x) x))))
(princ (format "functionp (lambda (x y) (+ x y)): %S\n"
               (functionp (lambda (x y) (+ x y)))))

;; Byte-compiled functions
(princ (format "functionp (byte-compile (lambda () nil)): %S\n"
               (functionp (byte-compile (lambda () nil)))))

;; Non-function cases (should return nil)

;; nil and t
(princ (format "functionp nil: %S\n" (functionp nil)))
(princ (format "functionp t: %S\n" (functionp t)))

;; Integers
(princ (format "functionp 42: %S\n" (functionp 42)))
(princ (format "functionp 0: %S\n" (functionp 0)))
(princ (format "functionp -42: %S\n" (functionp -42)))

;; Floats
(princ (format "functionp 3.14: %S\n" (functionp 3.14)))

;; Unbound symbols
(princ (format "functionp 'unbound-symbol-xyz: %S\n" (functionp 'unbound-symbol-xyz)))

;; Strings
(princ (format "functionp \"string\": %S\n" (functionp "string")))

;; Vectors
(princ (format "functionp [1 2 3]: %S\n" (functionp [1 2 3])))

;; Lists (not lambda)
(princ (format "functionp '(1 2 3): %S\n" (functionp '(1 2 3))))
(princ (format "functionp '(): %S\n" (functionp '())))

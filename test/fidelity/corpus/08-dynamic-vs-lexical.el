;;; 08-dynamic-vs-lexical.el --- Test dynamic vs lexical binding -*- lexical-binding: t; -*-

(princ "=== Lexical binding tests ===\n")

;; Lexical closure
(let ((x 42))
  (let ((get-x (lambda () x)))
    (let ((x 99))  ; Shadow x
      (princ (format "Lexical: outer x=42, inner x=99, (funcall get-x)=%d\n"
                     (funcall get-x))))))

;; Dynamic binding example (needs to eval with lexical-binding nil)
(princ "\n=== Dynamic binding simulation ===\n")
(let ((code '(progn
               (setq x-dynamic 42)
               (defun get-x-dynamic () x-dynamic)
               (let ((x-dynamic 99))
                 (format "Dynamic: (get-x-dynamic)=%d" (get-x-dynamic))))))
  (princ (format "%s\n" (eval code nil))))  ; nil = dynamic scope

;; Let vs let*
(princ "\n=== let vs let* ===\n")
(let ((x 1)
      (y (+ x 10)))  ; Error in lexical: x not bound yet (but we're in let)
  (princ (format "let with forward ref attempt: x=%d\n" x)))

(let* ((x 1)
       (y (+ x 10)))
  (princ (format "let* with forward ref: x=%d, y=%d\n" x y)))

;;; 10-format-prin1.el --- Test format and prin1 edge cases

(princ "=== Format and prin1 edge cases ===\n")

;; Format specifiers
(princ (format "Integer %%d: %d\n" 42))
(princ (format "Float %%f: %f\n" 3.14159))
(princ (format "String %%s: %s\n" "hello"))
(princ (format "S-exp %%S: %S\n" '(a b c)))
(princ (format "Octal %%o: %o\n" 255))
(princ (format "Hex %%x: %x\n" 255))
(princ (format "Hex %%X: %X\n" 255))

;; Width and precision
(princ (format "Width 10: '%10d'\n" 42))
(princ (format "Left-align: '%-10d'\n" 42))
(princ (format "Zero-pad: '%010d'\n" 42))
(princ (format "Precision: '%.2f'\n" 3.14159))

;; Special cases
(princ (format "Percent: %%\n"))
(princ (format "Multiple: %d %s %S\n" 1 "two" 'three))

;; prin1 vs princ vs print
(princ "prin1 of string: ")
(prin1 "hello\nworld")
(princ "\n")

(princ "princ of string: ")
(princ "hello\nworld")
(princ "\n")

;; prin1-to-string
(princ (format "prin1-to-string: %S\n"
               (prin1-to-string '(a "b" (c . d)))))

;; Circular structures (with print-circle)
(let ((lst '(a b c)))
  (setcdr (last lst) lst)  ; Make circular
  (princ (format "Circular list: %S\n" lst)))

;; Uninterned symbols
(let ((sym (make-symbol "uninterned")))
  (princ (format "Uninterned symbol: %S\n" sym)))

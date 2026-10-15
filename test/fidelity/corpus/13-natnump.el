;;; 13-natnump.el --- Test natnump (first C→Zig port)

(princ "=== natnump tests (first C→Zig leaf port) ===\n")

;; Fixnum tests
(princ (format "natnump 0: %S\n" (natnump 0)))
(princ (format "natnump 1: %S\n" (natnump 1)))
(princ (format "natnump -1: %S\n" (natnump -1)))
(princ (format "natnump 42: %S\n" (natnump 42)))
(princ (format "natnump -42: %S\n" (natnump -42)))

;; Fixnum boundaries
(princ (format "natnump most-positive-fixnum: %S\n"
               (natnump most-positive-fixnum)))
(princ (format "natnump most-negative-fixnum: %S\n"
               (natnump most-negative-fixnum)))

;; Bignum tests
(let ((big-pos (1+ most-positive-fixnum)))
  (princ (format "natnump (1+ most-positive-fixnum): %S\n"
                 (natnump big-pos))))

(let ((big-neg (1- most-negative-fixnum)))
  (princ (format "natnump (1- most-negative-fixnum): %S\n"
                 (natnump big-neg))))

(let ((huge-pos (read "99999999999999999999999999999")))
  (princ (format "natnump 99...9 (huge positive): %S\n"
                 (natnump huge-pos))))

(let ((huge-neg (read "-99999999999999999999999999999")))
  (princ (format "natnump -99...9 (huge negative): %S\n"
                 (natnump huge-neg))))

;; Non-integers (should all be nil)
(princ (format "natnump nil: %S\n" (natnump nil)))
(princ (format "natnump t: %S\n" (natnump t)))
(princ (format "natnump 'symbol: %S\n" (natnump 'foo)))
(princ (format "natnump \"string\": %S\n" (natnump "string")))
(princ (format "natnump 0.0: %S\n" (natnump 0.0)))
(princ (format "natnump 3.14: %S\n" (natnump 3.14)))
(princ (format "natnump '(1 . 2): %S\n" (natnump '(1 . 2))))
(princ (format "natnump [1 2 3]: %S\n" (natnump [1 2 3])))

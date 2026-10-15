;;; 04-float-edge-cases.el --- Test float edge cases

(princ "=== Float edge cases ===\n")

;; Special float values
(princ (format "1.0e+INF: %S\n" 1.0e+INF))
(princ (format "-1.0e+INF: %S\n" -1.0e+INF))
(princ (format "0.0e+NaN: %S\n" 0.0e+NaN))

;; Negative zero
(let ((neg-zero -0.0))
  (princ (format "-0.0: %S\n" neg-zero))
  (princ (format "equal -0.0 0.0: %S\n" (equal -0.0 0.0)))
  (princ (format "eql -0.0 0.0: %S\n" (eql -0.0 0.0)))
  (princ (format "= -0.0 0.0: %S\n" (= -0.0 0.0))))

;; NaN behavior
(let ((nan 0.0e+NaN))
  (princ (format "isnan NaN: %S\n" (isnan nan)))
  (princ (format "= NaN NaN: %S\n" (= nan nan)))
  (princ (format "equal NaN NaN: %S\n" (equal nan nan))))

;; Infinity arithmetic
(princ (format "1.0e+INF + 1.0: %S\n" (+ 1.0e+INF 1.0)))
(princ (format "1.0e+INF - 1.0e+INF: %S\n" (- 1.0e+INF 1.0e+INF)))
(princ (format "1.0e+INF * 2.0: %S\n" (* 1.0e+INF 2.0)))
(princ (format "1.0 / 0.0: %S\n" (/ 1.0 0.0)))

;; Very small and very large
(princ (format "1.0e-308: %S\n" 1.0e-308))
(princ (format "1.0e308: %S\n" 1.0e308))

;; Float printing format
(princ (format "%.17g format of 0.1: %.17g\n" 0.1))
(princ (format "%.17g format of 0.3: %.17g\n" 0.3))

;;; 41-markerp.el --- Test markerp (Category A fanout round #3)

(princ "=== markerp tests (Category A fanout round #3) ===\n")

;; Marker cases (should return t)

;; Basic markers
(princ (format "markerp (make-marker): %S\n" (markerp (make-marker))))
(princ (format "markerp (point-marker): %S\n" (markerp (point-marker))))
(princ (format "markerp (point-min-marker): %S\n" (markerp (point-min-marker))))
(princ (format "markerp (point-max-marker): %S\n" (markerp (point-max-marker))))
(princ (format "markerp (copy-marker (point)): %S\n"
               (markerp (copy-marker (point)))))

;; Non-marker cases (should return nil)

;; nil and t
(princ (format "markerp nil: %S\n" (markerp nil)))
(princ (format "markerp t: %S\n" (markerp t)))

;; Integers (positions, but not markers)
(princ (format "markerp 0: %S\n" (markerp 0)))
(princ (format "markerp 1: %S\n" (markerp 1)))
(princ (format "markerp 42: %S\n" (markerp 42)))
(princ (format "markerp (point): %S\n" (markerp (point))))

;; Floats
(princ (format "markerp 3.14: %S\n" (markerp 3.14)))

;; Symbols
(princ (format "markerp 'foo: %S\n" (markerp 'foo)))

;; Strings
(princ (format "markerp \"string\": %S\n" (markerp "string")))

;; Vectors
(princ (format "markerp [1 2 3]: %S\n" (markerp [1 2 3])))

;; Lists
(princ (format "markerp '(1 2 3): %S\n" (markerp '(1 2 3))))

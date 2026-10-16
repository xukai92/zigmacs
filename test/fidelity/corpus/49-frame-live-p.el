;;; 49-frame-live-p.el --- Corpus test for frame-live-p  -*- lexical-binding: t; -*-

;; Fidelity corpus test: frame-live-p (Category H₁)
;; Tests: live frames, non-frame types

(princ "frame-live-p corpus:\n")

;; Test 1: Selected frame (always live, returns terminal type)
(princ "  selected-frame: ")
(princ (frame-live-p (selected-frame)))
(princ "\n")

;; Test 2: Non-frame (nil)
(princ "  nil: ")
(princ (frame-live-p nil))
(princ "\n")

;; Test 3: Non-frame (number)
(princ "  number: ")
(princ (frame-live-p 42))
(princ "\n")

;; Test 4: Non-frame (string)
(princ "  string: ")
(princ (frame-live-p "test"))
(princ "\n")

;; Test 5: Non-frame (symbol)
(princ "  symbol: ")
(princ (frame-live-p 'some-symbol))
(princ "\n")

;; Test 6: Non-frame (list)
(princ "  list: ")
(princ (frame-live-p '(1 2 3)))
(princ "\n")

;;; 49-frame-live-p.el ends here

;;; 50-window-valid-p.el --- Corpus test for window-valid-p  -*- lexical-binding: t; -*-

;; Fidelity corpus test: window-valid-p (Category H₁)
;; Tests: valid windows (live + internal), non-window types

(princ "window-valid-p corpus:\n")

;; Test 1: Selected window (valid)
(princ "  selected-window: ")
(princ (window-valid-p (selected-window)))
(princ "\n")

;; Test 2: Minibuffer window (valid in batch)
(princ "  minibuffer-window: ")
(princ (window-valid-p (minibuffer-window)))
(princ "\n")

;; Test 3: Non-window (nil)
(princ "  nil: ")
(princ (window-valid-p nil))
(princ "\n")

;; Test 4: Non-window (number)
(princ "  number: ")
(princ (window-valid-p 42))
(princ "\n")

;; Test 5: Non-window (string)
(princ "  string: ")
(princ (window-valid-p "test"))
(princ "\n")

;; Test 6: Non-window (symbol)
(princ "  symbol: ")
(princ (window-valid-p 'some-symbol))
(princ "\n")

;; Test 7: Non-window (list)
(princ "  list: ")
(princ (window-valid-p '(1 2 3)))
(princ "\n")

;;; 50-window-valid-p.el ends here

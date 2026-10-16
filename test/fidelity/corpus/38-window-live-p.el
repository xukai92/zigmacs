;;; 38-window-live-p.el --- Corpus test for window-live-p  -*- lexical-binding: t; -*-

;; Fidelity corpus test: window-live-p (Category H₁)
;; Tests: live windows, non-window types

(princ "window-live-p corpus:\n")

;; Test 1: Selected window (always live)
(princ "  selected-window: ")
(princ (window-live-p (selected-window)))
(princ "\n")

;; Test 2: Minibuffer window (live in batch)
(princ "  minibuffer-window: ")
(princ (window-live-p (minibuffer-window)))
(princ "\n")

;; Test 3: Non-window (nil)
(princ "  nil: ")
(princ (window-live-p nil))
(princ "\n")

;; Test 4: Non-window (number)
(princ "  number: ")
(princ (window-live-p 42))
(princ "\n")

;; Test 5: Non-window (string)
(princ "  string: ")
(princ (window-live-p "test"))
(princ "\n")

;; Test 6: Non-window (symbol)
(princ "  symbol: ")
(princ (window-live-p 'some-symbol))
(princ "\n")

;; Test 7: Non-window (list)
(princ "  list: ")
(princ (window-live-p '(1 2 3)))
(princ "\n")

;;; 38-window-live-p.el ends here

;;; 37-keymapp.el --- Corpus test for keymapp  -*- lexical-binding: t; -*-

;; Fidelity corpus test: keymapp (Category H₁)
;; Tests: sparse keymap, full keymap, symbol with keymap, non-keymaps

(princ "keymapp corpus:\n")

;; Test 1: Sparse keymap
(princ "  sparse keymap: ")
(princ (keymapp (make-sparse-keymap)))
(princ "\n")

;; Test 2: Full keymap
(princ "  full keymap: ")
(princ (keymapp (make-keymap)))
(princ "\n")

;; Test 3: Global map
(princ "  global-map: ")
(princ (keymapp (current-global-map)))
(princ "\n")

;; Test 4: Symbol whose function is a keymap
(princ "  symbol-as-keymap: ")
(let ((sym (make-symbol "test-keymap")))
  (fset sym (make-sparse-keymap))
  (princ (keymapp sym)))
(princ "\n")

;; Test 5: Non-keymap (nil)
(princ "  nil: ")
(princ (keymapp nil))
(princ "\n")

;; Test 6: Non-keymap (number)
(princ "  number: ")
(princ (keymapp 42))
(princ "\n")

;; Test 7: Non-keymap (string)
(princ "  string: ")
(princ (keymapp "test"))
(princ "\n")

;; Test 8: Non-keymap (undefined symbol)
(princ "  undefined symbol: ")
(princ (keymapp 'undefined-symbol))
(princ "\n")

;; Test 9: Non-keymap (list)
(princ "  list: ")
(princ (keymapp '(1 2 3)))
(princ "\n")

;;; 37-keymapp.el ends here

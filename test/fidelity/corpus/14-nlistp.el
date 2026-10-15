;;; 14-nlistp.el --- Test nlistp (second C→Zig port)

(princ "=== nlistp tests (second C→Zig leaf port) ===\n")

;; List cases (should return nil)
(princ (format "nlistp nil: %S\n" (nlistp nil)))
(princ (format "nlistp '(): %S\n" (nlistp '())))
(princ (format "nlistp '(1 2 3): %S\n" (nlistp '(1 2 3))))
(princ (format "nlistp '(a b c): %S\n" (nlistp '(a b c))))
(princ (format "nlistp '(1): %S\n" (nlistp '(1))))

;; Improper lists (cons cells - still lists, should return nil)
(princ (format "nlistp '(1 . 2): %S\n" (nlistp '(1 . 2))))
(princ (format "nlistp '(1 2 . 3): %S\n" (nlistp '(1 2 . 3))))
(princ (format "nlistp (cons 'a 'b): %S\n" (nlistp (cons 'a 'b))))

;; Non-list cases (should return t)
(princ (format "nlistp t: %S\n" (nlistp t)))
(princ (format "nlistp 'symbol: %S\n" (nlistp 'foo)))

;; Numbers
(princ (format "nlistp 42: %S\n" (nlistp 42)))
(princ (format "nlistp 0: %S\n" (nlistp 0)))
(princ (format "nlistp -1: %S\n" (nlistp -1)))
(princ (format "nlistp 3.0: %S\n" (nlistp 3.0)))
(princ (format "nlistp most-positive-fixnum: %S\n"
               (nlistp most-positive-fixnum)))

;; Strings
(princ (format "nlistp \"string\": %S\n" (nlistp "string")))
(princ (format "nlistp \"\": %S\n" (nlistp "")))

;; Vectors
(princ (format "nlistp [1 2 3]: %S\n" (nlistp [1 2 3])))
(princ (format "nlistp []: %S\n" (nlistp [])))

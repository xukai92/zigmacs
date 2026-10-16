;;; 27-sequencep.el --- Test sequencep (seventeenth C→Zig port)

(princ "=== sequencep tests (seventeenth C→Zig leaf port) ===\n")

;; Sequence cases (should return t)

;; nil (CRITICAL: nil is a sequence - the empty list)
(princ (format "sequencep nil: %S\n" (sequencep nil)))
(princ (format "sequencep '(): %S\n" (sequencep '())))

;; Lists
(princ (format "sequencep '(1): %S\n" (sequencep '(1))))
(princ (format "sequencep '(1 2 3): %S\n" (sequencep '(1 2 3))))
(princ (format "sequencep '(a b c): %S\n" (sequencep '(a b c))))
(princ (format "sequencep '(1 . 2): %S\n" (sequencep '(1 . 2))))

;; Strings
(princ (format "sequencep \"string\": %S\n" (sequencep "string")))
(princ (format "sequencep \"\": %S\n" (sequencep "")))
(princ (format "sequencep \"hello world\": %S\n" (sequencep "hello world")))

;; Vectors
(princ (format "sequencep []: %S\n" (sequencep [])))
(princ (format "sequencep [1]: %S\n" (sequencep [1])))
(princ (format "sequencep [1 2 3]: %S\n" (sequencep [1 2 3])))
(princ (format "sequencep [a b c]: %S\n" (sequencep [a b c])))

;; Bool-vectors
(princ (format "sequencep (make-bool-vector 0 nil): %S\n"
               (sequencep (make-bool-vector 0 nil))))
(princ (format "sequencep (make-bool-vector 3 t): %S\n"
               (sequencep (make-bool-vector 3 t))))

;; Char-tables
(princ (format "sequencep (make-char-table nil): %S\n"
               (sequencep (make-char-table nil))))

;; Non-sequence cases (should return nil)

;; t (CRITICAL: t is NOT a sequence)
(princ (format "sequencep t: %S\n" (sequencep t)))

;; Integers
(princ (format "sequencep 42: %S\n" (sequencep 42)))
(princ (format "sequencep 0: %S\n" (sequencep 0)))
(princ (format "sequencep -42: %S\n" (sequencep -42)))

;; Floats
(princ (format "sequencep 3.14: %S\n" (sequencep 3.14)))
(princ (format "sequencep 0.0: %S\n" (sequencep 0.0)))

;; Symbols (except nil)
(princ (format "sequencep 'foo: %S\n" (sequencep 'foo)))
(princ (format "sequencep 'x: %S\n" (sequencep 'x)))

;; Characters
(princ (format "sequencep ?a: %S\n" (sequencep ?a)))
(princ (format "sequencep ?\\n: %S\n" (sequencep ?\n)))

;; Records
(princ (format "sequencep (record 'foo): %S\n" (sequencep (record 'foo))))

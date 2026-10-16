;;; 25-recordp.el --- Test recordp (fifteenth C→Zig port)

(princ "=== recordp tests (fifteenth C→Zig leaf port) ===\n")

;; Record cases (should return t)

;; Basic records
(princ (format "recordp (record 'foo): %S\n" (recordp (record 'foo))))
(princ (format "recordp (record 'bar 1): %S\n" (recordp (record 'bar 1))))
(princ (format "recordp (record 'baz 1 2 3): %S\n"
               (recordp (record 'baz 1 2 3))))
(princ (format "recordp (record 'test \"string\" 42): %S\n"
               (recordp (record 'test "string" 42))))

;; Records with various field types
(princ (format "recordp (record 'type nil): %S\n"
               (recordp (record 'type nil))))
(princ (format "recordp (record 'type t): %S\n"
               (recordp (record 'type t))))
(princ (format "recordp (record 'type [1 2 3]): %S\n"
               (recordp (record 'type [1 2 3]))))

;; Non-record cases (should return nil)

;; nil and t
(princ (format "recordp nil: %S\n" (recordp nil)))
(princ (format "recordp t: %S\n" (recordp t)))

;; Integers
(princ (format "recordp 42: %S\n" (recordp 42)))
(princ (format "recordp 0: %S\n" (recordp 0)))
(princ (format "recordp -42: %S\n" (recordp -42)))

;; Floats
(princ (format "recordp 3.14: %S\n" (recordp 3.14)))
(princ (format "recordp 0.0: %S\n" (recordp 0.0)))

;; Symbols
(princ (format "recordp 'foo: %S\n" (recordp 'foo)))
(princ (format "recordp 'x: %S\n" (recordp 'x)))

;; Strings
(princ (format "recordp \"string\": %S\n" (recordp "string")))
(princ (format "recordp \"\": %S\n" (recordp "")))

;; Vectors (CRITICAL: vectors are NOT records)
(princ (format "recordp []: %S\n" (recordp [])))
(princ (format "recordp [1 2 3]: %S\n" (recordp [1 2 3])))
(princ (format "recordp [foo bar]: %S\n" (recordp [foo bar])))

;; Lists
(princ (format "recordp '(1 2 3): %S\n" (recordp '(1 2 3))))
(princ (format "recordp '(1): %S\n" (recordp '(1))))
(princ (format "recordp '(): %S\n" (recordp '())))

;; Characters
(princ (format "recordp ?a: %S\n" (recordp ?a)))

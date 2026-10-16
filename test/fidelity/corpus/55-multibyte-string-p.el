;;; 55-multibyte-string-p.el --- Test multibyte-string-p (Category A port, fanout round #4)

(princ "=== multibyte-string-p tests (Category A port, fanout round #4) ===\n")

;; Multibyte string cases (should return t)

;; Non-ASCII multibyte strings
(princ (format "multibyte-string-p \"é\": %S\n"
               (multibyte-string-p "é")))
(princ (format "multibyte-string-p \"café\": %S\n"
               (multibyte-string-p "café")))
(princ (format "multibyte-string-p \"日本語\": %S\n"
               (multibyte-string-p "日本語")))
(princ (format "multibyte-string-p \"hello 世界\": %S\n"
               (multibyte-string-p "hello 世界")))
(princ (format "multibyte-string-p \"αβγ\": %S\n"
               (multibyte-string-p "αβγ")))

;; ASCII strings (multibyte by default in modern Emacs)
(princ (format "multibyte-string-p \"hello\": %S\n"
               (multibyte-string-p "hello")))
(princ (format "multibyte-string-p \"abc\": %S\n"
               (multibyte-string-p "abc")))
(princ (format "multibyte-string-p \"a\": %S\n"
               (multibyte-string-p "a")))
(princ (format "multibyte-string-p \"\": %S\n"
               (multibyte-string-p "")))

;; Unibyte string cases (should return nil)

;; Explicitly unibyte strings
(princ (format "multibyte-string-p (string-to-unibyte \"hello\"): %S\n"
               (multibyte-string-p (string-to-unibyte "hello"))))
(princ (format "multibyte-string-p (string-to-unibyte \"abc\"): %S\n"
               (multibyte-string-p (string-to-unibyte "abc"))))
(princ (format "multibyte-string-p (string-to-unibyte \"\"): %S\n"
               (multibyte-string-p (string-to-unibyte ""))))

;; Non-string cases (should return nil)

;; nil and t
(princ (format "multibyte-string-p nil: %S\n" (multibyte-string-p nil)))
(princ (format "multibyte-string-p t: %S\n" (multibyte-string-p t)))

;; Integers
(princ (format "multibyte-string-p 42: %S\n" (multibyte-string-p 42)))
(princ (format "multibyte-string-p 0: %S\n" (multibyte-string-p 0)))
(princ (format "multibyte-string-p -42: %S\n" (multibyte-string-p -42)))

;; Floats
(princ (format "multibyte-string-p 3.14: %S\n" (multibyte-string-p 3.14)))
(princ (format "multibyte-string-p 0.0: %S\n" (multibyte-string-p 0.0)))

;; Symbols
(princ (format "multibyte-string-p 'foo: %S\n" (multibyte-string-p 'foo)))
(princ (format "multibyte-string-p 'bar: %S\n" (multibyte-string-p 'bar)))

;; Lists
(princ (format "multibyte-string-p '(1 2 3): %S\n"
               (multibyte-string-p '(1 2 3))))
(princ (format "multibyte-string-p '(): %S\n"
               (multibyte-string-p '())))
(princ (format "multibyte-string-p '(\"string\"): %S\n"
               (multibyte-string-p '("string"))))

;; Vectors
(princ (format "multibyte-string-p []: %S\n" (multibyte-string-p [])))
(princ (format "multibyte-string-p [1 2 3]: %S\n"
               (multibyte-string-p [1 2 3])))

;; Characters (CRITICAL: characters are NOT strings)
(princ (format "multibyte-string-p ?a: %S\n" (multibyte-string-p ?a)))
(princ (format "multibyte-string-p ?é: %S\n" (multibyte-string-p ?é)))

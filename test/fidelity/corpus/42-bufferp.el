;;; 42-bufferp.el --- Test bufferp (Category A fanout round #3)

(princ "=== bufferp tests (Category A fanout round #3) ===\n")

;; Buffer cases (should return t)

;; Current buffer
(princ (format "bufferp (current-buffer): %S\n" (bufferp (current-buffer))))

;; Named buffers
(princ (format "bufferp (get-buffer-create \"*test-buffer*\"): %S\n"
               (bufferp (get-buffer-create "*test-buffer*"))))

;; Scratch buffer
(princ (format "bufferp (get-buffer \"*scratch*\"): %S\n"
               (bufferp (get-buffer "*scratch*"))))

;; Messages buffer
(princ (format "bufferp (get-buffer \"*Messages*\"): %S\n"
               (bufferp (get-buffer "*Messages*"))))

;; Non-buffer cases (should return nil)

;; nil and t
(princ (format "bufferp nil: %S\n" (bufferp nil)))
(princ (format "bufferp t: %S\n" (bufferp t)))

;; Integers
(princ (format "bufferp 42: %S\n" (bufferp 42)))
(princ (format "bufferp 0: %S\n" (bufferp 0)))

;; Floats
(princ (format "bufferp 3.14: %S\n" (bufferp 3.14)))

;; Symbols
(princ (format "bufferp 'foo: %S\n" (bufferp 'foo)))

;; Strings (buffer names, but not buffers)
(princ (format "bufferp \"string\": %S\n" (bufferp "string")))
(princ (format "bufferp \"*scratch*\": %S\n" (bufferp "*scratch*")))

;; Vectors
(princ (format "bufferp [1 2 3]: %S\n" (bufferp [1 2 3])))

;; Lists
(princ (format "bufferp '(1 2 3): %S\n" (bufferp '(1 2 3))))

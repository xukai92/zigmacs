;;; 36-buffer-live-p.el --- Corpus test for buffer-live-p  -*- lexical-binding: t; -*-

;; Fidelity corpus test: buffer-live-p (Category H₁)
;; Tests: live buffer, killed buffer, non-buffer types

(princ "buffer-live-p corpus:\n")

;; Test 1: Live buffer (current-buffer)
(princ "  live buffer: ")
(princ (buffer-live-p (current-buffer)))
(princ "\n")

;; Test 2: Killed buffer
(princ "  killed buffer: ")
(let ((buf (generate-new-buffer "temp")))
  (kill-buffer buf)
  (princ (buffer-live-p buf)))
(princ "\n")

;; Test 3: Non-buffer (nil)
(princ "  nil: ")
(princ (buffer-live-p nil))
(princ "\n")

;; Test 4: Non-buffer (number)
(princ "  number: ")
(princ (buffer-live-p 42))
(princ "\n")

;; Test 5: Non-buffer (string)
(princ "  string: ")
(princ (buffer-live-p "test"))
(princ "\n")

;; Test 6: Multiple buffers
(princ "  multiple: ")
(let ((buf1 (generate-new-buffer "test1"))
      (buf2 (generate-new-buffer "test2")))
  (princ (list (buffer-live-p buf1)
               (buffer-live-p buf2)))
  (kill-buffer buf1)
  (princ " -> ")
  (princ (list (buffer-live-p buf1)
               (buffer-live-p buf2)))
  (kill-buffer buf2))
(princ "\n")

;;; 36-buffer-live-p.el ends here

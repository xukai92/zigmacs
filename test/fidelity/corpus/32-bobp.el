;;; 32-bobp.el --- Test bobp (beginning-of-buffer-p predicate)

(princ "=== bobp tests (Cat-C read-only point predicate) ===\n")

;; Empty buffer - bobp should return t
(with-temp-buffer
  (princ (format "Empty buffer: bobp=%S point=%S\n"
                 (bobp) (point))))

;; Basic buffer tests
(with-temp-buffer
  (insert "hello world")
  (princ "Buffer: \"hello world\"\n")

  ;; At beginning
  (goto-char (point-min))
  (princ (format "  At point-min (1): bobp=%S\n" (bobp)))

  ;; In middle
  (goto-char 6)
  (princ (format "  At point 6: bobp=%S\n" (bobp)))

  ;; At end
  (goto-char (point-max))
  (princ (format "  At point-max (12): bobp=%S\n" (bobp))))

;; Multiline buffer
(with-temp-buffer
  (insert "line1\nline2\nline3")
  (princ "Multiline buffer:\n")

  (goto-char 1)
  (princ (format "  At position 1: bobp=%S\n" (bobp)))

  (goto-char 2)
  (princ (format "  At position 2: bobp=%S\n" (bobp)))

  (goto-char 7)  ; Start of line2
  (princ (format "  At position 7 (start of line2): bobp=%S\n" (bobp)))

  (goto-char (point-max))
  (princ (format "  At point-max: bobp=%S\n" (bobp))))

;; Narrowing tests
(with-temp-buffer
  (insert "0123456789")
  (princ "Narrowing tests:\n")

  ;; Narrow to region [4, 8]
  (narrow-to-region 4 8)

  ;; At narrow beginning (BEGV = 4)
  (goto-char (point-min))
  (princ (format "  At narrow beginning (4): bobp=%S point=%S\n"
                 (bobp) (point)))

  ;; In middle of narrow region
  (goto-char 6)
  (princ (format "  At position 6 (in narrow): bobp=%S\n" (bobp)))

  ;; At narrow end
  (goto-char (point-max))
  (princ (format "  At narrow end (8): bobp=%S\n" (bobp)))

  ;; Widen and retest
  (widen)
  (goto-char 1)
  (princ (format "  After widen, at 1: bobp=%S\n" (bobp)))
  (goto-char 4)
  (princ (format "  After widen, at 4: bobp=%S\n" (bobp))))

;; Movement sequence
(with-temp-buffer
  (insert "abcdefgh")
  (princ "Movement sequence:\n")
  (dolist (pos '(1 2 5 1 8 1))
    (goto-char pos)
    (princ (format "  At position %S: bobp=%S\n" pos (bobp)))))

(princ "=== bobp tests complete ===\n")

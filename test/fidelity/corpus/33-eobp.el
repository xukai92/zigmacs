;;; 33-eobp.el --- Test eobp (end-of-buffer-p predicate)

(princ "=== eobp tests (Cat-C read-only point predicate) ===\n")

;; Empty buffer - eobp should return t
(with-temp-buffer
  (princ (format "Empty buffer: eobp=%S point=%S\n"
                 (eobp) (point))))

;; Basic buffer tests
(with-temp-buffer
  (insert "hello world")
  (princ "Buffer: \"hello world\"\n")

  ;; At beginning
  (goto-char (point-min))
  (princ (format "  At point-min (1): eobp=%S\n" (eobp)))

  ;; In middle
  (goto-char 6)
  (princ (format "  At point 6: eobp=%S\n" (eobp)))

  ;; At end
  (goto-char (point-max))
  (princ (format "  At point-max (12): eobp=%S\n" (eobp))))

;; Multiline buffer
(with-temp-buffer
  (insert "line1\nline2\nline3")
  (princ "Multiline buffer:\n")

  (goto-char 1)
  (princ (format "  At position 1: eobp=%S\n" (eobp)))

  (goto-char 7)  ; Start of line2
  (princ (format "  At position 7 (start of line2): eobp=%S\n" (eobp)))

  (goto-char (1- (point-max)))
  (princ (format "  At position before max: eobp=%S\n" (eobp)))

  (goto-char (point-max))
  (princ (format "  At point-max: eobp=%S\n" (eobp))))

;; Narrowing tests
(with-temp-buffer
  (insert "0123456789")
  (princ "Narrowing tests:\n")

  ;; Narrow to region [4, 8]
  (narrow-to-region 4 8)

  ;; At narrow beginning (BEGV = 4)
  (goto-char (point-min))
  (princ (format "  At narrow beginning (4): eobp=%S\n" (eobp)))

  ;; In middle of narrow region
  (goto-char 6)
  (princ (format "  At position 6 (in narrow): eobp=%S\n" (eobp)))

  ;; At narrow end (ZV = 8)
  (goto-char (point-max))
  (princ (format "  At narrow end (8): eobp=%S point=%S\n"
                 (eobp) (point)))

  ;; Widen and retest
  (widen)
  (goto-char 8)
  (princ (format "  After widen, at 8: eobp=%S\n" (eobp)))
  (goto-char (point-max))
  (princ (format "  After widen, at max (11): eobp=%S\n" (eobp))))

;; Movement sequence
(with-temp-buffer
  (insert "abcdefgh")
  (princ "Movement sequence:\n")
  (dolist (pos '(1 5 9 8 9))
    (goto-char pos)
    (princ (format "  At position %S: eobp=%S\n" pos (eobp)))))

(princ "=== eobp tests complete ===\n")

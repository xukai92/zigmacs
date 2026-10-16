;;; 34-bolp.el --- Test bolp (beginning-of-line-p predicate)

(princ "=== bolp tests (Cat-C read-only point predicate) ===\n")

;; Empty buffer - bolp should return t
(with-temp-buffer
  (princ (format "Empty buffer: bolp=%S point=%S\n"
                 (bolp) (point))))

;; Single line buffer
(with-temp-buffer
  (insert "hello world")
  (princ "Single line: \"hello world\"\n")

  ;; At beginning (also beginning of line)
  (goto-char 1)
  (princ (format "  At position 1: bolp=%S\n" (bolp)))

  ;; In middle of line
  (goto-char 6)
  (princ (format "  At position 6: bolp=%S\n" (bolp)))

  ;; At end (no newline)
  (goto-char (point-max))
  (princ (format "  At end: bolp=%S\n" (bolp))))

;; Multiline buffer
(with-temp-buffer
  (insert "line1\nline2\nline3")
  (princ "Multiline buffer: \"line1\\nline2\\nline3\"\n")

  ;; At buffer start (position 1)
  (goto-char 1)
  (princ (format "  Position 1 (start): bolp=%S\n" (bolp)))

  ;; Middle of line1
  (goto-char 3)
  (princ (format "  Position 3 (mid line1): bolp=%S\n" (bolp)))

  ;; At newline after line1 (position 6)
  (goto-char 6)
  (princ (format "  Position 6 (at \\n after line1): bolp=%S\n" (bolp)))

  ;; After newline, start of line2 (position 7)
  (goto-char 7)
  (princ (format "  Position 7 (start of line2): bolp=%S\n" (bolp)))

  ;; Middle of line2
  (goto-char 9)
  (princ (format "  Position 9 (mid line2): bolp=%S\n" (bolp)))

  ;; Start of line3
  (goto-char 13)
  (princ (format "  Position 13 (start of line3): bolp=%S\n" (bolp)))

  ;; End of buffer
  (goto-char (point-max))
  (princ (format "  At point-max: bolp=%S\n" (bolp))))

;; Empty lines
(with-temp-buffer
  (insert "a\n\nc")
  (princ "With empty line: \"a\\n\\nc\"\n")

  (goto-char 1)
  (princ (format "  Position 1 (a): bolp=%S\n" (bolp)))

  (goto-char 2)
  (princ (format "  Position 2 (first \\n): bolp=%S\n" (bolp)))

  (goto-char 3)
  (princ (format "  Position 3 (empty line): bolp=%S\n" (bolp)))

  (goto-char 4)
  (princ (format "  Position 4 (c): bolp=%S\n" (bolp))))

;; Narrowing tests
(with-temp-buffer
  (insert "aaaa\nbbbb\ncccc")
  (princ "Narrowing tests:\n")

  ;; Narrow to middle of line2 through line3
  (narrow-to-region 8 14)

  (goto-char (point-min))
  (princ (format "  At narrow beginning (8, mid-line): bolp=%S\n" (bolp)))

  (goto-char 10)
  (princ (format "  Position 10 (at \\n in narrow): bolp=%S\n" (bolp)))

  (goto-char 11)
  (princ (format "  Position 11 (start of line in narrow): bolp=%S\n" (bolp)))

  (widen)
  (goto-char 1)
  (princ (format "  After widen, at 1: bolp=%S\n" (bolp))))

;; Trailing newline
(with-temp-buffer
  (insert "text\n")
  (princ "Trailing newline: \"text\\n\"\n")

  (goto-char 5)
  (princ (format "  Position 5 (at trailing \\n): bolp=%S\n" (bolp)))

  (goto-char 6)
  (princ (format "  Position 6 (after trailing \\n): bolp=%S\n" (bolp))))

(princ "=== bolp tests complete ===\n")

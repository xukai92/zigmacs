;;; 35-eolp.el --- Test eolp (end-of-line-p predicate)

(princ "=== eolp tests (Cat-C read-only point predicate) ===\n")

;; Empty buffer - eolp should return t
(with-temp-buffer
  (princ (format "Empty buffer: eolp=%S point=%S\n"
                 (eolp) (point))))

;; Single line buffer
(with-temp-buffer
  (insert "hello world")
  (princ "Single line: \"hello world\"\n")

  ;; At beginning
  (goto-char 1)
  (princ (format "  At position 1: eolp=%S\n" (eolp)))

  ;; In middle of line
  (goto-char 6)
  (princ (format "  At position 6: eolp=%S\n" (eolp)))

  ;; At end (no newline, but end of buffer)
  (goto-char (point-max))
  (princ (format "  At end: eolp=%S\n" (eolp))))

;; Multiline buffer
(with-temp-buffer
  (insert "line1\nline2\nline3")
  (princ "Multiline buffer: \"line1\\nline2\\nline3\"\n")

  ;; At buffer start
  (goto-char 1)
  (princ (format "  Position 1 (start): eolp=%S\n" (eolp)))

  ;; Middle of line1
  (goto-char 3)
  (princ (format "  Position 3 (mid line1): eolp=%S\n" (eolp)))

  ;; At newline after line1 (position 6)
  (goto-char 6)
  (princ (format "  Position 6 (at \\n after line1): eolp=%S\n" (eolp)))

  ;; After newline, start of line2 (position 7)
  (goto-char 7)
  (princ (format "  Position 7 (start of line2): eolp=%S\n" (eolp)))

  ;; Middle of line2
  (goto-char 9)
  (princ (format "  Position 9 (mid line2): eolp=%S\n" (eolp)))

  ;; At newline after line2
  (goto-char 12)
  (princ (format "  Position 12 (at \\n after line2): eolp=%S\n" (eolp)))

  ;; Middle of line3
  (goto-char 15)
  (princ (format "  Position 15 (mid line3): eolp=%S\n" (eolp)))

  ;; End of buffer (also end of line)
  (goto-char (point-max))
  (princ (format "  At point-max: eolp=%S\n" (eolp))))

;; Empty lines
(with-temp-buffer
  (insert "a\n\nc")
  (princ "With empty line: \"a\\n\\nc\"\n")

  (goto-char 1)
  (princ (format "  Position 1 (a): eolp=%S\n" (eolp)))

  (goto-char 2)
  (princ (format "  Position 2 (first \\n): eolp=%S\n" (eolp)))

  (goto-char 3)
  (princ (format "  Position 3 (second \\n, empty line): eolp=%S\n" (eolp)))

  (goto-char 4)
  (princ (format "  Position 4 (c): eolp=%S\n" (eolp))))

;; Narrowing tests
(with-temp-buffer
  (insert "aaaa\nbbbb\ncccc")
  (princ "Narrowing tests:\n")

  ;; Narrow to middle of line2 through line3
  (narrow-to-region 8 14)

  (goto-char (point-min))
  (princ (format "  At narrow beginning (8, mid-line): eolp=%S\n" (eolp)))

  (goto-char 10)
  (princ (format "  Position 10 (at \\n in narrow): eolp=%S\n" (eolp)))

  (goto-char 11)
  (princ (format "  Position 11 (start of line in narrow): eolp=%S\n" (eolp)))

  (goto-char (point-max))
  (princ (format "  At narrow end (14): eolp=%S\n" (eolp)))

  (widen)
  (goto-char 5)
  (princ (format "  After widen, at 5 (\\n): eolp=%S\n" (eolp))))

;; Trailing newline
(with-temp-buffer
  (insert "text\n")
  (princ "Trailing newline: \"text\\n\"\n")

  (goto-char 5)
  (princ (format "  Position 5 (at trailing \\n): eolp=%S\n" (eolp)))

  (goto-char 6)
  (princ (format "  Position 6 (after trailing \\n, at eob): eolp=%S\n" (eolp))))

;; Multiple consecutive newlines
(with-temp-buffer
  (insert "a\n\n\nb")
  (princ "Multiple newlines: \"a\\n\\n\\nb\"\n")

  (goto-char 2)
  (princ (format "  Position 2 (first \\n): eolp=%S\n" (eolp)))

  (goto-char 3)
  (princ (format "  Position 3 (second \\n): eolp=%S\n" (eolp)))

  (goto-char 4)
  (princ (format "  Position 4 (third \\n): eolp=%S\n" (eolp)))

  (goto-char 5)
  (princ (format "  Position 5 (b): eolp=%S\n" (eolp))))

(princ "=== eolp tests complete ===\n")

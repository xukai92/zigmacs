;;; 07-narrowing.el --- Test narrowing and save-restriction

(princ "=== Narrowing ===\n")

(with-temp-buffer
  (insert "0123456789")

  (princ (format "Full buffer: %S, point-min=%d, point-max=%d\n"
                 (buffer-string) (point-min) (point-max)))

  ;; Narrow to region
  (narrow-to-region 3 8)
  (princ (format "After narrow 3-8: visible=%S, point-min=%d, point-max=%d\n"
                 (buffer-substring (point-min) (point-max))
                 (point-min) (point-max)))

  ;; Operations in narrowed buffer
  (goto-char (point-min))
  (insert "A")
  (princ (format "After insert in narrow: %S\n"
                 (buffer-substring (point-min) (point-max))))

  ;; save-restriction
  (save-restriction
    (widen)
    (princ (format "Inside save-restriction (widened): %S, min=%d, max=%d\n"
                   (buffer-string) (point-min) (point-max))))

  (princ (format "After save-restriction: still narrow=%S, min=%d, max=%d\n"
                 (buffer-substring (point-min) (point-max))
                 (point-min) (point-max)))

  ;; Widen
  (widen)
  (princ (format "After widen: %S, min=%d, max=%d\n"
                 (buffer-string) (point-min) (point-max))))

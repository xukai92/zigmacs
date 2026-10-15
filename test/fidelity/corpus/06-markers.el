;;; 06-markers.el --- Test markers with insertion types

(princ "=== Markers ===\n")

(with-temp-buffer
  (insert "abcdefghij")

  ;; Create markers at various positions
  (let ((m1 (copy-marker 3))     ; before 'd'
        (m2 (copy-marker 3 t))   ; before 'd', advances on insertion
        (m3 (copy-marker 7)))    ; before 'h'

    (princ (format "Initial: buffer=%S, m1=%d, m2=%d, m3=%d\n"
                   (buffer-string)
                   (marker-position m1)
                   (marker-position m2)
                   (marker-position m3)))

    ;; Insert at marker position
    (goto-char m1)
    (insert "XXX")

    (princ (format "After insert at m1: buffer=%S\n" (buffer-string)))
    (princ (format "m1 position: %d (insertion-type: %S)\n"
                   (marker-position m1) (marker-insertion-type m1)))
    (princ (format "m2 position: %d (insertion-type: %S)\n"
                   (marker-position m2) (marker-insertion-type m2)))
    (princ (format "m3 position: %d\n" (marker-position m3)))

    ;; Set marker
    (set-marker m1 1)
    (princ (format "After set-marker m1 to 1: %d\n" (marker-position m1)))

    ;; Point and mark as markers
    (goto-char 5)
    (set-mark 10)
    (princ (format "Point: %d, Mark: %d\n" (point) (mark)))
    (princ (format "Point marker: %S\n" (point-marker)))
    (princ (format "Mark marker insertion type: %S\n" (mark-marker-insertion-type)))))

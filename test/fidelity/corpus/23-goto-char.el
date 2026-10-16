;;; 23-goto-char.el --- Test goto-char (first Cat-C C→Zig port)

(princ "=== goto-char tests (first Cat-C [stateful] C→Zig port) ===\n")

;; Basic navigation tests
(with-temp-buffer
  (insert "hello world")
  (princ (format "Buffer: \"hello world\" (len 11)\n"))

  ;; Move to beginning
  (princ (format "goto-char 1: ret=%S point=%S\n"
                 (goto-char 1) (point)))

  ;; Move to middle
  (princ (format "goto-char 6: ret=%S point=%S\n"
                 (goto-char 6) (point)))

  ;; Move to end (point-max = 12)
  (princ (format "goto-char 12: ret=%S point=%S\n"
                 (goto-char 12) (point)))

  ;; Clamping tests - before BEGV
  (princ (format "goto-char 0: ret=%S point=%S (clamp to min)\n"
                 (goto-char 0) (point)))
  (princ (format "goto-char -10: ret=%S point=%S (clamp to min)\n"
                 (goto-char -10) (point)))

  ;; Clamping tests - after ZV
  (princ (format "goto-char 99: ret=%S point=%S (clamp to max)\n"
                 (goto-char 99) (point)))
  (princ (format "goto-char 1000: ret=%S point=%S (clamp to max)\n"
                 (goto-char 1000) (point))))

;; Test with markers
(with-temp-buffer
  (insert "0123456789")
  (let ((marker (make-marker)))
    (set-marker marker 5 (current-buffer))
    (goto-char 1)
    (princ (format "goto-char (marker at 5): ret=<marker> point=%S\n"
                   (progn (goto-char marker) (point))))

    ;; Test point-min-marker
    (let ((min-marker (point-min-marker)))
      (goto-char 8)
      (princ (format "goto-char (point-min-marker): ret=<marker> point=%S\n"
                     (progn (goto-char min-marker) (point)))))

    ;; Test point-max-marker
    (let ((max-marker (point-max-marker)))
      (goto-char 1)
      (princ (format "goto-char (point-max-marker): ret=<marker> point=%S\n"
                     (progn (goto-char max-marker) (point)))))))

;; Test with narrowing
(with-temp-buffer
  (insert "0123456789")
  (princ "Narrowing tests:\n")
  (narrow-to-region 4 8)  ; Narrow to positions 4-8 (chars "345")

  ;; Within narrow region
  (princ (format "  goto-char 6 (in narrow [4,8]): ret=%S point=%S\n"
                 (goto-char 6) (point)))

  ;; Before BEGV - should clamp to 4
  (princ (format "  goto-char 1 (before BEGV): ret=%S point=%S\n"
                 (goto-char 1) (point)))

  ;; After ZV - should clamp to 8
  (princ (format "  goto-char 99 (after ZV): ret=%S point=%S\n"
                 (goto-char 99) (point)))

  (widen)
  (princ (format "  After widen, goto-char 1: ret=%S point=%S\n"
                 (goto-char 1) (point))))

;; Empty buffer
(with-temp-buffer
  (princ "Empty buffer tests:\n")
  (princ (format "  goto-char 1: ret=%S point=%S\n"
                 (goto-char 1) (point)))
  (princ (format "  goto-char 0: ret=%S point=%S\n"
                 (goto-char 0) (point)))
  (princ (format "  goto-char 99: ret=%S point=%S\n"
                 (goto-char 99) (point))))

;; Complex scenario - multiple moves
(with-temp-buffer
  (insert "abcdefghij")
  (princ "Multiple moves sequence:\n")
  (let ((positions (list 1 5 10 11 1 99 0)))
    (dolist (pos positions)
      (princ (format "  goto-char %S: point=%S\n" pos (progn (goto-char pos) (point)))))))

;; Return value tests
(with-temp-buffer
  (insert "test")
  (princ "Return value tests:\n")

  ;; Normal case - returns input
  (let ((ret (goto-char 3)))
    (princ (format "  (goto-char 3) returns: %S (input arg)\n" ret)))

  ;; Clamping case - still returns input (not clamped position)
  (let ((ret (goto-char 99)))
    (princ (format "  (goto-char 99) returns: %S (input arg, not %S)\n"
                   ret (point))))

  ;; Marker case - returns marker
  (let* ((marker (make-marker))
         (ret (progn
                (set-marker marker 2 (current-buffer))
                (goto-char marker))))
    (princ (format "  (goto-char marker) returns: marker? %S\n"
                   (markerp ret)))))

;; Error cases (wrapped in condition-case)
(princ "Error cases:\n")

(condition-case err
    (goto-char "not a number")
  (wrong-type-argument
   (princ (format "  goto-char \"string\": error=%S\n" (car err)))))

(condition-case err
    (goto-char 'symbol)
  (wrong-type-argument
   (princ (format "  goto-char 'symbol: error=%S\n" (car err)))))

(condition-case err
    (goto-char nil)
  (wrong-type-argument
   (princ (format "  goto-char nil: error=%S\n" (car err)))))

(condition-case err
    (goto-char '(1 2 3))
  (wrong-type-argument
   (princ (format "  goto-char '(1 2 3): error=%S\n" (car err)))))

;; Float should also error (not a fixnum)
(condition-case err
    (goto-char 3.14)
  (wrong-type-argument
   (princ (format "  goto-char 3.14: error=%S\n" (car err)))))

(princ "=== goto-char tests complete ===\n")

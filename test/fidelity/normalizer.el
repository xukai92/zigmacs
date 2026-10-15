;;; normalizer.el --- Output normalization for fidelity harness -*- lexical-binding: t; -*-

;; Ordered list of (regexp . replacement) filters per HARNESS.md §5.3.
;; Each normalizer is tied to a divergences.toml registry entry.

(defconst zigmacs-normalizers
  '(
    ;; Window object IDs (addresses)
    ("#<window \\([0-9]+\\)" . "#<window N")
    ("#<window [0-9]+ on \\(.+\\)>" . "#<window N on \\1>")

    ;; Frame object IDs
    ("#<frame .* \\(0x[0-9a-f]+\\)>" . "#<frame ... ADDR>")

    ;; Buffer object IDs (some contexts)
    ("#<buffer \\(.+\\) \\(0x[0-9a-f]+\\)>" . "#<buffer \\1>")

    ;; Process IDs
    ("\\bpid \\([0-9]+\\)" . "pid N")
    ("\\bPID: [0-9]+" . "PID: N")

    ;; Gensym counters (uninterned symbols)
    ("#:g\\([0-9]+\\)" . "#:gN")

    ;; Time representations
    ("\\b[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\} [0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}"
     . "YYYY-MM-DD HH:MM:SS")
    ("\\b[A-Z][a-z][a-z] [A-Z][a-z][a-z] [ 0-9][0-9] [0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\} [0-9]\\{4\\}"
     . "DDD MMM DD HH:MM:SS YYYY")

    ;; Temp file paths
    ("/tmp/[a-zA-Z0-9_-]+" . "/tmp/TEMP")
    ("/var/folders/[^/]+/[^/]+/[^/ ]+" . "/tmp/TEMP")

    ;; Absolute paths to user home (make relative or generic)
    ("/home/[^/]+/" . "/home/USER/")
    ("/Users/[^/]+/" . "/home/USER/")

    ;; System name variations
    ("\\bsystem-name: [^ \n]+" . "system-name: HOST")

    ;; User login name
    ("\\buser: [^ \n]+" . "user: USER")

    ;; Memory addresses in various contexts
    ("\\b0x[0-9a-f]\\{8,16\\}\\b" . "0xADDR")

    ;; Emacs build time
    ("\\bemacs-build-time: .+" . "emacs-build-time: FROZEN")
    )
  "List of (REGEXP . REPLACEMENT) normalizers.
Applied in order to both oracle and port outputs.
Each entry corresponds to a divergences.toml registry entry.")

(defun zigmacs-normalize-output (text)
  "Apply all normalizers to TEXT.
Returns normalized text suitable for comparison."
  (let ((result text))
    (dolist (norm zigmacs-normalizers)
      (let ((regexp (car norm))
            (replacement (cdr norm)))
        (setq result (replace-regexp-in-string regexp replacement result t))))
    result))

(defun zigmacs-normalize-file (input-file output-file)
  "Normalize INPUT-FILE and write to OUTPUT-FILE."
  (with-temp-buffer
    (insert-file-contents input-file)
    (let ((normalized (zigmacs-normalize-output (buffer-string))))
      (with-temp-file output-file
        (insert normalized)))))

(provide 'normalizer)
;;; normalizer.el ends here

;;; preamble.el --- Determinism controls for Zigmacs fidelity harness -*- lexical-binding: t; -*-

;; Pin all nondeterminism sources per HARNESS.md §5.1 table.
;; Loaded via: emacs -Q --batch -l preamble.el

;;; 1. Random seed
(random "zigmacs-fixed-seed")

;;; 2. Freeze time
;; Override time functions to return a fixed instant
(defconst zigmacs--frozen-time '(25000 0 0 0))  ; Fixed time representation

(defun current-time ()
  "Return frozen time for determinism."
  zigmacs--frozen-time)

(defun float-time (&optional _specified-time)
  "Return frozen time as float."
  1640000000.0)  ; 2021-12-20 (arbitrary fixed value)

(defun current-time-string (&optional _specified-time)
  "Return frozen time string."
  "Mon Dec 20 12:00:00 2021")

;;; 3. Gensym counter
(setq gensym-counter 0)

;;; 4. Float output format
(setq float-output-format nil)  ; Use default, but it's predictable

;;; 5. Print variables for canonical output
(setq print-circle t
      print-gensym t
      print-length nil
      print-level nil
      print-quoted t)

;;; 6. Coding systems
(prefer-coding-system 'utf-8-unix)
(setq default-buffer-file-coding-system 'utf-8-unix)
(setq locale-coding-system 'utf-8-unix)

;;; 7. GC threshold - raise to avoid incidental GC during test cases
(setq gc-cons-threshold 100000000)  ; 100MB

;;; 8. Environment pinning
(setenv "LC_ALL" "C.UTF-8")
(setenv "LANG" "C.UTF-8")
(setenv "TZ" "UTC")

;;; 9. System identity (these will be normalized anyway, but pin where possible)
;; Note: Some like emacs-pid, system-name can't be fully controlled in preamble,
;; so they're handled by the normalizer

;;; 10. Disable anything that might affect output
(setq inhibit-message t)  ; Suppress echo area messages in batch mode
(setq message-log-max nil)  ; No *Messages* buffer

;;; 11. Directory setup (to be overridden per-test with sandboxed temp dirs)
;; Tests should set up their own temp HOME/cwd

(provide 'preamble)
;;; preamble.el ends here

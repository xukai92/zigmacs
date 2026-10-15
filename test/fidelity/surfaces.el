;;; surfaces.el --- Observable surface serialization for fidelity harness -*- lexical-binding: t; -*-

;; Canonical capture of all observable surfaces per HARNESS.md §4.

(require 'cl-lib)

;;; Surface (a): Return value via canonical printer

(defun zigmacs-surfaces--canonicalize-value (value)
  "Print VALUE canonically for comparison.
Uses print-circle, print-gensym, etc. per §4a."
  (let ((print-circle t)
        (print-gensym t)
        (print-length nil)
        (print-level nil)
        (print-quoted t))
    (prin1-to-string value)))

;;; Surface (b): Streams (stdout/stderr)
;; Captured by redirecting standard-output/standard-error
;; The runner handles this

;;; Surface (c): Nonlocal exits

(defun zigmacs-surfaces--capture-nonlocal-exit (form)
  "Execute FORM and capture any nonlocal exit.
Returns (type . data):
  - (:normal . return-value) for normal return
  - (:signal error-symbol . error-data) for errors
  - (:throw tag . value) for throws"
  (condition-case err
      (let ((result (catch 'zigmacs--catch-wrapper
                      (list :normal (eval form t)))))
        (if (and (consp result) (eq (car result) :normal))
            result
          ;; Was a throw
          (cons :throw result)))
    (error (cons :signal err))))

;;; Surface (d): Editing state - full buffer serialization

(defun zigmacs-surfaces--serialize-text-properties (start end)
  "Return canonical representation of text properties from START to END.
Format: list of (pos-start pos-end . plist) sorted by position."
  (let ((result nil)
        (pos start))
    (while (< pos end)
      (let* ((next-change (next-property-change pos nil end))
             (props (text-properties-at pos)))
        (when props
          (push (list pos next-change props) result))
        (setq pos next-change)))
    (nreverse result)))

(defun zigmacs-surfaces--serialize-markers ()
  "Return canonical representation of all markers in current buffer.
Format: list of (position insertion-type) sorted by position."
  (let ((markers nil))
    ;; Collect point and mark
    (push (list (point) nil 'point) markers)
    (when (mark t)
      (push (list (mark t) (mark-marker-insertion-type) 'mark) markers))

    ;; Sort by position for determinism
    (sort markers (lambda (a b) (< (car a) (car b))))))

(defun zigmacs-surfaces--serialize-overlays ()
  "Return canonical representation of overlays in current buffer.
Format: list of (start end properties) sorted by start, then end."
  (let ((overlays (overlays-in (point-min) (point-max)))
        (result nil))
    (dolist (ov overlays)
      (push (list (overlay-start ov)
                  (overlay-end ov)
                  (overlay-properties ov))
            result))
    ;; Sort for determinism
    (sort result (lambda (a b)
                   (or (< (car a) (car b))
                       (and (= (car a) (car b))
                            (< (cadr a) (cadr b))))))))

(defun zigmacs-surfaces--serialize-buffer-locals (vars)
  "Return values of buffer-local VARS as alist.
VARS is a list of symbols to check."
  (mapcar (lambda (var)
            (cons var (if (boundp var)
                          (buffer-local-value var (current-buffer))
                        :unbound)))
          vars))

(defun zigmacs-surfaces--serialize-buffer-state (&optional buffer-local-vars)
  "Serialize complete editing state of current buffer.
BUFFER-LOCAL-VARS is optional list of buffer-local variables to capture.
Returns alist with all state components."
  (list
   (cons 'buffer-name (buffer-name))
   (cons 'buffer-text (buffer-substring-no-properties (point-min) (point-max)))
   (cons 'text-properties (zigmacs-surfaces--serialize-text-properties
                           (point-min) (point-max)))
   (cons 'markers (zigmacs-surfaces--serialize-markers))
   (cons 'overlays (zigmacs-surfaces--serialize-overlays))
   (cons 'narrowing (list (point-min) (point-max)))
   (cons 'point (point))
   (cons 'mark (mark t))
   (cons 'buffer-locals (when buffer-local-vars
                          (zigmacs-surfaces--serialize-buffer-locals
                           buffer-local-vars)))))

;;; Surface (e): Declared global side effects

(defun zigmacs-surfaces--serialize-match-data ()
  "Serialize match-data for comparison."
  (match-data))

(defun zigmacs-surfaces--serialize-global-effects (effects)
  "Serialize declared global side effects.
EFFECTS is a plist of effect types to capture, e.g.:
  (:match-data t :kill-ring t :vars (list var1 var2))

Returns alist of captured effects."
  (let ((result nil))
    (when (plist-get effects :match-data)
      (push (cons 'match-data (zigmacs-surfaces--serialize-match-data)) result))
    (when (plist-get effects :kill-ring)
      (push (cons 'kill-ring (copy-sequence kill-ring)) result))
    (let ((vars (plist-get effects :vars)))
      (when vars
        (push (cons 'global-vars
                    (mapcar (lambda (v) (cons v (symbol-value v))) vars))
              result)))
    (nreverse result)))

;;; Complete surface capture

(defun zigmacs-surfaces-capture (form &optional buffer-locals global-effects)
  "Execute FORM and capture all observable surfaces.
BUFFER-LOCALS: list of buffer-local vars to capture (for surface d).
GLOBAL-EFFECTS: plist of global effects to capture (for surface e).

Returns alist:
  - return: the return value (or nonlocal exit)
  - stdout: captured standard-output
  - stderr: captured standard-error (if distinguishable)
  - buffer-state: editing state (if in a buffer context)
  - global-effects: declared global side effects"
  (let ((stdout-output "")
        (stderr-output "")
        (return-value nil)
        (buffer-state nil)
        (global-state nil))

    ;; Capture stdout
    (setq return-value
          (with-output-to-string
            (let ((standard-output (current-buffer)))
              (setq stdout-output (buffer-string))
              (zigmacs-surfaces--capture-nonlocal-exit form))))

    ;; Capture buffer state if we're in a buffer
    (when (buffer-name)
      (setq buffer-state (zigmacs-surfaces--serialize-buffer-state buffer-locals)))

    ;; Capture global effects
    (when global-effects
      (setq global-state (zigmacs-surfaces--serialize-global-effects global-effects)))

    (list (cons 'return return-value)
          (cons 'stdout stdout-output)
          (cons 'buffer-state buffer-state)
          (cons 'global-effects global-state))))

(provide 'surfaces)
;;; surfaces.el ends here

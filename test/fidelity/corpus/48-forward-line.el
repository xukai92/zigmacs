;;; 48-forward-line.el --- Fidelity corpus for forward-line  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Fidelity corpus for forward-line (Category C: stateful point mover).
;; Exercises: basic movement, negative args, narrowing, return values,
;; shortage calculation, the special end-of-buffer exception.

;;; Code:

;; Basic forward line movement
(with-temp-buffer
  (insert "line1\nline2\nline3\n")
  (goto-char (point-min))
  (princ (list :start (point)))
  (princ (list :result-1 (forward-line 1) :pos (point)))
  (princ (list :result-2 (forward-line 1) :pos (point)))
  (princ (list :result-3 (forward-line 1) :pos (point))))

;; Nil argument (defaults to 1)
(with-temp-buffer
  (insert "line1\nline2\n")
  (goto-char (point-min))
  (princ (list :nil-arg (forward-line) :pos (point))))

;; Negative movement (backward)
(with-temp-buffer
  (insert "line1\nline2\nline3\n")
  (goto-char (point-max))
  (princ (list :at-end (point)))
  (princ (list :back-1 (forward-line -1) :pos (point)))
  (princ (list :back-2 (forward-line -1) :pos (point))))

;; Zero movement (to beginning of current line)
(with-temp-buffer
  (insert "line1\nline2\nline3\n")
  (goto-char 10)  ; somewhere in line2
  (princ (list :before-zero (point)))
  (princ (list :zero-result (forward-line 0) :pos (point))))

;; Shortage (can't move requested amount)
(with-temp-buffer
  (insert "line1\nline2\n")
  (goto-char (point-min))
  (princ (list :shortage (forward-line 10) :pos (point))))

;; Negative shortage
(with-temp-buffer
  (insert "line1\nline2\n")
  (goto-char (point-min))
  (princ (list :neg-shortage (forward-line -5) :pos (point))))

;; End-of-buffer exception: non-empty line at end counts as moved
(with-temp-buffer
  (insert "line1\nline2")  ; no trailing newline
  (goto-char (point-min))
  (princ (list :line1 (forward-line 1) :pos (point)))
  ;; This is the exception case
  (princ (list :line2-no-newline (forward-line 1) :pos (point))))

;; Empty lines
(with-temp-buffer
  (insert "line1\n\n\nline2\n")
  (goto-char (point-min))
  (princ (list :empty-1 (forward-line 1) :pos (point)))
  (princ (list :empty-2 (forward-line 1) :pos (point)))
  (princ (list :empty-3 (forward-line 1) :pos (point))))

;; Narrowed buffer
(with-temp-buffer
  (insert "line1\nline2\nline3\nline4\n")
  (narrow-to-region 7 19)  ; "line2\nline3\n"
  (goto-char (point-min))
  (princ (list :narrow-start (point)))
  (princ (list :narrow-move (forward-line 1) :pos (point)))
  (widen)
  (princ (list :after-widen (point))))

;; Large movements
(with-temp-buffer
  (dotimes (i 50)
    (insert (format "line%d\n" i)))
  (goto-char (point-min))
  (princ (list :large-forward (forward-line 25) :pos (point)))
  (princ (list :large-backward (forward-line -10) :pos (point))))

;; Empty buffer
(with-temp-buffer
  (princ (list :empty (forward-line 1) :pos (point))))

;; Single character, no newline
(with-temp-buffer
  (insert "x")
  (goto-char (point-min))
  (princ (list :single-char (forward-line 1) :pos (point))))

;; Multiple movements from same position
(with-temp-buffer
  (insert "a\nb\nc\nd\n")
  (goto-char (point-min))
  (princ (list :move-1 (forward-line 1) :pos (point)))
  (goto-char (point-min))
  (princ (list :move-2 (forward-line 2) :pos (point)))
  (goto-char (point-min))
  (princ (list :move-3 (forward-line 3) :pos (point))))

;;; 48-forward-line.el ends here

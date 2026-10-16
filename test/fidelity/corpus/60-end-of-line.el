;;; 60-end-of-line.el --- Fidelity corpus for end-of-line  -*- lexical-binding: t; -*-

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

;; Fidelity corpus for end-of-line (Category C: stateful point mover).
;; Exercises: basic movement, various argument values, narrowing, boundaries,
;; empty lines, no trailing newline, intangibility loop behavior.

;;; Code:

;; Basic end-of-line movement
(with-temp-buffer
  (insert "line1\nline2\nline3\n")
  (goto-char 3)  ; in line1
  (princ (list :before (point)))
  (end-of-line)
  (princ (list :after (point))))

;; Nil argument (defaults to 1)
(with-temp-buffer
  (insert "line1\nline2\n")
  (goto-char 3)
  (princ (list :nil-arg-before (point)))
  (end-of-line)
  (princ (list :nil-arg-after (point))))

;; Explicit argument 1
(with-temp-buffer
  (insert "line1\nline2\n")
  (goto-char 3)
  (end-of-line 1)
  (princ (list :arg-1 (point))))

;; Argument 2 (move forward one line then to end)
(with-temp-buffer
  (insert "line1\nline2\nline3\n")
  (goto-char 3)  ; in line1
  (princ (list :arg-2-before (point)))
  (end-of-line 2)
  (princ (list :arg-2-after (point))))

;; Argument 0 (move backward one line then to end)
(with-temp-buffer
  (insert "line1\nline2\nline3\n")
  (goto-char 10)  ; in line2
  (princ (list :arg-0-before (point)))
  (end-of-line 0)
  (princ (list :arg-0-after (point))))

;; Negative argument
(with-temp-buffer
  (insert "line1\nline2\nline3\n")
  (goto-char 10)  ; in line2
  (princ (list :neg-before (point)))
  (end-of-line -1)
  (princ (list :neg-after (point))))

;; Already at end of line
(with-temp-buffer
  (insert "line1\nline2\n")
  (goto-char 6)  ; already at eol
  (princ (list :at-eol-before (point)))
  (end-of-line)
  (princ (list :at-eol-after (point))))

;; Empty buffer
(with-temp-buffer
  (princ (list :empty-before (point)))
  (end-of-line)
  (princ (list :empty-after (point))))

;; Empty lines
(with-temp-buffer
  (insert "line1\n\n\nline2\n")
  (goto-char 7)  ; first empty line (at newline)
  (princ (list :empty-line-1 (point)))
  (end-of-line)
  (princ (list :empty-line-1-after (point)))
  (goto-char 8)  ; second empty line
  (end-of-line)
  (princ (list :empty-line-2-after (point))))

;; No trailing newline
(with-temp-buffer
  (insert "line1\nline2")  ; no trailing newline
  (goto-char 1)
  (princ (list :no-newline-1 (point)))
  (end-of-line)
  (princ (list :no-newline-1-after (point)))
  (end-of-line 2)
  (princ (list :no-newline-2-after (point))))

;; Narrowed buffer
(with-temp-buffer
  (insert "line1\nline2\nline3\nline4\n")
  (narrow-to-region 7 19)  ; "line2\nline3\n"
  (goto-char 10)
  (princ (list :narrow-before (point)))
  (end-of-line)
  (princ (list :narrow-after (point)))
  (widen)
  (princ (list :after-widen (point))))

;; Multiple movements
(with-temp-buffer
  (insert "line1\nline2\nline3\nline4\n")
  (goto-char 3)
  (end-of-line)
  (princ (list :move-1 (point)))
  (goto-char 10)
  (end-of-line)
  (princ (list :move-2 (point)))
  (goto-char 15)
  (end-of-line)
  (princ (list :move-3 (point))))

;; Large argument values
(with-temp-buffer
  (dotimes (i 100)
    (insert (format "line%d\n" i)))
  (goto-char 50)
  (end-of-line 50)
  (princ (list :large-arg (point))))

;; At point-max
(with-temp-buffer
  (insert "line1\nline2\n")
  (goto-char (point-max))
  (princ (list :max-before (point)))
  (end-of-line)
  (princ (list :max-after (point))))

;; At point-min
(with-temp-buffer
  (insert "line1\nline2\n")
  (goto-char (point-min))
  (princ (list :min-before (point)))
  (end-of-line)
  (princ (list :min-after (point))))

;; Single line buffer with no newline
(with-temp-buffer
  (insert "single")
  (goto-char 1)
  (princ (list :single-before (point)))
  (end-of-line)
  (princ (list :single-after (point))))

;; Movement beyond buffer boundaries (clamped)
(with-temp-buffer
  (insert "line1\nline2\n")
  (goto-char 10)
  (princ (list :beyond-before (point)))
  (end-of-line -10)
  (princ (list :beyond-after (point))))

;; Consecutive end-of-line calls
(with-temp-buffer
  (insert "a\nb\nc\nd\n")
  (goto-char (point-min))
  (end-of-line)
  (princ (list :consec-1 (point)))
  (goto-char (point-min))
  (end-of-line 2)
  (princ (list :consec-2 (point)))
  (goto-char (point-min))
  (end-of-line 3)
  (princ (list :consec-3 (point))))

;; Line with only newline
(with-temp-buffer
  (insert "\n")
  (goto-char (point-min))
  (princ (list :only-newline-before (point)))
  (end-of-line)
  (princ (list :only-newline-after (point))))

;;; 60-end-of-line.el ends here

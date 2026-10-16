;;; 46-forward-char.el --- Fidelity corpus for forward-char  -*- lexical-binding: t; -*-

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

;; Fidelity corpus for forward-char (Category C: stateful point mover).
;; Exercises: basic movement, negative args, narrowing, return values, edge cases.

;;; Code:

;; Basic forward movement
(with-temp-buffer
  (insert "hello world")
  (goto-char (point-min))
  (princ (list :before (point)))
  (forward-char 1)
  (princ (list :after-1 (point)))
  (forward-char 5)
  (princ (list :after-6 (point)))
  (forward-char)  ; nil defaults to 1
  (princ (list :after-7 (point))))

;; Negative movement (backward)
(with-temp-buffer
  (insert "abcdefg")
  (goto-char (point-max))
  (princ (list :at-end (point)))
  (forward-char -3)
  (princ (list :back-3 (point)))
  (forward-char -1)
  (princ (list :back-1 (point))))

;; Multi-line buffer
(with-temp-buffer
  (insert "line1\nline2\nline3\n")
  (goto-char (point-min))
  (forward-char 5)
  (princ (list :pos-5 (point)))
  (forward-char 1)  ; cross newline
  (princ (list :pos-6 (point)))
  (forward-char 10)
  (princ (list :pos-16 (point))))

;; Narrowed buffer
(with-temp-buffer
  (insert "0123456789")
  (narrow-to-region 3 8)  ; "34567"
  (goto-char (point-min))
  (princ (list :narrow-min (point)))
  (forward-char 2)
  (princ (list :narrow-moved (point)))
  (widen)
  (princ (list :after-widen (point))))

;; Zero movement
(with-temp-buffer
  (insert "test")
  (goto-char 3)
  (forward-char 0)
  (princ (list :zero-move (point))))

;; Edge cases (wrapped to avoid signaling)
(with-temp-buffer
  (insert "edge")
  (goto-char (point-min))
  (princ (list :at-beginning (point)))
  (ignore-errors (forward-char -1))  ; would signal
  (princ (list :still-at-beginning (point)))
  (goto-char (point-max))
  (princ (list :at-end (point)))
  (ignore-errors (forward-char 1))  ; would signal
  (princ (list :still-at-end (point))))

;; Return value (always nil)
(with-temp-buffer
  (insert "return")
  (goto-char (point-min))
  (princ (list :return-value (forward-char 3))))

;; Large movements
(with-temp-buffer
  (insert (make-string 100 ?x))
  (goto-char (point-min))
  (forward-char 50)
  (princ (list :large-forward (point)))
  (forward-char -25)
  (princ (list :large-backward (point))))

;; Empty buffer
(with-temp-buffer
  (princ (list :empty-pos (point)))
  (ignore-errors (forward-char 1))
  (princ (list :empty-after (point))))

;;; 46-forward-char.el ends here

;;; 47-backward-char.el --- Fidelity corpus for backward-char  -*- lexical-binding: t; -*-

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

;; Fidelity corpus for backward-char (Category C: stateful point mover).
;; Exercises: basic movement, negative args, narrowing, return values, edge cases.

;;; Code:

;; Basic backward movement
(with-temp-buffer
  (insert "hello world")
  (goto-char (point-max))
  (princ (list :before (point)))
  (backward-char 1)
  (princ (list :after-1 (point)))
  (backward-char 5)
  (princ (list :after-5 (point)))
  (backward-char)  ; nil defaults to 1
  (princ (list :after-6 (point))))

;; Negative movement (forward)
(with-temp-buffer
  (insert "abcdefg")
  (goto-char (point-min))
  (princ (list :at-start (point)))
  (backward-char -3)
  (princ (list :forward-3 (point)))
  (backward-char -1)
  (princ (list :forward-1 (point))))

;; Multi-line buffer
(with-temp-buffer
  (insert "line1\nline2\nline3\n")
  (goto-char (point-max))
  (backward-char 5)
  (princ (list :pos-back-5 (point)))
  (backward-char 1)  ; cross newline
  (princ (list :pos-back-6 (point)))
  (backward-char 10)
  (princ (list :pos-back-16 (point))))

;; Narrowed buffer
(with-temp-buffer
  (insert "0123456789")
  (narrow-to-region 3 8)  ; "34567"
  (goto-char (point-max))
  (princ (list :narrow-max (point)))
  (backward-char 2)
  (princ (list :narrow-moved (point)))
  (widen)
  (princ (list :after-widen (point))))

;; Zero movement
(with-temp-buffer
  (insert "test")
  (goto-char 3)
  (backward-char 0)
  (princ (list :zero-move (point))))

;; Edge cases (wrapped to avoid signaling)
(with-temp-buffer
  (insert "edge")
  (goto-char (point-max))
  (princ (list :at-end (point)))
  (ignore-errors (backward-char -1))  ; would signal
  (princ (list :still-at-end (point)))
  (goto-char (point-min))
  (princ (list :at-beginning (point)))
  (ignore-errors (backward-char 1))  ; would signal
  (princ (list :still-at-beginning (point))))

;; Return value (always nil)
(with-temp-buffer
  (insert "return")
  (goto-char (point-max))
  (princ (list :return-value (backward-char 3))))

;; Large movements
(with-temp-buffer
  (insert (make-string 100 ?x))
  (goto-char (point-max))
  (backward-char 50)
  (princ (list :large-backward (point)))
  (backward-char -25)
  (princ (list :large-forward (point))))

;; Empty buffer
(with-temp-buffer
  (princ (list :empty-pos (point)))
  (ignore-errors (backward-char 1))
  (princ (list :empty-after (point))))

;;; 47-backward-char.el ends here

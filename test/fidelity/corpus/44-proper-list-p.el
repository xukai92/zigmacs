;;; 44-proper-list-p.el --- Fidelity corpus for proper-list-p  -*- lexical-binding: t; -*-

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

;; Fidelity corpus for `proper-list-p' — comprehensive smoke test covering
;; proper lists, dotted lists, circular lists, and non-list objects.
;; This runs under Channel A (A/B mode) to verify bit-for-bit compatibility
;; with upstream.

;;; Code:

;; Proper lists (return length)
(proper-list-p nil)                   ; => 0
(proper-list-p '(a))                  ; => 1
(proper-list-p '(a b))                ; => 2
(proper-list-p '(a b c))              ; => 3
(proper-list-p '(1 2 3 4 5))          ; => 5
(proper-list-p (list 'a 'b 'c))       ; => 3

;; Nested lists (still proper)
(proper-list-p '((a b) (c d)))        ; => 2
(proper-list-p '(1 (2 3) 4))          ; => 3

;; Dotted (improper) lists (return nil)
(proper-list-p '(a . b))              ; => nil
(proper-list-p '(a b . c))            ; => nil
(proper-list-p (cons 1 2))            ; => nil
(proper-list-p (cons 'x (cons 'y 'z))) ; => nil

;; Non-list objects (return nil)
(proper-list-p 5)                     ; => nil
(proper-list-p "abc")                 ; => nil
(proper-list-p [a b c])               ; => nil
(proper-list-p 'symbol)               ; => nil
(proper-list-p t)                     ; => nil
(proper-list-p ?a)                    ; => nil

;; Circular lists (return nil)
(let ((circular (list 'a 'b 'c)))
  (setcdr (last circular) circular)
  (proper-list-p circular))           ; => nil

(let ((circular (list 1)))
  (setcdr circular circular)
  (proper-list-p circular))           ; => nil

;; Long lists
(proper-list-p (number-sequence 1 100))   ; => 100
(proper-list-p (number-sequence 1 1000))  ; => 1000

;; Edge cases
(proper-list-p (list))                ; => 0 (empty list = nil)
(proper-list-p (cons 'a nil))         ; => 1 (proper list of one element)

(princ "proper-list-p corpus complete\n")

;;; 44-proper-list-p.el ends here

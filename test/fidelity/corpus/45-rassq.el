;;; 45-rassq.el --- Fidelity corpus for rassq  -*- lexical-binding: t; -*-

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

;; Fidelity corpus for `rassq' — comprehensive smoke test covering
;; basic lookups, eq semantics, non-cons elements, and error cases.
;; This runs under Channel A (A/B mode) to verify bit-for-bit compatibility
;; with upstream.

;;; Code:

;; Basic lookups
(rassq 1 '((a . 1) (b . 2) (c . 3)))           ; => (a . 1)
(rassq 2 '((a . 1) (b . 2) (c . 3)))           ; => (b . 2)
(rassq 3 '((a . 1) (b . 2) (c . 3)))           ; => (c . 3)
(rassq 4 '((a . 1) (b . 2) (c . 3)))           ; => nil

;; Empty alist
(rassq 'x nil)                                  ; => nil
(rassq 1 nil)                                   ; => nil
(rassq nil nil)                                 ; => nil

;; Symbol values
(rassq 'foo '((x . foo) (y . bar) (z . baz)))   ; => (x . foo)
(rassq 'bar '((x . foo) (y . bar) (z . baz)))   ; => (y . bar)
(rassq 'qux '((x . foo) (y . bar) (z . baz)))   ; => nil

;; First match when multiple exist
(rassq 'x '((a . x) (b . x) (c . y)))           ; => (a . x)

;; Non-cons elements (ignored)
(rassq 2 '((a . 1) not-a-cons (b . 2) another (c . 3)))  ; => (b . 2)
(rassq 'not-a-cons '((a . 1) not-a-cons (b . 2)))        ; => nil

;; eq semantics (not equal)
(let ((val '(1 2)))
  (rassq val (list (cons 'a val))))             ; => (a 1 2) (same object)
(rassq '(1 2) '((a . (1 2))))                   ; => nil (different objects)

;; nil as value
(rassq nil '((a . nil) (b . 2)))                ; => (a . nil)
(rassq nil '((a . 1) (b . 2)))                  ; => nil

;; Error cases (wrapped in ignore-errors)
(ignore-errors (rassq 1 '((a . 1) (b . 2) . not-nil)))  ; improper list

(let ((circular (list '(a . 1) '(b . 2))))
  (setcdr (last circular) circular)
  (ignore-errors (rassq 3 circular)))           ; circular list

;; Edge cases
(rassq 'a (list (cons 'x 'a)))                  ; => (x . a)
(rassq 1 (list (cons 'first 1)))                ; => (first . 1)

;; Long alist
(let ((long-alist (mapcar (lambda (n) (cons n (* n 10)))
                          (number-sequence 1 100))))
  (rassq 500 long-alist))                       ; => (50 . 500)

(princ "rassq corpus complete\n")

;;; 45-rassq.el ends here

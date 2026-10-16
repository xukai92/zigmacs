;;; 57-assoc.el --- Fidelity corpus for assoc  -*- lexical-binding: t; -*-

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

;; Fidelity corpus for `assoc' — comprehensive smoke test covering
;; symbols, fixnums (eq-comparable fast path), strings, lists (equal
;; comparison), custom test functions, and error cases. This runs under
;; Channel A (A/B mode) to verify bit-for-bit compatibility with upstream.

;;; Code:

;; Symbols (eq-comparable fast path via assq, no testfn)
(assoc 'a '((a . 1) (b . 2) (c . 3)))      ; => (a . 1)
(assoc 'b '((a . 1) (b . 2) (c . 3)))      ; => (b . 2)
(assoc 'c '((a . 1) (b . 2) (c . 3)))      ; => (c . 3)
(assoc 'x '((a . 1) (b . 2) (c . 3)))      ; => nil
(assoc 'foo '((bar . 1) (baz . 2)))        ; => nil

;; Fixnums (eq-comparable fast path via assq, no testfn)
(assoc 1 '((1 . a) (2 . b) (3 . c)))       ; => (1 . a)
(assoc 2 '((1 . a) (2 . b) (3 . c)))       ; => (2 . b)
(assoc 3 '((1 . a) (2 . b) (3 . c)))       ; => (3 . c)
(assoc 9 '((1 . a) (2 . b) (3 . c)))       ; => nil

;; Strings (equal comparison, no testfn)
(assoc "a" '(("a" . 1) ("b" . 2)))         ; => ("a" . 1)
(assoc "b" '(("a" . 1) ("b" . 2)))         ; => ("b" . 2)
(assoc "x" '(("a" . 1) ("b" . 2)))         ; => nil
(assoc "key" '(("foo" . x) ("key" . y)))   ; => ("key" . y)

;; Lists as keys (equal comparison, no testfn)
(assoc '(1 2) '(((1 2) . a) ((3 4) . b)))  ; => ((1 2) . a)
(assoc '(3 4) '(((1 2) . a) ((3 4) . b)))  ; => ((3 4) . b)
(assoc '(5 6) '(((1 2) . a) ((3 4) . b)))  ; => nil

;; Empty alist
(assoc 'a nil)                ; => nil
(assoc "x" '())               ; => nil
(assoc 1 nil)                 ; => nil

;; Special values
(assoc nil '((a . 1) (nil . 2) (b . 3)))   ; => (nil . 2)
(assoc nil '((a . 1) (b . 2)))             ; => nil
(assoc t '((nil . 1) (t . 2)))             ; => (t . 2)

;; Keywords
(assoc :foo '((:bar . 1) (:foo . 2)))      ; => (:foo . 2)
(assoc :x '((:a . 1) (:b . 2)))            ; => nil

;; Non-cons elements (ignored)
(assoc 'a '((a . 1) not-a-cons (b . 2)))   ; => (a . 1)
(assoc 'b '((a . 1) not-a-cons (b . 2)))   ; => (b . 2)
(assoc 'x '((a . 1) not-a-cons (b . 2)))   ; => nil
(assoc 'a '(not-a-cons also-not 123))      ; => nil

;; Multiple entries with same key (returns first match)
(assoc 'a '((a . 1) (a . 2) (a . 3)))      ; => (a . 1)
(assoc "a" '(("a" . 1) ("a" . 2)))         ; => ("a" . 1)

;; Custom test function
(assoc "A" '(("a" . 1) ("b" . 2)) #'string-equal)  ; => ("a" . 1)
(assoc "B" '(("a" . 1) ("b" . 2)) #'string-equal)  ; => ("b" . 2)
(assoc "X" '(("a" . 1) ("b" . 2)) #'string-equal)  ; => nil

;; Test function: eq (like assq)
(assoc 'a '((a . 1) (b . 2)) #'eq)         ; => (a . 1)

;; Test function: equal (default behavior)
(assoc "a" '(("a" . 1) ("b" . 2)) #'equal) ; => ("a" . 1)

;; Nested structures as values
(assoc 'key '((key . (nested value)) (other . x)))  ; => (key . (nested value))

;; Error cases (wrapped in ignore-errors)
;; Improper lists
(ignore-errors (assoc 'x '((a . 1) (b . 2) . c)))  ; wrong-type-argument
(ignore-errors (assoc "x" '(("a" . 1) . b)))       ; wrong-type-argument

;; Circular lists (key not found)
(let ((circular (list '(a . 1) '(b . 2) '(c . 3))))
  (setcdr (last circular) circular)
  (ignore-errors (assoc 'x circular)))              ; circular-list

;; Edge cases that succeed
(assoc 'a '((a . 1) . b))    ; => (a . 1) (found before improper tail)

(let ((circular (list '(a . 1) '(b . 2) '(c . 3))))
  (setcdr (last circular) circular)
  (assoc 'a circular))       ; => (a . 1) (found, no error)

(princ "assoc corpus complete\n")

;;; 57-assoc.el ends here

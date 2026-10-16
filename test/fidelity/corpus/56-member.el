;;; 56-member.el --- Fidelity corpus for member  -*- lexical-binding: t; -*-

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

;; Fidelity corpus for `member' — comprehensive smoke test covering
;; symbols, fixnums (eq-comparable fast path), strings, lists (equal
;; comparison), and error cases. This runs under Channel A (A/B mode)
;; to verify bit-for-bit compatibility with upstream.

;;; Code:

;; Symbols (eq-comparable fast path via memq)
(member 'a '(a b c))          ; => (a b c)
(member 'b '(a b c))          ; => (b c)
(member 'c '(a b c))          ; => (c)
(member 'x '(a b c))          ; => nil
(member 'foo '(bar baz))      ; => nil

;; Fixnums (eq-comparable fast path via memq)
(member 1 '(1 2 3))           ; => (1 2 3)
(member 2 '(1 2 3))           ; => (2 3)
(member 3 '(1 2 3))           ; => (3)
(member 9 '(1 2 3))           ; => nil
(member 0 '(1 2 3))           ; => nil

;; Strings (equal comparison, not eq)
(member "a" '("a" "b" "c"))   ; => ("a" "b" "c")
(member "b" '("a" "b" "c"))   ; => ("b" "c")
(member "x" '("a" "b" "c"))   ; => nil
(member "hello" '("world" "hello" "there"))  ; => ("hello" "there")

;; Lists (equal comparison)
(member '(1 2) '((1 2) (3 4)))        ; => ((1 2) (3 4))
(member '(3 4) '((1 2) (3 4)))        ; => ((3 4))
(member '(5 6) '((1 2) (3 4)))        ; => nil
(member '(a b) '((x y) (a b) (c d)))  ; => ((a b) (c d))

;; Empty list
(member 'a nil)               ; => nil
(member 1 '())                ; => nil
(member "x" nil)              ; => nil

;; Special values
(member nil '(a nil b))       ; => (nil b)
(member nil '(a b c))         ; => nil
(member t '(nil t 1))         ; => (t 1)
(member t '(nil 1 2))         ; => nil

;; Keywords
(member :foo '(:bar :foo :baz))  ; => (:foo :baz)
(member :x '(:a :b :c))          ; => nil

;; Multiple occurrences (returns first match)
(member 'a '(x a b a c))      ; => (a b a c)
(member "a" '("x" "a" "b" "a"))  ; => ("a" "b" "a")
(member 2 '(1 2 3 2))         ; => (2 3 2)

;; Nested structures
(member '(a (b c)) '((x y) (a (b c)) (d e)))  ; => ((a (b c)) (d e))

;; Error cases (wrapped in ignore-errors)
;; Improper lists
(ignore-errors (member 'x '(a b . c)))     ; wrong-type-argument
(ignore-errors (member "x" '("a" . b)))    ; wrong-type-argument
(ignore-errors (member 1 '(2 3 . 4)))      ; wrong-type-argument

;; Circular lists (element not found)
(let ((circular (list 'a 'b 'c)))
  (setcdr (last circular) circular)
  (ignore-errors (member 'x circular)))     ; circular-list

;; Edge cases that succeed
(member 'a '(a . b))          ; => (a . b) (found before improper tail)
(member "a" '("a" . b))       ; => ("a" . b)

(let ((circular (list 'a 'b 'c)))
  (setcdr (last circular) circular)
  (member 'a circular))       ; => circular (found, no error)

(princ "member corpus complete\n")

;;; 56-member.el ends here

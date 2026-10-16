;;; 43-elt.el --- Fidelity corpus for elt  -*- lexical-binding: t; -*-

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

;; Fidelity corpus for `elt' — comprehensive smoke test covering
;; lists, vectors, strings, and error cases. This runs under Channel A
;; (A/B mode) to verify bit-for-bit compatibility with upstream.

;;; Code:

;; Lists
(elt '(a b c) 0)          ; => a
(elt '(a b c) 1)          ; => b
(elt '(a b c) 2)          ; => c
(elt '(10 20 30) 1)       ; => 20
(elt nil 0)               ; => nil
(elt '(x) 0)              ; => x
(elt '(a b) 5)            ; => nil (out of range)

;; Vectors
(elt [a b c] 0)           ; => a
(elt [a b c] 1)           ; => b
(elt [a b c] 2)           ; => c
(elt [10 20 30] 1)        ; => 20
(ignore-errors (elt [] 0))  ; error (out of range)

;; Strings
(elt "abc" 0)             ; => ?a
(elt "abc" 1)             ; => ?b
(elt "abc" 2)             ; => ?c
(elt "xyz" 0)             ; => ?x
(ignore-errors (elt "" 0))  ; error (out of range)

;; Nested structures
(elt '((a b) (c d) (e f)) 1)  ; => (c d)
(elt [(a b) (c d)] 0)         ; => (a b)

;; Error cases (wrapped in ignore-errors)
(ignore-errors (elt 5 0))           ; wrong-type-argument (not a sequence)
(ignore-errors (elt 'symbol 0))     ; wrong-type-argument
(ignore-errors (elt t 0))           ; wrong-type-argument
(ignore-errors (elt [a b c] 10))    ; args-out-of-range
(ignore-errors (elt [a b c] -1))    ; wrong-type-argument (negative fixnum)
(ignore-errors (elt '(a b c) 'x))   ; wrong-type-argument (non-integer index)

;; Edge cases
(elt (list 'a 'b 'c) 0)              ; => a
(elt (vector 'a 'b 'c) 1)            ; => b
(elt (make-string 3 ?x) 0)           ; => ?x

(princ "elt corpus complete\n")

;;; 43-elt.el ends here

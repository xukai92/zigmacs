;;; 58-hash-table-p.el --- Fidelity corpus for hash-table-p  -*- lexical-binding: t; -*-

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

;; Fidelity corpus for `hash-table-p' — comprehensive smoke test
;; covering hash tables and non-hash-table objects. This runs under
;; Channel A (A/B mode) to verify bit-for-bit compatibility with upstream.

;;; Code:

;; Hash tables (should return t)
(hash-table-p (make-hash-table))                    ; => t
(hash-table-p (make-hash-table :test 'eq))          ; => t
(hash-table-p (make-hash-table :test 'eql))         ; => t
(hash-table-p (make-hash-table :test 'equal))       ; => t
(hash-table-p (make-hash-table :size 100))          ; => t
(hash-table-p (make-hash-table :size 1000))         ; => t

;; Hash table with entries
(let ((ht (make-hash-table)))
  (puthash 'key 'value ht)
  (hash-table-p ht))                                ; => t

;; Hash table with multiple entries
(let ((ht (make-hash-table)))
  (puthash 'a 1 ht)
  (puthash 'b 2 ht)
  (puthash 'c 3 ht)
  (hash-table-p ht))                                ; => t

;; Hash table after clearing
(let ((ht (make-hash-table)))
  (puthash 'key 'value ht)
  (clrhash ht)
  (hash-table-p ht))                                ; => t

;; Hash table with various key types (equal test)
(let ((ht (make-hash-table :test 'equal)))
  (puthash "string" 1 ht)
  (puthash 42 2 ht)
  (puthash 'symbol 3 ht)
  (puthash '(list) 4 ht)
  (hash-table-p ht))                                ; => t

;; Non-hash-tables (should return nil)

;; nil
(hash-table-p nil)                                  ; => nil

;; Symbols
(hash-table-p 'foo)                                 ; => nil
(hash-table-p t)                                    ; => nil

;; Numbers
(hash-table-p 0)                                    ; => nil
(hash-table-p 42)                                   ; => nil
(hash-table-p -1)                                   ; => nil
(hash-table-p 3.14)                                 ; => nil

;; Strings
(hash-table-p "")                                   ; => nil
(hash-table-p "hello")                              ; => nil

;; Lists
(hash-table-p '())                                  ; => nil
(hash-table-p '(a b c))                             ; => nil
(hash-table-p '((a . 1) (b . 2)))                   ; => nil

;; Vectors
(hash-table-p [])                                   ; => nil
(hash-table-p [1 2 3])                              ; => nil

;; Cons
(hash-table-p '(a . b))                             ; => nil

;; Functions
(hash-table-p #'car)                                ; => nil
(hash-table-p (lambda () nil))                      ; => nil

;; Buffers
(hash-table-p (current-buffer))                     ; => nil

;; Windows
(hash-table-p (selected-window))                    ; => nil

;; Edge cases
(let ((ht (make-hash-table)))
  (hash-table-p ht))                                ; => t (empty hash table)

(let ((ht (make-hash-table)))
  (puthash 'key nil ht)
  (hash-table-p ht))                                ; => t (nil value)

(princ "hash-table-p corpus complete\n")

;;; 58-hash-table-p.el ends here

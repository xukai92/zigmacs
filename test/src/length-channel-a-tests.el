;;; length-channel-a-tests.el --- Channel A verification for length port  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Free Software Foundation, Inc.

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

;; Channel A verification tests for the length Zig port (Cat-B #1).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_length) and the original C implementation
;; (length_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/length-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest length-channel-a-lists ()
  "Test length on lists (proper, improper, circular)."
  ;; Proper lists
  (should (= (length nil) 0))
  (should (= (length '(1)) 1))
  (should (= (length '(1 2 3)) 3))
  (should (= (length '(a b c d e)) 5))
  (should (= (length '(1 2 3 4 5 6 7 8 9 10)) 10))

  ;; Long list
  (should (= (length (make-list 100 'x)) 100))
  (should (= (length (make-list 1000 'x)) 1000))

  ;; Improper lists (signal error)
  (should-error (length '(1 . 2)) :type 'wrong-type-argument)
  (should-error (length '(1 2 . 3)) :type 'wrong-type-argument)
  (should-error (length '(a b c . d)) :type 'wrong-type-argument)

  ;; Circular lists (signal error)
  (let ((circular (list 1 2 3)))
    (setcdr (last circular) circular)
    (should-error (length circular) :type 'circular-list))

  (let ((circular (list 'a)))
    (setcdr circular circular)
    (should-error (length circular) :type 'circular-list)))

(ert-deftest length-channel-a-strings ()
  "Test length on strings (ASCII, multibyte, empty)."
  ;; Empty string
  (should (= (length "") 0))

  ;; ASCII strings
  (should (= (length "a") 1))
  (should (= (length "hello") 5))
  (should (= (length "The quick brown fox") 19))

  ;; Multibyte strings (count characters, not bytes)
  (should (= (length "é") 1))       ; 1 char, 2 bytes in UTF-8
  (should (= (length "café") 4))    ; 4 chars, 5 bytes
  (should (= (length "日本語") 3))   ; 3 chars, 9 bytes
  (should (= (length "🚀") 1))       ; 1 char, 4 bytes (emoji)
  (should (= (length "hello 世界") 8))) ; 8 chars

(ert-deftest length-channel-a-vectors ()
  "Test length on vectors."
  ;; Empty vector
  (should (= (length []) 0))

  ;; Vectors of various sizes
  (should (= (length [1]) 1))
  (should (= (length [1 2 3]) 3))
  (should (= (length [a b c d e]) 5))
  (should (= (length (make-vector 100 nil)) 100))

  ;; Vector with mixed types
  (should (= (length [1 "two" 3.0 'four]) 4)))

(ert-deftest length-channel-a-other-sequences ()
  "Test length on other sequence types."
  ;; Bool-vectors
  (should (= (length (make-bool-vector 0 nil)) 0))
  (should (= (length (make-bool-vector 10 nil)) 10))
  (should (= (length (make-bool-vector 100 t)) 100))

  ;; Char-tables (always return MAX_CHAR)
  (let ((char-table (make-char-table 'foo)))
    (should (= (length char-table) 4194303)))) ; MAX_CHAR = 0x3FFFFF

(ert-deftest length-channel-a-wrong-types ()
  "Test length on non-sequence types (should signal error)."
  ;; Numbers
  (should-error (length 42) :type 'wrong-type-argument)
  (should-error (length 3.14) :type 'wrong-type-argument)

  ;; Symbols (except nil, which is the empty list)
  (should-error (length 'foo) :type 'wrong-type-argument)
  (should-error (length t) :type 'wrong-type-argument)

  ;; Other types
  (should-error (length (current-buffer)) :type 'wrong-type-argument)
  (should-error (length (make-hash-table)) :type 'wrong-type-argument))

(ert-deftest length-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all sequence types and edge cases."
  (let ((battery
         ;; Format: (input . expected-result-or-error-symbol)
         `(;; Lists
           (nil . 0)
           ((1) . 1)
           ((1 2 3) . 3)
           ((a b c d e f g h i j) . 10)

           ;; Strings
           ("" . 0)
           ("a" . 1)
           ("hello" . 5)
           ("café" . 4)
           ("🚀" . 1)

           ;; Vectors
           ([] . 0)
           ([1] . 1)
           ([1 2 3] . 3)
           ([a b c d e] . 5)

           ;; Wrong types (should error)
           (42 . error)
           (3.14 . error)
           (foo . error)
           (t . error))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (if (eq expected 'error)
            (should-error (length input) :type 'wrong-type-argument)
          (should (= (length input) expected)))))))

(ert-deftest length-channel-a-edge-cases ()
  "Additional edge cases for length."
  ;; Nested lists (count top-level elements only)
  (should (= (length '((1 2) (3 4) (5 6))) 3))
  (should (= (length '((a (b (c (d)))))) 1))

  ;; List with nil elements
  (should (= (length '(nil nil nil)) 3))
  (should (= (length '(1 nil 2 nil 3)) 5))

  ;; Very long list
  (should (= (length (make-list 10000 'x)) 10000)))

(provide 'length-channel-a-tests)
;;; length-channel-a-tests.el ends here

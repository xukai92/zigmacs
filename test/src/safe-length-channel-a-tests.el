;;; safe-length-channel-a-tests.el --- Channel A verification for safe-length port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the safe-length Zig port (Cat-B fanout #2).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_safe_length) and the original C implementation
;; (safe_length_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/safe-length-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest safe-length-channel-a-proper-lists ()
  "Test safe-length on proper lists."
  ;; Empty list
  (should (equal (safe-length nil) 0))
  (should (equal (safe-length '()) 0))

  ;; Single-element list
  (should (equal (safe-length '(a)) 1))
  (should (equal (safe-length '(1)) 1))

  ;; Multi-element lists
  (should (equal (safe-length '(a b c)) 3))
  (should (equal (safe-length '(1 2 3 4 5)) 5))

  ;; Nested lists (outer length only)
  (should (equal (safe-length '((1 2) (3 4))) 2))
  (should (equal (safe-length '(a (b c) d)) 3)))

(ert-deftest safe-length-channel-a-improper-lists ()
  "Test safe-length on improper lists (counts cons cells before atom)."
  ;; Dotted pair (1 cons cell)
  (should (equal (safe-length '(a . b)) 1))

  ;; Improper list with multiple elements
  (should (equal (safe-length '(a b . c)) 2))
  (should (equal (safe-length '(a b c . d)) 3)))

(ert-deftest safe-length-channel-a-atoms ()
  "Test safe-length on atoms (returns 0, never errors)."
  ;; Numbers
  (should (equal (safe-length 42) 0))
  (should (equal (safe-length 0) 0))
  (should (equal (safe-length -1) 0))
  (should (equal (safe-length 3.14) 0))

  ;; Symbols (excluding nil, which is a list)
  (should (equal (safe-length 'symbol) 0))
  (should (equal (safe-length t) 0))
  (should (equal (safe-length :keyword) 0))

  ;; Strings
  (should (equal (safe-length "string") 0))
  (should (equal (safe-length "") 0))

  ;; Vectors
  (should (equal (safe-length [1 2 3]) 0))
  (should (equal (safe-length []) 0)))

(ert-deftest safe-length-channel-a-circular-lists ()
  "Test safe-length on circular lists (returns number of distinct elements)."
  ;; Simple circular list: (a b c) → a
  (let ((circular (list 'a 'b 'c)))
    (setcdr (last circular) circular)
    ;; Should return 3 (number of distinct cons cells)
    (should (equal (safe-length circular) 3)))

  ;; Single-element circular: (a) → a
  (let ((circular (list 'a)))
    (setcdr circular circular)
    ;; Should return 1 (one distinct cons cell)
    (should (equal (safe-length circular) 1)))

  ;; Two-element circular: (a b) → a
  (let ((circular (list 'a 'b)))
    (setcdr (last circular) circular)
    ;; Should return 2
    (should (equal (safe-length circular) 2))))

(ert-deftest safe-length-channel-a-vs-length ()
  "Test that safe-length never errors, unlike length."
  ;; length signals error on circular lists
  (let ((circular (list 'a 'b 'c)))
    (setcdr (last circular) circular)
    (should-error (length circular) :type 'circular-list)
    ;; safe-length returns a value
    (should (equal (safe-length circular) 3)))

  ;; length signals error on improper lists
  (should-error (length '(a b . c)) :type 'wrong-type-argument)
  ;; safe-length returns a value
  (should (equal (safe-length '(a b . c)) 2))

  ;; length signals error on atoms
  (should-error (length 42) :type 'wrong-type-argument)
  ;; safe-length returns 0
  (should (equal (safe-length 42) 0))

  ;; Both work on proper lists
  (should (equal (length '(a b c)) (safe-length '(a b c)))))

(ert-deftest safe-length-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various inputs."
  (let ((test-cases
         ;; Format: (list expected-length)
         '(;; Proper lists
           (nil 0)
           (() 0)
           ((a) 1)
           ((a b c) 3)
           ((1 2 3 4 5) 5)

           ;; Atoms (all return 0)
           (42 0)
           (0 0)
           (symbol 0)
           (t 0)
           ("string" 0)
           ([1 2 3] 0)

           ;; Improper lists (count cons cells)
           ((a . b) 1)
           ((a b . c) 2)
           ((a b c . d) 3))))
    (dolist (case test-cases)
      (let ((input (nth 0 case))
            (expected (nth 1 case)))
        (should (equal (safe-length input) expected))))))

(ert-deftest safe-length-channel-a-long-lists ()
  "Test safe-length on long lists."
  ;; Very long proper list
  (let ((long-list (make-list 1000 'x)))
    (should (equal (safe-length long-list) 1000)))

  ;; Long improper list
  (let ((long-list (make-list 500 'x)))
    (setcdr (last long-list) 'atom)
    (should (equal (safe-length long-list) 500))))

(ert-deftest safe-length-channel-a-special-values ()
  "Test safe-length with special values."
  ;; List of nils
  (should (equal (safe-length '(nil nil nil)) 3))

  ;; List of t's
  (should (equal (safe-length '(t t)) 2))

  ;; Mixed special values
  (should (equal (safe-length '(nil t nil)) 3)))

(provide 'safe-length-channel-a-tests)
;;; safe-length-channel-a-tests.el ends here

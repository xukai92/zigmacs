;;; elt-channel-a-tests.el --- ERT tests for elt (Channel A)  -*- lexical-binding: t; -*-

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

;; Channel A (A/B parity) tests for the Zig port of `elt'.
;; These tests verify that the Zig implementation matches upstream Emacs
;; behavior exactly (bug-for-bug compatibility).

;;; Code:

(require 'ert)

(ert-deftest elt-channel-a-basic-list ()
  "Test elt with basic lists."
  (should (eq (elt '(a b c) 0) 'a))
  (should (eq (elt '(a b c) 1) 'b))
  (should (eq (elt '(a b c) 2) 'c))
  (should (eq (elt '(10 20 30) 1) 20)))

(ert-deftest elt-channel-a-nil ()
  "Test elt with nil (empty list)."
  (should (eq (elt nil 0) nil)))

(ert-deftest elt-channel-a-vector ()
  "Test elt with vectors."
  (should (eq (elt [a b c] 0) 'a))
  (should (eq (elt [a b c] 1) 'b))
  (should (eq (elt [a b c] 2) 'c))
  (should (eq (elt [10 20 30] 1) 20)))

(ert-deftest elt-channel-a-string ()
  "Test elt with strings."
  (should (eq (elt "abc" 0) ?a))
  (should (eq (elt "abc" 1) ?b))
  (should (eq (elt "abc" 2) ?c))
  (should (eq (elt "xyz" 0) ?x)))

(ert-deftest elt-channel-a-out-of-range-list ()
  "Test elt with out-of-range index on lists."
  ;; Lists return nil for out-of-range (via nthcdr returning nil)
  (should (eq (elt '(a b) 5) nil)))

(ert-deftest elt-channel-a-out-of-range-vector ()
  "Test elt signals error for out-of-range index on vectors."
  (should-error (elt [a b c] 10) :type 'args-out-of-range)
  (should-error (elt [a b c] -1) :type 'wrong-type-argument))

(ert-deftest elt-channel-a-wrong-type ()
  "Test elt signals error for non-sequences."
  (should-error (elt 5 0) :type 'wrong-type-argument)
  (should-error (elt 'symbol 0) :type 'wrong-type-argument)
  (should-error (elt t 0) :type 'wrong-type-argument))

(ert-deftest elt-channel-a-bad-index ()
  "Test elt signals error for non-integer indices."
  (should-error (elt '(a b c) 'x) :type 'wrong-type-argument)
  (should-error (elt [a b c] "0") :type 'wrong-type-argument)
  (should-error (elt '(a b c) nil) :type 'wrong-type-argument))

(ert-deftest elt-channel-a-nested ()
  "Test elt with nested structures."
  (should (equal (elt '((a b) (c d) (e f)) 1) '(c d)))
  (should (equal (elt [(a b) (c d)] 0) '(a b))))

(provide 'elt-channel-a-tests)
;;; elt-channel-a-tests.el ends here

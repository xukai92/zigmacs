;;; cdr-safe-channel-a-tests.el --- Channel A verification for cdr-safe port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the cdr-safe Zig port (Cat-B fanout #2).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_cdr_safe) and the original C implementation
;; (cdr_safe_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/cdr-safe-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest cdr-safe-channel-a-cons-cells ()
  "Test cdr-safe on cons cells (returns cdr)."
  ;; Simple cons cells
  (should (equal (cdr-safe '(1 . 2)) 2))
  (should (equal (cdr-safe (cons 'a 'b)) 'b))
  (should (equal (cdr-safe (cons nil t)) t))
  (should (equal (cdr-safe (cons t nil)) nil))

  ;; Proper lists (cons cells with list cdrs)
  (should (equal (cdr-safe '(1)) nil))
  (should (equal (cdr-safe '(1 2 3)) '(2 3)))
  (should (equal (cdr-safe '(a b c)) '(b c)))

  ;; Nested structures
  (should (equal (cdr-safe '((1 2) 3)) '(3)))
  (should (equal (cdr-safe '(a . (b . c))) '(b . c))))

(ert-deftest cdr-safe-channel-a-non-cons ()
  "Test cdr-safe on non-cons values (returns nil)."
  ;; Atoms (should return nil, not error)
  (should (null (cdr-safe nil)))
  (should (null (cdr-safe 42)))
  (should (null (cdr-safe 0)))
  (should (null (cdr-safe -1)))
  (should (null (cdr-safe 'symbol)))
  (should (null (cdr-safe t)))
  (should (null (cdr-safe "string")))
  (should (null (cdr-safe "")))
  (should (null (cdr-safe [1 2 3])))
  (should (null (cdr-safe [])))
  (should (null (cdr-safe 3.14))))

(ert-deftest cdr-safe-channel-a-special-values ()
  "Test cdr-safe with special values."
  ;; nil as cdr
  (should (null (cdr-safe '(1 . nil))))
  (should (null (cdr-safe '(a))))

  ;; Keywords
  (should (equal (cdr-safe '(:foo . :bar)) :bar))

  ;; Characters (fixnums)
  (should (equal (cdr-safe (cons ?a ?b)) ?b)))

(ert-deftest cdr-safe-channel-a-vs-cdr ()
  "Test that cdr-safe returns nil instead of signaling error."
  ;; cdr signals error on atoms, cdr-safe returns nil
  (should-error (cdr 42) :type 'wrong-type-argument)
  (should (null (cdr-safe 42)))

  (should-error (cdr "string") :type 'wrong-type-argument)
  (should (null (cdr-safe "string")))

  ;; Both work on cons cells
  (should (equal (cdr '(1 2)) (cdr-safe '(1 2))))

  ;; Both handle nil specially (nil is the empty list)
  (should (null (cdr nil)))
  (should (null (cdr-safe nil))))

(ert-deftest cdr-safe-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various inputs."
  (let ((test-cases
         ;; Format: (input expected-result)
         '(;; Cons cells
           ((1 . 2) 2)
           ((a . b) b)
           ((nil . t) t)
           ((t . nil) nil)

           ;; Proper lists
           ((1) nil)
           ((1 2 3) (2 3))
           ((a b c) (b c))

           ;; Atoms (all return nil)
           (nil nil)
           (42 nil)
           (0 nil)
           (-1 nil)
           (symbol nil)
           (t nil)
           ("string" nil)
           ("" nil)
           ([1 2 3] nil)
           ([] nil)
           (3.14 nil))))
    (dolist (case test-cases)
      (let ((input (nth 0 case))
            (expected (nth 1 case)))
        (should (equal (cdr-safe input) expected))))))

(provide 'cdr-safe-channel-a-tests)
;;; cdr-safe-channel-a-tests.el ends here

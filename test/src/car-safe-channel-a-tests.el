;;; car-safe-channel-a-tests.el --- Channel A verification for car-safe port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the car-safe Zig port (Cat-B fanout #2).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_car_safe) and the original C implementation
;; (car_safe_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/car-safe-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest car-safe-channel-a-cons-cells ()
  "Test car-safe on cons cells (returns car)."
  ;; Simple cons cells
  (should (equal (car-safe '(1 . 2)) 1))
  (should (equal (car-safe (cons 'a 'b)) 'a))
  (should (equal (car-safe (cons nil t)) nil))
  (should (equal (car-safe (cons t nil)) t))

  ;; Proper lists (cons cells)
  (should (equal (car-safe '(1)) 1))
  (should (equal (car-safe '(1 2 3)) 1))
  (should (equal (car-safe '(a b c)) 'a))

  ;; Nested structures
  (should (equal (car-safe '((1 2) 3)) '(1 2)))
  (should (equal (car-safe '((a . b) c)) '(a . b))))

(ert-deftest car-safe-channel-a-non-cons ()
  "Test car-safe on non-cons values (returns nil)."
  ;; Atoms (should return nil, not error)
  (should (null (car-safe nil)))
  (should (null (car-safe 42)))
  (should (null (car-safe 0)))
  (should (null (car-safe -1)))
  (should (null (car-safe 'symbol)))
  (should (null (car-safe t)))
  (should (null (car-safe "string")))
  (should (null (car-safe "")))
  (should (null (car-safe [1 2 3])))
  (should (null (car-safe [])))
  (should (null (car-safe 3.14))))

(ert-deftest car-safe-channel-a-special-values ()
  "Test car-safe with special values."
  ;; nil as car
  (should (null (car-safe '(nil . 1))))
  (should (null (car-safe '(nil))))

  ;; Keywords
  (should (equal (car-safe '(:foo . :bar)) :foo))

  ;; Characters (fixnums)
  (should (equal (car-safe (cons ?a ?b)) ?a)))

(ert-deftest car-safe-channel-a-vs-car ()
  "Test that car-safe returns nil instead of signaling error."
  ;; car signals error on atoms, car-safe returns nil
  (should-error (car 42) :type 'wrong-type-argument)
  (should (null (car-safe 42)))

  (should-error (car "string") :type 'wrong-type-argument)
  (should (null (car-safe "string")))

  ;; Both work on cons cells
  (should (equal (car '(1 2)) (car-safe '(1 2))))

  ;; Both handle nil specially (nil is the empty list)
  (should (null (car nil)))
  (should (null (car-safe nil))))

(ert-deftest car-safe-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various inputs."
  (let ((test-cases
         ;; Format: (input expected-result)
         '(;; Cons cells
           ((1 . 2) 1)
           ((a . b) a)
           ((nil . t) nil)
           ((t . nil) t)

           ;; Proper lists
           ((1) 1)
           ((1 2 3) 1)
           ((a b c) a)

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
        (should (equal (car-safe input) expected))))))

(provide 'car-safe-channel-a-tests)
;;; car-safe-channel-a-tests.el ends here

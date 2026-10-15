;;; natnump-channel-a-tests.el --- Channel A verification for natnump port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the natnump Zig port.
;; This is the FIRST C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_natnump) and the original C implementation
;; (natnump_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/natnump-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest natnump-channel-a-fixnum-boundaries ()
  "Test natnump on fixnum boundary values."
  ;; Zero - the boundary case
  (should (eq (natnump 0) t))

  ;; Positive fixnums
  (should (eq (natnump 1) t))
  (should (eq (natnump 42) t))
  (should (eq (natnump 999999) t))
  (should (eq (natnump most-positive-fixnum) t))

  ;; Negative fixnums - should return nil
  (should (eq (natnump -1) nil))
  (should (eq (natnump -42) nil))
  (should (eq (natnump -999999) nil))
  (should (eq (natnump most-negative-fixnum) nil)))

(ert-deftest natnump-channel-a-bignums ()
  "Test natnump on bignum values."
  ;; Positive bignums (just past fixnum boundary)
  (should (eq (natnump (1+ most-positive-fixnum)) t))
  (should (eq (natnump (+ most-positive-fixnum 100)) t))

  ;; Large positive bignum
  (should (eq (natnump (read "99999999999999999999999999999")) t))

  ;; Negative bignums (just past fixnum boundary)
  (should (eq (natnump (1- most-negative-fixnum)) nil))
  (should (eq (natnump (- most-negative-fixnum 100)) nil))

  ;; Large negative bignum
  (should (eq (natnump (read "-99999999999999999999999999999")) nil)))

(ert-deftest natnump-channel-a-non-integers ()
  "Test natnump on non-integer values - all should return nil."
  ;; nil and t
  (should (eq (natnump nil) nil))
  (should (eq (natnump t) nil))

  ;; Symbols
  (should (eq (natnump 'foo) nil))
  (should (eq (natnump 'some-symbol) nil))

  ;; Strings
  (should (eq (natnump "") nil))
  (should (eq (natnump "123") nil))
  (should (eq (natnump "not-a-number") nil))

  ;; Floats - including 0.0 and positive floats
  (should (eq (natnump 0.0) nil))
  (should (eq (natnump 3.14) nil))
  (should (eq (natnump -2.5) nil))
  (should (eq (natnump 1.0) nil))

  ;; Cons cells
  (should (eq (natnump '(1 . 2)) nil))
  (should (eq (natnump '(a b c)) nil))

  ;; Vectors
  (should (eq (natnump [1 2 3]) nil))
  (should (eq (natnump []) nil)))

(ert-deftest natnump-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Fixnum boundaries
           (0 . t)
           (1 . t)
           (-1 . nil)
           (,most-positive-fixnum . t)
           (,most-negative-fixnum . nil)

           ;; Bignums
           (,(1+ most-positive-fixnum) . t)
           (,(1- most-negative-fixnum) . nil)
           (,(read "99999999999999999999999999999") . t)
           (,(read "-99999999999999999999999999999") . nil)

           ;; Non-integers
           (nil . nil)
           (t . nil)
           (foo . nil)
           ("string" . nil)
           (0.0 . nil)
           (3.14 . nil)
           (-2.5 . nil)
           ((1 . 2) . nil)
           ([1 2 3] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (natnump input) expected))))))

(ert-deftest natnump-channel-a-edge-cases ()
  "Additional edge cases for natnump."
  ;; Edge case: exactly at fixnum boundaries
  (should (eq (natnump most-positive-fixnum) t))
  (should (eq (natnump (1+ most-positive-fixnum)) t))
  (should (eq (natnump most-negative-fixnum) nil))
  (should (eq (natnump (1- most-negative-fixnum)) nil))

  ;; Edge case: zero as fixnum
  (should (eq (natnump 0) t))

  ;; Edge case: various non-number types
  (should (eq (natnump (current-buffer)) nil))
  (should (eq (natnump (selected-window)) nil)))

(provide 'natnump-channel-a-tests)
;;; natnump-channel-a-tests.el ends here

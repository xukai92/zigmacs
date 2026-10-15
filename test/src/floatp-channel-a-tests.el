;;; floatp-channel-a-tests.el --- Channel A verification for floatp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the floatp Zig port.
;; This is the FIFTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_floatp) and the original C implementation
;; (floatp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/floatp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest floatp-channel-a-floats ()
  "Test floatp on floating point values (should return t)."
  ;; Common floats
  (should (eq (floatp 0.0) t))
  (should (eq (floatp 3.0) t))
  (should (eq (floatp 3.14) t))
  (should (eq (floatp -3.14) t))
  (should (eq (floatp -1.5) t))

  ;; Scientific notation
  (should (eq (floatp 1.0e10) t))
  (should (eq (floatp 1.0e-10) t))
  (should (eq (floatp -1.0e10) t))

  ;; Special float values
  (should (eq (floatp -0.0) t))
  (should (eq (floatp 1.0e+INF) t))
  (should (eq (floatp -1.0e+INF) t))
  (should (eq (floatp 0.0e+NaN) t)))

(ert-deftest floatp-channel-a-integers ()
  "Test floatp on integers (should return nil).
CRITICAL: integers (fixnums and bignums) are NOT floats in Emacs Lisp."
  ;; Fixnums
  (should (eq (floatp 0) nil))
  (should (eq (floatp 42) nil))
  (should (eq (floatp -42) nil))
  (should (eq (floatp most-positive-fixnum) nil))
  (should (eq (floatp most-negative-fixnum) nil))

  ;; Characters (fixnums)
  (should (eq (floatp ?a) nil))
  (should (eq (floatp ?\n) nil))
  (should (eq (floatp ?\t) nil))

  ;; Bignums
  (should (eq (floatp (1+ most-positive-fixnum)) nil))
  (should (eq (floatp (1- most-negative-fixnum)) nil))
  (should (eq (floatp (expt 2 100)) nil))
  (should (eq (floatp (- (expt 2 100))) nil)))

(ert-deftest floatp-channel-a-non-numbers ()
  "Test floatp on non-numeric values (should return nil)."
  ;; nil and t
  (should (eq (floatp nil) nil))
  (should (eq (floatp t) nil))

  ;; Symbols
  (should (eq (floatp 'foo) nil))
  (should (eq (floatp 'some-symbol) nil))
  (should (eq (floatp 'x) nil))

  ;; Strings
  (should (eq (floatp "") nil))
  (should (eq (floatp "string") nil))
  (should (eq (floatp "3.14") nil))

  ;; Lists
  (should (eq (floatp '(1 2 3)) nil))
  (should (eq (floatp '(1)) nil))
  (should (eq (floatp '()) nil))
  (should (eq (floatp '(1 . 2)) nil))

  ;; Vectors
  (should (eq (floatp []) nil))
  (should (eq (floatp [1 2 3]) nil))
  (should (eq (floatp [3.14]) nil)))

(ert-deftest floatp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Floats (should return t)
           (3.0 . t)
           (3.14 . t)
           (0.0 . t)
           (-1.5 . t)
           (-3.14 . t)
           (1.0e10 . t)
           (1.0e-10 . t)
           (-0.0 . t)
           (1.0e+INF . t)
           (-1.0e+INF . t)
           (0.0e+NaN . t)

           ;; Integers (CRITICAL: should return nil)
           (0 . nil)
           (42 . nil)
           (-42 . nil)
           (,most-positive-fixnum . nil)
           (,most-negative-fixnum . nil)
           (,(expt 2 100) . nil)
           (,(- (expt 2 100)) . nil)
           (?a . nil)

           ;; Non-numbers (should return nil)
           (nil . nil)
           (t . nil)
           (foo . nil)
           (x . nil)
           ("string" . nil)
           ("" . nil)
           ("3.14" . nil)
           ((1 2 3) . nil)
           ((1) . nil)
           (() . nil)
           ((1 . 2) . nil)
           ([1 2 3] . nil)
           ([] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (floatp input) expected))))))

(ert-deftest floatp-channel-a-edge-cases ()
  "Additional edge cases for floatp."
  ;; Very large floats
  (should (eq (floatp 1.0e100) t))
  (should (eq (floatp -1.0e100) t))

  ;; Very small floats
  (should (eq (floatp 1.0e-100) t))
  (should (eq (floatp -1.0e-100) t))

  ;; Large integers (should return nil — NOT floats)
  (should (eq (floatp (expt 2 1000)) nil))
  (should (eq (floatp (- (expt 2 1000))) nil))

  ;; Various non-number types
  (should (eq (floatp (current-buffer)) nil))
  (should (eq (floatp (selected-window)) nil))
  (should (eq (floatp (point-marker)) nil))
  (should (eq (floatp (make-hash-table)) nil)))

(provide 'floatp-channel-a-tests)
;;; floatp-channel-a-tests.el ends here

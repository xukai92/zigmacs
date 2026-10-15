;;; integerp-channel-a-tests.el --- Channel A verification for integerp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the integerp Zig port.
;; This is the FOURTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_integerp) and the original C implementation
;; (integerp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/integerp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest integerp-channel-a-integers ()
  "Test integerp on integer values (should return t)."
  ;; Fixnums
  (should (eq (integerp 0) t))
  (should (eq (integerp 42) t))
  (should (eq (integerp -42) t))
  (should (eq (integerp most-positive-fixnum) t))
  (should (eq (integerp most-negative-fixnum) t))

  ;; Characters (fixnums)
  (should (eq (integerp ?a) t))
  (should (eq (integerp ?\n) t))
  (should (eq (integerp ?\t) t))

  ;; Bignums
  (should (eq (integerp (1+ most-positive-fixnum)) t))
  (should (eq (integerp (1- most-negative-fixnum)) t))
  (should (eq (integerp (expt 2 100)) t))
  (should (eq (integerp (- (expt 2 100))) t)))

(ert-deftest integerp-channel-a-floats ()
  "Test integerp on floats (should return nil).
CRITICAL: floats are NOT integers in Emacs Lisp."
  (should (eq (integerp 0.0) nil))
  (should (eq (integerp 3.0) nil))
  (should (eq (integerp 3.14) nil))
  (should (eq (integerp -3.14) nil))
  (should (eq (integerp 1.0e10) nil))
  (should (eq (integerp 1.0e-10) nil))
  (should (eq (integerp -0.0) nil)))

(ert-deftest integerp-channel-a-non-numbers ()
  "Test integerp on non-numeric values (should return nil)."
  ;; nil and t
  (should (eq (integerp nil) nil))
  (should (eq (integerp t) nil))

  ;; Symbols
  (should (eq (integerp 'foo) nil))
  (should (eq (integerp 'some-symbol) nil))
  (should (eq (integerp 'x) nil))

  ;; Strings
  (should (eq (integerp "") nil))
  (should (eq (integerp "string") nil))
  (should (eq (integerp "42") nil))

  ;; Lists
  (should (eq (integerp '(1 2 3)) nil))
  (should (eq (integerp '(1)) nil))
  (should (eq (integerp '()) nil))
  (should (eq (integerp '(1 . 2)) nil))

  ;; Vectors
  (should (eq (integerp []) nil))
  (should (eq (integerp [1 2 3]) nil))
  (should (eq (integerp [42]) nil)))

(ert-deftest integerp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Integers (should return t)
           (0 . t)
           (42 . t)
           (-42 . t)
           (,most-positive-fixnum . t)
           (,most-negative-fixnum . t)
           (,(1+ most-positive-fixnum) . t)
           (,(1- most-negative-fixnum) . t)
           (,(expt 2 100) . t)
           (,(- (expt 2 100)) . t)
           (?a . t)

           ;; Floats (CRITICAL: should return nil)
           (3.0 . nil)
           (0.0 . nil)
           (-3.14 . nil)
           (1.0e10 . nil)

           ;; Non-numbers (should return nil)
           (nil . nil)
           (t . nil)
           (foo . nil)
           (x . nil)
           ("string" . nil)
           ("" . nil)
           ("42" . nil)
           ((1 2 3) . nil)
           ((1) . nil)
           (() . nil)
           ((1 . 2) . nil)
           ([1 2 3] . nil)
           ([] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (integerp input) expected))))))

(ert-deftest integerp-channel-a-edge-cases ()
  "Additional edge cases for integerp."
  ;; Large integers
  (should (eq (integerp (expt 2 1000)) t))
  (should (eq (integerp (- (expt 2 1000))) t))

  ;; Special float values (should return nil — NOT integers)
  (should (eq (integerp 1.0e+INF) nil))
  (should (eq (integerp -1.0e+INF) nil))
  (should (eq (integerp 0.0e+NaN) nil))

  ;; Various non-number types
  (should (eq (integerp (current-buffer)) nil))
  (should (eq (integerp (selected-window)) nil))
  (should (eq (integerp (point-marker)) nil))
  (should (eq (integerp (make-hash-table)) nil)))

(provide 'integerp-channel-a-tests)
;;; integerp-channel-a-tests.el ends here

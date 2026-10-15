;;; numberp-channel-a-tests.el --- Channel A verification for numberp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the numberp Zig port.
;; This is the THIRD C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_numberp) and the original C implementation
;; (numberp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/numberp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest numberp-channel-a-numbers ()
  "Test numberp on numeric values (should return t)."
  ;; Fixnums
  (should (eq (numberp 0) t))
  (should (eq (numberp 42) t))
  (should (eq (numberp -42) t))
  (should (eq (numberp most-positive-fixnum) t))
  (should (eq (numberp most-negative-fixnum) t))

  ;; Characters (fixnums)
  (should (eq (numberp ?a) t))
  (should (eq (numberp ?\n) t))
  (should (eq (numberp ?\t) t))

  ;; Bignums
  (should (eq (numberp (1+ most-positive-fixnum)) t))
  (should (eq (numberp (1- most-negative-fixnum)) t))
  (should (eq (numberp (expt 2 100)) t))
  (should (eq (numberp (- (expt 2 100))) t))

  ;; Floats
  (should (eq (numberp 0.0) t))
  (should (eq (numberp 3.14) t))
  (should (eq (numberp -3.14) t))
  (should (eq (numberp 1.0e10) t))
  (should (eq (numberp 1.0e-10) t))
  (should (eq (numberp -0.0) t)))

(ert-deftest numberp-channel-a-non-numbers ()
  "Test numberp on non-numeric values (should return nil)."
  ;; nil and t
  (should (eq (numberp nil) nil))
  (should (eq (numberp t) nil))

  ;; Symbols
  (should (eq (numberp 'foo) nil))
  (should (eq (numberp 'some-symbol) nil))
  (should (eq (numberp 'x) nil))

  ;; Strings
  (should (eq (numberp "") nil))
  (should (eq (numberp "string") nil))
  (should (eq (numberp "42") nil))

  ;; Lists
  (should (eq (numberp '(1 2 3)) nil))
  (should (eq (numberp '(1)) nil))
  (should (eq (numberp '()) nil))
  (should (eq (numberp '(1 . 2)) nil))

  ;; Vectors
  (should (eq (numberp []) nil))
  (should (eq (numberp [1 2 3]) nil))
  (should (eq (numberp [42]) nil)))

(ert-deftest numberp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Numbers (should return t)
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
           (3.0 . t)
           (0.0 . t)
           (-3.14 . t)
           (1.0e10 . t)

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
        (should (eq (numberp input) expected))))))

(ert-deftest numberp-channel-a-edge-cases ()
  "Additional edge cases for numberp."
  ;; Large numbers
  (should (eq (numberp (expt 2 1000)) t))
  (should (eq (numberp (- (expt 2 1000))) t))

  ;; Special float values
  (should (eq (numberp 1.0e+INF) t))
  (should (eq (numberp -1.0e+INF) t))
  (should (eq (numberp 0.0e+NaN) t))

  ;; Various non-number types
  (should (eq (numberp (current-buffer)) nil))
  (should (eq (numberp (selected-window)) nil))
  (should (eq (numberp (point-marker)) nil))
  (should (eq (numberp (make-hash-table)) nil)))

(provide 'numberp-channel-a-tests)
;;; numberp-channel-a-tests.el ends here

;;; consp-channel-a-tests.el --- Channel A verification for consp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the consp Zig port.
;; This is the EIGHTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_consp) and the original C implementation
;; (consp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/consp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest consp-channel-a-cons-cells ()
  "Test consp on cons cells (should return t)."
  ;; Basic cons cells
  (should (eq (consp '(1 . 2)) t))
  (should (eq (consp (cons 1 2)) t))
  (should (eq (consp (cons nil nil)) t))

  ;; Lists (which are built from cons cells)
  (should (eq (consp '(1)) t))
  (should (eq (consp '(1 2 3)) t))
  (should (eq (consp '(a b c)) t))

  ;; Nested structures
  (should (eq (consp '((1 2) (3 4))) t))
  (should (eq (consp '(1 . (2 . 3))) t)))

(ert-deftest consp-channel-a-nil ()
  "Test consp on nil (CRITICAL: should return nil).
CRITICAL: nil is NOT a cons cell (contrast with listp where nil IS a list)."
  (should (eq (consp nil) nil))
  (should (eq (consp '()) nil)))

(ert-deftest consp-channel-a-non-cons ()
  "Test consp on non-cons values (should return nil)."
  ;; Numbers
  (should (eq (consp 0) nil))
  (should (eq (consp 42) nil))
  (should (eq (consp -42) nil))
  (should (eq (consp 3.0) nil))
  (should (eq (consp 3.14) nil))

  ;; Characters (fixnums)
  (should (eq (consp ?a) nil))
  (should (eq (consp ?\n) nil))

  ;; Symbols
  (should (eq (consp 'x) nil))
  (should (eq (consp 'foo) nil))
  (should (eq (consp t) nil))
  (should (eq (consp :keyword) nil))

  ;; Strings
  (should (eq (consp "s") nil))
  (should (eq (consp "") nil))
  (should (eq (consp "foo") nil))

  ;; Vectors
  (should (eq (consp []) nil))
  (should (eq (consp [1]) nil))
  (should (eq (consp [1 2 3]) nil)))

(ert-deftest consp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Cons cells (should return t)
           ((1 . 2) . t)
           (,(cons 1 2) . t)
           (,(cons nil nil) . t)
           ((1) . t)
           ((1 2 3) . t)
           ((a b c) . t)
           (((1 2) (3 4)) . t)

           ;; nil (CRITICAL: should return nil)
           (nil . nil)
           (() . nil)

           ;; Numbers (should return nil)
           (0 . nil)
           (42 . nil)
           (-42 . nil)
           (,most-positive-fixnum . nil)
           (,most-negative-fixnum . nil)
           (,(expt 2 100) . nil)
           (,(- (expt 2 100)) . nil)
           (3.0 . nil)
           (3.14 . nil)
           (-3.14 . nil)

           ;; Characters (should return nil)
           (?a . nil)
           (?\n . nil)

           ;; Symbols (should return nil)
           (x . nil)
           (foo . nil)
           (t . nil)
           (:keyword . nil)

           ;; Strings (should return nil)
           ("s" . nil)
           ("" . nil)
           ("foo" . nil)

           ;; Vectors (should return nil)
           ([] . nil)
           ([1] . nil)
           ([1 2 3] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (consp input) expected))))))

(ert-deftest consp-channel-a-edge-cases ()
  "Additional edge cases for consp.
CRITICAL: nil is NOT a cons (this is the key bug-for-bug behavior)."
  ;; nil edge cases
  (should (eq (consp nil) nil))
  (should (eq (consp '()) nil))

  ;; Other non-cons types
  (should (eq (consp (current-buffer)) nil))
  (should (eq (consp (selected-window)) nil))
  (should (eq (consp (point-marker)) nil))
  (should (eq (consp (make-hash-table)) nil))

  ;; Cons cells with special values
  (should (eq (consp (cons t nil)) t))
  (should (eq (consp (cons nil t)) t))
  (should (eq (consp (cons 'foo 'bar)) t)))

(provide 'consp-channel-a-tests)
;;; consp-channel-a-tests.el ends here

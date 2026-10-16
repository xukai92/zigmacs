;;; listp-channel-a-tests.el --- Channel A verification for listp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the listp Zig port.
;; This is the TENTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_listp) and the original C implementation
;; (listp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/listp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest listp-channel-a-lists ()
  "Test listp on lists (should return t).
CRITICAL: nil IS a list (contrast with consp where nil is NOT a cons)."
  ;; nil is a list (CRITICAL behavior)
  (should (eq (listp nil) t))
  (should (eq (listp '()) t))

  ;; Cons cells are lists
  (should (eq (listp '(1 . 2)) t))
  (should (eq (listp (cons 1 2)) t))
  (should (eq (listp (cons nil nil)) t))

  ;; Proper lists
  (should (eq (listp '(1)) t))
  (should (eq (listp '(1 2 3)) t))
  (should (eq (listp '(a b c)) t))

  ;; Nested structures
  (should (eq (listp '((1 2) (3 4))) t))
  (should (eq (listp '(1 . (2 . 3))) t)))

(ert-deftest listp-channel-a-non-lists ()
  "Test listp on non-list values (should return nil)."
  ;; Numbers
  (should (eq (listp 0) nil))
  (should (eq (listp 42) nil))
  (should (eq (listp -42) nil))
  (should (eq (listp 3.0) nil))
  (should (eq (listp 3.14) nil))

  ;; Characters (fixnums)
  (should (eq (listp ?a) nil))
  (should (eq (listp ?\n) nil))

  ;; Symbols (but NOT nil)
  (should (eq (listp 'x) nil))
  (should (eq (listp 'foo) nil))
  (should (eq (listp t) nil))
  (should (eq (listp :keyword) nil))

  ;; Strings
  (should (eq (listp "s") nil))
  (should (eq (listp "") nil))
  (should (eq (listp "foo") nil))

  ;; Vectors
  (should (eq (listp []) nil))
  (should (eq (listp [1]) nil))
  (should (eq (listp [1 2 3]) nil)))

(ert-deftest listp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Lists (should return t)
           ;; nil is a list (CRITICAL)
           (nil . t)
           (() . t)

           ;; Cons cells are lists
           ((1 . 2) . t)
           (,(cons 1 2) . t)
           (,(cons nil nil) . t)
           ((1) . t)
           ((1 2 3) . t)
           ((a b c) . t)
           (((1 2) (3 4)) . t)

           ;; Non-lists (should return nil)
           ;; Numbers
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

           ;; Characters
           (?a . nil)
           (?\n . nil)

           ;; Symbols (but NOT nil)
           (x . nil)
           (foo . nil)
           (t . nil)
           (:keyword . nil)

           ;; Strings
           ("s" . nil)
           ("" . nil)
           ("foo" . nil)

           ;; Vectors
           ([] . nil)
           ([1] . nil)
           ([1 2 3] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (listp input) expected))))))

(ert-deftest listp-channel-a-edge-cases ()
  "Additional edge cases for listp.
CRITICAL: nil IS a list (this is the key bug-for-bug behavior, opposite of consp)."
  ;; nil edge cases (CRITICAL: nil IS a list)
  (should (eq (listp nil) t))
  (should (eq (listp '()) t))

  ;; Other non-list types
  (should (eq (listp (current-buffer)) nil))
  (should (eq (listp (selected-window)) nil))
  (should (eq (listp (point-marker)) nil))
  (should (eq (listp (make-hash-table)) nil))

  ;; Cons cells with special values (all lists)
  (should (eq (listp (cons t nil)) t))
  (should (eq (listp (cons nil t)) t))
  (should (eq (listp (cons 'foo 'bar)) t)))

(ert-deftest listp-channel-a-inverse-of-nlistp ()
  "Verify that listp is the exact inverse of nlistp."
  (let ((test-values
         `(nil
           ()
           (1 . 2)
           ,(cons 1 2)
           (1 2 3)
           42
           3.14
           x
           "string"
           [1 2 3]
           t)))
    (dolist (value test-values)
      ;; listp(x) = NOT nlistp(x)
      (should (eq (listp value)
                  (if (nlistp value) nil t))))))

(provide 'listp-channel-a-tests)
;;; listp-channel-a-tests.el ends here

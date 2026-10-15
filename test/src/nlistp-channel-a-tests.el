;;; nlistp-channel-a-tests.el --- Channel A verification for nlistp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the nlistp Zig port.
;; This is the SECOND C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_nlistp) and the original C implementation
;; (nlistp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/nlistp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest nlistp-channel-a-lists ()
  "Test nlistp on list values (should return nil)."
  ;; nil is a list
  (should (eq (nlistp nil) nil))

  ;; Proper lists (cons cells)
  (should (eq (nlistp '(1 2 3)) nil))
  (should (eq (nlistp '(a b c)) nil))
  (should (eq (nlistp '(1)) nil))

  ;; Improper lists (cons cells with non-nil cdr)
  (should (eq (nlistp '(1 . 2)) nil))
  (should (eq (nlistp '(1 2 . 3)) nil))
  (should (eq (nlistp (cons 'a 'b)) nil)))

(ert-deftest nlistp-channel-a-non-lists ()
  "Test nlistp on non-list values (should return t)."
  ;; t is not a list
  (should (eq (nlistp t) t))

  ;; Symbols
  (should (eq (nlistp 'foo) t))
  (should (eq (nlistp 'some-symbol) t))

  ;; Numbers (fixnums, bignums, floats)
  (should (eq (nlistp 0) t))
  (should (eq (nlistp 42) t))
  (should (eq (nlistp -42) t))
  (should (eq (nlistp most-positive-fixnum) t))
  (should (eq (nlistp most-negative-fixnum) t))
  (should (eq (nlistp (1+ most-positive-fixnum)) t))
  (should (eq (nlistp 3.14) t))
  (should (eq (nlistp 0.0) t))

  ;; Strings
  (should (eq (nlistp "") t))
  (should (eq (nlistp "string") t))
  (should (eq (nlistp "not-a-list") t))

  ;; Vectors
  (should (eq (nlistp []) t))
  (should (eq (nlistp [1 2 3]) t))
  (should (eq (nlistp [a b c]) t)))

(ert-deftest nlistp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Lists (should return nil)
           (nil . nil)
           ((1 2 3) . nil)
           ((a b c) . nil)
           ((1) . nil)
           ((1 . 2) . nil)
           ((1 2 . 3) . nil)

           ;; Non-lists (should return t)
           (t . t)
           (foo . t)
           (42 . t)
           (0 . t)
           (-1 . t)
           (,most-positive-fixnum . t)
           (,most-negative-fixnum . t)
           (,(1+ most-positive-fixnum) . t)
           (3.14 . t)
           (0.0 . t)
           ("string" . t)
           ("" . t)
           ([1 2 3] . t)
           ([] . t))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (nlistp input) expected))))))

(ert-deftest nlistp-channel-a-edge-cases ()
  "Additional edge cases for nlistp."
  ;; Empty list (nil) is a list
  (should (eq (nlistp nil) nil))
  (should (eq (nlistp '()) nil))

  ;; Single element list
  (should (eq (nlistp '(x)) nil))

  ;; Deeply nested cons
  (should (eq (nlistp '(((a)))) nil))
  (should (eq (nlistp '(a . (b . (c . nil)))) nil))

  ;; Various non-list types
  (should (eq (nlistp (current-buffer)) t))
  (should (eq (nlistp (selected-window)) t))
  (should (eq (nlistp (point-marker)) t)))

(provide 'nlistp-channel-a-tests)
;;; nlistp-channel-a-tests.el ends here

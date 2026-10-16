;;; subrp-channel-a-tests.el --- Channel A verification for subrp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the subrp Zig port.
;; This is a Category A port from fanout round #4.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_subrp) and the original C implementation
;; (subrp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/subrp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest subrp-channel-a-subrs ()
  "Test subrp on built-in functions (should return t)."
  ;; Built-in functions
  (should (eq (subrp (symbol-function 'car)) t))
  (should (eq (subrp (symbol-function 'cdr)) t))
  (should (eq (subrp (symbol-function 'cons)) t))
  (should (eq (subrp (symbol-function 'list)) t))
  (should (eq (subrp (symbol-function '+)) t))
  (should (eq (subrp (symbol-function '-)) t))
  (should (eq (subrp (symbol-function 'eq)) t))
  (should (eq (subrp (symbol-function 'equal)) t))
  (should (eq (subrp (symbol-function 'symbolp)) t))
  (should (eq (subrp (symbol-function 'stringp)) t)))

(ert-deftest subrp-channel-a-non-subrs ()
  "Test subrp on non-subr values (should return nil)."
  ;; nil and t
  (should (eq (subrp nil) nil))
  (should (eq (subrp t) nil))

  ;; Integers
  (should (eq (subrp 0) nil))
  (should (eq (subrp 42) nil))
  (should (eq (subrp -42) nil))

  ;; Floats
  (should (eq (subrp 3.14) nil))
  (should (eq (subrp 0.0) nil))

  ;; Symbols
  (should (eq (subrp 'foo) nil))
  (should (eq (subrp 'car) nil))  ; Symbol, not the function

  ;; Strings
  (should (eq (subrp "foo") nil))
  (should (eq (subrp "") nil))

  ;; Lists
  (should (eq (subrp '(1 2 3)) nil))
  (should (eq (subrp '()) nil))

  ;; Vectors
  (should (eq (subrp []) nil))
  (should (eq (subrp [1 2 3]) nil))

  ;; Characters
  (should (eq (subrp ?a) nil))

  ;; Lambda/closures are NOT subrs
  (should (eq (subrp (lambda () 1)) nil))
  (should (eq (subrp (lambda (x) x)) nil)))

(ert-deftest subrp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Subrs (should return t)
           (,(symbol-function 'car) . t)
           (,(symbol-function 'cdr) . t)
           (,(symbol-function 'cons) . t)
           (,(symbol-function 'list) . t)
           (,(symbol-function '+) . t)

           ;; Non-subrs (should return nil)
           (nil . nil)
           (t . nil)
           (42 . nil)
           (0 . nil)
           (3.14 . nil)
           (foo . nil)
           ("foo" . nil)
           ((1 2 3) . nil)
           ([] . nil)
           (?a . nil)
           (,(lambda () 1) . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (subrp input) expected))))))

(ert-deftest subrp-channel-a-edge-cases ()
  "Additional edge cases for subrp."
  ;; Various non-subr objects
  (should (eq (subrp (current-buffer)) nil))
  (should (eq (subrp (selected-window)) nil))
  (should (eq (subrp (point-marker)) nil))
  (should (eq (subrp (make-hash-table)) nil))

  ;; Keywords
  (should (eq (subrp :foo) nil))
  (should (eq (subrp :bar) nil)))

(provide 'subrp-channel-a-tests)
;;; subrp-channel-a-tests.el ends here

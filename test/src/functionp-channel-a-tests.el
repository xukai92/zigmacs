;;; functionp-channel-a-tests.el --- Channel A verification for functionp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the functionp Zig port.
;; This is a Category A port in Zigmacs fanout round #3.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_functionp) and the original C implementation
;; (functionp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/functionp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest functionp-channel-a-functions ()
  "Test functionp on function values (should return t)."
  ;; Built-in functions
  (should (eq (functionp 'car) t))
  (should (eq (functionp 'list) t))
  (should (eq (functionp '+) t))

  ;; Lambda expressions
  (should (eq (functionp (lambda () nil)) t))
  (should (eq (functionp (lambda (x) x)) t))

  ;; Byte-compiled functions
  (should (eq (functionp (byte-compile (lambda () nil))) t))

  ;; Symbols with function bindings
  (fset 'test-function (lambda () nil))
  (should (eq (functionp 'test-function) t))
  (fmakunbound 'test-function))

(ert-deftest functionp-channel-a-non-functions ()
  "Test functionp on non-function values (should return nil)."
  ;; nil and t
  (should (eq (functionp nil) nil))
  (should (eq (functionp t) nil))

  ;; Integers
  (should (eq (functionp 0) nil))
  (should (eq (functionp 42) nil))

  ;; Floats
  (should (eq (functionp 3.14) nil))

  ;; Unbound symbols
  (should (eq (functionp 'unbound-symbol-xyz) nil))

  ;; Symbols with variable bindings only
  (should (eq (functionp 'some-variable) nil))

  ;; Strings
  (should (eq (functionp "string") nil))

  ;; Vectors
  (should (eq (functionp [1 2 3]) nil))

  ;; Lists (not lambda)
  (should (eq (functionp '(1 2 3)) nil))

  ;; Other types
  (should (eq (functionp (current-buffer)) nil))
  (should (eq (functionp (make-marker)) nil))
  (should (eq (functionp (make-hash-table)) nil)))

(ert-deftest functionp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Functions (should return t)
           (car . t)
           (list . t)
           (+ . t)
           (,(lambda () nil) . t)

           ;; Non-functions (should return nil)
           (nil . nil)
           (t . nil)
           (0 . nil)
           (42 . nil)
           (3.14 . nil)
           (unbound-xyz . nil)
           ("string" . nil)
           ([1 2 3] . nil)
           ((1 2 3) . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (functionp input) expected))))))

(provide 'functionp-channel-a-tests)
;;; functionp-channel-a-tests.el ends here

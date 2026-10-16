;;; closurep-channel-a-tests.el --- Channel A verification for closurep port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the closurep Zig port.
;; This is a Category A port from fanout round #4.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_closurep) and the original C implementation
;; (closurep_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/closurep-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest closurep-channel-a-closures ()
  "Test closurep on closure values (should return t)."
  ;; Lexical binding must be enabled for closures
  (let ((lexical-binding t))
    ;; Basic closures
    (should (eq (closurep (lambda () 1)) t))
    (should (eq (closurep (lambda (x) x)) t))
    (should (eq (closurep (lambda (x y) (+ x y))) t))

    ;; Closure with captured variables
    (let ((captured 42))
      (should (eq (closurep (lambda () captured)) t))
      (should (eq (closurep (lambda (x) (+ x captured))) t)))))

(ert-deftest closurep-channel-a-non-closures ()
  "Test closurep on non-closure values (should return nil)."
  ;; nil and t
  (should (eq (closurep nil) nil))
  (should (eq (closurep t) nil))

  ;; Integers
  (should (eq (closurep 0) nil))
  (should (eq (closurep 42) nil))
  (should (eq (closurep -42) nil))

  ;; Floats
  (should (eq (closurep 3.14) nil))
  (should (eq (closurep 0.0) nil))

  ;; Symbols
  (should (eq (closurep 'foo) nil))
  (should (eq (closurep 'car) nil))

  ;; Strings
  (should (eq (closurep "foo") nil))
  (should (eq (closurep "") nil))

  ;; Lists
  (should (eq (closurep '(1 2 3)) nil))
  (should (eq (closurep '()) nil))
  (should (eq (closurep '(lambda (x) x)) nil))  ; Quoted lambda is a list

  ;; Vectors
  (should (eq (closurep []) nil))
  (should (eq (closurep [1 2 3]) nil))

  ;; Characters
  (should (eq (closurep ?a) nil))

  ;; Built-in functions are NOT closures
  (should (eq (closurep (symbol-function 'car)) nil))
  (should (eq (closurep (symbol-function 'cdr)) nil)))

(ert-deftest closurep-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((lexical-binding t)
        (battery
         ;; Format: (input . expected-result)
         `(;; Closures (should return t)
           (,(lambda () 1) . t)
           (,(lambda (x) x) . t)
           (,(lambda (x y) (+ x y)) . t)

           ;; Non-closures (should return nil)
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
           (,(symbol-function 'car) . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (closurep input) expected))))))

(ert-deftest closurep-channel-a-edge-cases ()
  "Additional edge cases for closurep."
  ;; Various non-closure objects
  (should (eq (closurep (current-buffer)) nil))
  (should (eq (closurep (selected-window)) nil))
  (should (eq (closurep (point-marker)) nil))
  (should (eq (closurep (make-hash-table)) nil))

  ;; Keywords
  (should (eq (closurep :foo) nil))
  (should (eq (closurep :bar) nil)))

(provide 'closurep-channel-a-tests)
;;; closurep-channel-a-tests.el ends here

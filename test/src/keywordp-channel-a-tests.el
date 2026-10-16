;;; keywordp-channel-a-tests.el --- Channel A verification for keywordp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the keywordp Zig port.
;; This is a Category A port from fanout round #4.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_keywordp) and the original C implementation
;; (keywordp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/keywordp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest keywordp-channel-a-keywords ()
  "Test keywordp on keyword values (should return t)."
  ;; Standard keywords
  (should (eq (keywordp :foo) t))
  (should (eq (keywordp :bar) t))
  (should (eq (keywordp :baz) t))
  (should (eq (keywordp :test) t))
  (should (eq (keywordp :a) t))
  (should (eq (keywordp :x) t))
  (should (eq (keywordp :some-keyword) t))
  (should (eq (keywordp :another-keyword) t)))

(ert-deftest keywordp-channel-a-non-keywords ()
  "Test keywordp on non-keyword values (should return nil)."
  ;; nil and t
  (should (eq (keywordp nil) nil))
  (should (eq (keywordp t) nil))

  ;; Regular symbols (not keywords)
  (should (eq (keywordp 'foo) nil))
  (should (eq (keywordp 'bar) nil))
  (should (eq (keywordp 'some-symbol) nil))
  (should (eq (keywordp 'x) nil))

  ;; Integers
  (should (eq (keywordp 0) nil))
  (should (eq (keywordp 42) nil))
  (should (eq (keywordp -42) nil))
  (should (eq (keywordp most-positive-fixnum) nil))

  ;; Floats
  (should (eq (keywordp 3.14) nil))
  (should (eq (keywordp 0.0) nil))

  ;; Strings
  (should (eq (keywordp "foo") nil))
  (should (eq (keywordp ":foo") nil))  ; String, not keyword
  (should (eq (keywordp "") nil))

  ;; Lists
  (should (eq (keywordp '(1 2 3)) nil))
  (should (eq (keywordp '(:foo)) nil))

  ;; Vectors
  (should (eq (keywordp []) nil))
  (should (eq (keywordp [1 2 3]) nil))

  ;; Characters
  (should (eq (keywordp ?a) nil))
  (should (eq (keywordp ?:) nil)))

(ert-deftest keywordp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Keywords (should return t)
           (:foo . t)
           (:bar . t)
           (:test . t)
           (:a . t)
           (:some-keyword . t)

           ;; Non-keywords (should return nil)
           (nil . nil)
           (t . nil)
           (foo . nil)
           (bar . nil)
           (some-symbol . nil)
           (42 . nil)
           (0 . nil)
           (-42 . nil)
           (3.14 . nil)
           ("foo" . nil)
           (":foo" . nil)
           ((1 2 3) . nil)
           ((:foo) . nil)
           ([] . nil)
           (?a . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (keywordp input) expected))))))

(ert-deftest keywordp-channel-a-edge-cases ()
  "Additional edge cases for keywordp."
  ;; Various non-keyword objects
  (should (eq (keywordp (current-buffer)) nil))
  (should (eq (keywordp (selected-window)) nil))
  (should (eq (keywordp (point-marker)) nil))
  (should (eq (keywordp (make-hash-table)) nil))

  ;; Lambda/closure (not a keyword)
  (should (eq (keywordp (lambda () 1)) nil))

  ;; Built-in function (not a keyword)
  (should (eq (keywordp (symbol-function 'car)) nil)))

(provide 'keywordp-channel-a-tests)
;;; keywordp-channel-a-tests.el ends here

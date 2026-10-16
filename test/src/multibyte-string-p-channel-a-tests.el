;;; multibyte-string-p-channel-a-tests.el --- Channel A verification for multibyte-string-p port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the multibyte-string-p Zig port.
;; This is a Category A port from fanout round #4.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_multibyte_string_p) and the original C implementation
;; (multibyte_string_p_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/multibyte-string-p-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest multibyte-string-p-channel-a-multibyte-strings ()
  "Test multibyte-string-p on multibyte strings (should return t)."
  ;; Multibyte strings (non-ASCII)
  (should (eq (multibyte-string-p "é") t))
  (should (eq (multibyte-string-p "café") t))
  (should (eq (multibyte-string-p "日本語") t))
  (should (eq (multibyte-string-p "hello 世界") t))
  (should (eq (multibyte-string-p "αβγ") t))
  (should (eq (multibyte-string-p "Ω") t))

  ;; ASCII strings are multibyte by default in modern Emacs
  (should (eq (multibyte-string-p "hello") t))
  (should (eq (multibyte-string-p "abc") t))
  (should (eq (multibyte-string-p "a") t)))

(ert-deftest multibyte-string-p-channel-a-unibyte-strings ()
  "Test multibyte-string-p on unibyte strings (should return nil)."
  ;; Explicitly created unibyte strings
  (should (eq (multibyte-string-p (string-to-unibyte "hello")) nil))
  (should (eq (multibyte-string-p (string-to-unibyte "abc")) nil))
  (should (eq (multibyte-string-p (string-to-unibyte "a")) nil))
  (should (eq (multibyte-string-p (string-to-unibyte "")) nil)))

(ert-deftest multibyte-string-p-channel-a-non-strings ()
  "Test multibyte-string-p on non-string values (should return nil)."
  ;; nil and t
  (should (eq (multibyte-string-p nil) nil))
  (should (eq (multibyte-string-p t) nil))

  ;; Integers
  (should (eq (multibyte-string-p 0) nil))
  (should (eq (multibyte-string-p 42) nil))
  (should (eq (multibyte-string-p -42) nil))

  ;; Floats
  (should (eq (multibyte-string-p 3.14) nil))
  (should (eq (multibyte-string-p 0.0) nil))

  ;; Symbols
  (should (eq (multibyte-string-p 'foo) nil))
  (should (eq (multibyte-string-p 'bar) nil))

  ;; Lists
  (should (eq (multibyte-string-p '(1 2 3)) nil))
  (should (eq (multibyte-string-p '()) nil))
  (should (eq (multibyte-string-p '("string")) nil))

  ;; Vectors
  (should (eq (multibyte-string-p []) nil))
  (should (eq (multibyte-string-p [1 2 3]) nil))

  ;; Characters
  (should (eq (multibyte-string-p ?a) nil))
  (should (eq (multibyte-string-p ?é) nil)))

(ert-deftest multibyte-string-p-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Multibyte strings (should return t)
           ("é" . t)
           ("café" . t)
           ("日本語" . t)
           ("hello 世界" . t)
           ("hello" . t)
           ("abc" . t)

           ;; Unibyte strings (should return nil)
           (,(string-to-unibyte "hello") . nil)
           (,(string-to-unibyte "abc") . nil)
           (,(string-to-unibyte "") . nil)

           ;; Non-strings (should return nil)
           (nil . nil)
           (t . nil)
           (42 . nil)
           (0 . nil)
           (3.14 . nil)
           (foo . nil)
           ((1 2 3) . nil)
           ([] . nil)
           (?a . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (multibyte-string-p input) expected))))))

(ert-deftest multibyte-string-p-channel-a-edge-cases ()
  "Additional edge cases for multibyte-string-p."
  ;; Empty string
  (should (eq (multibyte-string-p "") t))  ; Empty multibyte string

  ;; Various non-string objects
  (should (eq (multibyte-string-p (current-buffer)) nil))
  (should (eq (multibyte-string-p (selected-window)) nil))
  (should (eq (multibyte-string-p (point-marker)) nil))
  (should (eq (multibyte-string-p (make-hash-table)) nil))

  ;; Keywords
  (should (eq (multibyte-string-p :foo) nil))

  ;; Closures
  (should (eq (multibyte-string-p (lambda () 1)) nil)))

(provide 'multibyte-string-p-channel-a-tests)
;;; multibyte-string-p-channel-a-tests.el ends here

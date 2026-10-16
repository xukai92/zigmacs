;;; arrayp-channel-a-tests.el --- Channel A verification for arrayp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the arrayp Zig port.
;; This is the FOURTEENTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_arrayp) and the original C implementation
;; (arrayp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/arrayp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest arrayp-channel-a-arrays ()
  "Test arrayp on array values (should return t)."
  ;; Strings
  (should (eq (arrayp "string") t))
  (should (eq (arrayp "") t))
  (should (eq (arrayp "a") t))
  (should (eq (arrayp "hello world") t))

  ;; Vectors
  (should (eq (arrayp []) t))
  (should (eq (arrayp [1]) t))
  (should (eq (arrayp [1 2 3]) t))
  (should (eq (arrayp [a b c]) t))

  ;; Bool-vectors
  (should (eq (arrayp (make-bool-vector 0 nil)) t))
  (should (eq (arrayp (make-bool-vector 3 t)) t))
  (should (eq (arrayp (make-bool-vector 10 nil)) t))

  ;; Char-tables
  (should (eq (arrayp (make-char-table nil)) t))
  (should (eq (arrayp (make-char-table 'syntax-table)) t)))

(ert-deftest arrayp-channel-a-non-arrays ()
  "Test arrayp on non-array values (should return nil)."
  ;; nil and t
  (should (eq (arrayp nil) nil))
  (should (eq (arrayp t) nil))

  ;; Integers
  (should (eq (arrayp 0) nil))
  (should (eq (arrayp 42) nil))
  (should (eq (arrayp -42) nil))
  (should (eq (arrayp most-positive-fixnum) nil))
  (should (eq (arrayp (expt 2 100)) nil))

  ;; Floats
  (should (eq (arrayp 3.14) nil))
  (should (eq (arrayp 0.0) nil))
  (should (eq (arrayp -1.5) nil))

  ;; Symbols
  (should (eq (arrayp 'foo) nil))
  (should (eq (arrayp 'some-symbol) nil))
  (should (eq (arrayp 'x) nil))

  ;; Lists (CRITICAL: lists are NOT arrays)
  (should (eq (arrayp '(1 2 3)) nil))
  (should (eq (arrayp '(1)) nil))
  (should (eq (arrayp '()) nil))
  (should (eq (arrayp '(1 . 2)) nil))

  ;; Characters
  (should (eq (arrayp ?a) nil))
  (should (eq (arrayp ?\n) nil)))

(ert-deftest arrayp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Arrays (should return t)
           ("string" . t)
           ("" . t)
           ([1 2 3] . t)
           ([] . t)
           (,(make-bool-vector 3 t) . t)
           (,(make-char-table nil) . t)

           ;; Non-arrays (should return nil)
           (nil . nil)
           (t . nil)
           (42 . nil)
           (0 . nil)
           (-42 . nil)
           (,most-positive-fixnum . nil)
           (,(expt 2 100) . nil)
           (3.14 . nil)
           (0.0 . nil)
           (foo . nil)
           (x . nil)
           ((1 2 3) . nil)
           ((1) . nil)
           (() . nil)
           ((1 . 2) . nil)
           (?a . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (arrayp input) expected))))))

(ert-deftest arrayp-channel-a-edge-cases ()
  "Additional edge cases for arrayp."
  ;; Multibyte strings
  (should (eq (arrayp "hello 世界") t))
  (should (eq (arrayp "αβγ") t))

  ;; Nested structures (only top-level matters)
  (should (eq (arrayp [[1 2] [3 4]]) t))
  (should (eq (arrayp ["a" "b"]) t))
  (should (eq (arrayp '([1 2] [3 4])) nil))  ; list of vectors is still a list

  ;; Various non-array objects
  (should (eq (arrayp (current-buffer)) nil))
  (should (eq (arrayp (selected-window)) nil))
  (should (eq (arrayp (point-marker)) nil))
  (should (eq (arrayp (make-hash-table)) nil)))

(provide 'arrayp-channel-a-tests)
;;; arrayp-channel-a-tests.el ends here

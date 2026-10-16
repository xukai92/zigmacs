;;; sequencep-channel-a-tests.el --- Channel A verification for sequencep port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the sequencep Zig port.
;; This is the SEVENTEENTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_sequencep) and the original C implementation
;; (sequencep_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/sequencep-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest sequencep-channel-a-sequences ()
  "Test sequencep on sequence values (should return t)."
  ;; nil (CRITICAL: nil is a sequence - the empty list)
  (should (eq (sequencep nil) t))
  (should (eq (sequencep '()) t))

  ;; Lists
  (should (eq (sequencep '(1)) t))
  (should (eq (sequencep '(1 2 3)) t))
  (should (eq (sequencep '(a b c)) t))
  (should (eq (sequencep '(1 . 2)) t))

  ;; Strings
  (should (eq (sequencep "string") t))
  (should (eq (sequencep "") t))
  (should (eq (sequencep "hello world") t))

  ;; Vectors
  (should (eq (sequencep []) t))
  (should (eq (sequencep [1]) t))
  (should (eq (sequencep [1 2 3]) t))
  (should (eq (sequencep [a b c]) t))

  ;; Bool-vectors
  (should (eq (sequencep (make-bool-vector 0 nil)) t))
  (should (eq (sequencep (make-bool-vector 3 t)) t))

  ;; Char-tables
  (should (eq (sequencep (make-char-table nil)) t)))

(ert-deftest sequencep-channel-a-non-sequences ()
  "Test sequencep on non-sequence values (should return nil)."
  ;; t (CRITICAL: t is NOT a sequence)
  (should (eq (sequencep t) nil))

  ;; Integers
  (should (eq (sequencep 0) nil))
  (should (eq (sequencep 42) nil))
  (should (eq (sequencep -42) nil))
  (should (eq (sequencep most-positive-fixnum) nil))
  (should (eq (sequencep (expt 2 100)) nil))

  ;; Floats
  (should (eq (sequencep 3.14) nil))
  (should (eq (sequencep 0.0) nil))
  (should (eq (sequencep -1.5) nil))

  ;; Symbols (except nil)
  (should (eq (sequencep 'foo) nil))
  (should (eq (sequencep 'some-symbol) nil))
  (should (eq (sequencep 'x) nil))

  ;; Characters
  (should (eq (sequencep ?a) nil))
  (should (eq (sequencep ?\n) nil))

  ;; Records
  (should (eq (sequencep (record 'foo)) nil)))

(ert-deftest sequencep-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Sequences (should return t)
           (nil . t)
           (() . t)
           ((1 2 3) . t)
           ((1) . t)
           ((1 . 2) . t)
           ("string" . t)
           ("" . t)
           ([1 2 3] . t)
           ([] . t)
           (,(make-bool-vector 3 t) . t)
           (,(make-char-table nil) . t)

           ;; Non-sequences (should return nil)
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
           (?a . nil)
           (,(record 'foo) . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (sequencep input) expected))))))

(ert-deftest sequencep-channel-a-edge-cases ()
  "Additional edge cases for sequencep."
  ;; Nested structures
  (should (eq (sequencep '((1 2) (3 4))) t))
  (should (eq (sequencep [[1 2] [3 4]]) t))
  (should (eq (sequencep '([1 2] [3 4])) t))

  ;; Multibyte strings
  (should (eq (sequencep "hello 世界") t))
  (should (eq (sequencep "αβγ") t))

  ;; Large structures
  (should (eq (sequencep (make-list 1000 1)) t))
  (should (eq (sequencep (make-vector 1000 1)) t))

  ;; Various non-sequence objects
  (should (eq (sequencep (current-buffer)) nil))
  (should (eq (sequencep (selected-window)) nil))
  (should (eq (sequencep (point-marker)) nil))
  (should (eq (sequencep (make-hash-table)) nil)))

(provide 'sequencep-channel-a-tests)
;;; sequencep-channel-a-tests.el ends here

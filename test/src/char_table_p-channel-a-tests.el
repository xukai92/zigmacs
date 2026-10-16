;;; char_table_p-channel-a-tests.el --- Channel A verification for char-table-p port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the char-table-p Zig port.
;; This is a Category A port in Zigmacs fanout round #3.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_char_table_p) and the original C implementation
;; (char_table_p_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/char_table_p-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest char-table-p-channel-a-char-tables ()
  "Test char-table-p on char-table values (should return t)."
  ;; Basic char-tables
  (should (eq (char-table-p (make-char-table nil)) t))
  (should (eq (char-table-p (make-char-table 'syntax-table)) t))
  (should (eq (char-table-p (make-char-table 'category-table)) t))
  (should (eq (char-table-p (make-char-table 'case-table)) t)))

(ert-deftest char-table-p-channel-a-non-char-tables ()
  "Test char-table-p on non-char-table values (should return nil)."
  ;; nil and t
  (should (eq (char-table-p nil) nil))
  (should (eq (char-table-p t) nil))

  ;; Integers
  (should (eq (char-table-p 0) nil))
  (should (eq (char-table-p 42) nil))
  (should (eq (char-table-p -42) nil))

  ;; Floats
  (should (eq (char-table-p 3.14) nil))

  ;; Symbols
  (should (eq (char-table-p 'foo) nil))

  ;; Strings
  (should (eq (char-table-p "string") nil))
  (should (eq (char-table-p "") nil))

  ;; Vectors
  (should (eq (char-table-p [1 2 3]) nil))
  (should (eq (char-table-p []) nil))

  ;; Lists
  (should (eq (char-table-p '(1 2 3)) nil))
  (should (eq (char-table-p '()) nil))

  ;; Other types
  (should (eq (char-table-p (current-buffer)) nil))
  (should (eq (char-table-p (point-marker)) nil))
  (should (eq (char-table-p (make-hash-table)) nil))
  (should (eq (char-table-p (make-bool-vector 3 t)) nil)))

(ert-deftest char-table-p-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Char-tables (should return t)
           (,(make-char-table nil) . t)
           (,(make-char-table 'syntax-table) . t)

           ;; Non-char-tables (should return nil)
           (nil . nil)
           (t . nil)
           (42 . nil)
           (0 . nil)
           (3.14 . nil)
           (foo . nil)
           ("string" . nil)
           ([1 2 3] . nil)
           ((1 2 3) . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (char-table-p input) expected))))))

(provide 'char_table_p-channel-a-tests)
;;; char_table_p-channel-a-tests.el ends here

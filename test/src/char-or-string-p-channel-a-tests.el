;;; char-or-string-p-channel-a-tests.el --- Channel A verification for char-or-string-p port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the char-or-string-p Zig port.
;; This is the TWELFTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_char_or_string_p) and the original C implementation
;; (char_or_string_p_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/char-or-string-p-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest char-or-string-p-channel-a-characters ()
  "Test char-or-string-p on characters (should return t).
CRITICAL: characters are represented as fixnums in Emacs Lisp."
  ;; Regular characters
  (should (eq (char-or-string-p ?a) t))
  (should (eq (char-or-string-p ?z) t))
  (should (eq (char-or-string-p ?A) t))
  (should (eq (char-or-string-p ?Z) t))
  (should (eq (char-or-string-p ?0) t))
  (should (eq (char-or-string-p ?9) t))

  ;; Special characters
  (should (eq (char-or-string-p ?\n) t))
  (should (eq (char-or-string-p ?\t) t))
  (should (eq (char-or-string-p ?\r) t))
  (should (eq (char-or-string-p ?\s) t))  ;; space
  (should (eq (char-or-string-p ?\f) t))  ;; form feed
  (should (eq (char-or-string-p ?\b) t))  ;; backspace

  ;; Punctuation
  (should (eq (char-or-string-p ?.) t))
  (should (eq (char-or-string-p ?,) t))
  (should (eq (char-or-string-p ?!) t))
  (should (eq (char-or-string-p ??) t))

  ;; Unicode characters
  (should (eq (char-or-string-p ?λ) t))
  (should (eq (char-or-string-p ?π) t))
  (should (eq (char-or-string-p ?€) t)))

(ert-deftest char-or-string-p-channel-a-strings ()
  "Test char-or-string-p on strings (should return t)."
  ;; Empty string
  (should (eq (char-or-string-p "") t))

  ;; Regular strings
  (should (eq (char-or-string-p "a") t))
  (should (eq (char-or-string-p "foo") t))
  (should (eq (char-or-string-p "bar") t))
  (should (eq (char-or-string-p "string") t))

  ;; Strings with special characters
  (should (eq (char-or-string-p "hello\nworld") t))
  (should (eq (char-or-string-p "tab\there") t))
  (should (eq (char-or-string-p "  spaces  ") t))

  ;; Unicode strings
  (should (eq (char-or-string-p "λ") t))
  (should (eq (char-or-string-p "πr²") t))
  (should (eq (char-or-string-p "€100") t))

  ;; Numeric strings
  (should (eq (char-or-string-p "42") t))
  (should (eq (char-or-string-p "3.14") t))
  (should (eq (char-or-string-p "0") t)))

(ert-deftest char-or-string-p-channel-a-non-char-or-string ()
  "Test char-or-string-p on non-character/non-string values (should return nil).
CRITICAL: characters are integers 0..MAX_CHAR (0x3FFFFF). Negative integers and
integers > MAX_CHAR are NOT characters."
  ;; Integers outside the valid character range (should return nil)
  ;; Negative integers are NOT characters
  (should (eq (char-or-string-p -1) nil))
  (should (eq (char-or-string-p -42) nil))
  (should (eq (char-or-string-p most-negative-fixnum) nil))
  ;; Large integers > MAX_CHAR are NOT characters
  (should (eq (char-or-string-p most-positive-fixnum) nil))
  ;; Bignums are NOT characters
  (should (eq (char-or-string-p (expt 2 100)) nil))

  ;; Floats
  (should (eq (char-or-string-p 0.0) nil))
  (should (eq (char-or-string-p 3.14) nil))
  (should (eq (char-or-string-p -3.14) nil))
  (should (eq (char-or-string-p 1.0e+INF) nil))
  (should (eq (char-or-string-p 0.0e+NaN) nil))

  ;; Symbols
  (should (eq (char-or-string-p nil) nil))
  (should (eq (char-or-string-p t) nil))
  (should (eq (char-or-string-p 'foo) nil))
  (should (eq (char-or-string-p 'x) nil))
  (should (eq (char-or-string-p :keyword) nil))

  ;; Lists
  (should (eq (char-or-string-p '(1 2 3)) nil))
  (should (eq (char-or-string-p '(1)) nil))
  (should (eq (char-or-string-p '()) nil))
  (should (eq (char-or-string-p '(foo bar)) nil))
  (should (eq (char-or-string-p '(1 . 2)) nil))

  ;; Vectors
  (should (eq (char-or-string-p []) nil))
  (should (eq (char-or-string-p [1 2 3]) nil))
  (should (eq (char-or-string-p [foo]) nil)))

(ert-deftest char-or-string-p-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Characters (should return t)
           (?a . t)
           (?z . t)
           (?A . t)
           (?0 . t)
           (?\n . t)
           (?\t . t)
           (?\s . t)
           (?\r . t)
           (?. . t)
           (?! . t)
           (?λ . t)

           ;; Strings (should return t)
           ("" . t)
           ("a" . t)
           ("foo" . t)
           ("bar" . t)
           ("string" . t)
           ("hello\nworld" . t)
           ("42" . t)
           ("3.14" . t)
           ("λ" . t)

           ;; Small non-negative integers are characters (should return t)
           (0 . t)
           (42 . t)
           (100 . t)

           ;; Negative integers and large integers are NOT characters (should return nil)
           (-1 . nil)
           (-42 . nil)
           (,most-positive-fixnum . nil)
           (,most-negative-fixnum . nil)
           (,(expt 2 100) . nil)

           ;; Floats (should return nil)
           (0.0 . nil)
           (3.14 . nil)
           (-3.14 . nil)
           (1.0e+INF . nil)

           ;; Symbols (should return nil)
           (nil . nil)
           (t . nil)
           (foo . nil)
           (x . nil)
           (:keyword . nil)

           ;; Lists (should return nil)
           ((1 2 3) . nil)
           ((1) . nil)
           ((foo bar) . nil)
           ((1 . 2) . nil)

           ;; Vectors (should return nil)
           ([] . nil)
           ([1 2 3] . nil)
           ([foo] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (char-or-string-p input) expected))))))

(ert-deftest char-or-string-p-channel-a-edge-cases ()
  "Additional edge cases for char-or-string-p."
  ;; Various control characters
  (should (eq (char-or-string-p ?\0) t))  ;; null
  (should (eq (char-or-string-p ?\e) t))  ;; escape
  (should (eq (char-or-string-p ?\d) t))  ;; delete

  ;; Long strings
  (should (eq (char-or-string-p (make-string 1000 ?x)) t))

  ;; Very large numbers (not characters)
  (should (eq (char-or-string-p (expt 2 1000)) nil))
  (should (eq (char-or-string-p (- (expt 2 1000))) nil))

  ;; Various non-character/non-string types
  (should (eq (char-or-string-p (current-buffer)) nil))
  (should (eq (char-or-string-p (selected-window)) nil))
  (should (eq (char-or-string-p (point-marker)) nil))
  (should (eq (char-or-string-p (make-hash-table)) nil)))

(provide 'char-or-string-p-channel-a-tests)
;;; char-or-string-p-channel-a-tests.el ends here

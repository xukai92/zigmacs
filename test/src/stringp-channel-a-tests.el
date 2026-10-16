;;; stringp-channel-a-tests.el --- Channel A verification for stringp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the stringp Zig port.
;; This is the SEVENTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_stringp) and the original C implementation
;; (stringp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/stringp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest stringp-channel-a-strings ()
  "Test stringp on strings (should return t)."
  ;; Basic strings
  (should (eq (stringp "s") t))
  (should (eq (stringp "") t))
  (should (eq (stringp "foo") t))
  (should (eq (stringp "string") t))

  ;; Multiline strings
  (should (eq (stringp "multi\nline") t))
  (should (eq (stringp "line1\nline2\nline3") t))

  ;; Unibyte strings
  (should (eq (stringp (string-to-unibyte "test")) t))
  (should (eq (stringp (string-to-unibyte "")) t))

  ;; Multibyte strings (explicit)
  (should (eq (stringp (string-to-multibyte "test")) t)))

(ert-deftest stringp-channel-a-non-strings ()
  "Test stringp on non-string values (should return nil)."
  ;; Numbers
  (should (eq (stringp 0) nil))
  (should (eq (stringp 42) nil))
  (should (eq (stringp -42) nil))
  (should (eq (stringp 3.0) nil))
  (should (eq (stringp 3.14) nil))

  ;; Characters (fixnums)
  (should (eq (stringp ?a) nil))
  (should (eq (stringp ?\n) nil))
  (should (eq (stringp ?\t) nil))

  ;; Symbols (including nil and t)
  (should (eq (stringp 'x) nil))
  (should (eq (stringp 'foo) nil))
  (should (eq (stringp nil) nil))
  (should (eq (stringp t) nil))
  (should (eq (stringp :keyword) nil))

  ;; Lists
  (should (eq (stringp '()) nil))
  (should (eq (stringp '(1)) nil))
  (should (eq (stringp '(1 2 3)) nil))
  (should (eq (stringp '(1 . 2)) nil))

  ;; Vectors
  (should (eq (stringp []) nil))
  (should (eq (stringp [1]) nil))
  (should (eq (stringp [1 2 3]) nil)))

(ert-deftest stringp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Strings (should return t)
           ("s" . t)
           ("" . t)
           ("foo" . t)
           ("multi\nline" . t)
           (,(string-to-unibyte "test") . t)
           (,(string-to-multibyte "test") . t)

           ;; Numbers (should return nil)
           (0 . nil)
           (42 . nil)
           (-42 . nil)
           (,most-positive-fixnum . nil)
           (,most-negative-fixnum . nil)
           (,(expt 2 100) . nil)
           (,(- (expt 2 100)) . nil)
           (3.0 . nil)
           (3.14 . nil)
           (-3.14 . nil)

           ;; Characters (should return nil)
           (?a . nil)
           (?\n . nil)

           ;; Symbols (should return nil)
           (x . nil)
           (foo . nil)
           (nil . nil)
           (t . nil)
           (:keyword . nil)

           ;; Lists (should return nil)
           (() . nil)
           ((1) . nil)
           ((1 2 3) . nil)
           ((1 . 2) . nil)

           ;; Vectors (should return nil)
           ([] . nil)
           ([1] . nil)
           ([1 2 3] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (stringp input) expected))))))

(ert-deftest stringp-channel-a-edge-cases ()
  "Additional edge cases for stringp.
CRITICAL: A symbol whose name is a string should return nil,
because stringp tests the object itself, not its name."
  ;; Symbol with string name (still a symbol, not a string)
  (should (eq (stringp 'x) nil))
  (should (eq (stringp 'foo) nil))
  (should (eq (stringp (intern "test")) nil))

  ;; Other non-string types
  (should (eq (stringp (current-buffer)) nil))
  (should (eq (stringp (selected-window)) nil))
  (should (eq (stringp (point-marker)) nil))
  (should (eq (stringp (make-hash-table)) nil)))

(provide 'stringp-channel-a-tests)
;;; stringp-channel-a-tests.el ends here

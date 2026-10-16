;;; vectorp-channel-a-tests.el --- Channel A verification for vectorp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the vectorp Zig port.
;; This is the NINTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_vectorp) and the original C implementation
;; (vectorp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/vectorp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest vectorp-channel-a-vectors ()
  "Test vectorp on vectors (should return t)."
  ;; Basic vectors
  (should (eq (vectorp [1 2 3]) t))
  (should (eq (vectorp []) t))
  (should (eq (vectorp [1]) t))
  (should (eq (vectorp (make-vector 3 0)) t))
  (should (eq (vectorp (make-vector 0 nil)) t))

  ;; Nested structures
  (should (eq (vectorp [[1 2] [3 4]]) t))
  (should (eq (vectorp [(1 2) (3 4)]) t)))

(ert-deftest vectorp-channel-a-non-vectors ()
  "Test vectorp on non-vector values (should return nil).
CRITICAL: strings, bool-vectors, and char-tables are NOT plain vectors."
  ;; Strings (NOT vectors)
  (should (eq (vectorp "s") nil))
  (should (eq (vectorp "") nil))
  (should (eq (vectorp "foo") nil))

  ;; Bool-vectors (NOT vectors)
  (should (eq (vectorp (make-bool-vector 3 t)) nil))
  (should (eq (vectorp (make-bool-vector 0 nil)) nil))

  ;; Char-tables (NOT vectors)
  (should (eq (vectorp (make-char-table 'test)) nil))

  ;; Lists
  (should (eq (vectorp '(1 2)) nil))
  (should (eq (vectorp '(1 2 3)) nil))
  (should (eq (vectorp nil) nil))
  (should (eq (vectorp '()) nil))

  ;; Numbers
  (should (eq (vectorp 0) nil))
  (should (eq (vectorp 42) nil))
  (should (eq (vectorp -42) nil))
  (should (eq (vectorp 3.0) nil))
  (should (eq (vectorp 3.14) nil))

  ;; Characters (fixnums)
  (should (eq (vectorp ?a) nil))
  (should (eq (vectorp ?\n) nil))

  ;; Symbols
  (should (eq (vectorp 'x) nil))
  (should (eq (vectorp 'foo) nil))
  (should (eq (vectorp t) nil))
  (should (eq (vectorp :keyword) nil)))

(ert-deftest vectorp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Vectors (should return t)
           ([1 2 3] . t)
           ([] . t)
           ([1] . t)
           (,(make-vector 3 0) . t)
           (,(make-vector 0 nil) . t)
           ([[1 2] [3 4]] . t)
           ([(1 2) (3 4)] . t)

           ;; Strings (CRITICAL: should return nil)
           ("s" . nil)
           ("" . nil)
           ("foo" . nil)
           ("multi\nline" . nil)

           ;; Bool-vectors (CRITICAL: should return nil)
           (,(make-bool-vector 3 t) . nil)
           (,(make-bool-vector 0 nil) . nil)

           ;; Char-tables (CRITICAL: should return nil)
           (,(make-char-table 'test) . nil)

           ;; Lists (should return nil)
           ((1 2) . nil)
           ((1 2 3) . nil)
           (nil . nil)
           (() . nil)

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
           (t . nil)
           (:keyword . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (vectorp input) expected))))))

(ert-deftest vectorp-channel-a-edge-cases ()
  "Additional edge cases for vectorp.
CRITICAL: strings, bool-vectors, and char-tables are NOT plain vectors."
  ;; Empty vector
  (should (eq (vectorp []) t))

  ;; Vectors with special values
  (should (eq (vectorp [nil]) t))
  (should (eq (vectorp [t]) t))
  (should (eq (vectorp [nil t]) t))

  ;; String is NOT a vector (despite being array-like)
  (should (eq (vectorp "s") nil))
  (should (eq (vectorp "") nil))

  ;; Bool-vector is NOT a plain vector
  (should (eq (vectorp (make-bool-vector 3 t)) nil))

  ;; Char-table is NOT a plain vector
  (should (eq (vectorp (make-char-table 'test)) nil))

  ;; Other non-vector types
  (should (eq (vectorp (current-buffer)) nil))
  (should (eq (vectorp (selected-window)) nil))
  (should (eq (vectorp (point-marker)) nil))
  (should (eq (vectorp (make-hash-table)) nil)))

(provide 'vectorp-channel-a-tests)
;;; vectorp-channel-a-tests.el ends here

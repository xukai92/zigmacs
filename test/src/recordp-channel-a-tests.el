;;; recordp-channel-a-tests.el --- Channel A verification for recordp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the recordp Zig port.
;; This is the FIFTEENTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_recordp) and the original C implementation
;; (recordp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/recordp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest recordp-channel-a-records ()
  "Test recordp on record values (should return t)."
  ;; Basic records
  (should (eq (recordp (record 'foo)) t))
  (should (eq (recordp (record 'bar 1)) t))
  (should (eq (recordp (record 'baz 1 2 3)) t))
  (should (eq (recordp (record 'test "string" 42)) t))

  ;; Records with various types as fields
  (should (eq (recordp (record 'type nil)) t))
  (should (eq (recordp (record 'type t)) t))
  (should (eq (recordp (record 'type [1 2 3])) t))
  (should (eq (recordp (record 'type '(1 2 3))) t)))

(ert-deftest recordp-channel-a-non-records ()
  "Test recordp on non-record values (should return nil)."
  ;; nil and t
  (should (eq (recordp nil) nil))
  (should (eq (recordp t) nil))

  ;; Integers
  (should (eq (recordp 0) nil))
  (should (eq (recordp 42) nil))
  (should (eq (recordp -42) nil))

  ;; Floats
  (should (eq (recordp 3.14) nil))
  (should (eq (recordp 0.0) nil))

  ;; Symbols
  (should (eq (recordp 'foo) nil))
  (should (eq (recordp 'some-symbol) nil))

  ;; Strings
  (should (eq (recordp "string") nil))
  (should (eq (recordp "") nil))

  ;; Vectors (CRITICAL: vectors are NOT records)
  (should (eq (recordp []) nil))
  (should (eq (recordp [1 2 3]) nil))
  (should (eq (recordp [foo bar]) nil))

  ;; Lists
  (should (eq (recordp '(1 2 3)) nil))
  (should (eq (recordp '(1)) nil))
  (should (eq (recordp '()) nil))
  (should (eq (recordp '(1 . 2)) nil))

  ;; Characters
  (should (eq (recordp ?a) nil)))

(ert-deftest recordp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Records (should return t)
           (,(record 'foo) . t)
           (,(record 'bar 1 2) . t)
           (,(record 'baz "x") . t)

           ;; Non-records (should return nil)
           (nil . nil)
           (t . nil)
           (42 . nil)
           (0 . nil)
           (3.14 . nil)
           (foo . nil)
           ("string" . nil)
           ("" . nil)
           ([1 2 3] . nil)
           ([] . nil)
           ((1 2 3) . nil)
           ((1) . nil)
           (() . nil)
           (?a . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (recordp input) expected))))))

(ert-deftest recordp-channel-a-edge-cases ()
  "Additional edge cases for recordp."
  ;; Records with empty type
  (should (eq (recordp (record '||)) t))

  ;; Records with keyword type
  (should (eq (recordp (record :keyword)) t))

  ;; Various non-record objects
  (should (eq (recordp (current-buffer)) nil))
  (should (eq (recordp (selected-window)) nil))
  (should (eq (recordp (point-marker)) nil))
  (should (eq (recordp (make-hash-table)) nil))
  (should (eq (recordp (make-bool-vector 3 t)) nil))
  (should (eq (recordp (make-char-table nil)) nil)))

(provide 'recordp-channel-a-tests)
;;; recordp-channel-a-tests.el ends here

;;; hash-table-p-channel-a-tests.el --- Channel A verification for hash-table-p port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the hash-table-p Zig port (fanout round #4).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_hash_table_p) and the original C implementation
;; (hash_table_p_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/hash-table-p-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest hash-table-p-channel-a-true ()
  "Test hash-table-p with actual hash tables (returns t)."
  ;; Default hash table
  (should (eq (hash-table-p (make-hash-table)) t))

  ;; Hash table with specific test
  (should (eq (hash-table-p (make-hash-table :test 'eq)) t))
  (should (eq (hash-table-p (make-hash-table :test 'eql)) t))
  (should (eq (hash-table-p (make-hash-table :test 'equal)) t))

  ;; Hash table with size
  (should (eq (hash-table-p (make-hash-table :size 100)) t))

  ;; Hash table with entries
  (let ((ht (make-hash-table)))
    (puthash 'key 'value ht)
    (should (eq (hash-table-p ht) t)))

  ;; Large hash table
  (let ((ht (make-hash-table :size 1000)))
    (dotimes (i 500)
      (puthash i (* i i) ht))
    (should (eq (hash-table-p ht) t))))

(ert-deftest hash-table-p-channel-a-false ()
  "Test hash-table-p with non-hash-table objects (returns nil)."
  ;; nil
  (should (eq (hash-table-p nil) nil))

  ;; Symbols
  (should (eq (hash-table-p 'foo) nil))
  (should (eq (hash-table-p t) nil))

  ;; Numbers
  (should (eq (hash-table-p 0) nil))
  (should (eq (hash-table-p 42) nil))
  (should (eq (hash-table-p -1) nil))
  (should (eq (hash-table-p 3.14) nil))

  ;; Strings
  (should (eq (hash-table-p "") nil))
  (should (eq (hash-table-p "hello") nil))

  ;; Lists
  (should (eq (hash-table-p '()) nil))
  (should (eq (hash-table-p '(a b c)) nil))
  (should (eq (hash-table-p '((a . 1) (b . 2))) nil))

  ;; Vectors
  (should (eq (hash-table-p []) nil))
  (should (eq (hash-table-p [1 2 3]) nil))

  ;; Cons
  (should (eq (hash-table-p '(a . b)) nil))

  ;; Functions
  (should (eq (hash-table-p #'car) nil))
  (should (eq (hash-table-p (lambda () nil)) nil))

  ;; Buffers
  (should (eq (hash-table-p (current-buffer)) nil))

  ;; Windows
  (should (eq (hash-table-p (selected-window)) nil)))

(ert-deftest hash-table-p-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various inputs."
  (let ((test-cases
         ;; Format: (object expected)
         '(;; Hash tables -> t
           ((make-hash-table) t)
           ((make-hash-table :test 'equal) t)

           ;; Non-hash-tables -> nil
           (nil nil)
           (t nil)
           (foo nil)
           (0 nil)
           (42 nil)
           ("string" nil)
           ((a b c) nil)
           ([1 2 3] nil)
           ((a . b) nil))))
    (dolist (case test-cases)
      (let ((object (eval (nth 0 case)))
            (expected (nth 1 case)))
        (should (eq (hash-table-p object) expected))))))

(ert-deftest hash-table-p-channel-a-edge-cases ()
  "Additional edge cases for hash-table-p."
  ;; Empty hash table
  (let ((ht (make-hash-table)))
    (should (eq (hash-table-p ht) t)))

  ;; Hash table after clearing
  (let ((ht (make-hash-table)))
    (puthash 'key 'value ht)
    (clrhash ht)
    (should (eq (hash-table-p ht) t)))

  ;; Hash table with nil values
  (let ((ht (make-hash-table)))
    (puthash 'key nil ht)
    (should (eq (hash-table-p ht) t)))

  ;; Hash table with various key types
  (let ((ht (make-hash-table :test 'equal)))
    (puthash "string" 1 ht)
    (puthash 42 2 ht)
    (puthash 'symbol 3 ht)
    (puthash '(list) 4 ht)
    (should (eq (hash-table-p ht) t))))

(provide 'hash-table-p-channel-a-tests)
;;; hash-table-p-channel-a-tests.el ends here

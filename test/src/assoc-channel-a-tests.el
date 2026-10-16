;;; assoc-channel-a-tests.el --- Channel A verification for assoc port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the assoc Zig port (fanout round #4).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_assoc) and the original C implementation
;; (assoc_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/assoc-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest assoc-channel-a-found ()
  "Test assoc when key is found (returns element)."
  ;; Simple cases with symbols (eq-comparable fast path)
  (should (equal (assoc 'a '((a . 1) (b . 2) (c . 3))) '(a . 1)))
  (should (equal (assoc 'b '((a . 1) (b . 2) (c . 3))) '(b . 2)))
  (should (equal (assoc 'c '((a . 1) (b . 2) (c . 3))) '(c . 3)))

  ;; Fixnums (eq-comparable fast path)
  (should (equal (assoc 1 '((1 . a) (2 . b) (3 . c))) '(1 . a)))
  (should (equal (assoc 2 '((1 . a) (2 . b) (3 . c))) '(2 . b)))

  ;; Strings (equal comparison, not eq)
  (should (equal (assoc "a" '(("a" . 1) ("b" . 2))) '("a" . 1)))
  (should (equal (assoc "key" '(("foo" . x) ("key" . y))) '("key" . y)))

  ;; Lists as keys (equal comparison)
  (should (equal (assoc '(1 2) '(((1 2) . a) ((3 4) . b))) '((1 2) . a))))

(ert-deftest assoc-channel-a-not-found ()
  "Test assoc when key is not found (returns nil)."
  ;; Symbols
  (should (null (assoc 'x '((a . 1) (b . 2) (c . 3)))))
  (should (null (assoc 'foo '((bar . 1) (baz . 2)))))

  ;; Fixnums
  (should (null (assoc 9 '((1 . a) (2 . b) (3 . c)))))

  ;; Strings
  (should (null (assoc "x" '(("a" . 1) ("b" . 2)))))

  ;; Lists
  (should (null (assoc '(5 6) '(((1 2) . a) ((3 4) . b)))))

  ;; Empty alist
  (should (null (assoc 'a nil)))
  (should (null (assoc "x" '())))
  (should (null (assoc 1 nil))))

(ert-deftest assoc-channel-a-equal-vs-eq ()
  "Test that assoc uses equal (or eq for symbols/fixnums), not just eq."
  ;; Strings: different string objects with same content are equal
  (should (equal (assoc "a" '(("x" . 1) ("a" . 2))) '("a" . 2)))

  ;; Lists: different list objects with same content are equal
  (should (equal (assoc '(1 2) '(((3 4) . a) ((1 2) . b))) '((1 2) . b)))

  ;; But symbols and fixnums use the fast eq path (via assq)
  (should (equal (assoc 'a '((x . 1) (a . 2))) '(a . 2)))
  (should (equal (assoc 42 '((1 . x) (42 . y))) '(42 . y))))

(ert-deftest assoc-channel-a-testfn ()
  "Test assoc with custom test function."
  ;; Custom testfn: string-equal (case-insensitive)
  (should (equal (assoc "A" '(("a" . 1) ("b" . 2)) #'string-equal) '("a" . 1)))
  (should (equal (assoc "B" '(("a" . 1) ("b" . 2)) #'string-equal) '("b" . 2)))
  (should (null (assoc "X" '(("a" . 1) ("b" . 2)) #'string-equal)))

  ;; Custom testfn: eq (should behave like assq for symbols)
  (should (equal (assoc 'a '((a . 1) (b . 2)) #'eq) '(a . 1)))

  ;; Custom testfn: equal (should behave like default assoc)
  (should (equal (assoc "a" '(("a" . 1) ("b" . 2)) #'equal) '("a" . 1))))

(ert-deftest assoc-channel-a-non-cons-elements ()
  "Test that assoc ignores non-cons elements in alist."
  ;; Alist with non-cons elements
  (should (equal (assoc 'a '((a . 1) not-a-cons (b . 2))) '(a . 1)))
  (should (equal (assoc 'b '((a . 1) not-a-cons (b . 2))) '(b . 2)))
  (should (null (assoc 'x '((a . 1) not-a-cons (b . 2)))))

  ;; Only non-cons elements
  (should (null (assoc 'a '(not-a-cons also-not 123))))

  ;; nil as element (non-cons)
  (should (equal (assoc 'a '((a . 1) nil (b . 2))) '(a . 1))))

(ert-deftest assoc-channel-a-improper-lists ()
  "Test assoc on improper lists (should signal error when traversing past element)."
  ;; If key is found, no error
  (should (equal (assoc 'a '((a . 1) . b)) '(a . 1)))

  ;; If key is not found, error when encountering improper tail
  (should-error (assoc 'x '((a . 1) (b . 2) . c)) :type 'wrong-type-argument)
  (should-error (assoc "x" '(("a" . 1) . b)) :type 'wrong-type-argument))

(ert-deftest assoc-channel-a-circular-lists ()
  "Test assoc on circular lists (should signal error or handle correctly)."
  ;; Circular alist with key present
  (let ((circular (list '(a . 1) '(b . 2) '(c . 3))))
    (setcdr (last circular) circular)
    ;; Finding a key that exists should work
    (should (equal (assoc 'a circular) '(a . 1)))
    (should (equal (assoc 'b circular) '(b . 2)))
    ;; Finding a non-existent key should signal circular-list error
    (should-error (assoc 'x circular) :type 'circular-list)))

(ert-deftest assoc-channel-a-special-values ()
  "Test assoc with special values."
  ;; nil as key
  (should (equal (assoc nil '((a . 1) (nil . 2) (b . 3))) '(nil . 2)))
  (should (null (assoc nil '((a . 1) (b . 2)))))

  ;; t as key
  (should (equal (assoc t '((nil . 1) (t . 2))) '(t . 2)))

  ;; Keywords
  (should (equal (assoc :foo '((:bar . 1) (:foo . 2))) '(:foo . 2)))

  ;; Numbers (fixnums)
  (should (equal (assoc 0 '((1 . a) (0 . b))) '(0 . b)))
  (should (equal (assoc -1 '((0 . a) (-1 . b))) '(-1 . b))))

(ert-deftest assoc-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various inputs."
  (let ((test-cases
         ;; Format: (key alist testfn expected)
         '(;; Symbols (eq fast path, no testfn)
           (a ((a . 1) (b . 2)) nil (a . 1))
           (b ((a . 1) (b . 2)) nil (b . 2))
           (x ((a . 1) (b . 2)) nil nil)

           ;; Fixnums (eq fast path, no testfn)
           (1 ((1 . a) (2 . b)) nil (1 . a))
           (2 ((1 . a) (2 . b)) nil (2 . b))
           (9 ((1 . a) (2 . b)) nil nil)

           ;; Strings (equal comparison, no testfn)
           ("a" (("a" . 1) ("b" . 2)) nil ("a" . 1))
           ("b" (("a" . 1) ("b" . 2)) nil ("b" . 2))
           ("x" (("a" . 1) ("b" . 2)) nil nil)

           ;; Lists (equal comparison, no testfn)
           ((1 2) (((1 2) . a) ((3 4) . b)) nil ((1 2) . a))
           ((3 4) (((1 2) . a) ((3 4) . b)) nil ((3 4) . b))
           ((5 6) (((1 2) . a) ((3 4) . b)) nil nil)

           ;; Empty alist
           (a nil nil nil))))
    (dolist (case test-cases)
      (let ((key (nth 0 case))
            (alist (nth 1 case))
            (testfn (nth 2 case))
            (expected (nth 3 case)))
        (should (equal (assoc key alist testfn) expected))))))

(ert-deftest assoc-channel-a-edge-cases ()
  "Additional edge cases for assoc."
  ;; Multiple entries with same key (returns first match)
  (should (equal (assoc 'a '((a . 1) (a . 2) (a . 3))) '(a . 1)))
  (should (equal (assoc "a" '(("a" . 1) ("a" . 2))) '("a" . 1)))

  ;; Nested structures as values
  (should (equal (assoc 'key '((key . (nested value)) (other . x)))
                 '(key . (nested value)))))

(provide 'assoc-channel-a-tests)
;;; assoc-channel-a-tests.el ends here

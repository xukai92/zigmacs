;;; member-channel-a-tests.el --- Channel A verification for member port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the member Zig port (fanout round #4).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_member) and the original C implementation
;; (member_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/member-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest member-channel-a-found ()
  "Test member when element is found (returns tail)."
  ;; Simple cases with symbols (eq-comparable fast path)
  (should (equal (member 'a '(a b c)) '(a b c)))
  (should (equal (member 'b '(a b c)) '(b c)))
  (should (equal (member 'c '(a b c)) '(c)))

  ;; Fixnums (eq-comparable fast path)
  (should (equal (member 1 '(1 2 3)) '(1 2 3)))
  (should (equal (member 2 '(1 2 3)) '(2 3)))

  ;; Strings (equal comparison, not eq)
  (should (equal (member "a" '("x" "a" "b")) '("a" "b")))
  (should (equal (member "hello" '("world" "hello" "there")) '("hello" "there")))

  ;; Lists (equal comparison)
  (should (equal (member '(1 2) '((3 4) (1 2) (5 6))) '((1 2) (5 6)))))

(ert-deftest member-channel-a-not-found ()
  "Test member when element is not found (returns nil)."
  ;; Symbols
  (should (null (member 'x '(a b c))))
  (should (null (member 'foo '(bar baz))))

  ;; Fixnums
  (should (null (member 1 '(2 3 4))))
  (should (null (member 0 '(1 2 3))))

  ;; Strings
  (should (null (member "x" '("a" "b" "c"))))

  ;; Lists
  (should (null (member '(1 2) '((3 4) (5 6)))))

  ;; Empty list
  (should (null (member 'a nil)))
  (should (null (member "x" '())))
  (should (null (member 1 nil))))

(ert-deftest member-channel-a-equal-vs-eq ()
  "Test that member uses equal, not eq."
  ;; Strings: different string objects with same content are equal
  (should (equal (member "a" '("x" "a" "b")) '("a" "b")))

  ;; Lists: different list objects with same content are equal
  (should (equal (member '(1 2) '((3 4) (1 2) (5 6))) '((1 2) (5 6))))

  ;; But symbols and fixnums use the fast eq path
  (should (equal (member 'a '(x a b)) '(a b)))
  (should (equal (member 42 '(1 42 3)) '(42 3))))

(ert-deftest member-channel-a-improper-lists ()
  "Test member on improper lists (should signal error when traversing past element)."
  ;; If element is found, no error
  (should (equal (member 'a '(a . b)) '(a . b)))
  (should (equal (member "a" '("a" . b)) '("a" . b)))

  ;; If element is not found, error when encountering improper tail
  (should-error (member 'x '(a b . c)) :type 'wrong-type-argument)
  (should-error (member "x" '("a" "b" . c)) :type 'wrong-type-argument)
  (should-error (member 1 '(2 3 . 4)) :type 'wrong-type-argument))

(ert-deftest member-channel-a-circular-lists ()
  "Test member on circular lists (should signal error or handle correctly)."
  ;; Circular list with element present
  (let ((circular (list 'a 'b 'c)))
    (setcdr (last circular) circular)
    ;; Finding an element that exists should work
    (should (equal (member 'a circular) circular))
    (should (equal (member 'b circular) (cdr circular)))
    ;; Finding a non-existent element should signal circular-list error
    (should-error (member 'x circular) :type 'circular-list))

  ;; With strings (equal comparison)
  (let ((circular (list "a" "b" "c")))
    (setcdr (last circular) circular)
    (should (equal (member "a" circular) circular))
    (should-error (member "x" circular) :type 'circular-list)))

(ert-deftest member-channel-a-special-values ()
  "Test member with special values."
  ;; nil as element
  (should (equal (member nil '(a nil b)) '(nil b)))
  (should (null (member nil '(a b c))))

  ;; t as element
  (should (equal (member t '(nil t 1)) '(t 1)))
  (should (null (member t '(nil 1 2))))

  ;; Keywords
  (should (equal (member :foo '(:bar :foo :baz)) '(:foo :baz)))

  ;; Numbers (fixnums)
  (should (equal (member 0 '(1 0 2)) '(0 2)))
  (should (equal (member -1 '(0 -1 1)) '(-1 1))))

(ert-deftest member-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various inputs."
  (let ((test-cases
         ;; Format: (elt list expected-tail-or-nil)
         '(;; Symbols (eq fast path)
           (a (a b c) (a b c))
           (b (a b c) (b c))
           (x (a b c) nil)

           ;; Fixnums (eq fast path)
           (1 (1 2 3) (1 2 3))
           (2 (1 2 3) (2 3))
           (9 (1 2 3) nil)

           ;; Strings (equal comparison)
           ("a" ("a" "b" "c") ("a" "b" "c"))
           ("b" ("a" "b" "c") ("b" "c"))
           ("x" ("a" "b" "c") nil)

           ;; Lists (equal comparison)
           ((1 2) ((1 2) (3 4)) ((1 2) (3 4)))
           ((3 4) ((1 2) (3 4)) ((3 4)))
           ((5 6) ((1 2) (3 4)) nil)

           ;; Empty list
           (a nil nil)
           ("x" nil nil))))
    (dolist (case test-cases)
      (let ((elt (nth 0 case))
            (list (nth 1 case))
            (expected (nth 2 case)))
        (should (equal (member elt list) expected))))))

(ert-deftest member-channel-a-edge-cases ()
  "Additional edge cases for member."
  ;; Multiple occurrences (returns first match)
  (should (equal (member 'a '(x a b a c)) '(a b a c)))
  (should (equal (member "a" '("x" "a" "b" "a")) '("a" "b" "a")))

  ;; Nested structures
  (should (equal (member '(a (b c)) '((x y) (a (b c)) (d e)))
                 '((a (b c)) (d e)))))

(provide 'member-channel-a-tests)
;;; member-channel-a-tests.el ends here

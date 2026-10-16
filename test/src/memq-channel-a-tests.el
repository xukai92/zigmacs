;;; memq-channel-a-tests.el --- Channel A verification for memq port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the memq Zig port (Cat-B #2).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_memq) and the original C implementation
;; (memq_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/memq-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest memq-channel-a-found ()
  "Test memq when element is found (returns tail)."
  ;; Simple cases
  (should (equal (memq 'a '(a b c)) '(a b c)))
  (should (equal (memq 'b '(a b c)) '(b c)))
  (should (equal (memq 'c '(a b c)) '(c)))

  ;; First element
  (should (equal (memq 1 '(1 2 3)) '(1 2 3)))

  ;; Last element
  (should (equal (memq 3 '(1 2 3)) '(3)))

  ;; Middle element
  (should (equal (memq 2 '(1 2 3)) '(2 3)))

  ;; Multiple occurrences (returns first match)
  (should (equal (memq 'x '(a x b x c)) '(x b x c)))

  ;; Symbol identity (eq comparison)
  (let ((sym1 'foo)
        (sym2 'foo))  ; Same symbol
    (should (equal (memq sym1 (list 'a sym2 'b)) (list sym2 'b)))))

(ert-deftest memq-channel-a-not-found ()
  "Test memq when element is not found (returns nil)."
  ;; Not in list
  (should (null (memq 'x '(a b c))))
  (should (null (memq 1 '(2 3 4))))
  (should (null (memq 'foo '(bar baz))))

  ;; Empty list
  (should (null (memq 'a nil)))
  (should (null (memq 1 nil)))
  (should (null (memq 'x '()))))

(ert-deftest memq-channel-a-eq-vs-equal ()
  "Test that memq uses eq, not equal."
  ;; Strings: memq uses eq, so different string objects are not equal
  (should (null (memq "a" '("a" "b" "c"))))

  ;; But if it's the same object (eq), it's found
  (let ((str "hello"))
    (should (equal (memq str (list "foo" str "bar")) (list str "bar"))))

  ;; Lists: memq uses eq
  (should (null (memq '(1 2) '((1 2) (3 4)))))

  ;; But if it's the same list object
  (let ((lst '(1 2)))
    (should (equal (memq lst (list '(0) lst '(3))) (list lst '(3)))))

  ;; Numbers: fixnums use eq
  (should (equal (memq 42 '(1 42 3)) '(42 3)))

  ;; nil and t
  (should (equal (memq nil '(a nil b)) '(nil b)))
  (should (equal (memq t '(nil t 1)) '(t 1))))

(ert-deftest memq-channel-a-improper-lists ()
  "Test memq on improper lists (should signal error when traversing past element)."
  ;; If element is found, no error (returns tail even if improper)
  (should (equal (memq 'a '(a . b)) '(a . b)))
  (should (equal (memq 'b '(a b . c)) '(b . c)))

  ;; If element is not found, error when encountering improper tail
  (should-error (memq 'x '(a b . c)) :type 'wrong-type-argument)
  (should-error (memq 'x '(a . b)) :type 'wrong-type-argument)
  (should-error (memq 'c '(a b . c)) :type 'wrong-type-argument))

(ert-deftest memq-channel-a-circular-lists ()
  "Test memq on circular lists (should signal error or handle correctly)."
  ;; Circular list with element present
  (let ((circular (list 'a 'b 'c)))
    (setcdr (last circular) circular)
    ;; Finding an element that exists should work
    (should (equal (memq 'a circular) circular))
    (should (equal (memq 'b circular) (cdr circular)))
    ;; Finding a non-existent element should signal circular-list error
    (should-error (memq 'x circular) :type 'circular-list))

  ;; Single-element circular list
  (let ((circular (list 'a)))
    (setcdr circular circular)
    (should (equal (memq 'a circular) circular))
    (should-error (memq 'b circular) :type 'circular-list)))

(ert-deftest memq-channel-a-special-values ()
  "Test memq with special values."
  ;; nil as element
  (should (equal (memq nil '(a nil b)) '(nil b)))
  (should (null (memq nil '(a b c))))

  ;; t as element
  (should (equal (memq t '(nil t 1)) '(t 1)))
  (should (null (memq t '(nil 1 2))))

  ;; Keywords
  (should (equal (memq :foo '(:bar :foo :baz)) '(:foo :baz)))

  ;; Numbers (fixnums)
  (should (equal (memq 0 '(1 0 2)) '(0 2)))
  (should (equal (memq -1 '(0 -1 1)) '(-1 1))))

(ert-deftest memq-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various inputs."
  (let ((test-cases
         ;; Format: (elt list expected-tail-or-nil-or-error)
         '(;; Found cases
           (a (a b c) (a b c))
           (b (a b c) (b c))
           (c (a b c) (c))
           (1 (1 2 3) (1 2 3))

           ;; Not found cases
           (x (a b c) nil)
           (1 (2 3 4) nil)
           (foo () nil)
           (a nil nil)

           ;; Special values
           (nil (a nil b) (nil b))
           (t (nil t 1) (t 1))

           ;; Long list
           (x (a b c d e f g h i j k l m n o p q r s t u v w x y z)
              (x y z)))))
    (dolist (case test-cases)
      (let ((elt (nth 0 case))
            (list (nth 1 case))
            (expected (nth 2 case)))
        (if (eq expected 'error)
            (should-error (memq elt list))
          (should (equal (memq elt list) expected)))))))

(ert-deftest memq-channel-a-edge-cases ()
  "Additional edge cases for memq."
  ;; Element appears multiple times
  (should (equal (memq 'a '(a a a)) '(a a a)))
  (should (equal (memq 'a '(b a a)) '(a a)))

  ;; List with duplicate elements
  (should (equal (memq 2 '(1 2 2 3)) '(2 2 3)))

  ;; Very long list
  (let ((long-list (make-list 1000 'x)))
    (setcar (nthcdr 500 long-list) 'target)
    (should (equal (length (memq 'target long-list)) 500))))

(provide 'memq-channel-a-tests)
;;; memq-channel-a-tests.el ends here

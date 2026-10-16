;;; assq-channel-a-tests.el --- Channel A verification for assq port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the assq Zig port (Cat-B #3).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_assq) and the original C implementation
;; (assq_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/assq-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest assq-channel-a-found ()
  "Test assq when key is found (returns cons cell)."
  ;; Simple cases
  (should (equal (assq 'a '((a . 1) (b . 2) (c . 3))) '(a . 1)))
  (should (equal (assq 'b '((a . 1) (b . 2) (c . 3))) '(b . 2)))
  (should (equal (assq 'c '((a . 1) (b . 2) (c . 3))) '(c . 3)))

  ;; First element
  (should (equal (assq 'foo '((foo . bar) (baz . qux))) '(foo . bar)))

  ;; Last element
  (should (equal (assq 'baz '((foo . bar) (baz . qux))) '(baz . qux)))

  ;; Multiple occurrences (returns first match)
  (should (equal (assq 'x '((a . 1) (x . 2) (x . 3))) '(x . 2)))

  ;; Association with list value
  (should (equal (assq 'key '((key 1 2 3) (other 4 5))) '(key 1 2 3))))

(ert-deftest assq-channel-a-not-found ()
  "Test assq when key is not found (returns nil)."
  ;; Not in alist
  (should (null (assq 'x '((a . 1) (b . 2) (c . 3)))))
  (should (null (assq 'foo '((bar . 1) (baz . 2)))))

  ;; Empty alist
  (should (null (assq 'a nil)))
  (should (null (assq 'x '()))))

(ert-deftest assq-channel-a-eq-comparison ()
  "Test that assq uses eq for key comparison."
  ;; Symbol identity (eq works for interned symbols)
  (let ((key 'foo))
    (should (equal (assq key '((foo . 1) (bar . 2))) '(foo . 1))))

  ;; Strings: eq doesn't work for different string objects
  (should (null (assq "key" '(("key" . 1) ("other" . 2)))))

  ;; But if it's the same string object
  (let ((str "key"))
    (should (equal (assq str (list (cons str 1) (cons "other" 2)))
                   (cons str 1))))

  ;; Numbers: fixnums use eq
  (should (equal (assq 1 '((1 . a) (2 . b))) '(1 . a)))
  (should (equal (assq 42 '((0 . x) (42 . y) (100 . z))) '(42 . y))))

(ert-deftest assq-channel-a-non-cons-elements ()
  "Test that assq ignores non-cons elements in alist."
  ;; Non-cons elements are ignored
  (should (equal (assq 'a '(not-a-cons (a . 1) also-not (b . 2)))
                 '(a . 1)))
  (should (equal (assq 'b '(123 "string" (b . 2) foo))
                 '(b . 2)))

  ;; Only non-cons elements
  (should (null (assq 'x '(1 2 3 "foo" bar))))

  ;; nil is ignored as a non-cons
  (should (equal (assq 'a '(nil (a . 1) nil (b . 2))) '(a . 1))))

(ert-deftest assq-channel-a-improper-lists ()
  "Test assq on improper lists (should signal error)."
  ;; Improper alist
  (should-error (assq 'x '((a . 1) (b . 2) . c))
                :type 'wrong-type-argument)

  ;; Key not found before improper tail
  (should-error (assq 'x '((a . 1) . b))
                :type 'wrong-type-argument))

(ert-deftest assq-channel-a-circular-alists ()
  "Test assq on circular alists."
  ;; Circular alist with key present
  (let ((circular '((a . 1) (b . 2))))
    (setcdr (last circular) circular)
    ;; Finding existing key should work
    (should (equal (assq 'a circular) '(a . 1)))
    (should (equal (assq 'b circular) '(b . 2)))
    ;; Finding non-existent key should signal circular-list error
    (should-error (assq 'x circular) :type 'circular-list))

  ;; Single-element circular alist
  (let ((circular (list (cons 'key 'value))))
    (setcdr circular circular)
    (should (equal (assq 'key circular) '(key . value)))
    (should-error (assq 'other circular) :type 'circular-list)))

(ert-deftest assq-channel-a-special-values ()
  "Test assq with special values as keys."
  ;; nil as key
  (should (equal (assq nil '((nil . foo) (a . bar))) '(nil . foo)))
  (should (null (assq nil '((a . 1) (b . 2)))))

  ;; t as key
  (should (equal (assq t '((t . true) (nil . false))) '(t . true)))

  ;; Keywords as keys
  (should (equal (assq :foo '((:bar . 1) (:foo . 2))) '(:foo . 2)))

  ;; Zero as key
  (should (equal (assq 0 '((0 . zero) (1 . one))) '(0 . zero))))

(ert-deftest assq-channel-a-association-values ()
  "Test assq with various association value types."
  ;; Simple values
  (should (equal (assq 'a '((a . 1))) '(a . 1)))
  (should (equal (assq 'b '((b . "string"))) '(b . "string")))

  ;; List values (not just dotted pairs)
  (should (equal (assq 'x '((x 1 2 3))) '(x 1 2 3)))
  (should (equal (assq 'y '((y))) '(y)))

  ;; nil as value
  (should (equal (assq 'a '((a . nil) (b . 2))) '(a . nil)))
  (should (equal (assq 'a '((a) (b . 2))) '(a)))

  ;; Nested structures as values
  (should (equal (assq 'a '((a (1 2 (3 4))))) '(a (1 2 (3 4))))))

(ert-deftest assq-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various inputs."
  (let ((test-cases
         ;; Format: (key alist expected-result-or-nil)
         '(;; Found cases
           (a ((a . 1) (b . 2)) (a . 1))
           (b ((a . 1) (b . 2)) (b . 2))
           (c ((a . 1) (b . 2) (c . 3)) (c . 3))

           ;; Not found cases
           (x ((a . 1) (b . 2)) nil)
           (foo () nil)
           (a nil nil)

           ;; Non-cons elements ignored
           (a (1 2 (a . 1) 3) (a . 1))
           (b ("foo" nil (b . 2)) (b . 2))

           ;; Special keys
           (nil ((nil . foo)) (nil . foo))
           (t ((t . bar)) (t . bar))
           (0 ((0 . zero)) (0 . zero))

           ;; Multiple occurrences (first wins)
           (x ((x . 1) (x . 2)) (x . 1))

           ;; List values
           (a ((a 1 2 3)) (a 1 2 3)))))
    (dolist (case test-cases)
      (let ((key (nth 0 case))
            (alist (nth 1 case))
            (expected (nth 2 case)))
        (should (equal (assq key alist) expected))))))

(ert-deftest assq-channel-a-edge-cases ()
  "Additional edge cases for assq."
  ;; Key appears multiple times (first wins)
  (should (equal (assq 'x '((x . first) (x . second) (x . third)))
                 '(x . first)))

  ;; Very long alist
  (let ((long-alist (mapcar (lambda (n) (cons n (* n 10)))
                            (number-sequence 0 999))))
    (should (equal (assq 500 long-alist) '(500 . 5000)))
    (should (equal (assq 0 long-alist) '(0 . 0)))
    (should (equal (assq 999 long-alist) '(999 . 9990))))

  ;; Alist with cons cells as values
  (should (equal (assq 'a '((a (b . c)))) '(a (b . c))))

  ;; Empty associations
  (should (equal (assq 'a '((a))) '(a))))

(provide 'assq-channel-a-tests)
;;; assq-channel-a-tests.el ends here

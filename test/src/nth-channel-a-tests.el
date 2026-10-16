;;; nth-channel-a-tests.el --- Channel A verification for nth port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the nth Zig port (Cat-B fanout #2).
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_nth) and the original C implementation
;; (nth_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/nth-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest nth-channel-a-basic ()
  "Test nth with basic inputs."
  ;; Valid indices
  (should (equal (nth 0 '(a b c)) 'a))
  (should (equal (nth 1 '(a b c)) 'b))
  (should (equal (nth 2 '(a b c)) 'c))

  ;; First element
  (should (equal (nth 0 '(1 2 3)) 1))

  ;; Last element
  (should (equal (nth 2 '(1 2 3)) 3))

  ;; Single-element list
  (should (equal (nth 0 '(x)) 'x)))

(ert-deftest nth-channel-a-out-of-range ()
  "Test nth with out-of-range indices (returns nil)."
  ;; Index too large (returns nil, not error)
  (should (null (nth 3 '(a b c))))
  (should (null (nth 10 '(a b c))))
  (should (null (nth 100 '(1 2 3))))

  ;; Index on empty list
  (should (null (nth 0 nil)))
  (should (null (nth 1 nil)))
  (should (null (nth 0 '())))

  ;; Very large index
  (should (null (nth 1000 '(a)))))

(ert-deftest nth-channel-a-special-values ()
  "Test nth with special values."
  ;; nil as element
  (should (null (nth 0 '(nil))))
  (should (null (nth 1 '(a nil b))))

  ;; t as element
  (should (equal (nth 0 '(t)) t))
  (should (equal (nth 1 '(a t b)) t))

  ;; Keywords
  (should (equal (nth 1 '(:foo :bar :baz)) :bar))

  ;; Numbers
  (should (equal (nth 2 '(10 20 30 40)) 30))
  (should (equal (nth 0 '(0)) 0)))

(ert-deftest nth-channel-a-improper-lists ()
  "Test nth on improper lists."
  ;; If element is found before improper tail, should work
  (should (equal (nth 0 '(a . b)) 'a))
  (should (equal (nth 0 '(a b . c)) 'a))
  (should (equal (nth 1 '(a b . c)) 'b))

  ;; If traversal reaches improper tail, signals error
  (should-error (nth 2 '(a b . c)) :type 'wrong-type-argument)
  (should-error (nth 1 '(a . b)) :type 'wrong-type-argument))

(ert-deftest nth-channel-a-circular-lists ()
  "Test nth on circular lists."
  ;; Circular list with element reachable
  (let ((circular (list 'a 'b 'c)))
    (setcdr (last circular) circular)
    (should (equal (nth 0 circular) 'a))
    (should (equal (nth 1 circular) 'b))
    (should (equal (nth 2 circular) 'c))
    ;; Index beyond distinct elements triggers circular-list error
    (should-error (nth 10 circular) :type 'circular-list)))

(ert-deftest nth-channel-a-invalid-n ()
  "Test nth with invalid N (non-integer)."
  ;; nth requires N to be an integer
  (should-error (nth 'a '(1 2 3)) :type 'wrong-type-argument)
  (should-error (nth "0" '(1 2 3)) :type 'wrong-type-argument)
  (should-error (nth nil '(1 2 3)) :type 'wrong-type-argument)
  (should-error (nth '(0) '(1 2 3)) :type 'wrong-type-argument))

(ert-deftest nth-channel-a-negative-n ()
  "Test nth with negative N."
  ;; Negative N is handled by nthcdr (signals error)
  (should-error (nth -1 '(a b c)) :type 'args-out-of-range))

(ert-deftest nth-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various inputs."
  (let ((test-cases
         ;; Format: (n list expected-result-or-error)
         '(;; Valid cases
           (0 (a b c) a)
           (1 (a b c) b)
           (2 (a b c) c)
           (0 (1 2 3) 1)
           (2 (10 20 30 40) 30)

           ;; Out of range (returns nil)
           (3 (a b c) nil)
           (10 (a b c) nil)
           (0 nil nil)
           (0 () nil)

           ;; Special values
           (0 (nil) nil)
           (0 (t) t)
           (1 (:foo :bar :baz) :bar)

           ;; Single element
           (0 (x) x)
           (1 (x) nil))))
    (dolist (case test-cases)
      (let ((n (nth 0 case))
            (list (nth 1 case))
            (expected (nth 2 case)))
        (if (eq expected 'error)
            (should-error (nth n list))
          (should (equal (nth n list) expected)))))))

(ert-deftest nth-channel-a-long-lists ()
  "Test nth on long lists."
  ;; Long list
  (let ((long-list (number-sequence 0 999)))
    (should (equal (nth 0 long-list) 0))
    (should (equal (nth 500 long-list) 500))
    (should (equal (nth 999 long-list) 999))
    (should (null (nth 1000 long-list)))))

(provide 'nth-channel-a-tests)
;;; nth-channel-a-tests.el ends here

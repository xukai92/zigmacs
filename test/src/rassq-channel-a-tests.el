;;; rassq-channel-a-tests.el --- ERT tests for rassq (Channel A)  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Free Software Foundation, Inc.

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

;; Channel A (A/B parity) tests for the Zig port of `rassq'.
;; These tests verify that the Zig implementation matches upstream Emacs
;; behavior exactly (bug-for-bug compatibility).

;;; Code:

(require 'ert)

(ert-deftest rassq-channel-a-basic ()
  "Test rassq with basic alists."
  (let ((alist '((a . 1) (b . 2) (c . 3))))
    (should (equal (rassq 1 alist) '(a . 1)))
    (should (equal (rassq 2 alist) '(b . 2)))
    (should (equal (rassq 3 alist) '(c . 3)))
    (should (eq (rassq 4 alist) nil))))

(ert-deftest rassq-channel-a-nil ()
  "Test rassq with nil (empty alist)."
  (should (eq (rassq 'x nil) nil))
  (should (eq (rassq 1 nil) nil)))

(ert-deftest rassq-channel-a-symbols ()
  "Test rassq with symbol values."
  (let ((alist '((x . foo) (y . bar) (z . baz))))
    (should (equal (rassq 'foo alist) '(x . foo)))
    (should (equal (rassq 'bar alist) '(y . bar)))
    (should (eq (rassq 'qux alist) nil))))

(ert-deftest rassq-channel-a-first-match ()
  "Test rassq returns the first match when multiple exist."
  (let ((alist '((a . x) (b . x) (c . y))))
    (should (equal (rassq 'x alist) '(a . x)))))

(ert-deftest rassq-channel-a-non-cons-elements ()
  "Test rassq ignores non-cons elements in alist."
  (let ((alist '((a . 1) not-a-cons (b . 2) another-non-cons (c . 3))))
    (should (equal (rassq 2 alist) '(b . 2)))
    (should (eq (rassq 'not-a-cons alist) nil))))

(ert-deftest rassq-channel-a-eq-semantics ()
  "Test rassq uses eq comparison (not equal)."
  (let ((alist '((a . (1 2)) (b . (3 4)))))
    ;; Different list objects with same content should not match
    (should (eq (rassq '(1 2) alist) nil))
    ;; But the same object should match
    (let ((val (car (cdar alist))))
      (should (equal (rassq (cdr (car alist)) alist) '(a . (1 2)))))))

(ert-deftest rassq-channel-a-improper-list ()
  "Test rassq signals error on improper lists."
  (let ((improper '((a . 1) (b . 2) . not-nil)))
    (should-error (rassq 1 improper) :type 'wrong-type-argument)))

(ert-deftest rassq-channel-a-circular-list ()
  "Test rassq signals error on circular lists."
  (let ((circular (list '(a . 1) '(b . 2))))
    (setcdr (last circular) circular)
    (should-error (rassq 3 circular) :type 'circular-list)))

(ert-deftest rassq-channel-a-nested ()
  "Test rassq with nested structures."
  (let ((alist '((x . (a b)) (y . (c d)))))
    ;; Test that eq comparison is used for nested lists
    (let ((target (cdr (cadr alist))))
      (should (equal (rassq target alist) '(y . (c d)))))))

(provide 'rassq-channel-a-tests)
;;; rassq-channel-a-tests.el ends here

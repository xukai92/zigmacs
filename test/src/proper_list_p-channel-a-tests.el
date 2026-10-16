;;; proper_list_p-channel-a-tests.el --- ERT tests for proper-list-p (Channel A)  -*- lexical-binding: t; -*-

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

;; Channel A (A/B parity) tests for the Zig port of `proper-list-p'.
;; These tests verify that the Zig implementation matches upstream Emacs
;; behavior exactly (bug-for-bug compatibility).

;;; Code:

(require 'ert)

(ert-deftest proper-list-p-channel-a-nil ()
  "Test proper-list-p with nil (empty list)."
  (should (eq (proper-list-p nil) 0)))

(ert-deftest proper-list-p-channel-a-proper-lists ()
  "Test proper-list-p with proper lists."
  (should (eq (proper-list-p '(a)) 1))
  (should (eq (proper-list-p '(a b)) 2))
  (should (eq (proper-list-p '(a b c)) 3))
  (should (eq (proper-list-p '(1 2 3 4 5)) 5)))

(ert-deftest proper-list-p-channel-a-dotted ()
  "Test proper-list-p with dotted (improper) lists."
  (should (eq (proper-list-p '(a . b)) nil))
  (should (eq (proper-list-p '(a b . c)) nil))
  (should (eq (proper-list-p (cons 1 2)) nil)))

(ert-deftest proper-list-p-channel-a-non-lists ()
  "Test proper-list-p with non-list objects."
  (should (eq (proper-list-p 5) nil))
  (should (eq (proper-list-p "abc") nil))
  (should (eq (proper-list-p [a b c]) nil))
  (should (eq (proper-list-p 'symbol) nil))
  (should (eq (proper-list-p t) nil)))

(ert-deftest proper-list-p-channel-a-circular ()
  "Test proper-list-p with circular lists."
  (let ((circular (list 'a 'b 'c)))
    (setcdr (last circular) circular)
    (should (eq (proper-list-p circular) nil))))

(ert-deftest proper-list-p-channel-a-nested ()
  "Test proper-list-p with nested lists (still proper)."
  (should (eq (proper-list-p '((a b) (c d))) 2))
  (should (eq (proper-list-p '(1 (2 3) 4)) 3)))

(ert-deftest proper-list-p-channel-a-long-list ()
  "Test proper-list-p with a long list."
  (let ((long-list (number-sequence 1 1000)))
    (should (eq (proper-list-p long-list) 1000))))

(provide 'proper_list_p-channel-a-tests)
;;; proper_list_p-channel-a-tests.el ends here

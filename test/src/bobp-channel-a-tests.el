;;; bobp-channel-a-tests.el --- Channel A tests for bobp -*- lexical-binding: t; -*-

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

;; Channel A tests for bobp (beginning-of-buffer-p predicate).
;; Tests various buffer configurations and point positions.

;;; Code:

(require 'ert)

(ert-deftest bobp-empty-buffer ()
  "Test bobp in an empty buffer."
  (with-temp-buffer
    (should (bobp))))

(ert-deftest bobp-at-beginning ()
  "Test bobp at the beginning of a buffer with content."
  (with-temp-buffer
    (insert "hello world")
    (goto-char (point-min))
    (should (bobp))))

(ert-deftest bobp-not-at-beginning ()
  "Test bobp when not at the beginning."
  (with-temp-buffer
    (insert "hello world")
    (goto-char 5)
    (should-not (bobp))))

(ert-deftest bobp-at-end ()
  "Test bobp at the end of buffer."
  (with-temp-buffer
    (insert "hello world")
    (goto-char (point-max))
    (should-not (bobp))))

(ert-deftest bobp-narrowed-at-beginning ()
  "Test bobp in a narrowed buffer at the beginning."
  (with-temp-buffer
    (insert "hello world")
    (narrow-to-region 3 8)
    (goto-char (point-min))
    (should (bobp))))

(ert-deftest bobp-narrowed-not-at-beginning ()
  "Test bobp in a narrowed buffer not at the beginning."
  (with-temp-buffer
    (insert "hello world")
    (narrow-to-region 3 8)
    (goto-char 5)
    (should-not (bobp))))

(ert-deftest bobp-multiline ()
  "Test bobp with multiline content."
  (with-temp-buffer
    (insert "line1\nline2\nline3")
    (goto-char (point-min))
    (should (bobp))
    (forward-char 1)
    (should-not (bobp))))

(provide 'bobp-channel-a-tests)
;;; bobp-channel-a-tests.el ends here

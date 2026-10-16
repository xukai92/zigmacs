;;; eobp-channel-a-tests.el --- Channel A tests for eobp -*- lexical-binding: t; -*-

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

;; Channel A tests for eobp (end-of-buffer-p predicate).
;; Tests various buffer configurations and point positions.

;;; Code:

(require 'ert)

(ert-deftest eobp-empty-buffer ()
  "Test eobp in an empty buffer."
  (with-temp-buffer
    (should (eobp))))

(ert-deftest eobp-at-end ()
  "Test eobp at the end of a buffer with content."
  (with-temp-buffer
    (insert "hello world")
    (goto-char (point-max))
    (should (eobp))))

(ert-deftest eobp-not-at-end ()
  "Test eobp when not at the end."
  (with-temp-buffer
    (insert "hello world")
    (goto-char 5)
    (should-not (eobp))))

(ert-deftest eobp-at-beginning ()
  "Test eobp at the beginning of buffer."
  (with-temp-buffer
    (insert "hello world")
    (goto-char (point-min))
    (should-not (eobp))))

(ert-deftest eobp-narrowed-at-end ()
  "Test eobp in a narrowed buffer at the end."
  (with-temp-buffer
    (insert "hello world")
    (narrow-to-region 3 8)
    (goto-char (point-max))
    (should (eobp))))

(ert-deftest eobp-narrowed-not-at-end ()
  "Test eobp in a narrowed buffer not at the end."
  (with-temp-buffer
    (insert "hello world")
    (narrow-to-region 3 8)
    (goto-char 5)
    (should-not (eobp))))

(ert-deftest eobp-multiline ()
  "Test eobp with multiline content."
  (with-temp-buffer
    (insert "line1\nline2\nline3")
    (goto-char (point-max))
    (should (eobp))
    (backward-char 1)
    (should-not (eobp))))

(provide 'eobp-channel-a-tests)
;;; eobp-channel-a-tests.el ends here

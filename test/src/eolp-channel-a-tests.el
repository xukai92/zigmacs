;;; eolp-channel-a-tests.el --- Channel A tests for eolp -*- lexical-binding: t; -*-

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

;; Channel A tests for eolp (end-of-line-p predicate).
;; Tests various line positions and buffer states.

;;; Code:

(require 'ert)

(ert-deftest eolp-empty-buffer ()
  "Test eolp in an empty buffer."
  (with-temp-buffer
    (should (eolp))))

(ert-deftest eolp-at-end-of-buffer ()
  "Test eolp at the end of buffer (which is also end of line)."
  (with-temp-buffer
    (insert "hello world")
    (goto-char (point-max))
    (should (eolp))))

(ert-deftest eolp-at-newline ()
  "Test eolp at a newline."
  (with-temp-buffer
    (insert "line1\nline2")
    (goto-char 6)  ; At the newline
    (should (eolp))))

(ert-deftest eolp-mid-line ()
  "Test eolp in the middle of a line."
  (with-temp-buffer
    (insert "hello world")
    (goto-char 5)
    (should-not (eolp))))

(ert-deftest eolp-at-beginning-of-line ()
  "Test eolp at the beginning of a line."
  (with-temp-buffer
    (insert "line1\nline2")
    (goto-char 7)  ; Right after the newline (start of line2)
    (should-not (eolp))))

(ert-deftest eolp-multiline-ends ()
  "Test eolp at the end of various lines."
  (with-temp-buffer
    (insert "line1\nline2\nline3")
    (goto-char 6)   ; End of line1 (at newline)
    (should (eolp))
    (goto-char 12)  ; End of line2 (at newline)
    (should (eolp))
    (goto-char (point-max))  ; End of line3 (at buffer end)
    (should (eolp))))

(ert-deftest eolp-narrowed ()
  "Test eolp in a narrowed buffer."
  (with-temp-buffer
    (insert "aaaa\nbbbb\ncccc")
    (narrow-to-region 6 14)  ; From 'b' to 'c'
    (goto-char (point-max))
    (should (eolp))))

(ert-deftest eolp-empty-line ()
  "Test eolp on an empty line."
  (with-temp-buffer
    (insert "line1\n\nline3")
    (goto-char 7)  ; At the second newline (empty line)
    (should (eolp))))

(provide 'eolp-channel-a-tests)
;;; eolp-channel-a-tests.el ends here

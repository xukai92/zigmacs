;;; bolp-channel-a-tests.el --- Channel A tests for bolp -*- lexical-binding: t; -*-

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

;; Channel A tests for bolp (beginning-of-line-p predicate).
;; Tests various line positions and buffer states.

;;; Code:

(require 'ert)

(ert-deftest bolp-empty-buffer ()
  "Test bolp in an empty buffer."
  (with-temp-buffer
    (should (bolp))))

(ert-deftest bolp-at-beginning-of-buffer ()
  "Test bolp at the beginning of buffer (which is also beginning of line)."
  (with-temp-buffer
    (insert "hello world")
    (goto-char (point-min))
    (should (bolp))))

(ert-deftest bolp-after-newline ()
  "Test bolp right after a newline."
  (with-temp-buffer
    (insert "line1\nline2")
    (goto-char 7)  ; Right after the newline
    (should (bolp))))

(ert-deftest bolp-mid-line ()
  "Test bolp in the middle of a line."
  (with-temp-buffer
    (insert "hello world")
    (goto-char 5)
    (should-not (bolp))))

(ert-deftest bolp-at-end-of-line ()
  "Test bolp at the end of a line (before newline)."
  (with-temp-buffer
    (insert "line1\nline2")
    (goto-char 6)  ; At the newline
    (should-not (bolp))))

(ert-deftest bolp-multiline-start ()
  "Test bolp at the start of various lines."
  (with-temp-buffer
    (insert "line1\nline2\nline3")
    (goto-char (point-min))
    (should (bolp))
    (goto-char 7)  ; Start of line2
    (should (bolp))
    (goto-char 13) ; Start of line3
    (should (bolp))))

(ert-deftest bolp-narrowed ()
  "Test bolp in a narrowed buffer."
  (with-temp-buffer
    (insert "aaaa\nbbbb\ncccc")
    (narrow-to-region 6 14)  ; From 'b' to 'c'
    (goto-char (point-min))
    (should (bolp))))

(ert-deftest bolp-after-empty-line ()
  "Test bolp after an empty line."
  (with-temp-buffer
    (insert "line1\n\nline3")
    (goto-char 7)  ; After first newline
    (should (bolp))
    (goto-char 8)  ; After second newline (empty line)
    (should (bolp))))

(provide 'bolp-channel-a-tests)
;;; bolp-channel-a-tests.el ends here

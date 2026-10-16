;;; end-of-line-channel-a-tests.el --- Channel A tests for end-of-line  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the Zig port of end-of-line.
;; Run with ZIGMACS_AB=1 to enable A/B comparison mode.
;;
;; end-of-line is a STATEFUL primitive (mutates point) — the Channel A
;; dispatcher uses snapshot→replay to compare C vs Zig implementations.
;; On mismatch, emacs_abort is called (uncatchable).
;;
;; end-of-line always returns nil.

;;; Code:

(require 'ert)

(ert-deftest end-of-line-channel-a/basic ()
  "Test basic end-of-line movement."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char 3)  ; somewhere in line1
    (should (= (point) 3))
    (end-of-line)
    (should (= (point) 6))))

(ert-deftest end-of-line-channel-a/nil-arg ()
  "Test end-of-line with nil arg (defaults to 1)."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char 3)
    (end-of-line)
    (should (= (point) 6))))

(ert-deftest end-of-line-channel-a/explicit-1 ()
  "Test end-of-line with explicit argument 1."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char 3)
    (end-of-line 1)
    (should (= (point) 6))))

(ert-deftest end-of-line-channel-a/arg-2 ()
  "Test end-of-line with argument 2."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char 3)  ; in line1
    (end-of-line 2)
    (should (= (point) 12))))  ; end of line2

(ert-deftest end-of-line-channel-a/arg-0 ()
  "Test end-of-line with argument 0."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char 10)  ; in line2
    (end-of-line 0)
    (should (= (point) 6))))  ; end of line1

(ert-deftest end-of-line-channel-a/negative ()
  "Test end-of-line with negative argument."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char 10)  ; in line2
    (end-of-line -1)
    (should (= (point) 1))))  ; moves to beginning (clamped)

(ert-deftest end-of-line-channel-a/narrowed ()
  "Test end-of-line in narrowed buffer."
  (with-temp-buffer
    (insert "line1\nline2\nline3\nline4\n")
    (narrow-to-region 7 19)  ; "line2\nline3\n"
    (goto-char 10)
    (end-of-line)
    (should (= (point) 12))))

(ert-deftest end-of-line-channel-a/at-eol ()
  "Test end-of-line when already at end."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char 6)  ; already at eol
    (end-of-line)
    (should (= (point) 6))))

(ert-deftest end-of-line-channel-a/empty-buffer ()
  "Test end-of-line in empty buffer."
  (with-temp-buffer
    (end-of-line)
    (should (= (point) 1))))

(ert-deftest end-of-line-channel-a/empty-lines ()
  "Test end-of-line with empty lines."
  (with-temp-buffer
    (insert "line1\n\n\nline2\n")
    (goto-char 8)  ; in the empty lines
    (end-of-line)
    (should (= (point) 8))))

(ert-deftest end-of-line-channel-a/no-trailing-newline ()
  "Test end-of-line with no trailing newline."
  (with-temp-buffer
    (insert "line1\nline2")  ; no trailing newline
    (goto-char 1)
    (end-of-line)
    (should (= (point) 6))
    (end-of-line 2)
    (should (= (point) 12))))

(ert-deftest end-of-line-channel-a/multiline ()
  "Test end-of-line with multiple movements."
  (with-temp-buffer
    (dotimes (_ 20)
      (insert "line\n"))
    (goto-char 3)
    (end-of-line)
    (let ((pos (point)))
      (goto-char (point-min))
      (end-of-line 3)
      (should (> (point) pos)))))

(ert-deftest end-of-line-channel-a/boundary ()
  "Test end-of-line at buffer boundaries."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char (point-min))
    (end-of-line)
    (should (= (point) 6))
    (goto-char (point-max))
    (end-of-line)
    (should (= (point) (point-max)))))

(provide 'end-of-line-channel-a-tests)
;;; end-of-line-channel-a-tests.el ends here

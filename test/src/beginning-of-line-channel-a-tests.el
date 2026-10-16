;;; beginning-of-line-channel-a-tests.el --- Channel A tests for beginning-of-line  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the Zig port of beginning-of-line.
;; Run with ZIGMACS_AB=1 to enable A/B comparison mode.
;;
;; beginning-of-line is a STATEFUL primitive (mutates point) — the Channel A
;; dispatcher uses snapshot→replay to compare C vs Zig implementations.
;; On mismatch, emacs_abort is called (uncatchable).
;;
;; beginning-of-line always returns nil.

;;; Code:

(require 'ert)

(ert-deftest beginning-of-line-channel-a/basic ()
  "Test basic beginning-of-line movement."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char 10)  ; somewhere in line2
    (should (= (point) 10))
    (beginning-of-line)
    (should (= (point) 7))))

(ert-deftest beginning-of-line-channel-a/nil-arg ()
  "Test beginning-of-line with nil arg (defaults to 1)."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char 10)
    (beginning-of-line)
    (should (= (point) 7))))

(ert-deftest beginning-of-line-channel-a/explicit-1 ()
  "Test beginning-of-line with explicit argument 1."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char 10)
    (beginning-of-line 1)
    (should (= (point) 7))))

(ert-deftest beginning-of-line-channel-a/arg-2 ()
  "Test beginning-of-line with argument 2."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char 3)  ; in line1
    (beginning-of-line 2)
    (should (= (point) 7))))  ; beginning of line2

(ert-deftest beginning-of-line-channel-a/arg-0 ()
  "Test beginning-of-line with argument 0."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char 10)  ; in line2
    (beginning-of-line 0)
    (should (= (point) 1))))  ; beginning of line1

(ert-deftest beginning-of-line-channel-a/negative ()
  "Test beginning-of-line with negative argument."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char 10)  ; in line2
    (beginning-of-line -1)
    (should (= (point) 1))))  ; beginning of line1

(ert-deftest beginning-of-line-channel-a/narrowed ()
  "Test beginning-of-line in narrowed buffer."
  (with-temp-buffer
    (insert "line1\nline2\nline3\nline4\n")
    (narrow-to-region 7 19)  ; "line2\nline3\n"
    (goto-char 10)
    (beginning-of-line)
    (should (= (point) 7))))

(ert-deftest beginning-of-line-channel-a/at-bol ()
  "Test beginning-of-line when already at beginning."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char 7)  ; already at bol
    (beginning-of-line)
    (should (= (point) 7))))

(ert-deftest beginning-of-line-channel-a/empty-buffer ()
  "Test beginning-of-line in empty buffer."
  (with-temp-buffer
    (beginning-of-line)
    (should (= (point) 1))))

(ert-deftest beginning-of-line-channel-a/empty-lines ()
  "Test beginning-of-line with empty lines."
  (with-temp-buffer
    (insert "line1\n\n\nline2\n")
    (goto-char 8)  ; second empty line
    (beginning-of-line)
    (should (= (point) 8))))

(ert-deftest beginning-of-line-channel-a/multiline ()
  "Test beginning-of-line with multiple movements."
  (with-temp-buffer
    (dotimes (_ 20)
      (insert "line\n"))
    (goto-char 50)
    (beginning-of-line)
    (let ((pos (point)))
      (beginning-of-line 3)
      (should (> (point) pos)))))

(ert-deftest beginning-of-line-channel-a/boundary ()
  "Test beginning-of-line at buffer boundaries."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char (point-min))
    (beginning-of-line)
    (should (= (point) 1))
    (goto-char (point-max))
    (beginning-of-line)
    (should (= (point) 13))))

(provide 'beginning-of-line-channel-a-tests)
;;; beginning-of-line-channel-a-tests.el ends here

;;; forward-line-channel-a-tests.el --- Channel A tests for forward-line  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the Zig port of forward-line.
;; Run with ZIGMACS_AB=1 to enable A/B comparison mode.
;;
;; forward-line is a STATEFUL primitive (mutates point) — the Channel A
;; dispatcher uses snapshot→replay to compare C vs Zig implementations.
;; On mismatch, emacs_abort is called (uncatchable).
;;
;; forward-line returns the count of lines left to move (0 on full success).

;;; Code:

(require 'ert)

(ert-deftest forward-line-channel-a/basic ()
  "Test basic forward line movement."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char (point-min))
    (should (= (point) 1))
    (should (= (forward-line 1) 0))
    (should (= (point) 7))
    (should (= (forward-line 1) 0))
    (should (= (point) 13))))

(ert-deftest forward-line-channel-a/nil-arg ()
  "Test forward-line with nil arg (defaults to 1)."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char (point-min))
    (should (= (forward-line) 0))
    (should (= (point) 7))))

(ert-deftest forward-line-channel-a/negative ()
  "Test backward line movement with negative arg."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char (point-max))
    (should (= (forward-line -1) 0))
    (should (= (point) 13))
    (should (= (forward-line -1) 0))
    (should (= (point) 7))))

(ert-deftest forward-line-channel-a/partial ()
  "Test partial movement (shortage)."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char (point-min))
    ;; Try to move 5 lines, but only 2 exist
    (let ((shortage (forward-line 5)))
      (should (> shortage 0))
      (should (= (point) (point-max))))))

(ert-deftest forward-line-channel-a/zero ()
  "Test movement to beginning of current line."
  (with-temp-buffer
    (insert "line1\nline2\nline3\n")
    (goto-char 10)  ; somewhere in line2
    (should (= (forward-line 0) 0))
    (should (= (point) 7))))

(ert-deftest forward-line-channel-a/narrowed ()
  "Test movement in narrowed buffer."
  (with-temp-buffer
    (insert "line1\nline2\nline3\nline4\n")
    (narrow-to-region 7 19)  ; "line2\nline3\n"
    (goto-char (point-min))
    (should (= (forward-line 1) 0))
    (should (= (point) 13))))

(ert-deftest forward-line-channel-a/end-of-buffer ()
  "Test movement at end of buffer."
  (with-temp-buffer
    (insert "line1\nline2")  ; no trailing newline
    (goto-char (point-min))
    (should (= (forward-line 1) 0))
    (should (= (point) 7))
    ;; Exception: non-empty line at end counts as one line moved
    (should (= (forward-line 1) 0))
    (should (= (point) 12))))

(ert-deftest forward-line-channel-a/beginning-of-buffer ()
  "Test backward movement at beginning."
  (with-temp-buffer
    (insert "line1\nline2\n")
    (goto-char (point-min))
    (let ((shortage (forward-line -1)))
      (should (< shortage 0))
      (should (= (point) 1)))))

(ert-deftest forward-line-channel-a/multiline ()
  "Test large movements."
  (with-temp-buffer
    (dotimes (_ 20)
      (insert "line\n"))
    (goto-char (point-min))
    (should (= (forward-line 10) 0))
    (should (= (forward-line -5) 0))
    (should (= (forward-line 3) 0))))

(ert-deftest forward-line-channel-a/empty-lines ()
  "Test movement over empty lines."
  (with-temp-buffer
    (insert "line1\n\n\nline2\n")
    (goto-char (point-min))
    (should (= (forward-line 1) 0))
    (should (= (point) 7))
    (should (= (forward-line 1) 0))
    (should (= (point) 8))
    (should (= (forward-line 1) 0))
    (should (= (point) 9))))

(provide 'forward-line-channel-a-tests)
;;; forward-line-channel-a-tests.el ends here

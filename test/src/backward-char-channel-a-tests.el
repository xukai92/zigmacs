;;; backward-char-channel-a-tests.el --- Channel A tests for backward-char  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the Zig port of backward-char.
;; Run with ZIGMACS_AB=1 to enable A/B comparison mode.
;;
;; backward-char is a STATEFUL primitive (mutates point) — the Channel A
;; dispatcher uses snapshot→replay to compare C vs Zig implementations.
;; On mismatch, emacs_abort is called (uncatchable).
;;
;; Tests exercise in-bounds moves (both C and Zig run and post-PT is compared).
;; Edge moves that signal errors are wrapped in should-error.

;;; Code:

(require 'ert)

(ert-deftest backward-char-channel-a/basic ()
  "Test basic backward movement in a buffer."
  (with-temp-buffer
    (insert "hello world")
    (goto-char (point-max))
    (should (= (point) 12))
    (backward-char 1)
    (should (= (point) 11))
    (backward-char 3)
    (should (= (point) 8))
    (backward-char)  ; nil defaults to 1
    (should (= (point) 7))))

(ert-deftest backward-char-channel-a/negative ()
  "Test forward movement with negative arg."
  (with-temp-buffer
    (insert "hello")
    (goto-char (point-min))
    (should (= (point) 1))
    (backward-char -2)
    (should (= (point) 3))
    (backward-char -1)
    (should (= (point) 4))))

(ert-deftest backward-char-channel-a/multiline ()
  "Test movement across multiple lines."
  (with-temp-buffer
    (insert "line1\nline2\nline3")
    (goto-char (point-max))
    (backward-char 5)  ; from end to start of "line3"
    (should (= (point) 13))
    (backward-char 1)  ; cross newline
    (should (= (point) 12))
    (backward-char 5)  ; to start of "line2"
    (should (= (point) 7))))

(ert-deftest backward-char-channel-a/narrowed ()
  "Test movement in narrowed buffer."
  (with-temp-buffer
    (insert "abcdefghij")
    (narrow-to-region 3 8)  ; "cdefg"
    (goto-char (point-max))
    (should (= (point) 8))
    (backward-char 2)
    (should (= (point) 6))
    (backward-char 3)
    (should (= (point) 3))))

(ert-deftest backward-char-channel-a/zero ()
  "Test movement by zero (should be no-op)."
  (with-temp-buffer
    (insert "hello")
    (goto-char 3)
    (backward-char 0)
    (should (= (point) 3))))

(ert-deftest backward-char-channel-a/edge-cases ()
  "Test edge cases that signal errors."
  (with-temp-buffer
    (insert "hello")
    ;; At beginning, backward move signals
    (goto-char (point-min))
    (should-error (backward-char 1) :type 'beginning-of-buffer)
    ;; At end, forward move signals
    (goto-char (point-max))
    (should-error (backward-char -1) :type 'end-of-buffer)))

(ert-deftest backward-char-channel-a/large-values ()
  "Test with large movement values."
  (with-temp-buffer
    (insert (make-string 1000 ?x))
    (goto-char (point-max))
    (backward-char 500)
    (should (= (point) 501))
    (backward-char -250)
    (should (= (point) 751))))

(provide 'backward-char-channel-a-tests)
;;; backward-char-channel-a-tests.el ends here

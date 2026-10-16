;;; bufferp-channel-a-tests.el --- Channel A verification for bufferp port  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Free Software Foundation, Inc.

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

;; Channel A verification tests for the bufferp Zig port.
;; This is a Category A port in Zigmacs fanout round #3.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_bufferp) and the original C implementation
;; (bufferp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/bufferp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest bufferp-channel-a-buffers ()
  "Test bufferp on buffer values (should return t)."
  ;; Current buffer
  (should (eq (bufferp (current-buffer)) t))

  ;; Named buffers
  (should (eq (bufferp (get-buffer-create "*test-buffer*")) t))
  (with-temp-buffer
    (should (eq (bufferp (current-buffer)) t)))

  ;; Scratch buffer
  (should (eq (bufferp (get-buffer "*scratch*")) t)))

(ert-deftest bufferp-channel-a-non-buffers ()
  "Test bufferp on non-buffer values (should return nil)."
  ;; nil and t
  (should (eq (bufferp nil) nil))
  (should (eq (bufferp t) nil))

  ;; Integers
  (should (eq (bufferp 0) nil))
  (should (eq (bufferp 42) nil))

  ;; Floats
  (should (eq (bufferp 3.14) nil))

  ;; Symbols
  (should (eq (bufferp 'foo) nil))

  ;; Strings (buffer names, but not buffers)
  (should (eq (bufferp "string") nil))
  (should (eq (bufferp "*scratch*") nil))

  ;; Vectors
  (should (eq (bufferp [1 2 3]) nil))

  ;; Lists
  (should (eq (bufferp '(1 2 3)) nil))

  ;; Other types
  (should (eq (bufferp (make-marker)) nil))
  (should (eq (bufferp (make-hash-table)) nil))
  (should (eq (bufferp (make-char-table nil)) nil)))

(ert-deftest bufferp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Buffers (should return t)
           (,(current-buffer) . t)
           (,(get-buffer-create "*test-battery*") . t)

           ;; Non-buffers (should return nil)
           (nil . nil)
           (t . nil)
           (0 . nil)
           (42 . nil)
           (3.14 . nil)
           (foo . nil)
           ("string" . nil)
           ("*scratch*" . nil)
           ([1 2 3] . nil)
           ((1 2 3) . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (bufferp input) expected))))))

(provide 'bufferp-channel-a-tests)
;;; bufferp-channel-a-tests.el ends here

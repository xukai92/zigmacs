;;; markerp-channel-a-tests.el --- Channel A verification for markerp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the markerp Zig port.
;; This is a Category A port in Zigmacs fanout round #3.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_markerp) and the original C implementation
;; (markerp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/markerp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest markerp-channel-a-markers ()
  "Test markerp on marker values (should return t)."
  ;; Basic markers
  (should (eq (markerp (make-marker)) t))
  (should (eq (markerp (point-marker)) t))
  (should (eq (markerp (point-min-marker)) t))
  (should (eq (markerp (point-max-marker)) t))
  (should (eq (markerp (copy-marker (point))) t)))

(ert-deftest markerp-channel-a-non-markers ()
  "Test markerp on non-marker values (should return nil)."
  ;; nil and t
  (should (eq (markerp nil) nil))
  (should (eq (markerp t) nil))

  ;; Integers (positions, but not markers)
  (should (eq (markerp 0) nil))
  (should (eq (markerp 1) nil))
  (should (eq (markerp 42) nil))
  (should (eq (markerp (point)) nil))

  ;; Floats
  (should (eq (markerp 3.14) nil))

  ;; Symbols
  (should (eq (markerp 'foo) nil))

  ;; Strings
  (should (eq (markerp "string") nil))

  ;; Vectors
  (should (eq (markerp [1 2 3]) nil))

  ;; Lists
  (should (eq (markerp '(1 2 3)) nil))

  ;; Other types
  (should (eq (markerp (current-buffer)) nil))
  (should (eq (markerp (make-hash-table)) nil))
  (should (eq (markerp (make-char-table nil)) nil)))

(ert-deftest markerp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Markers (should return t)
           (,(make-marker) . t)
           (,(point-marker) . t)

           ;; Non-markers (should return nil)
           (nil . nil)
           (t . nil)
           (0 . nil)
           (42 . nil)
           (3.14 . nil)
           (foo . nil)
           ("string" . nil)
           ([1 2 3] . nil)
           ((1 2 3) . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (markerp input) expected))))))

(provide 'markerp-channel-a-tests)
;;; markerp-channel-a-tests.el ends here

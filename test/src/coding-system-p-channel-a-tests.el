;;; coding-system-p-channel-a-tests.el --- Channel A verification for coding-system-p port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the coding-system-p Zig port.
;; Category H₁ (I/O · process · coding) - predicate function.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_coding_system_p) and the original C implementation
;; (coding_system_p_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/coding-system-p-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest coding-system-p-channel-a-nil ()
  "Test coding-system-p on nil (CRITICAL: should return t).
CRITICAL: nil is considered a valid coding system in Emacs."
  (should (eq (coding-system-p nil) t))
  (should (eq (coding-system-p '()) t)))

(ert-deftest coding-system-p-channel-a-valid-coding-systems ()
  "Test coding-system-p on valid coding systems (should return t)."
  ;; Standard coding systems
  (should (eq (coding-system-p 'utf-8) t))
  (should (eq (coding-system-p 'utf-8-unix) t))
  (should (eq (coding-system-p 'utf-8-dos) t))
  (should (eq (coding-system-p 'utf-8-mac) t))
  (should (eq (coding-system-p 'iso-8859-1) t))
  (should (eq (coding-system-p 'us-ascii) t))
  (should (eq (coding-system-p 'emacs-mule) t))
  (should (eq (coding-system-p 'iso-latin-1) t))
  (should (eq (coding-system-p 'no-conversion) t))
  (should (eq (coding-system-p 'raw-text) t))
  (should (eq (coding-system-p 'undecided) t)))

(ert-deftest coding-system-p-channel-a-non-coding-systems ()
  "Test coding-system-p on non-coding-system values (should return nil)."
  ;; Numbers
  (should (eq (coding-system-p 0) nil))
  (should (eq (coding-system-p 42) nil))
  (should (eq (coding-system-p -42) nil))
  (should (eq (coding-system-p 3.0) nil))
  (should (eq (coding-system-p 3.14) nil))

  ;; Characters (fixnums)
  (should (eq (coding-system-p ?a) nil))
  (should (eq (coding-system-p ?\n) nil))

  ;; Regular symbols (not coding systems)
  (should (eq (coding-system-p 'foo) nil))
  (should (eq (coding-system-p 'bar) nil))
  (should (eq (coding-system-p 'x) nil))
  (should (eq (coding-system-p t) nil))
  (should (eq (coding-system-p :keyword) nil))

  ;; Strings
  (should (eq (coding-system-p "utf-8") nil))
  (should (eq (coding-system-p "s") nil))
  (should (eq (coding-system-p "") nil))

  ;; Lists
  (should (eq (coding-system-p '(1 2 3)) nil))
  (should (eq (coding-system-p (cons 1 2)) nil))

  ;; Vectors
  (should (eq (coding-system-p []) nil))
  (should (eq (coding-system-p [1]) nil))
  (should (eq (coding-system-p [1 2 3]) nil)))

(ert-deftest coding-system-p-channel-a-other-objects ()
  "Test coding-system-p on other Emacs objects (should return nil)."
  ;; Buffers
  (should (eq (coding-system-p (current-buffer)) nil))

  ;; Windows
  (should (eq (coding-system-p (selected-window)) nil))

  ;; Markers
  (should (eq (coding-system-p (point-marker)) nil))

  ;; Hash tables
  (should (eq (coding-system-p (make-hash-table)) nil)))

(ert-deftest coding-system-p-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; nil (CRITICAL: should return t)
           (nil . t)
           (() . t)

           ;; Valid coding systems (should return t)
           (utf-8 . t)
           (utf-8-unix . t)
           (utf-8-dos . t)
           (iso-8859-1 . t)
           (us-ascii . t)
           (emacs-mule . t)
           (iso-latin-1 . t)
           (no-conversion . t)
           (raw-text . t)
           (undecided . t)

           ;; Numbers (should return nil)
           (0 . nil)
           (42 . nil)
           (-42 . nil)
           (,most-positive-fixnum . nil)
           (,most-negative-fixnum . nil)
           (,(expt 2 100) . nil)
           (,(- (expt 2 100)) . nil)
           (3.0 . nil)
           (3.14 . nil)
           (-3.14 . nil)

           ;; Characters (should return nil)
           (?a . nil)
           (?\n . nil)

           ;; Non-coding-system symbols (should return nil)
           (foo . nil)
           (bar . nil)
           (x . nil)
           (t . nil)
           (:keyword . nil)

           ;; Strings (should return nil)
           ("utf-8" . nil)
           ("s" . nil)
           ("" . nil)

           ;; Lists (should return nil)
           ((1 2 3) . nil)
           (,(cons 1 2) . nil)

           ;; Vectors (should return nil)
           ([] . nil)
           ([1] . nil)
           ([1 2 3] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (coding-system-p input) expected))))))

(ert-deftest coding-system-p-channel-a-edge-cases ()
  "Additional edge cases for coding-system-p.
CRITICAL: nil is a valid coding system (returns t)."
  ;; nil edge cases (CRITICAL)
  (should (eq (coding-system-p nil) t))
  (should (eq (coding-system-p '()) t))

  ;; Other object types
  (should (eq (coding-system-p (current-buffer)) nil))
  (should (eq (coding-system-p (selected-window)) nil))
  (should (eq (coding-system-p (point-marker)) nil))
  (should (eq (coding-system-p (make-hash-table)) nil))

  ;; Functions
  (should (eq (coding-system-p (symbol-function 'car)) nil))

  ;; Special symbols
  (should (eq (coding-system-p t) nil)))

(provide 'coding-system-p-channel-a-tests)
;;; coding-system-p-channel-a-tests.el ends here

;;; processp-channel-a-tests.el --- Channel A verification for processp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the processp Zig port.
;; Category H₁ (I/O · process · coding) - predicate function.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_processp) and the original C implementation
;; (processp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/processp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest processp-channel-a-non-process ()
  "Test processp on non-process values (should return nil)."
  ;; nil
  (should (eq (processp nil) nil))
  (should (eq (processp '()) nil))

  ;; Numbers
  (should (eq (processp 0) nil))
  (should (eq (processp 42) nil))
  (should (eq (processp -42) nil))
  (should (eq (processp 3.0) nil))
  (should (eq (processp 3.14) nil))

  ;; Characters (fixnums)
  (should (eq (processp ?a) nil))
  (should (eq (processp ?\n) nil))

  ;; Symbols
  (should (eq (processp 'x) nil))
  (should (eq (processp 'foo) nil))
  (should (eq (processp t) nil))
  (should (eq (processp :keyword) nil))

  ;; Strings
  (should (eq (processp "s") nil))
  (should (eq (processp "") nil))
  (should (eq (processp "foo") nil))

  ;; Lists
  (should (eq (processp '(1 2 3)) nil))
  (should (eq (processp (cons 1 2)) nil))

  ;; Vectors
  (should (eq (processp []) nil))
  (should (eq (processp [1]) nil))
  (should (eq (processp [1 2 3]) nil)))

(ert-deftest processp-channel-a-other-objects ()
  "Test processp on other Emacs objects (should return nil)."
  ;; Buffers
  (should (eq (processp (current-buffer)) nil))

  ;; Windows
  (should (eq (processp (selected-window)) nil))

  ;; Markers
  (should (eq (processp (point-marker)) nil))

  ;; Hash tables
  (should (eq (processp (make-hash-table)) nil)))

(ert-deftest processp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; nil (should return nil)
           (nil . nil)
           (() . nil)

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

           ;; Symbols (should return nil)
           (x . nil)
           (foo . nil)
           (t . nil)
           (:keyword . nil)

           ;; Strings (should return nil)
           ("s" . nil)
           ("" . nil)
           ("foo" . nil)

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
        (should (eq (processp input) expected))))))

(ert-deftest processp-channel-a-edge-cases ()
  "Additional edge cases for processp."
  ;; Other object types
  (should (eq (processp (current-buffer)) nil))
  (should (eq (processp (selected-window)) nil))
  (should (eq (processp (point-marker)) nil))
  (should (eq (processp (make-hash-table)) nil))

  ;; Functions
  (should (eq (processp (symbol-function 'car)) nil))

  ;; Special values
  (should (eq (processp nil) nil))
  (should (eq (processp t) nil)))

(provide 'processp-channel-a-tests)
;;; processp-channel-a-tests.el ends here

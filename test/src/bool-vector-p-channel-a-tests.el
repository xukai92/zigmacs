;;; bool-vector-p-channel-a-tests.el --- Channel A verification for bool-vector-p port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the bool-vector-p Zig port.
;; This is the SIXTEENTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_bool_vector_p) and the original C implementation
;; (bool_vector_p_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/bool-vector-p-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest bool-vector-p-channel-a-bool-vectors ()
  "Test bool-vector-p on bool-vector values (should return t)."
  ;; Empty bool-vector
  (should (eq (bool-vector-p (make-bool-vector 0 nil)) t))
  (should (eq (bool-vector-p (make-bool-vector 0 t)) t))

  ;; Small bool-vectors
  (should (eq (bool-vector-p (make-bool-vector 1 nil)) t))
  (should (eq (bool-vector-p (make-bool-vector 3 t)) t))
  (should (eq (bool-vector-p (make-bool-vector 5 nil)) t))

  ;; Larger bool-vectors
  (should (eq (bool-vector-p (make-bool-vector 10 t)) t))
  (should (eq (bool-vector-p (make-bool-vector 100 nil)) t))
  (should (eq (bool-vector-p (make-bool-vector 1000 t)) t)))

(ert-deftest bool-vector-p-channel-a-non-bool-vectors ()
  "Test bool-vector-p on non-bool-vector values (should return nil)."
  ;; nil and t
  (should (eq (bool-vector-p nil) nil))
  (should (eq (bool-vector-p t) nil))

  ;; Integers
  (should (eq (bool-vector-p 0) nil))
  (should (eq (bool-vector-p 42) nil))
  (should (eq (bool-vector-p -42) nil))

  ;; Floats
  (should (eq (bool-vector-p 3.14) nil))
  (should (eq (bool-vector-p 0.0) nil))

  ;; Symbols
  (should (eq (bool-vector-p 'foo) nil))
  (should (eq (bool-vector-p 'some-symbol) nil))

  ;; Strings
  (should (eq (bool-vector-p "string") nil))
  (should (eq (bool-vector-p "") nil))

  ;; Regular vectors (CRITICAL: vectors are NOT bool-vectors)
  (should (eq (bool-vector-p []) nil))
  (should (eq (bool-vector-p [1 2 3]) nil))
  (should (eq (bool-vector-p [t nil t]) nil))
  (should (eq (bool-vector-p [foo bar]) nil))

  ;; Lists
  (should (eq (bool-vector-p '(1 2 3)) nil))
  (should (eq (bool-vector-p '(t nil)) nil))
  (should (eq (bool-vector-p '()) nil))

  ;; Characters
  (should (eq (bool-vector-p ?a) nil))

  ;; Records
  (should (eq (bool-vector-p (record 'foo)) nil)))

(ert-deftest bool-vector-p-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Bool-vectors (should return t)
           (,(make-bool-vector 0 nil) . t)
           (,(make-bool-vector 3 t) . t)
           (,(make-bool-vector 10 nil) . t)
           (,(make-bool-vector 100 t) . t)

           ;; Non-bool-vectors (should return nil)
           (nil . nil)
           (t . nil)
           (42 . nil)
           (0 . nil)
           (3.14 . nil)
           (foo . nil)
           ("string" . nil)
           ("" . nil)
           ([1 2 3] . nil)
           ([t nil] . nil)
           ([] . nil)
           ((1 2 3) . nil)
           ((t nil) . nil)
           (() . nil)
           (?a . nil)
           (,(record 'foo) . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (bool-vector-p input) expected))))))

(ert-deftest bool-vector-p-channel-a-edge-cases ()
  "Additional edge cases for bool-vector-p."
  ;; Large bool-vectors
  (should (eq (bool-vector-p (make-bool-vector 10000 t)) t))

  ;; Various non-bool-vector objects
  (should (eq (bool-vector-p (current-buffer)) nil))
  (should (eq (bool-vector-p (selected-window)) nil))
  (should (eq (bool-vector-p (point-marker)) nil))
  (should (eq (bool-vector-p (make-hash-table)) nil))
  (should (eq (bool-vector-p (make-char-table nil)) nil)))

(provide 'bool-vector-p-channel-a-tests)
;;; bool-vector-p-channel-a-tests.el ends here

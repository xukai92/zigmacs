;;; atom-channel-a-tests.el --- Channel A verification for atom port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the atom Zig port.
;; This is the THIRTEENTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_atom) and the original C implementation
;; (atom_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/atom-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest atom-channel-a-atoms ()
  "Test atom on atoms (should return t).
CRITICAL: inverted logic - atoms are NOT cons cells. nil is an atom."
  ;; nil is an atom (empty list)
  (should (eq (atom nil) t))
  (should (eq (atom '()) t))

  ;; Symbols
  (should (eq (atom t) t))
  (should (eq (atom 'foo) t))
  (should (eq (atom 'bar) t))
  (should (eq (atom 'x) t))
  (should (eq (atom :keyword) t))

  ;; Integers (fixnums and bignums)
  (should (eq (atom 0) t))
  (should (eq (atom 42) t))
  (should (eq (atom -42) t))
  (should (eq (atom most-positive-fixnum) t))
  (should (eq (atom most-negative-fixnum) t))
  (should (eq (atom (expt 2 100)) t))
  (should (eq (atom (- (expt 2 100))) t))

  ;; Characters (fixnums)
  (should (eq (atom ?a) t))
  (should (eq (atom ?\n) t))
  (should (eq (atom ?\t) t))

  ;; Floats
  (should (eq (atom 0.0) t))
  (should (eq (atom 3.14) t))
  (should (eq (atom -3.14) t))
  (should (eq (atom 1.0e+INF) t))
  (should (eq (atom 0.0e+NaN) t))

  ;; Strings
  (should (eq (atom "") t))
  (should (eq (atom "string") t))
  (should (eq (atom "foo") t))

  ;; Vectors
  (should (eq (atom []) t))
  (should (eq (atom [1 2 3]) t))
  (should (eq (atom [foo]) t)))

(ert-deftest atom-channel-a-cons-cells ()
  "Test atom on cons cells (should return nil).
CRITICAL: cons cells are NOT atoms - they return nil."
  ;; Simple cons cells
  (should (eq (atom '(1 . 2)) nil))
  (should (eq (atom (cons 'a 'b)) nil))
  (should (eq (atom (cons 1 2)) nil))
  (should (eq (atom (cons nil nil)) nil))

  ;; Lists (which are cons cells)
  (should (eq (atom '(1)) nil))
  (should (eq (atom '(1 2 3)) nil))
  (should (eq (atom '(foo bar)) nil))
  (should (eq (atom '(a b c d)) nil))

  ;; Nested lists
  (should (eq (atom '((1 2) (3 4))) nil))
  (should (eq (atom '(1 (2 3))) nil))
  (should (eq (atom '((a))) nil))

  ;; Lists with symbols
  (should (eq (atom '(foo)) nil))
  (should (eq (atom '(t nil)) nil))
  (should (eq (atom '(:keyword value)) nil)))

(ert-deftest atom-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Atoms (should return t)
           (nil . t)
           (t . t)
           (foo . t)
           (bar . t)
           (x . t)
           (:keyword . t)
           (0 . t)
           (42 . t)
           (-42 . t)
           (,most-positive-fixnum . t)
           (,most-negative-fixnum . t)
           (,(expt 2 100) . t)
           (?a . t)
           (?\n . t)
           (0.0 . t)
           (3.14 . t)
           (-3.14 . t)
           (1.0e+INF . t)
           ("" . t)
           ("string" . t)
           ("foo" . t)
           ([] . t)
           ([1 2 3] . t)
           ([foo] . t)

           ;; Cons cells (should return nil)
           ((1 . 2) . nil)
           ((a . b) . nil)
           ((nil . nil) . nil)
           ((1) . nil)
           ((1 2 3) . nil)
           ((foo bar) . nil)
           ((a b c d) . nil)
           (((1 2) (3 4)) . nil)
           ((1 (2 3)) . nil)
           (((a)) . nil)
           ((foo) . nil)
           ((t nil) . nil)
           ((:keyword value) . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (atom input) expected))))))

(ert-deftest atom-channel-a-edge-cases ()
  "Additional edge cases for atom."
  ;; Very large numbers (atoms)
  (should (eq (atom (expt 2 1000)) t))
  (should (eq (atom (- (expt 2 1000))) t))

  ;; Special float values (atoms)
  (should (eq (atom -1.0e+INF) t))
  (should (eq (atom 0.0e+NaN) t))
  (should (eq (atom -0.0) t))

  ;; Various object types (atoms)
  (should (eq (atom (current-buffer)) t))
  (should (eq (atom (selected-window)) t))
  (should (eq (atom (point-marker)) t))
  (should (eq (atom (make-hash-table)) t))

  ;; Empty list is nil, which is an atom
  (should (eq (atom '()) t))

  ;; Single-element lists are cons cells
  (should (eq (atom '(x)) nil))

  ;; Dotted pairs are cons cells
  (should (eq (atom '(1 2 . 3)) nil))

  ;; Improper lists are cons cells
  (should (eq (atom '(1 . (2 . 3))) nil)))

(provide 'atom-channel-a-tests)
;;; atom-channel-a-tests.el ends here

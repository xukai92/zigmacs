;;; symbolp-channel-a-tests.el --- Channel A verification for symbolp port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the symbolp Zig port.
;; This is the SIXTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_symbolp) and the original C implementation
;; (symbolp_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/symbolp-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest symbolp-channel-a-symbols ()
  "Test symbolp on symbols (should return t).
CRITICAL: nil and t ARE symbols in Emacs Lisp."
  ;; Basic symbols
  (should (eq (symbolp 'x) t))
  (should (eq (symbolp 'foo) t))
  (should (eq (symbolp 'some-symbol) t))
  (should (eq (symbolp 'variable-name) t))

  ;; Keywords (also symbols)
  (should (eq (symbolp :keyword) t))
  (should (eq (symbolp :kw) t))
  (should (eq (symbolp :foo) t))

  ;; CRITICAL: nil and t are symbols
  (should (eq (symbolp nil) t))
  (should (eq (symbolp t) t)))

(ert-deftest symbolp-channel-a-numbers ()
  "Test symbolp on numbers (should return nil)."
  ;; Fixnums
  (should (eq (symbolp 0) nil))
  (should (eq (symbolp 42) nil))
  (should (eq (symbolp -42) nil))
  (should (eq (symbolp most-positive-fixnum) nil))
  (should (eq (symbolp most-negative-fixnum) nil))

  ;; Characters (fixnums)
  (should (eq (symbolp ?a) nil))
  (should (eq (symbolp ?\n) nil))
  (should (eq (symbolp ?\t) nil))

  ;; Bignums
  (should (eq (symbolp (1+ most-positive-fixnum)) nil))
  (should (eq (symbolp (1- most-negative-fixnum)) nil))
  (should (eq (symbolp (expt 2 100)) nil))
  (should (eq (symbolp (- (expt 2 100))) nil))

  ;; Floats
  (should (eq (symbolp 0.0) nil))
  (should (eq (symbolp 3.0) nil))
  (should (eq (symbolp 3.14) nil))
  (should (eq (symbolp -3.14) nil))
  (should (eq (symbolp 1.0e10) nil))
  (should (eq (symbolp 1.0e+INF) nil))
  (should (eq (symbolp 0.0e+NaN) nil)))

(ert-deftest symbolp-channel-a-non-symbols ()
  "Test symbolp on non-symbol values (should return nil)."
  ;; Strings
  (should (eq (symbolp "") nil))
  (should (eq (symbolp "string") nil))
  (should (eq (symbolp "foo") nil))
  (should (eq (symbolp "x") nil))

  ;; Lists (including empty list, which is nil - but tested separately as a symbol)
  (should (eq (symbolp '(1 2 3)) nil))
  (should (eq (symbolp '(1)) nil))
  (should (eq (symbolp '(x)) nil))
  (should (eq (symbolp '(1 . 2)) nil))

  ;; Vectors
  (should (eq (symbolp []) nil))
  (should (eq (symbolp [1 2 3]) nil))
  (should (eq (symbolp [x]) nil)))

(ert-deftest symbolp-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Symbols (should return t)
           (x . t)
           (foo . t)
           (some-symbol . t)
           (:keyword . t)
           (:kw . t)
           (:foo . t)

           ;; CRITICAL: nil and t are symbols
           (nil . t)
           (t . t)

           ;; Numbers (should return nil)
           (0 . nil)
           (42 . nil)
           (-42 . nil)
           (,most-positive-fixnum . nil)
           (,most-negative-fixnum . nil)
           (,(expt 2 100) . nil)
           (,(- (expt 2 100)) . nil)
           (?a . nil)
           (0.0 . nil)
           (3.0 . nil)
           (3.14 . nil)
           (-3.14 . nil)
           (1.0e10 . nil)

           ;; Strings (should return nil)
           ("" . nil)
           ("string" . nil)
           ("foo" . nil)

           ;; Lists (should return nil)
           ((1 2 3) . nil)
           ((1) . nil)
           ((x) . nil)
           ((1 . 2) . nil)

           ;; Vectors (should return nil)
           ([] . nil)
           ([1 2 3] . nil)
           ([x] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (symbolp input) expected))))))

(ert-deftest symbolp-channel-a-edge-cases ()
  "Additional edge cases for symbolp."
  ;; Gensyms (uninterned symbols)
  (should (eq (symbolp (make-symbol "foo")) t))
  (should (eq (symbolp (gensym)) t))

  ;; Other non-symbol types
  (should (eq (symbolp (current-buffer)) nil))
  (should (eq (symbolp (selected-window)) nil))
  (should (eq (symbolp (point-marker)) nil))
  (should (eq (symbolp (make-hash-table)) nil)))

(provide 'symbolp-channel-a-tests)
;;; symbolp-channel-a-tests.el ends here

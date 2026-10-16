;;; bare-symbol-p-channel-a-tests.el --- Channel A verification for bare-symbol-p port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the bare-symbol-p Zig port.
;; This is the ELEVENTH C→Zig leaf port in Zigmacs.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_bare_symbol_p) and the original C implementation
;; (bare_symbol_p_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/bare-symbol-p-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest bare-symbol-p-channel-a-symbols ()
  "Test bare-symbol-p on bare symbols (should return t)."
  ;; nil and t are bare symbols
  (should (eq (bare-symbol-p nil) t))
  (should (eq (bare-symbol-p t) t))

  ;; Regular symbols
  (should (eq (bare-symbol-p 'foo) t))
  (should (eq (bare-symbol-p 'bar) t))
  (should (eq (bare-symbol-p 'some-symbol) t))
  (should (eq (bare-symbol-p 'x) t))

  ;; Keywords (which are bare symbols)
  (should (eq (bare-symbol-p :keyword) t))
  (should (eq (bare-symbol-p :test) t))
  (should (eq (bare-symbol-p :foo) t))

  ;; Uninterned symbols
  (should (eq (bare-symbol-p (make-symbol "uninterned")) t)))

(ert-deftest bare-symbol-p-channel-a-non-symbols ()
  "Test bare-symbol-p on non-symbol values (should return nil).
CRITICAL: bare-symbol-p only returns t for bare symbols, not symbol-with-position."
  ;; Integers
  (should (eq (bare-symbol-p 0) nil))
  (should (eq (bare-symbol-p 42) nil))
  (should (eq (bare-symbol-p -42) nil))
  (should (eq (bare-symbol-p most-positive-fixnum) nil))
  (should (eq (bare-symbol-p most-negative-fixnum) nil))
  (should (eq (bare-symbol-p (expt 2 100)) nil))

  ;; Characters (fixnums)
  (should (eq (bare-symbol-p ?a) nil))
  (should (eq (bare-symbol-p ?\n) nil))
  (should (eq (bare-symbol-p ?\t) nil))

  ;; Floats
  (should (eq (bare-symbol-p 0.0) nil))
  (should (eq (bare-symbol-p 3.14) nil))
  (should (eq (bare-symbol-p -3.14) nil))
  (should (eq (bare-symbol-p 1.0e+INF) nil))
  (should (eq (bare-symbol-p 0.0e+NaN) nil))

  ;; Strings
  (should (eq (bare-symbol-p "") nil))
  (should (eq (bare-symbol-p "string") nil))
  (should (eq (bare-symbol-p "foo") nil))
  (should (eq (bare-symbol-p "nil") nil))

  ;; Lists
  (should (eq (bare-symbol-p '(1 2 3)) nil))
  (should (eq (bare-symbol-p '(1)) nil))
  ;; NOTE: '() is nil, which IS a bare symbol, so it returns t (tested in symbols section)
  (should (eq (bare-symbol-p '(foo bar)) nil))
  (should (eq (bare-symbol-p '(1 . 2)) nil))

  ;; Vectors
  (should (eq (bare-symbol-p []) nil))
  (should (eq (bare-symbol-p [1 2 3]) nil))
  (should (eq (bare-symbol-p [foo]) nil)))

(ert-deftest bare-symbol-p-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering all input types.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         `(;; Bare symbols (should return t)
           (nil . t)
           (t . t)
           (foo . t)
           (bar . t)
           (x . t)
           (some-symbol . t)
           (:keyword . t)
           (:test . t)
           (:foo . t)

           ;; Non-symbols (should return nil)
           (0 . nil)
           (42 . nil)
           (-42 . nil)
           (,most-positive-fixnum . nil)
           (,most-negative-fixnum . nil)
           (,(expt 2 100) . nil)
           (?a . nil)
           (0.0 . nil)
           (3.14 . nil)
           (-3.14 . nil)
           (1.0e+INF . nil)
           ("string" . nil)
           ("" . nil)
           ("foo" . nil)
           ((1 2 3) . nil)
           ((1) . nil)
           ((foo bar) . nil)
           ((1 . 2) . nil)
           ([1 2 3] . nil)
           ([] . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (bare-symbol-p input) expected))))))

(ert-deftest bare-symbol-p-channel-a-edge-cases ()
  "Additional edge cases for bare-symbol-p."
  ;; Uninterned symbols are bare symbols
  (should (eq (bare-symbol-p (make-symbol "uninterned")) t))
  (should (eq (bare-symbol-p (make-symbol "")) t))

  ;; Various non-symbol types
  (should (eq (bare-symbol-p (current-buffer)) nil))
  (should (eq (bare-symbol-p (selected-window)) nil))
  (should (eq (bare-symbol-p (point-marker)) nil))
  (should (eq (bare-symbol-p (make-hash-table)) nil))

  ;; Very large numbers
  (should (eq (bare-symbol-p (expt 2 1000)) nil))
  (should (eq (bare-symbol-p (- (expt 2 1000))) nil))

  ;; Special float values
  (should (eq (bare-symbol-p -1.0e+INF) nil))
  (should (eq (bare-symbol-p 0.0e+NaN) nil)))

(provide 'bare-symbol-p-channel-a-tests)
;;; bare-symbol-p-channel-a-tests.el ends here

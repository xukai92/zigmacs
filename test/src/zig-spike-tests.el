;;; zig-spike-tests.el --- Tests for Phase-1 C↔Zig interop spike  -*- lexical-binding: t; -*-

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

;; Tests for the Phase-1 C↔Zig interop spike. This is an ADDITIVE
;; architecture de-risking spike, NOT a port. Tests prove:
;; 1. Zig object links into emacs binary
;; 2. C→Zig calls work
;; 3. Zig→C calls work (Zig calls Emacs C functions)
;; 4. Lisp_Object round-trips correctly

;;; Code:

(require 'ert)

(ert-deftest zig-spike-interop-selftest ()
  "Test Phase-1 C↔Zig interop spike.
Verifies that:
- The Zig object is linked (primitive exists)
- C→Zig calls work (we can call the primitive)
- Zig→C calls work (Zig calls Fadd1, Fcons)
- Lisp_Object round-trips correctly (fixnums, cons cells)"
  ;; The primitive should exist
  (should (fboundp 'zigmacs--interop-selftest))

  ;; Call it and check the result structure
  (let ((result (zigmacs--interop-selftest)))
    ;; Should return a list with 3 elements
    (should (consp result))
    (should (= (length result) 3))

    ;; Element 0: Simple test - Zig calls Fadd1(41) -> should be 42
    (let ((simple-result (nth 0 result)))
      (should (integerp simple-result))
      (should (= simple-result 42)))

    ;; Element 1: Cons test - Zig builds (99 . 100) via Fcons
    (let ((cons-result (nth 1 result)))
      (should (consp cons-result))
      (should (= (car cons-result) 99))
      (should (= (cdr cons-result) 100)))

    ;; Element 2: Complex test - Zig builds (43 . (44 . 0)) via multiple Fadd1 + Fcons
    (let ((complex-result (nth 2 result)))
      (should (consp complex-result))
      (should (= (car complex-result) 43))
      (should (consp (cdr complex-result)))
      (should (= (car (cdr complex-result)) 44))
      ;; The cdr of the inner cons should be 0 (our makeshift nil)
      (should (= (cdr (cdr complex-result)) 0)))))

(ert-deftest zig-spike-primitive-exists ()
  "Verify the spike primitive is registered."
  (should (fboundp 'zigmacs--interop-selftest)))

;;; zig-spike-tests.el ends here

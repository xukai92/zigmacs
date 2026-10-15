;;; zig-cimport-tests.el --- tests for Phase-2 @cImport spike  -*- lexical-binding:t -*-

;; Copyright (C) 2024 Free Software Foundation, Inc.

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

;; Tests for Phase-2 @cImport spike (C shim binding strategy).
;;
;; CRITICAL ARCHITECTURAL FINDING tested here:
;; - Zig 0.17.0 REMOVED @cImport (deprecated in 0.16)
;; - `zig translate-c` CRASHES (SEGV) on Emacs's lisp.h
;; - VIABLE BINDING STRATEGY: Zig extern → C shim → Emacs macro/inline API
;;
;; This is an ADDITIVE/INERT spike to prove the binding strategy.
;; NOT a port.  NOT for production.

;;; Code:

(require 'ert)

(ert-deftest zig-cimport-spike-basic ()
  "Test that zigmacs--cimport-selftest returns expected structure.

The Zig implementation uses C shims to access Emacs's macro/inline API:
- make_fixnum, XFIXNUM (fixnum operations)
- Fcons, CONSP, XCAR, XCDR (cons operations)
- Qnil, Qt, NILP (symbols and predicates)

Expected result: (42 (99 . 100) nil t)"
  (let ((result (zigmacs--cimport-selftest)))
    ;; Should return a 4-element list
    (should (listp result))
    (should (= (length result) 4))

    ;; Element 0: fixnum 42
    (should (eq (nth 0 result) 42))

    ;; Element 1: cons (99 . 100)
    (should (consp (nth 1 result)))
    (should (eq (car (nth 1 result)) 99))
    (should (eq (cdr (nth 1 result)) 100))

    ;; Element 2: nil
    (should (eq (nth 2 result) nil))

    ;; Element 3: t
    (should (eq (nth 3 result) t))))

(ert-deftest zig-cimport-spike-fixnum-round-trip ()
  "Test that fixnums round-trip correctly through Zig via shim layer."
  (let ((result (zigmacs--cimport-selftest)))
    ;; Verify the fixnum (42) is exactly 42, proving correct tagging
    (should (integerp (nth 0 result)))
    (should (= (nth 0 result) 42))))

(ert-deftest zig-cimport-spike-cons-operations ()
  "Test that cons operations work correctly via C shim layer."
  (let* ((result (zigmacs--cimport-selftest))
         (test-cons (nth 1 result)))
    ;; Verify it's a cons
    (should (consp test-cons))

    ;; Verify car and cdr are correct
    ;; This proves XCAR/XCDR shims work correctly
    (should (= (car test-cons) 99))
    (should (= (cdr test-cons) 100))))

(ert-deftest zig-cimport-spike-symbols ()
  "Test that Qnil and Qt are accessible via C shim layer."
  (let ((result (zigmacs--cimport-selftest)))
    ;; Element 2 should be nil (not 0, not empty list in disguise)
    (should (null (nth 2 result)))

    ;; Element 3 should be t (the symbol, not just any non-nil value)
    (should (eq (nth 3 result) t))))

;;; zig-cimport-tests.el ends here

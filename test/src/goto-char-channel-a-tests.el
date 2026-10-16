;;; goto-char-channel-a-tests.el --- Channel A verification for goto-char port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the goto-char Zig port (Cat-C #1).
;;
;; This is the FIRST Category C (stateful) port. These tests verify
;; bug-for-bug compatibility between the Zig implementation (zig_goto_char)
;; and the original C implementation (goto_char_orig) using the new
;; SNAPSHOT→REPLAY mechanism.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification with
;; point snapshot/restore:
;;   ZIGMACS_AB=1 make -C test src/goto-char-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest goto-char-channel-a-valid-position ()
  "Test goto-char with valid positions within buffer bounds."
  (with-temp-buffer
    (insert "hello world")
    ;; Move to beginning
    (should (= (goto-char 1) 1))
    (should (= (point) 1))

    ;; Move to middle
    (should (= (goto-char 6) 6))
    (should (= (point) 6))

    ;; Move to end
    (should (= (goto-char 12) 12))
    (should (= (point) 12))

    ;; Move back to beginning
    (should (= (goto-char 1) 1))
    (should (= (point) 1))))

(ert-deftest goto-char-channel-a-clamp-before-begv ()
  "Test goto-char clamps position before BEGV to point-min."
  (with-temp-buffer
    (insert "hello world")
    ;; Attempt to move before beginning (should clamp to 1)
    (should (= (goto-char 0) 0))
    (should (= (point) 1))

    (should (= (goto-char -10) -10))
    (should (= (point) 1))

    (should (= (goto-char -999999) -999999))
    (should (= (point) 1))))

(ert-deftest goto-char-channel-a-clamp-after-zv ()
  "Test goto-char clamps position after ZV to point-max."
  (with-temp-buffer
    (insert "hello world")
    ;; Buffer has 11 chars + 1 for point-max = 12
    ;; Attempt to move past end (should clamp to 12)
    (should (= (goto-char 99) 99))
    (should (= (point) 12))

    (should (= (goto-char 1000) 1000))
    (should (= (point) 12))

    (should (= (goto-char 999999) 999999))
    (should (= (point) 12))))

(ert-deftest goto-char-channel-a-narrowing ()
  "Test goto-char respects narrowing (BEGV/ZV)."
  (with-temp-buffer
    (insert "0123456789")
    ;; Narrow to middle of buffer (chars 3-7, positions 4-8)
    (narrow-to-region 4 8)

    ;; Should clamp to narrowed region start (4)
    (should (= (goto-char 1) 1))
    (should (= (point) 4))

    ;; Valid position within narrowed region
    (should (= (goto-char 6) 6))
    (should (= (point) 6))

    ;; Should clamp to narrowed region end (8)
    (should (= (goto-char 99) 99))
    (should (= (point) 8))

    ;; Widen and check full buffer access
    (widen)
    (should (= (goto-char 1) 1))
    (should (= (point) 1))
    (should (= (goto-char 11) 11))
    (should (= (point) 11))))

(ert-deftest goto-char-channel-a-marker-argument ()
  "Test goto-char with marker argument."
  (with-temp-buffer
    (insert "hello world")

    ;; Create marker at position 6
    (let ((marker (make-marker)))
      (set-marker marker 6 (current-buffer))

      ;; goto-char should accept marker and move to its position
      (goto-char 1)
      (should (markerp marker))
      (should (= (goto-char marker) marker))
      (should (= (point) 6)))

    ;; Marker at beginning
    (let ((marker (point-min-marker)))
      (goto-char 5)
      (should (= (goto-char marker) marker))
      (should (= (point) 1)))

    ;; Marker at end
    (let ((marker (point-max-marker)))
      (goto-char 1)
      (should (= (goto-char marker) marker))
      (should (= (point) 12)))))

(ert-deftest goto-char-channel-a-marker-clamping ()
  "Test that goto-char clamps marker positions to buffer bounds."
  (with-temp-buffer
    (insert "0123456789")
    (narrow-to-region 4 8)

    ;; Marker outside narrowed region should be clamped
    (let ((marker-before (make-marker))
          (marker-after (make-marker)))
      (widen)
      (set-marker marker-before 2 (current-buffer))  ; Before BEGV
      (set-marker marker-after 9 (current-buffer))   ; After ZV
      (narrow-to-region 4 8)

      ;; goto-char with marker before BEGV should clamp to BEGV
      (goto-char marker-before)
      (should (= (point) 4))

      ;; goto-char with marker after ZV should clamp to ZV
      (goto-char marker-after)
      (should (= (point) 8)))))

(ert-deftest goto-char-channel-a-wrong-type ()
  "Test goto-char signals wrong-type-argument for non-number/non-marker."
  ;; String
  (should-error (goto-char "not a number")
                :type 'wrong-type-argument)

  ;; Symbol
  (should-error (goto-char 'foo)
                :type 'wrong-type-argument)

  ;; List
  (should-error (goto-char '(1 2 3))
                :type 'wrong-type-argument)

  ;; nil
  (should-error (goto-char nil)
                :type 'wrong-type-argument)

  ;; Float (not a fixnum or marker)
  (should-error (goto-char 3.14)
                :type 'wrong-type-argument))

(ert-deftest goto-char-channel-a-return-value ()
  "Test that goto-char returns its argument (position)."
  (with-temp-buffer
    (insert "hello")

    ;; Returns the position argument (not the clamped position)
    (should (= (goto-char 3) 3))
    (should (= (goto-char 1) 1))

    ;; Even when clamping occurs, returns the input argument
    (should (= (goto-char 99) 99))
    (should (= (point) 6))  ; Point is clamped to max

    (should (= (goto-char 0) 0))
    (should (= (point) 1))  ; Point is clamped to min

    ;; With marker, returns the marker
    (let ((marker (make-marker)))
      (set-marker marker 3 (current-buffer))
      (should (eq (goto-char marker) marker)))))

(ert-deftest goto-char-channel-a-empty-buffer ()
  "Test goto-char in empty buffer."
  (with-temp-buffer
    ;; Empty buffer: point-min = point-max = 1
    (should (= (point-min) 1))
    (should (= (point-max) 1))

    ;; goto-char to 1 should work
    (should (= (goto-char 1) 1))
    (should (= (point) 1))

    ;; goto-char to 0 should clamp to 1
    (should (= (goto-char 0) 0))
    (should (= (point) 1))

    ;; goto-char to any position should clamp to 1
    (should (= (goto-char 100) 100))
    (should (= (point) 1))))

(ert-deftest goto-char-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various scenarios."
  (with-temp-buffer
    (insert "0123456789")
    (let ((test-cases
           ;; Format: (input-pos expected-point)
           '((1 1)
             (5 5)
             (11 11)
             (0 1)     ; Clamp to min
             (99 11)   ; Clamp to max
             (-100 1)  ; Clamp to min
             (6 6))))
      (dolist (case test-cases)
        (let ((input (nth 0 case))
              (expected-point (nth 1 case)))
          (goto-char input)
          (should (= (point) expected-point)))))))

(ert-deftest goto-char-channel-a-snapshot-replay ()
  "Test that verifies the snapshot→replay mechanism works correctly.
   This test exercises multiple goto-char calls to ensure the
   snapshot/restore doesn't leak state between A/B comparisons."
  (with-temp-buffer
    (insert "abcdefghij")

    ;; Series of moves that would fail if snapshot→replay is broken
    (goto-char 1)
    (should (= (point) 1))

    (goto-char 5)
    (should (= (point) 5))

    (goto-char 10)
    (should (= (point) 10))

    ;; Clamping case
    (goto-char 99)
    (should (= (point) 11))

    ;; Back to start
    (goto-char 1)
    (should (= (point) 1))

    ;; With narrowing
    (narrow-to-region 3 8)
    (goto-char 5)
    (should (= (point) 5))

    (goto-char 1)  ; Should clamp to 3
    (should (= (point) 3))

    (goto-char 99)  ; Should clamp to 8
    (should (= (point) 8))))

(provide 'goto-char-channel-a-tests)
;;; goto-char-channel-a-tests.el ends here

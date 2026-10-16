;;; file-name-absolute-p-channel-a-tests.el --- Channel A verification for file-name-absolute-p port  -*- lexical-binding: t; -*-

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

;; Channel A verification tests for the file-name-absolute-p Zig port.
;; Category H₁ (I/O · process · coding) - string/path logic function.
;;
;; These tests verify bug-for-bug compatibility between the Zig
;; implementation (zig_file_name_absolute_p) and the original C implementation
;; (file_name_absolute_p_orig) across a comprehensive battery of inputs.
;;
;; Run with ZIGMACS_AB=1 to enable in-process A/B verification:
;;   ZIGMACS_AB=1 make -C test src/file-name-absolute-p-channel-a-tests

;;; Code:

(require 'ert)

(ert-deftest file-name-absolute-p-channel-a-absolute-paths ()
  "Test file-name-absolute-p on absolute paths (should return t)."
  ;; Unix absolute paths starting with /
  (should (eq (file-name-absolute-p "/") t))
  (should (eq (file-name-absolute-p "/foo") t))
  (should (eq (file-name-absolute-p "/foo/bar") t))
  (should (eq (file-name-absolute-p "/foo/bar/baz.txt") t))
  (should (eq (file-name-absolute-p "/tmp") t))
  (should (eq (file-name-absolute-p "/usr/local/bin") t))

  ;; Tilde-prefixed paths (considered absolute in Emacs)
  (should (eq (file-name-absolute-p "~") t))
  (should (eq (file-name-absolute-p "~/") t))
  (should (eq (file-name-absolute-p "~/foo") t))
  (should (eq (file-name-absolute-p "~/foo/bar") t))
  (should (eq (file-name-absolute-p "~/.emacs") t))
  (should (eq (file-name-absolute-p "~/.emacs.d/init.el") t)))

(ert-deftest file-name-absolute-p-channel-a-relative-paths ()
  "Test file-name-absolute-p on relative paths (should return nil)."
  ;; Simple relative paths
  (should (eq (file-name-absolute-p "foo") nil))
  (should (eq (file-name-absolute-p "bar") nil))
  (should (eq (file-name-absolute-p "foo/bar") nil))
  (should (eq (file-name-absolute-p "foo/bar/baz.txt") nil))

  ;; Current and parent directory references
  (should (eq (file-name-absolute-p ".") nil))
  (should (eq (file-name-absolute-p "..") nil))
  (should (eq (file-name-absolute-p "./foo") nil))
  (should (eq (file-name-absolute-p "../bar") nil))
  (should (eq (file-name-absolute-p "../../baz") nil))

  ;; Empty string
  (should (eq (file-name-absolute-p "") nil)))

(ert-deftest file-name-absolute-p-channel-a-tilde-edge-cases ()
  "Test tilde handling edge cases."
  ;; Tilde at start with various separators
  (should (eq (file-name-absolute-p "~") t))
  (should (eq (file-name-absolute-p "~/") t))
  (should (eq (file-name-absolute-p "~/foo") t))

  ;; Tilde NOT at start (relative paths)
  (should (eq (file-name-absolute-p "foo~") nil))
  (should (eq (file-name-absolute-p "foo/~bar") nil))
  (should (eq (file-name-absolute-p "a~b") nil)))

(ert-deftest file-name-absolute-p-channel-a-comprehensive-battery ()
  "Comprehensive battery test covering various path forms.
This is the main Channel A verification test."
  (let ((battery
         ;; Format: (input . expected-result)
         '(;; Absolute Unix paths (should return t)
           ("/" . t)
           ("/foo" . t)
           ("/foo/bar" . t)
           ("/foo/bar/baz.txt" . t)
           ("/tmp" . t)
           ("/usr/local/bin" . t)
           ("/a" . t)
           ("/123" . t)

           ;; Tilde-prefixed absolute paths (should return t)
           ("~" . t)
           ("~/" . t)
           ("~/foo" . t)
           ("~/foo/bar" . t)
           ("~/.emacs" . t)
           ("~/.emacs.d/init.el" . t)

           ;; Relative paths (should return nil)
           ("foo" . nil)
           ("bar" . nil)
           ("foo/bar" . nil)
           ("foo/bar/baz.txt" . nil)
           ("." . nil)
           (".." . nil)
           ("./foo" . nil)
           ("../bar" . nil)
           ("../../baz" . nil)
           ("" . nil)

           ;; Edge cases
           ("a" . nil)
           ("x" . nil)
           ("123" . nil)
           ("foo~" . nil)
           ("a~b" . nil))))
    (dolist (case battery)
      (let ((input (car case))
            (expected (cdr case)))
        (should (eq (file-name-absolute-p input) expected))))))

(ert-deftest file-name-absolute-p-channel-a-error-cases ()
  "Test that non-strings signal errors."
  ;; Should signal wrong-type-argument for non-strings
  (should-error (file-name-absolute-p nil) :type 'wrong-type-argument)
  (should-error (file-name-absolute-p 42) :type 'wrong-type-argument)
  (should-error (file-name-absolute-p t) :type 'wrong-type-argument)
  (should-error (file-name-absolute-p '(foo)) :type 'wrong-type-argument)
  (should-error (file-name-absolute-p [foo]) :type 'wrong-type-argument))

(provide 'file-name-absolute-p-channel-a-tests)
;;; file-name-absolute-p-channel-a-tests.el ends here

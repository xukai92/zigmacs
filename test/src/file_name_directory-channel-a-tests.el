;;; file_name_directory-channel-a-tests.el --- Channel A tests for file-name-directory -*- lexical-binding: t; -*-

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

;; ERT tests for file-name-directory (Zig port vs original C).
;; These tests verify the Zig implementation matches the C behavior.

;;; Code:

(require 'ert)

(ert-deftest file-name-directory-basic ()
  "Test basic file-name-directory behavior."
  ;; File with directory
  (should (equal (file-name-directory "/a/b/c.txt") "/a/b/"))
  ;; Directory ending in slash
  (should (equal (file-name-directory "/a/b/") "/a/b/"))
  ;; No directory component
  (should (equal (file-name-directory "noslash") nil))
  ;; Empty string
  (should (equal (file-name-directory "") nil))
  ;; Root directory
  (should (equal (file-name-directory "/") "/"))
  ;; Relative path
  (should (equal (file-name-directory "x/y") "x/")))

(ert-deftest file-name-directory-multibyte ()
  "Test file-name-directory with multibyte characters."
  ;; Cyrillic characters
  (should (equal (file-name-directory "/tmp/файл/x") "/tmp/файл/"))
  ;; Japanese characters
  (should (equal (file-name-directory "/home/ユーザー/file.txt") "/home/ユーザー/"))
  ;; Emoji
  (should (equal (file-name-directory "/path/🎉/file") "/path/🎉/")))

(ert-deftest file-name-directory-edge-cases ()
  "Test file-name-directory edge cases."
  ;; Single slash at end
  (should (equal (file-name-directory "file/") "file/"))
  ;; Multiple slashes
  (should (equal (file-name-directory "/a//b///c") "/a//b///"))
  ;; Dot files
  (should (equal (file-name-directory "/path/.hidden") "/path/"))
  (should (equal (file-name-directory ".hidden") nil))
  ;; Relative paths
  (should (equal (file-name-directory "./file") "./"))
  (should (equal (file-name-directory "../file") "../")))

(ert-deftest file-name-directory-special-paths ()
  "Test file-name-directory with special path patterns."
  ;; Home directory shorthand (literal, not expanded)
  (should (equal (file-name-directory "~/file.txt") "~/"))
  ;; Current directory
  (should (equal (file-name-directory ".") nil))
  (should (equal (file-name-directory "..") nil))
  ;; Trailing components
  (should (equal (file-name-directory "/a/b/c/d/e.txt") "/a/b/c/d/")))

(provide 'file_name_directory-channel-a-tests)
;;; file_name_directory-channel-a-tests.el ends here

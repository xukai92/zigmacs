;;; file_name_nondirectory-channel-a-tests.el --- Channel A tests for file-name-nondirectory  -*- lexical-binding: t; -*-

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

;; ERT tests for file-name-nondirectory (Zig port).
;; Covers: absolute paths, relative paths, trailing slashes, empty strings,
;; multibyte filenames, error cases.

;;; Code:

(require 'ert)

(ert-deftest file-name-nondirectory/absolute-paths ()
  "Test file-name-nondirectory on absolute paths."
  (should (equal (file-name-nondirectory "/a/b/c.txt") "c.txt"))
  (should (equal (file-name-nondirectory "/usr/local/bin/emacs") "emacs"))
  (should (equal (file-name-nondirectory "/tmp/file") "file")))

(ert-deftest file-name-nondirectory/relative-paths ()
  "Test file-name-nondirectory on relative paths."
  (should (equal (file-name-nondirectory "dir/file.el") "file.el"))
  (should (equal (file-name-nondirectory "file.txt") "file.txt"))
  (should (equal (file-name-nondirectory "noslash") "noslash")))

(ert-deftest file-name-nondirectory/trailing-slash ()
  "Test file-name-nondirectory with trailing slashes."
  (should (equal (file-name-nondirectory "/dir/") ""))
  (should (equal (file-name-nondirectory "/a/b/") ""))
  (should (equal (file-name-nondirectory "dir/") "")))

(ert-deftest file-name-nondirectory/empty-and-root ()
  "Test file-name-nondirectory with empty string and root."
  (should (equal (file-name-nondirectory "") ""))
  (should (equal (file-name-nondirectory "/") "")))

(ert-deftest file-name-nondirectory/multibyte ()
  "Test file-name-nondirectory with multibyte strings."
  (should (equal (file-name-nondirectory "/tmp/файл.txt") "файл.txt"))
  (should (equal (file-name-nondirectory "/home/用户/文档.org") "文档.org"))
  (should (equal (file-name-nondirectory "日本語/ファイル") "ファイル")))

(ert-deftest file-name-nondirectory/multiple-slashes ()
  "Test file-name-nondirectory with multiple consecutive slashes."
  (should (equal (file-name-nondirectory "/a//b///c.txt") "c.txt"))
  (should (equal (file-name-nondirectory "dir///file") "file")))

(ert-deftest file-name-nondirectory/type-errors ()
  "Test file-name-nondirectory errors on non-string arguments."
  (should-error (file-name-nondirectory nil) :type 'wrong-type-argument)
  (should-error (file-name-nondirectory 42) :type 'wrong-type-argument)
  (should-error (file-name-nondirectory '(a b c)) :type 'wrong-type-argument))

(provide 'file_name_nondirectory-channel-a-tests)
;;; file_name_nondirectory-channel-a-tests.el ends here

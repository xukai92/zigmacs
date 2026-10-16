;;; buffer_live_p-channel-a-tests.el --- Channel A tests for buffer-live-p  -*- lexical-binding: t; -*-

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

;; ERT tests for buffer-live-p (Zig port).
;; Covers: live buffers, killed buffers, non-buffer objects.

;;; Code:

(require 'ert)

(ert-deftest buffer-live-p/live-buffer ()
  "Test buffer-live-p on a live buffer."
  (should (eq (buffer-live-p (current-buffer)) t)))

(ert-deftest buffer-live-p/killed-buffer ()
  "Test buffer-live-p on a killed buffer."
  (let ((buf (generate-new-buffer "test")))
    (kill-buffer buf)
    (should (eq (buffer-live-p buf) nil))))

(ert-deftest buffer-live-p/non-buffers ()
  "Test buffer-live-p on non-buffer objects."
  (should (eq (buffer-live-p nil) nil))
  (should (eq (buffer-live-p t) nil))
  (should (eq (buffer-live-p 42) nil))
  (should (eq (buffer-live-p "string") nil))
  (should (eq (buffer-live-p 'symbol) nil))
  (should (eq (buffer-live-p [1 2 3]) nil))
  (should (eq (buffer-live-p '(1 2 3)) nil)))

(ert-deftest buffer-live-p/multiple-buffers ()
  "Test buffer-live-p distinguishes between live and killed buffers."
  (let ((buf1 (generate-new-buffer "test1"))
        (buf2 (generate-new-buffer "test2")))
    (should (eq (buffer-live-p buf1) t))
    (should (eq (buffer-live-p buf2) t))
    (kill-buffer buf1)
    (should (eq (buffer-live-p buf1) nil))
    (should (eq (buffer-live-p buf2) t))
    (kill-buffer buf2)
    (should (eq (buffer-live-p buf2) nil))))

(provide 'buffer_live_p-channel-a-tests)
;;; buffer_live_p-channel-a-tests.el ends here

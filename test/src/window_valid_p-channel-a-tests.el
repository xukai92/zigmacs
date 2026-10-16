;;; window_valid_p-channel-a-tests.el --- Channel A tests for window-valid-p  -*- lexical-binding: t; -*-

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

;; ERT tests for window-valid-p (Zig port).
;; Covers: valid windows (both live and internal), non-window objects.
;; Note: window-valid-p returns t for both live windows (displaying buffers)
;; and internal windows. Deleted windows return nil.

;;; Code:

(require 'ert)

(ert-deftest window-valid-p/selected-window ()
  "Test window-valid-p on selected window."
  ;; In batch mode, selected-window should be valid
  (should (eq (window-valid-p (selected-window)) t)))

(ert-deftest window-valid-p/non-windows ()
  "Test window-valid-p on non-window objects."
  (should (eq (window-valid-p nil) nil))
  (should (eq (window-valid-p t) nil))
  (should (eq (window-valid-p 42) nil))
  (should (eq (window-valid-p "string") nil))
  (should (eq (window-valid-p 'symbol) nil))
  (should (eq (window-valid-p [1 2 3]) nil))
  (should (eq (window-valid-p '(1 2 3)) nil)))

(ert-deftest window-valid-p/minibuffer-window ()
  "Test window-valid-p on minibuffer window."
  ;; minibuffer-window should be valid in batch mode
  (should (eq (window-valid-p (minibuffer-window)) t)))

(provide 'window_valid_p-channel-a-tests)
;;; window_valid_p-channel-a-tests.el ends here

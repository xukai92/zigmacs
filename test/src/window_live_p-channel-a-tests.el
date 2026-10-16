;;; window_live_p-channel-a-tests.el --- Channel A tests for window-live-p  -*- lexical-binding: t; -*-

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

;; ERT tests for window-live-p (Zig port).
;; Covers: live windows, non-window objects.
;; Note: Batch mode testing of deleted windows is difficult, so we focus on
;; basic cases.

;;; Code:

(require 'ert)

(ert-deftest window-live-p/selected-window ()
  "Test window-live-p on selected window."
  ;; In batch mode, selected-window should still be live
  (should (eq (window-live-p (selected-window)) t)))

(ert-deftest window-live-p/non-windows ()
  "Test window-live-p on non-window objects."
  (should (eq (window-live-p nil) nil))
  (should (eq (window-live-p t) nil))
  (should (eq (window-live-p 42) nil))
  (should (eq (window-live-p "string") nil))
  (should (eq (window-live-p 'symbol) nil))
  (should (eq (window-live-p [1 2 3]) nil))
  (should (eq (window-live-p '(1 2 3)) nil)))

(ert-deftest window-live-p/minibuffer-window ()
  "Test window-live-p on minibuffer window."
  ;; minibuffer-window should be live in batch mode
  (should (eq (window-live-p (minibuffer-window)) t)))

(provide 'window_live_p-channel-a-tests)
;;; window_live_p-channel-a-tests.el ends here

;;; frame_live_p-channel-a-tests.el --- Channel A tests for frame-live-p  -*- lexical-binding: t; -*-

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

;; ERT tests for frame-live-p (Zig port).
;; Covers: live frames, non-frame objects.
;; Note: Batch mode testing of deleted frames is difficult, so we focus on
;; basic cases.

;;; Code:

(require 'ert)

(ert-deftest frame-live-p/selected-frame ()
  "Test frame-live-p on selected frame."
  ;; In batch mode, selected-frame should be live and return terminal type
  (should (frame-live-p (selected-frame))))

(ert-deftest frame-live-p/non-frames ()
  "Test frame-live-p on non-frame objects."
  (should (eq (frame-live-p nil) nil))
  (should (eq (frame-live-p t) nil))
  (should (eq (frame-live-p 42) nil))
  (should (eq (frame-live-p "string") nil))
  (should (eq (frame-live-p 'symbol) nil))
  (should (eq (frame-live-p [1 2 3]) nil))
  (should (eq (frame-live-p '(1 2 3)) nil)))

(provide 'frame_live_p-channel-a-tests)
;;; frame_live_p-channel-a-tests.el ends here

;;; keymapp-channel-a-tests.el --- Channel A tests for keymapp  -*- lexical-binding: t; -*-

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

;; ERT tests for keymapp (Zig port).
;; Covers: sparse keymaps, full keymaps, symbols with keymap functions, non-keymaps.

;;; Code:

(require 'ert)

(ert-deftest keymapp/sparse-keymap ()
  "Test keymapp on a sparse keymap."
  (should (eq (keymapp (make-sparse-keymap)) t)))

(ert-deftest keymapp/full-keymap ()
  "Test keymapp on a full keymap."
  (should (eq (keymapp (make-keymap)) t)))

(ert-deftest keymapp/symbol-with-keymap ()
  "Test keymapp on a symbol whose function is a keymap."
  (let ((sym (make-symbol "test-keymap")))
    (fset sym (make-sparse-keymap))
    (should (eq (keymapp sym) t))))

(ert-deftest keymapp/non-keymaps ()
  "Test keymapp on non-keymap objects."
  (should (eq (keymapp nil) nil))
  (should (eq (keymapp t) nil))
  (should (eq (keymapp 42) nil))
  (should (eq (keymapp "string") nil))
  (should (eq (keymapp 'undefined-symbol) nil))
  (should (eq (keymapp [1 2 3]) nil))
  (should (eq (keymapp '(1 2 3)) nil)))

(ert-deftest keymapp/global-map ()
  "Test keymapp on global-map."
  (should (eq (keymapp (current-global-map)) t)))

(ert-deftest keymapp/local-map ()
  "Test keymapp on local map (if defined)."
  (with-temp-buffer
    (when (current-local-map)
      (should (eq (keymapp (current-local-map)) t)))))

(provide 'keymapp-channel-a-tests)
;;; keymapp-channel-a-tests.el ends here

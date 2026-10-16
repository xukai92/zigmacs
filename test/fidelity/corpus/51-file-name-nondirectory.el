;;; 51-file-name-nondirectory.el --- Corpus test for file-name-nondirectory  -*- lexical-binding: t; -*-

;; Fidelity corpus test: file-name-nondirectory (Category H₁)
;; Tests: absolute paths, relative paths, trailing slashes, multibyte, errors

(princ "file-name-nondirectory corpus:\n")

;; Test 1: Absolute path with file
(princ "  \"/a/b/c.txt\": ")
(princ (file-name-nondirectory "/a/b/c.txt"))
(princ "\n")

;; Test 2: Relative path
(princ "  \"noslash\": ")
(princ (file-name-nondirectory "noslash"))
(princ "\n")

;; Test 3: Trailing slash (directory)
(princ "  \"/dir/\": ")
(princ (file-name-nondirectory "/dir/"))
(princ "\n")

;; Test 4: Empty string
(princ "  \"\": ")
(princ (file-name-nondirectory ""))
(princ "\n")

;; Test 5: Root directory
(princ "  \"/\": ")
(princ (file-name-nondirectory "/"))
(princ "\n")

;; Test 6: Multiple slashes
(princ "  \"/a//b///c.txt\": ")
(princ (file-name-nondirectory "/a//b///c.txt"))
(princ "\n")

;; Test 7: Relative with directory
(princ "  \"dir/file.el\": ")
(princ (file-name-nondirectory "dir/file.el"))
(princ "\n")

;; Test 8: Multibyte filename
(princ "  \"/tmp/файл.txt\": ")
(princ (file-name-nondirectory "/tmp/файл.txt"))
(princ "\n")

;; Test 9: Multibyte with multiple dirs
(princ "  \"/home/用户/文档.org\": ")
(princ (file-name-nondirectory "/home/用户/文档.org"))
(princ "\n")

;; Test 10: Type error (wrapped in ignore-errors)
(princ "  nil (error): ")
(princ (ignore-errors (file-name-nondirectory nil)))
(princ "\n")

;; Test 11: Type error number (wrapped in ignore-errors)
(princ "  42 (error): ")
(princ (ignore-errors (file-name-nondirectory 42)))
(princ "\n")

;;; 51-file-name-nondirectory.el ends here

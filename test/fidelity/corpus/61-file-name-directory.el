;;; 61-file-name-directory.el --- Fidelity corpus for file-name-directory -*- lexical-binding: t; -*-

;; Fidelity test corpus for file-name-directory primitive
;; Tests that Zig port matches original C behavior exactly

;;; Basic paths
(file-name-directory "/a/b/c.txt")     ; → "/a/b/"
(file-name-directory "/a/b/")          ; → "/a/b/"
(file-name-directory "noslash")        ; → nil
(file-name-directory "")               ; → nil
(file-name-directory "/")              ; → "/"

;;; Relative paths
(file-name-directory "x/y")            ; → "x/"
(file-name-directory "./file")         ; → "./"
(file-name-directory "../file")        ; → "../"
(file-name-directory "file/")          ; → "file/"

;;; Multibyte strings
(file-name-directory "/tmp/файл/x")    ; → "/tmp/файл/"
(file-name-directory "/home/ユーザー/file.txt") ; → "/home/ユーザー/"
(file-name-directory "/path/🎉/data")  ; → "/path/🎉/"

;;; Edge cases
(file-name-directory "/a//b///c")      ; → "/a//b///"
(file-name-directory "/path/.hidden")  ; → "/path/"
(file-name-directory ".hidden")        ; → nil
(file-name-directory ".")              ; → nil
(file-name-directory "..")             ; → nil
(file-name-directory "~/file.txt")     ; → "~/"

;;; Deep paths
(file-name-directory "/a/b/c/d/e/f/g/h/i/j/file.txt") ; → "/a/b/c/d/e/f/g/h/i/j/"

;;; Special characters
(file-name-directory "/path with spaces/file.txt") ; → "/path with spaces/"
(file-name-directory "/path-with-dashes/file")     ; → "/path-with-dashes/"
(file-name-directory "/path_with_underscores/file") ; → "/path_with_underscores/"

;;; 61-file-name-directory.el ends here

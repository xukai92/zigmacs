;;; 11-unicode-coding.el --- Test unicode and coding systems -*- coding: utf-8; -*-

(princ "=== Unicode and coding systems ===\n")

;; Unicode strings
(let ((str "Hello, 世界! 🌍"))
  (princ (format "String: %s\n" str))
  (princ (format "Length: %d\n" (length str)))
  (princ (format "Bytes: %d\n" (string-bytes str))))

;; Characters
(princ (format "Char 'A': %d (0x%X)\n" ?A ?A))
(princ (format "Char '世': %d (0x%X)\n" ?世 ?世))
(princ (format "Char '🌍': %d (0x%X)\n" ?🌍 ?🌍))

;; String iteration
(let ((str "a→b"))
  (princ "Iterating characters:\n")
  (dotimes (i (length str))
    (princ (format "  %d: %c (code %d)\n" i (aref str i) (aref str i)))))

;; Coding system encoding/decoding
(let ((str "Ω"))
  (princ (format "Original: %s\n" str))
  (let ((utf8 (encode-coding-string str 'utf-8)))
    (princ (format "UTF-8 encoded bytes: %S\n" (string-to-list utf8)))
    (let ((decoded (decode-coding-string utf8 'utf-8)))
      (princ (format "Decoded: %s\n" decoded))
      (princ (format "Equal: %S\n" (equal str decoded))))))

;; Multibyte vs unibyte
(princ (format "Multibyte string: %S\n" (multibyte-string-p "hello")))
(let ((unibyte (string-to-unibyte "hello")))
  (princ (format "Unibyte string: %S\n" (multibyte-string-p unibyte))))

;;; 05-text-properties.el --- Test text properties

(princ "=== Text properties ===\n")

(with-temp-buffer
  ;; Add text with properties
  (insert "Hello, world!")
  (put-text-property 1 6 'face 'bold)
  (put-text-property 8 13 'font-lock-face 'font-lock-comment-face)
  (put-text-property 3 10 'category 'test-category)

  ;; Query properties
  (princ (format "Text: %S\n" (buffer-string)))
  (princ (format "Properties at 1: %S\n" (text-properties-at 1)))
  (princ (format "Properties at 3: %S\n" (text-properties-at 3)))
  (princ (format "Properties at 8: %S\n" (text-properties-at 8)))

  ;; Get property
  (princ (format "get-text-property 1 'face: %S\n" (get-text-property 1 'face)))
  (princ (format "get-text-property 3 'category: %S\n" (get-text-property 3 'category)))

  ;; Next property change
  (princ (format "next-property-change 1: %S\n" (next-property-change 1)))
  (princ (format "next-property-change 6: %S\n" (next-property-change 6)))

  ;; Substring with properties
  (let ((substr (buffer-substring 1 10)))
    (princ (format "Substring 1-10: %S\n" substr))
    (princ (format "Props at pos 1 in substr: %S\n" (text-properties-at 1 substr))))

  ;; Remove properties
  (remove-text-properties 1 6 '(face nil))
  (princ (format "After remove face: %S\n" (text-properties-at 1))))

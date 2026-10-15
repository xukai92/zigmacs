;;; 12-char-tables.el --- Test char-tables

(princ "=== Char-tables ===\n")

;; Create char-table
(let ((ct (make-char-table 'test-purpose 'default-value)))

  ;; Set values
  (aset ct ?a 'letter-a)
  (aset ct ?z 'letter-z)
  (aset ct ?0 'digit-zero)

  ;; Get values
  (princ (format "aref ct ?a: %S\n" (aref ct ?a)))
  (princ (format "aref ct ?z: %S\n" (aref ct ?z)))
  (princ (format "aref ct ?b: %S (default)\n" (aref ct ?b)))

  ;; Set range
  (set-char-table-range ct '(?A . ?Z) 'uppercase)
  (princ (format "After set-range A-Z: aref ?A: %S, ?M: %S, ?Z: %S\n"
                 (aref ct ?A) (aref ct ?M) (aref ct ?Z)))

  ;; Iterate
  (princ "Char-table map:\n")
  (let ((entries nil))
    (map-char-table
     (lambda (key value)
       (push (cons key value) entries))
     ct)
    ;; Print first few entries
    (dolist (e (seq-take (nreverse entries) 5))
      (princ (format "  %S -> %S\n" (car e) (cdr e))))))

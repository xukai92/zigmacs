;;; 09-hash-tables.el --- Test hash tables

(princ "=== Hash tables ===\n")

;; Create hash table
(let ((ht (make-hash-table :test 'equal)))

  ;; Add entries
  (puthash "key1" 'value1 ht)
  (puthash "key2" 'value2 ht)
  (puthash "key3" 'value3 ht)
  (puthash 42 'forty-two ht)

  (princ (format "Hash table size: %d\n" (hash-table-count ht)))

  ;; Retrieve
  (princ (format "gethash 'key1': %S\n" (gethash "key1" ht)))
  (princ (format "gethash 42: %S\n" (gethash 42 ht)))
  (princ (format "gethash 'missing': %S (default: 'none)\n"
                 (gethash "missing" ht 'none)))

  ;; Iterate (order is deterministic per insertion in Emacs)
  (princ "Iteration:\n")
  (maphash (lambda (k v)
             (princ (format "  %S -> %S\n" k v)))
           ht)

  ;; Remove
  (remhash "key2" ht)
  (princ (format "After remhash 'key2', size: %d\n" (hash-table-count ht)))

  ;; Different tests
  (let ((ht-eq (make-hash-table :test 'eq))
        (ht-eql (make-hash-table :test 'eql)))
    (puthash "abc" 1 ht-eq)
    (puthash "abc" 2 ht-eql)
    (princ (format "eq hash: %S, eql hash: %S\n"
                   (gethash "abc" ht-eq)
                   (gethash "abc" ht-eql)))))

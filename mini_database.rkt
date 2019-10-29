(define NULL 'null)

;====================================
;=            Cerința 1             =
;= Definirea elementelor de control =
;=          20 de puncte            =
;====================================

;= Funcțiile de acces
(define init-database
  (λ ()
    '())) 

(define create-table
  (λ (table columns-name)
    (append (list (list table)) (map list columns-name))))
     
(define get-name
  (λ (table)
    (caar table)))

(define get-columns 
  (λ (table)
    (foldr (lambda (column columns) (cons (car column) columns)) '() (cdr table))))

(define get-tables
  (λ (db)
    (if (null? db)
        '() 
        (foldl (lambda (x result) (cons (list (list (get-name x))) result)) '() db))))

(define get-table
  (λ (db table-name)
    (car (filter (lambda (x) (equal? (get-name x) table-name)) db))))

(define add-table
  (λ (db table)
    (if (null? db)
        (list table)
        (append db (list table)))))

(define remove-table
  (λ (db table-name)
    (filter (lambda (x) (not (equal? (get-name x) table-name))) db)))

;= Pentru testare, va trebui să definiți o bază de date (având identificatorul db) cu următoarele tabele

;============================================================================================
;=                         Tabela Studenți                                                   =
;= +----------------+-----------+---------+-------+-------+                                  =
;= | Număr matricol |   Nume    | Prenume | Grupă | Medie |                                  =
;= +----------------+-----------+---------+-------+-------+                                  =
;= |            123 | Ionescu   | Gigel   | 321CA |  9.82 |                                  =
;= |            124 | Popescu   | Maria   | 321CB |  9.91 |                                  =
;= |            125 | Popa      | Ionel   | 321CC |  9.99 |                                  =
;= |            126 | Georgescu | Ioana   | 321CD |  9.87 |                                  =
;= +----------------+-----------+---------+-------+-------+                                  =
;=                                                                                           =
;=                                         Tabela Cursuri                                    =
;= +------+----------+-----------------------------------+---------------+------------+      =
;= | Anul | Semestru |            Disciplină             | Număr credite | Număr teme |      =
;= +------+----------+-----------------------------------+---------------+------------+      =
;= | I    | I        | Programarea calculatoarelor       |             5 |          2 |      =
;= | II   | II       | Paradigme de programare           |             6 |          3 |      =
;= | III  | I        | Algoritmi paraleli și distribuiți |             5 |          3 |      =
;= | IV   | I        | Inteligență artificială           |             6 |          3 |      =
;= | I    | II       | Structuri de date                 |             5 |          3 |      =
;= | III  | II       | Baze de date                      |             5 |          0 |      =
;= +------+----------+-----------------------------------+---------------+------------+      =
;============================================================================================
(define db '((("Studenți") ("Număr matricol" 123 124 125 126)
                           ("Nume" "Ionescu" "Popescu" "Popa" "Georgescu")
                           ("Prenume" "Gigel" "Maria" "Ionel" "Ioana")
                           ("Grupă" "321CA" "321CB" "321CC" "321CD")
                           ("Medie" 9.82 9.91 9.99 9.87))
             (("Cursuri") ("Anul" "I" "II" "III" "IV" "I" "III")
                          ("Semestru" "I" "II" "I" "I" "II" "II")
                          ("Disciplină" "Programarea calculatoarelor" "Paradigme de programare"
                                        "Algoritmi paraleli și distribuiți" "Inteligență artificială"
                                        "Structuri de date" "Baze de date")
                          ("Număr credite" 5 6 5 6 5 5)
                          ("Număr teme" 2 3 3 3 3 0))))

;====================================
;=            Cerința 2             =
;=         Operația insert          =
;=            10 puncte             =
;====================================
(define insert
  (λ (db table-name record)
    (let ((table (get-table db table-name)))
      (let-values (((z y) (splitf-at db (lambda (x) (not (equal? (get-name x) (get-name table)))))))
        (remove '() (append z (list (append (list (list table-name)) (map (lambda (x) (insert-in-column x record)) (cdr table)))) (cdr y)))))))

(define insert-in-column
  (λ (column record)
    (let ((old-column column))
      (let insert ((column column) (record record))
        (if (null? record)
            (if (equal? old-column column)
                (append old-column (list NULL))
                column)
            (if (equal? (car column) (car (car record)))
                (insert (append column (list (cdr (car record)))) (cdr record))
                (insert column (cdr record))))))))

;====================================
;=            Cerința 3 a)          =
;=     Operația simple-select       =
;=             10 puncte            =
;====================================
(define simple-select
  (λ (db table-name columns)
    (let ((table (get-table db table-name)))
      (let ((selection (foldr (lambda (x y) (cons (get-column table x) y)) '() columns)))
        (if (equal? (ormap length selection) 0)
            '()
            selection)))))

(define get-column
  (λ (table column)
    (cdr (car (filter (lambda (x) (equal? (car x) column)) table)))))

;====================================
;=            Cerința 3 b)          =
;=           Operația select        =
;=            30 de puncte          =
;====================================
(define select
  (λ (db table-name columns conditions)
    (let ((table (get-table db table-name)))
      (let ((filtered-lines (foldl (lambda (x y) (apply-condition x (map list (get-columns table)) y )) (cdr table) conditions)))
        (map (lambda (x) (if (pair? x)
                             (case (car x)
                               ['min (car (argmin car (map list (get-column filtered-lines (cdr x)))))]
                               ['max (car (argmax car (map list (get-column filtered-lines (cdr x)))))]
                               ['count (length (remove-duplicates (get-column filtered-lines (cdr x))))]
                               ['sum (foldl + 0 (get-column filtered-lines (cdr x)))]
                               ['avg (/ (foldl + 0 (get-column filtered-lines (cdr x))) (length (remove-duplicates (get-column filtered-lines (cdr x)))))]
                               ['sort-asc (sort (get-column filtered-lines (cdr x)) <)]
                               ['sort-desc (sort (get-column filtered-lines (cdr x)) >)])
                             (get-column filtered-lines x))) columns)))))

(define apply-condition
  (λ (condition columns table)
    (if (equal? (length (car table)) 1)
        columns
        (if (equal? (first (get-column table (cadr condition))) NULL)
            (apply-condition condition columns (map (lambda (x) (cons (car x) (cddr x))) table))
            (if ((car condition) (first (get-column table (cadr condition))) (caddr condition))
                (apply-condition condition (map (lambda (x y) (append x (list (cadr y)))) columns table)
                                 (map (lambda (x) (cons (car x) (cddr x))) table))
                (apply-condition condition columns
                                 (map (lambda (x) (cons (car x) (cddr x))) table)))))))
;====================================
;=             Cerința 4            =
;=           Operația update        =
;=            20 de puncte          =
;====================================
(define update
  (λ (db table-name values conditions)
    (let ((table (get-table db table-name)) (data-base (filter (lambda (x) (not (equal? (caar x) table-name))) db)))
      (let ((columns (map list (get-columns table))))
        (let ((first-line (map (lambda (x y) (append x (list (cadr y)))) columns (cdr table))) )
          (let ((updated-table (map (lambda (x) (map car x)) (apply map list (update-line (cdr table) first-line conditions columns values)))))
            (append data-base (list (append (list (list table-name)) (map (lambda (x y) (append x y)) columns updated-table))))))))))


(define update-line
  (λ (table-D  line conditions columns values)         
    (if (equal? (length (car table-D)) 2)
        (if (apply-conditions line conditions columns)
            (list (map cdr (apply-changes line values)))
            (list (map cdr line)))
        (let ((new-table (map (lambda (x) (cons (car x) (cddr x))) table-D)) )
          (if (apply-conditions line conditions columns)
              (cons (map cdr (apply-changes line values))
                    (update-line new-table (map (lambda (x y) (append x (list (cadr y)))) columns new-table) conditions columns values))
              (cons (map cdr line)
                    (update-line new-table (map (lambda (x y) (append x (list (cadr y)))) columns new-table) conditions columns values)))))))

(define apply-changes
  (λ (line values)
    (map (lambda(x) (let ((replace (filter (lambda (y) (equal? (car y) (car x))) values)))
                      (if (null? replace)
                          x
                          (list (caar replace) (cdar replace))))) line)))

(define apply-conditions
  (λ (line conditions columns)
    (let repeat ((column-names columns) (conditions conditions) (line line))
      (if (null? conditions)
          #t
          (if (equal? (length (car (apply-condition (car conditions) columns line))) 1)
              #f
              (repeat column-names (cdr conditions) line))))))
              
;====================================
;=             Cerința 5            =
;=           Operația remove        =
;=              10 puncte           =
;====================================
(define delete
  (λ (db table-name conditions)
    (let ((table (get-table db table-name)) (data-base (filter (lambda (x) (not (equal? (caar x) table-name))) db)) )
      (if (null? conditions)
          (append data-base (list (list (list table-name))))
          (let ((columns (map list (get-columns table))))
            (let ((first-line (map (lambda (x y) (append x (list (cadr y)))) columns (cdr table))) )
              (let ((deleted-table (delete-line (cdr table) first-line conditions columns)))
                (if (null? deleted-table)
                    (append data-base (list (append (list (list table-name)) columns)))
                    (let ((updated-table (map (lambda (x) (map car x)) (apply map list (delete-line (cdr table) first-line conditions columns)))))
                      (append data-base (list (append (list (list table-name)) (map (lambda (x y) (append x y)) columns updated-table)))))))))))))

(define delete-line
  (λ (table line conditions columns)
    (if (equal? (length (car table)) 2)
        (if (apply-conditions line conditions columns)
            '()
            (list (map cdr line)))
        (let ((new-table (map (lambda (x) (cons (car x) (cddr x))) table)) )
          (if (apply-conditions line conditions columns)
              (delete-line new-table (map (lambda (x y) (append x (list (cadr y)))) columns new-table) conditions columns)
              (cons (map cdr line) (delete-line new-table (map (lambda (x y) (append x (list (cadr y)))) columns new-table) conditions columns)))))))

;====================================
;=               Bonus              =
;=            Natural Join          =
;=            20 de puncte          =
;====================================
(define natural-join
  (λ (db tables columns conditions)
    (let ((table1 (get-table db (car tables))) (table2 (get-table db (cadr tables))))
      (let ((new-db (filter (lambda (x) (not (or (equal? (caar x) (car tables)) (equal? (caar x) (cadr tables))))) db)))
        (let ((common-column (car (filter (lambda (x) (member (car x) (map car table1))) table2))))
          (let ((new-table (append (list (car table1))
                                   (append (cdr table1)
                                           (map (lambda (x) (cons x (build-list (sub1 (length (cadr table1))) (lambda (x) NULL))))
                                                (get-columns (remove common-column table2)))))))        
            (let ((column-pair (map (lambda(y) (map (lambda (x) (cons (car y) x)) (cdr y))) (cdr (remove common-column table2)))))
              (let ((reference-column (map (lambda (x) (cons (car common-column) x)) (cdr common-column))))
                (let ((join-conditions (map (lambda (x) (list (list = (car x) (cdr x)))) reference-column)))
                  (let ((new-table (select (foldl (lambda (x y result) (update result (caar table1)  x y))
                                                  (append new-db (list new-table))
                                                  (apply map list column-pair)
                                                  join-conditions)
                                           (caar table1) columns conditions)))
                    (apply map list (filter (lambda (x) (not (member NULL x))) (apply map list new-table)))))))))))))
                

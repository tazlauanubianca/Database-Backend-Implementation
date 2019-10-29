# Database backend implementation in Racket

The implementation of the tables was realized keeping the elements a column in a single list. Thus, a table was made up of a list
of lists in which the first list contained table names, and in the other lists the columns of the table were kept. The first item in each list it was the name of the column, the rest of the elements being the elements corresponding to the column.
If one of the entries did not have an element on one of the columns, instead respectively it is completed with NULL in the table.
Thus, a database will be kept in the form:
```
'((("Studenți") ("Număr matricol" 123 124 125 126)
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
```

## Elementary functions

First, the elementary functions for a database were implemented:
* init-database: Returns the life list
* create-table: Returns a list of lists in which the first list it has the table name and the other lists contain column names
* get-name: returns the first element in the first list of the table, that is, its name
* get-columns: Browse all lists in the table except the first
* the list containing the table name. From each the list is kept only the first element of each. This gives a list of tutor names columns.
* get-tables: Browse each list in the database and keep only the element of the first list of each table. This gives a list of all the names of the tables in the list.
* add-table: add a new table at the end of the database
* remove-table: Browse the database and remove the corresponding table

## Insert function

The function breaks the database into two distinct lists: the list of tables before it the table in which we want to insert the list of those after. In this way the elements from the table are kept in order and after insertion. The elements of the table in which they are
they went through one at a time and new elements are inserted on each column. If a column missing an item, NULL will be replaced instead.

## The simple-select function

The function goes through each element in the list with the names of the desired columns and calls an auxiliary function, get-column, that returns the elements of the respective column. From all the elements returned by the get-column function will make a list that will return
simple-select function.

## Select function

The function first goes through each condition and applies it to the given table until only they remain those entries that comply with all the conditions imposed. To accomplish this the table is passed to the apply-condition function that will return the elements in the table that respect a certain condition. After only the elements that meet the conditions are obtained of line, the filters for the column (min, max, count ...) will be applied. For this thing each column is traversed and if there is a filter for the respective column which
a corresponding case must be applied in a switch structure.

## Update function

The update function will select the table where you want to make changes and it will process. First, it will call the update-line function that runs the lines and if they meet all the conditions in the list, the desired changes will be applied and it will be kept in the final result. To determine if a line has all the conditions met the line will be sent to an auxiliary function apply-conditions
which will return true if they are met and false otherwise.

## Delete function

The function first checks if it has conditions to be met and if it will not be deleted the whole table. Then the table will be drawn line by line and checked if the line meets the conditions. If they meet the conditions of the respective line it will be deleted from the table and the new table will be restored with the lines kept. Finally the database will be restored and returned.

## Natural join

The function will first find the common column of the two tables. This will be the column depending on which the two tables will be joined. In the first table will be added lists of lengths equal to those already present in the table. These lists will represent the columns in the second table without the common column. Lists will be formed at the beginning of the column name, on the first position, and NULL on the following positions. After the formation step of the new table, pairs of shapes will be formed (cons "Column_name" "Value") from the lists in the second table without the column common. From the common column form conditions will be formed (list = "Column Name" "Value").
The lists thus formed, the one for the values we want for the elements in the new table and the list of conditions after which the changes are made, the defined update function will be called previously that will take all the pairs corresponding to a condition and apply them to the new one table. This process will be repeated for all the present conditions. Thus, in the place where the entries in the first table correspond to the common column with those in the second table, will be complete the values in the second table in the newly added columns.
The updated table will be further entered into the database and the database will be returned.



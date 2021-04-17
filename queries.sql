#!/bin/bash
chcp 65001

echo 1. Определить и удалить дубли в таблице посещаемости (если студент посетил занятие в определенную дату, то запись об этом должна быть в таблице только одна). Сделать это нужно одним запросом.
echo --------------------------------------------------
sqlite3 attendance.db -box -echo "SELECT DISTINCT students.surname, attendance.date FROM attendance INNER JOIN students ON students.id = attendance.student_id;"
echo " "

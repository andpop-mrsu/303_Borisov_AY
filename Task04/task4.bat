#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo 1. Найти все комедии, выпущенные после 2000 года, которые понравились мужчинам (оценка не ниже 4.5). Для каждого фильма в этом списке вывести название, год выпуска и количество таких оценок.
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT movies.title as 'Movie', movies.year as 'Year', COUNT(*) as 'Count of good ratings' FROM movies INNER JOIN(SELECT * FROM ratings WHERE rating>=4.5) ratings on ratings.movie_id = movies.id INNER JOIN(SELECT * FROM users WHERE users.gender = 'male') users ON ratings.user_id = users.id WHERE movies.id > 2000 AND instr(genres, 'Comedy')>0 GROUP BY title;"
echo " "

echo 2.Провести анализ занятий (профессий) пользователей - вывести количество пользователей для каждого рода занятий. Найти самую распространенную и самую редкую профессию посетитетей сайта.
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "CREATE VIEW occupations AS SELECT occupation AS 'occupation', COUNT(occupation) AS 'number' FROM users GROUP BY occupation;"
sqlite3 movies_rating.db -box -echo "SELECT * FROM occupations;"
sqlite3 movies_rating.db -box -echo "SELECT occupation AS 'the most rare' FROM occupations WHERE occupations.number = (SELECT MIN(number) FROM occupations);"
sqlite3 movies_rating.db -box -echo "SELECT occupation AS 'the most common' FROM occupations WHERE occupations.number = (SELECT MAX(number) FROM occupations);"
sqlite3 movies_rating.db -box -echo "drop view occupations;"
echo " "

echo 3.Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили.
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT movies.title as 'Movie', user1.name as 'User 1', user2.name as 'User 2' FROM ratings rat1, ratings rat2 INNER JOIN movies ON rat1.movie_id = movies.id INNER JOIN users user1 ON rat1.user_id = user1.id INNER JOIN users user2 ON rat2.user_id = user2.id WHERE rat1.movie_id = rat2.movie_id and rat1.user_id < rat2.user_id order by title limit 100;"
echo " "

echo 4.Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД.
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT movies.title, users.name, ratings.rating, date(ratings.timestamp,'unixepoch') FROM ratings INNER JOIN movies ON ratings.movie_id = movies.id INNER JOIN users ON users.id = ratings.user_id ORDER BY timestamp DESC LIMIT 10;"
echo " "

echo 5.Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке "Рекомендуем" для фильмов должно быть написано "Да" или "Нет".
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "CREATE VIEW movie_list AS SELECT movies.title AS 'Title', movies.year AS 'Year', AVGRating from movies INNER JOIN(SELECT ratings.movie_id, AVG(ratings.rating) AS 'AVGRating' FROM ratings GROUP BY ratings.movie_id) ratings on ratings.movie_id = movies.id;"
sqlite3 movies_rating.db -box -echo "SELECT Title, Year, AVGRating, case WHEN AVGRating = (SELECT MAX(AVGRating) FROM  movie_list) then 'Yes' WHEN AVGRating = (SELECT MIN(AVGRating) FROM  movie_list) then 'No' end  AS 'Рекомендуем' FROM movie_list WHERE AVGRating = (SELECT MIN(AVGRating) FROM  movie_list) OR AVGRating = (SELECT MAX(AVGRating) FROM  movie_list) ORDER BY Year, Title;"
echo " "

echo 6.Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "CREATE view femrat AS SELECT ratings.rating AS 'rating', ratings.timestamp as 'Date' FROM ratings INNER JOIN(SELECT users.id, users.gender FROM users WHERE users.gender = 'female') users on users.id = ratings.user_id WHERE date(ratings.timestamp,'unixepoch') between '2010' and '2012' order by ratings.timestamp;" 
sqlite3 movies_rating.db -box -echo "SELECT COUNT(rating) AS 'ratings from women', AVG(rating) AS 'AVG rating' FROM femrat; DROP view femrat;"
echo " "

echo 7.Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей.
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT Title, Year, AVGRating, ROW_NUMBER() over(ORDER BY AVGRating DESC) AS 'Place' FROM movie_list ORDER BY Year, Title Limit 20;"
sqlite3 movies_rating.db -box -echo "DROP view movie_list;"
echo " "

echo 8.Определить самый распространенный жанр фильма и количество фильмов в этом жанре.
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT id, title, genres FROM movies WHERE id = 78;"
sqlite3 movies_rating.db -box -echo "CREATE VIEW genre AS WITH t(id, genr, Rest) AS (SELECT id, null, genres from movies union all select id, case when instr(Rest, '|')=0 then Rest  else substr(Rest, 1, instr(Rest, '|')-1) end, case when instr(Rest, '|')=0 then null else substr(Rest, instr(Rest, '|')+1) end from t where Rest is not null order by id) SELECT genr AS 'Genres_for_count', COUNT(id) AS 'Number' FROM t WHERE genr IS NOT NULL GROUP BY genr;"
sqlite3 movies_rating.db -box -echo "SELECT Genres_for_count AS 'The most popular genre', Number FROM genre WHERE Number = (SELECT MAX(Number) FROM genre); DROP VIEW genre;"
echo " "

echo "Восьмое задание написано с помощью статьи на stackoverflow - https://ru.stackoverflow.com/questions/638098/%D0%9E%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0-%D1%81%D1%82%D1%80%D0%BE%D0%BA%D0%B8-%D0%B2-sqlite-%D0%A0%D0%B0%D0%B7%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B5-%D1%81%D1%82%D1%80%D0%BE%D0%BA%D0%B8-%D0%BD%D0%B0-%D0%BF%D0%BE%D0%B4%D1%81%D1%82%D1%80%D0%BE%D0%BA%D0%B8"









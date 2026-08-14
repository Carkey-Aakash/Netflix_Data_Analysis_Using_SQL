-- creating a new database 
CREATE DATABASE sql_project_p2;

-- creating a table as below
--At first if table name exists
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
( 
show_id VARCHAR(7),
type  VARCHAR(10),
title VARCHAR(110),
director VARCHAR(210),
casts  VARCHAR(800),
country VARCHAR(130),
date_added VARCHAR(20),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(80),
description VARCHAR(250)

)

-- showing query result
SELECT * FROM netflix;

-- Data cleaning -- 
-- checking if any null values are present -- 
SELECT * FROM netflix 
WHERE 
show_id IS NULL
OR type IS NULL
OR title IS NULL
OR director IS NULL
OR casts IS NULL
OR country IS NULL
OR release_year IS NULL
OR rating IS NULL
OR duration IS NULL
OR listed_in IS NULL
OR description IS NULL

-- CHEKING if all values  are null or not 
SELECT * FROM netflix 
WHERE 
show_id IS NULL
AND type IS NULL
AND title IS NULL
AND director IS NULL
AND casts IS NULL
AND country IS NULL
AND release_year IS NULL
AND rating IS NULL
AND duration IS NULL
AND listed_in IS NULL
AND description IS NULL
-- Result - not all values are null

-- DATA EXPLORATION-- 	
 -- checking total no of records 
 SELECT COUNT(*) FROM netflix; -- ans = 8807

 -- checking how many unique type are there
 SELECT DISTINCT type FROM netflix; --ans = movie ,Tv show

 -- checking count of each type -- 
 SELECT type, COUNT(*)
 FROM netflix
 GROUP BY type;  -- ans movie = 6131, Tv show = 2676

 -- cheking count of unique countries
 SELECT COUNT(DISTINCT country) FROM netflix; -- ans 748

 -- checking in which year most movie or tvshow is released.
 SELECT release_year, COUNT(*) as Total_number
 FROM netflix 
 GROUP BY release_year
 ORDER BY Total_number DESC
 LIMIT 1;  
 -- ans = 2018 with 1147


 -- checking  each rating columns and how many times they get
 SELECT rating ,COUNT(*)
 FROM netflix
 GROUP BY rating;

 -- BUSINESS QUESTION AND SQL QUERIES

 --Q.1  Find the top 5 realeased year.
 
 SELECT release_year,COUNT(*) AS ct_nbr
 FROM netflix
 GROUP BY release_year
 ORDER BY ct_nbr DESC
 LIMIT 5;

 -- Q.2 Find the most common rating for movies and TV shows
 SELECT type,rating,ct_nbr
 FROM 
 (
 SELECT type,rating,COUNT(*) AS ct_nbr,
 RANK() OVER(PARTITION BY type ORDER BY COUNT(*)  DESC) as rank
 FROM netflix
 GROUP BY type, rating) as t1
 WHERE rank = 1

 -- Q.3  List all movies released in a specific year (e.g., 2020)
 SELECT * 
 FROM netflix
 WHERE type = 'Movie' AND release_year =2020;

 --Q.4  Find the top 5 countries with the most content on Netflix
WITH new_netflix 
AS
(SELECT country,COUNT(*) AS total_count,
UNNEST(STRING_TO_ARRAY(country,',')) AS new_country
 FROM netflix 
 GROUP BY country
 ORDER BY total_count DESC )
 
 SELECT TRIM(new_country),COUNT(*) AS total_count
 FROM new_netflix
 GROUP BY TRIM(new_country)
 ORDER BY total_count DESC
 LIMIT 5;

 -- Q.5 Identify the longest movie

SELECT title, duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;

-- Q.6 find the content added in the last 5 years
-- since date are in two different format so using case for this


SELECT *
FROM netflix
WHERE 
    CASE 
        WHEN TRIM(date_added) LIKE '%-%-%'
            THEN TO_DATE(TRIM(date_added), 'DD-Mon-YY')
        ELSE TO_DATE(TRIM(date_added), 'Month DD, YYYY')
    END >= CURRENT_DATE - INTERVAL '5 years';

--Q.7 Find all the movies/TV show directed by director 'Rajiv Chilaka'?
SELECT * FROM
(
SELECT * ,
UNNEST(STRING_TO_ARRAY(director,',')) as new_director
FROM netflix
)
WHERE TRIM(new_director) = 'Rajiv Chilaka'

-- Q.8 Find all the TV Show greater with more than 5 seasons.
SELECT * FROM netflix
WHERE   
		type = 'TV Show'
		AND 
		CAST(SPLIT_PART(duration,' ',1)AS INTEGER) >5;

-- Q.9 Count the number of content items in each genre.
WITH new_netflix
AS
(
SELECT *,
UNNEST(STRING_TO_ARRAY(listed_in,','))as genre FROM netflix)

SELECT TRIM(genre),COUNT(*) AS total_content
FROM new_netflix
GROUP BY  TRIM(genre);

--Q.10 Find each year and the average number of content release in India in netflix
-- and return top 5 year with highest avg content release

WITH new_netflix
AS
(
SELECT *,
EXTRACT(YEAR FROM 
CASE
WHEN trim(date_added) LIKE '%-%-%' THEN
TO_DATE(trim(date_added),'DD-Mon-YY') ELSE
TO_DATE(trim(date_added),'MONTH DD,YYYY')
END 
)AS year
FROM netflix
)

SELECT year,COUNT(*) AS yearly_content,
(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM netflix where country ILIKE '%India%')::NUMERIC) * 100 as avg_content
FROM new_netflix
WHERE country ILIKE '%India%'
GROUP BY year
ORDER BY avg_content DESC 
LIMIT 5;

--Q.11 List all the movies that are documentries 

SELECT * FROM netflix
WHERE 
 	type= 'Movie' AND TRIM(listed_in) ILIKE '%Documentaries%' ;

-- Q.12 Find all the content without a director.
SELECT * FROM netflix 
WHERE director IS NULL;

--Q.13 Find how many movies where actor  salman khan appearead in last '10 years' ?
SELECT COUNT(*) as total_movies FROM netflix
WHERE 
	type= 'Movie'
	AND casts  ILIKE '%Salman Khan%'
	AND 
	CASE 
	WHEN trim(date_added) LIKE '%-%-%' THEN
	TO_DATE(trim(date_added),'DD-Mon-YY') ELSE
	TO_DATE(trim(date_added),'MONTH DD, YYYY')
	END >= CURRENT_DATE - INTERVAL '10 years'

--Q.14 Find the top 10 actors who have appeared in the highest numbers of movies in last 10 years
WITH top_actors 
AS
(
SELECT *,
UNNEST(STRING_TO_ARRAY(casts,',')) as actor
FROM netflix
WHERE 
	country ILIKE '%India%' AND type ='Movie'
)

SELECT TRIM(actor),COUNT(*) as total_movie
FROM top_actors
WHERE 
	CASE
	WHEN TRIM(date_added) LIKE '%-%-%' THEN
	TO_DATE(TRIM(date_added),'DD-Mon-YY') ELSE
	TO_DATE(TRIM(date_added),'MONTH DD, YYYY') 
	END >= CURRENT_DATE - INTERVAL '10 years'
GROUP BY TRIM(actor)
ORDER BY  total_movie  DESC 
LIMIT 10 ;

-- Q.15 categorize the content based on the presence of keywords 'kill' and 'violence'
-- in the description field. Label content containing these keywords as 'bad' and all others 
-- content as 'good'. How many items falls into each category.
WITH new_category
AS 
(
SELECT *,
CASE
	WHEN  description ~* '\mkill\M'
	OR description  ~* '\mviolence\M' THEN 'bad_content'
	ELSE 'good_content'
END AS category
FROM netflix
)

SELECT category,COUNT(*) AS total_content
FROM new_category
GROUP BY category
	
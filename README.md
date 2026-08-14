# Netflix Data Analysis using SQL

## Project Overview

This project is a SQL-based analysis of the Netflix dataset. The purpose of this project is to explore Netflix movies and TV shows and answer different business-related questions using SQL.

The dataset contains information about Netflix content such as title, type, director, cast, country, release year, rating, duration, genre, and description.

I used PostgreSQL to perform the analysis. The project includes data cleaning, data exploration, and 15 business questions that are solved using SQL queries.

## Dataset

The dataset contains **8,807 Netflix movies and TV shows** with the following columns:

| Column         | Description                                 |
| -------------- | ------------------------------------------- |
| `show_id`      | Unique ID of the Netflix content            |
| `type`         | Type of content, Movie or TV Show           |
| `title`        | Title of the movie or TV show               |
| `director`     | Director of the content                     |
| `casts`        | Actors and actresses                        |
| `country`      | Country where the content was produced      |
| `date_added`   | Date when the content was added to Netflix  |
| `release_year` | Original release year                       |
| `rating`       | Content rating                              |
| `duration`     | Movie duration or number of TV show seasons |
| `listed_in`    | Genre/category of the content               |
| `description`  | Description of the content                  |

## Dataset Overview

* Total records: 8,807
* Content types: 2
* Movies: 6,131
* TV Shows: 2,676
* Unique countries: 748
* Most common release year: 2018
* Number of columns: 12

## Tools Used

* PostgreSQL
* SQL
* CSV Dataset
* phpMyAdmin

## Database and Table

The database was created using:

```sql
CREATE DATABASE sql_project_p2;
```

The `netflix` table was created using:

```sql
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
    show_id VARCHAR(7),
    type VARCHAR(10),
    title VARCHAR(110),
    director VARCHAR(210),
    casts VARCHAR(800),
    country VARCHAR(130),
    date_added VARCHAR(20),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(80),
    description VARCHAR(250)
);
```

## Data Cleaning

Before performing the analysis, I checked whether there were NULL values in the important columns.

```sql
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
    OR description IS NULL;
```

I also checked whether there were records where all of these columns were NULL.

```sql
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
    AND description IS NULL;
```

The result showed that not all values in a record were NULL.

## Data Exploration

### Total number of records

```sql
SELECT COUNT(*) FROM netflix;
```

Result: **8,807**

### Unique content types

```sql
SELECT DISTINCT type FROM netflix;
```

Result:

* Movie
* TV Show

### Count of each content type

```sql
SELECT type, COUNT(*)
FROM netflix
GROUP BY type;
```

Result:

* Movie: 6,131
* TV Show: 2,676

### Number of unique countries

```sql
SELECT COUNT(DISTINCT country) FROM netflix;
```

Result: **748**

### Year with the highest number of released content

```sql
SELECT release_year, COUNT(*) AS Total_number
FROM netflix 
GROUP BY release_year
ORDER BY Total_number DESC
LIMIT 1;
```

Result: **2018 with 1,147 content items**

### Count of each rating

```sql
SELECT rating, COUNT(*)
FROM netflix
GROUP BY rating;
```

# Business Questions and SQL Queries

## Q.1 Find the top 5 realeased year.

```sql
SELECT release_year,COUNT(*) AS ct_nbr
FROM netflix
GROUP BY release_year
ORDER BY ct_nbr DESC
LIMIT 5;
```

## Q.2 Find the most common rating for movies and TV shows

```sql
SELECT type,rating,ct_nbr
FROM 
(
    SELECT type,rating,COUNT(*) AS ct_nbr,
    RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as rank
    FROM netflix
    GROUP BY type, rating
) as t1
WHERE rank = 1;
```

## Q.3 List all movies released in a specific year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```

## Q.4 Find the top 5 countries with the most content on Netflix

```sql
WITH new_netflix 
AS
(
    SELECT country,COUNT(*) AS total_count,
    UNNEST(STRING_TO_ARRAY(country,',')) AS new_country
    FROM netflix 
    GROUP BY country
    ORDER BY total_count DESC
)

SELECT TRIM(new_country),COUNT(*) AS total_count
FROM new_netflix
GROUP BY TRIM(new_country)
ORDER BY total_count DESC
LIMIT 5;
```

## Q.5 Identify the longest movie

```sql
SELECT title, duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;
```

## Q.6 find the content added in the last 5 years

```sql
SELECT *
FROM netflix
WHERE 
    CASE 
        WHEN TRIM(date_added) LIKE '%-%-%'
            THEN TO_DATE(TRIM(date_added), 'DD-Mon-YY')
        ELSE TO_DATE(TRIM(date_added), 'Month DD, YYYY')
    END >= CURRENT_DATE - INTERVAL '5 years';
```

## Q.7 Find all the movies/TV show directed by director 'Rajiv Chilaka'?

```sql
SELECT * FROM
(
    SELECT *,
    UNNEST(STRING_TO_ARRAY(director,',')) as new_director
    FROM netflix
)
WHERE TRIM(new_director) = 'Rajiv Chilaka';
```

## Q.8 Find all the TV Show greater with more than 5 seasons.

```sql
SELECT * FROM netflix
WHERE   
    type = 'TV Show'
    AND 
    CAST(SPLIT_PART(duration,' ',1) AS INTEGER) > 5;
```

## Q.9 Count the number of content items in each genre.

```sql
WITH new_netflix
AS
(
    SELECT *,
    UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre
    FROM netflix
)

SELECT TRIM(genre),COUNT(*) AS total_content
FROM new_netflix
GROUP BY TRIM(genre);
```

## Q.10 Find each year and the average number of content release in India in netflix and return top 5 year with highest avg content release

```sql
WITH new_netflix
AS
(
    SELECT *,
    EXTRACT(YEAR FROM 
        CASE
            WHEN trim(date_added) LIKE '%-%-%' THEN
                TO_DATE(trim(date_added),'DD-Mon-YY')
            ELSE
                TO_DATE(trim(date_added),'MONTH DD,YYYY')
        END 
    ) AS year
    FROM netflix
)

SELECT year,
COUNT(*) AS yearly_content,
(COUNT(*)::NUMERIC / 
    (SELECT COUNT(*) 
     FROM netflix 
     WHERE country ILIKE '%India%')::NUMERIC
) * 100 AS avg_content
FROM new_netflix
WHERE country ILIKE '%India%'
GROUP BY year
ORDER BY avg_content DESC 
LIMIT 5;
```

## Q.11 List all the movies that are documentries

```sql
SELECT * FROM netflix
WHERE 
    type = 'Movie' 
    AND TRIM(listed_in) ILIKE '%Documentaries%';
```

## Q.12 Find all the content without a director.

```sql
SELECT * FROM netflix 
WHERE director IS NULL;
```

## Q.13 Find how many movies where actor salman khan appearead in last '10 years' ?

```sql
SELECT COUNT(*) as total_movies 
FROM netflix
WHERE 
    type = 'Movie'
    AND casts ILIKE '%Salman Khan%'
    AND 
    CASE 
        WHEN trim(date_added) LIKE '%-%-%' THEN
            TO_DATE(trim(date_added),'DD-Mon-YY')
        ELSE
            TO_DATE(trim(date_added),'MONTH DD, YYYY')
    END >= CURRENT_DATE - INTERVAL '10 years';
```

## Q.14 Find the top 10 actors who have appeared in the highest numbers of movies in last 10 years

```sql
WITH top_actors 
AS
(
    SELECT *,
    UNNEST(STRING_TO_ARRAY(casts,',')) as actor
    FROM netflix
    WHERE 
        country ILIKE '%India%' 
        AND type = 'Movie'
)

SELECT TRIM(actor),COUNT(*) as total_movie
FROM top_actors
WHERE 
    CASE
        WHEN TRIM(date_added) LIKE '%-%-%' THEN
            TO_DATE(TRIM(date_added),'DD-Mon-YY')
        ELSE
            TO_DATE(TRIM(date_added),'MONTH DD, YYYY') 
    END >= CURRENT_DATE - INTERVAL '10 years'
GROUP BY TRIM(actor)
ORDER BY total_movie DESC 
LIMIT 10;
```

## Q.15 categorize the content based on the presence of keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'bad' and all others as 'good'. How many items falls into each category.

```sql
WITH new_category
AS 
(
    SELECT *,
    CASE
        WHEN description ~* '\mkill\M'
        OR description ~* '\mviolence\M' THEN 'bad_content'
        ELSE 'good_content'
    END AS category
    FROM netflix
)

SELECT category,COUNT(*) AS total_content
FROM new_category
GROUP BY category;
```

## SQL Topics Practiced

During this project, I practiced the following SQL concepts:

* SELECT
* WHERE
* GROUP BY
* ORDER BY
* LIMIT
* DISTINCT
* COUNT()
* RANK()
* Window Functions
* PARTITION BY
* CTEs
* Subqueries
* CASE statements
* STRING_TO_ARRAY()
* UNNEST()
* TRIM()
* SPLIT_PART()
* CAST()
* EXTRACT()
* TO_DATE()
* TO_CHAR()
* ILIKE
* Regular expressions
* Date and time operations
* NULL value handling

## What I Learned

This project helped me improve my SQL skills by working with a real-world dataset containing Netflix movies and TV shows.

I learned how to explore a large dataset, handle NULL values, work with multiple values stored in a single column, extract information from dates and durations, and answer business questions using SQL.

I also practiced more advanced SQL techniques such as CTEs, subqueries, window functions, ranking, string manipulation, and regular expressions.

## Project Structure

```text
Netflix-SQL-Analysis/
│
├── netflix_titles.csv
├── netflix_business.sql
└── README.md
```

## How to Run the Project

1. Download or clone this repository.
2. Open PostgreSQL.
3. Create the database using the SQL file.
4. Create the `netflix` table.
5. Import the `netflix_titles.csv` dataset.
6. Run the queries from `netflix_business.sql`.

## Future Improvements

Some possible improvements for this project are:

* Create a Power BI dashboard
* Analyze Netflix content trends over the years
* Compare Movies and TV Shows in more detail
* Analyze content by country
* Analyze ratings and genres
* Create visualizations for yearly content growth
* Perform more detailed actor and director analysis

## Author

**Akash Karki**

BSc. CSIT Student

Interested in Data Analysis, SQL, Python and Machine Learning


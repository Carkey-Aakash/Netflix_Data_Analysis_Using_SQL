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


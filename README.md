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

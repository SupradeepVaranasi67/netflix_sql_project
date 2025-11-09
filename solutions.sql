-- Netflix Project
drop table if exists netflix;
create table netflix(
	show_id	VARCHAR(6),
	type 	VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(208),
	actors 	 VARCHAR(1000),	
	country	 VARCHAR(150),
	date_added VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration 	VARCHAR(15),
	listed_in	VARCHAR(100),	
	description	VARCHAR(250)
);

select * from netflix;

select count(*) as total_content from netflix;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

select 
	type, count(*) as total_count
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows

select 
	type,
	rating
	-- count(*)
from
(
	select
		type,
		rating,
		count(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC ) as ranking
	from netflix
	group by 1, 2
) as t1
where ranking = 1

-- 3. List all movies released in a specific year (e.g., 2020)

select * 
	from netflix
	where 
		type='Movie'
		and
		release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

select
	distinct UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	count(show_id) as total_shows
from netflix
GROUP BY 1
ORDER BY 2
DESC LIMIT 5;


-- 5. Identify the longest movie

SELECT
	show_id,
	type,
	title,
	duration
from netflix
where 
	type='Movie'
	and
	duration = (select max(duration) from netflix)
order by duration DESC LIMIT 1



-- 6. Find content added in the last 5 years

select 
	date_added,
	type,
	duration,
	rating
from netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= (CURRENT_DATE - INTERVAL '5 years');


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select 
	show_id,
	type,
	title,
	director,
	rating
from netflix
where director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

select
	show_id,
	type,
	title,
	duration,
	rating
from netflix 
where 
	type = 'TV Show'
	and
	SPLIT_PART(duration, ' ', 1)::numeric > 5

-- 9. Count the number of content items in each genre

select
	distinct UNNEST(STRING_TO_ARRAY(listed_in, ',')) as new_genre,
	count(show_id) as total_count
from netflix
GROUP BY 1
ORDER BY 2 DESC;

-- 10.Find each year and the average numbers of content release in India on netflix.

select 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year_added,
	COUNT(show_id) as total_count,
	ROUND(
	COUNT(*)::numeric/(select COUNT(*) from netflix where country='India')::numeric*100
	, 2) as avg_count
from netflix
where country = 'India'
GROUP BY 1
ORDER BY 1 DESC;

-- return top 5 year with highest avg content release!

select 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year_added,
	COUNT(show_id) as total_content_released
from netflix
-- where country = 'India'
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

-- 11. List all movies that are documentaries


select
	show_id,
	title,
	type,
	director,
	listed_in
from netflix
where 
	listed_in ilike '%documentaries%'

-- 12. Find all content without a director

select 
	show_id,
	title,
	director,
	rating
from netflix
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select * from netflix;

select 
	show_id,
	title,
	release_year,
	actors,
	rating 
from netflix
where 
	actors like '%Salman Khan%'
	and 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 11
	

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
	UNNEST(STRING_TO_ARRAY(actors,',')),
	count(*)
from netflix
where country ilike '%india%'
GROUP BY 1
ORDER BY 2
DESC
LIMIT 10

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

with temp_table
as 
(select 
	*,
	CASE 
	WHEN description ilike '%kill%'
		 or
		 description ilike '%violence%'
		 THEN 'Bad_Content'
	ELSE 'Good_Content'
	END Category
from netflix
)
select 
	Category,
	count(*)
from temp_table
GROUP BY 1
	
	

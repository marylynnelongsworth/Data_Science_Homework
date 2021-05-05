-- 1. Create a new column called “status” in the rental table that uses a 
--    case statement to indicate if a film was returned late, early, or on time. 

SELECT r.*,  																-- select all columns from rental table aliased as "r"
		CASE WHEN CAST(r.return_date AS date) 								-- cast "return_date" as date 
				> (r.rental_date:: date + f.rental_duration) THEN 'Late'	-- if "rental_date" (cast as date) plus "rental_duration" is greater than due date, then dvd is late
			WHEN CAST(r.return_date AS date) 								-- cast "return_date" as date
				< (r.rental_date:: date + f.rental_duration) THEN 'Early'	-- if "rental_date" (cast as date) plus "rental_duration" is less than due date, then dvd is early
			WHEN CAST(r.return_date AS date) 								-- cast "return_date" as date
				= (r.rental_date:: date + f.rental_duration) THEN 'On Time'	-- if "rental_date" (cast as date) plus "rental_duration" is equal to due date, then dvd is on time
		ELSE 'Not Yet Returned' 											-- ELSE - someone is just hanging on
		END AS status														-- End looping through data when rows complete
FROM rental AS r															-- rental table aliased as "r"
	JOIN inventory AS i														-- inventory table aliased as "i"
		ON r.inventory_id = i.inventory_id  								-- JOIN rental table and inventory table on "inventory_id"
	JOIN film AS f															-- film table aliased as "f"
		ON i.film_id = f.film_id; 											-- JOIN inventory table and film table on "film_id"
----------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Show the total payment amounts for people who live in Kansas City or Saint Louis. 

SELECT cty.city,								-- select city column from city table aliased as "cty"
		SUM(f.rental_rate) AS rental_rate		-- "rental_rate" is the sum of the rental_rate column in the film table - aliased as "f"
FROM film AS f									-- film table aliased as "f"
	JOIN inventory AS i							-- inventory table aliased as "i"
		ON f.film_id = i.film_id				-- join inventory table and film table on "film_id"
	JOIN rental AS r							-- rental table aliased as "r"
		ON i.inventory_id = r.inventory_id		-- join inventory table and rental table on "inventory_id"
	JOIN customer AS cst						-- customer table aliased as "cst"
		ON r.customer_id = cst.customer_id		-- join rental table and customer table on "customer_id"
	JOIN address AS a							-- address table aliased as "a"
		ON cst.address_id = a.address_id		-- join customer table and address table on "address_id"
	JOIN city AS cty							-- city table aliased as cty
		ON a.city_id = cty.city_id				-- join address table and city table on "city_id"
WHERE cty.city ='Saint Louis' OR				-- return only rows where city column in city table is "Saint Louis"
	cty.city = 'Kansas City'					--    or rows where city column is "Kansas City"
GROUP BY cty.city;								-- group by the city column of the city table to get that sum in select
--------------------------------------------------------------------------------------------------------------------------------

-- 3.	How many film categories are in each category? 
--      Why do you think there is a table for category and a table for film category?

--   		1000 movies with 16 categories - and while this database does not do it, each movie
--  		could easily have a number of categories attached to it. Sci-fi/Horror, New/Music
-- 			And when the New isn't new any more, a film can be removed from the category.

SELECT c.name,									-- select the name column from the category table aliased as "c"
		count(f.film_id) AS number_of_films		-- count "film_id" entries in the film table and return it as "number of films"
FROM film AS f									-- film table aliased as "f"
	JOIN film_category AS fc					-- film category table aliased as "fc"
		ON f.film_id = fc.film_id				-- join film table and film category table on "film_id"
	JOIN category as c							-- category table aliased as "c"
		ON fc.category_id = c.category_id		-- join film category table and category table on "category_id"
GROUP by c.name									-- group categories by name
ORDER BY c.name;								-- order categories by name (ascending alphabetically
--------------------------------------------------------------------------------------------------------------------------------

-- 4. Show a roster for the staff that includes their email, address, city, 
--	  and country (not ids)

SELECT s.first_name,						-- select first name column of staff table aliased as "s"
		s.last_name,						-- select last name column of staff table aliased as "s"
		s.email,							-- select email column from staff table aliased as "s"
		a.address,							-- select address from address table aliased as "a"
		ct.city,							-- select city column from the city table aliased as "ct"
		cy.country							-- select country column from the country table aliased as "cy"
FROM staff AS s								-- staff table aliased as "s"
	JOIN address AS a						-- address table aliased as "a"
		ON s.address_id = a.address_id		-- join staff table and address table on "address_id"
	JOIN city AS ct							-- city table aliased as "ct"
		ON a.city_id = ct.city_id			-- join address table and city table on "city_id"
	JOIN country AS cy						-- country table aliased as "cy"
		ON ct.country_id = cy.country_id;	-- join city table and country table on "country_id"
----------------------------------------------------------------------------		

-- 5. Show the film_id, title, and length for the movies that were returned 
--     from May 15 to 31, 2005  ####  395 films were returned between the dates

SELECT f.film_id,							-- select film_id column from film table aliased as "f"
		f.title AS "Movie Title",			-- select title column from film table aliased as "f" and rename as "Movie Title"
		f.length AS "Minutes",				-- select length column from film table aliased as "f" and rename as "Minutes"
		r.return_date						-- select return_date from film table aliased as "f"
FROM rental as r							-- rental table aliased as "r"
	JOIN inventory as i						-- inventory table aliased as "i"
		ON r.inventory_id = i.inventory_id	-- join rental table and inventory table on "inventory_id"
	JOIN film as f							-- film table aliased as "f"
		ON i.film_id = f.film_id			-- join inventory table and film table on "film_id"
WHERE r.return_date							-- return only rows where the return date is between '05/15/2005' and '05/31/2005'
	BETWEEN '05/15/2005' AND '06/01/2005' 	-- NOTE! 06/01 used because return will only include dates before 06/01
ORDER BY r.return_date						-- order by return_date column from rental table
-------------------------------------------------------------------------------------	

-- 6. Write a subquery to show which movies are rented below the average price for all movies.

SELECT title,												 -- select title column from film table
	   rental_rate											 -- select rental_rate column from film table
FROM film													 -- film table not aliased since no join used
WHERE film_id IN (SELECT film_id							 -- SUBQUERY - select only those rows from inventory table
				  FROM inventory							 --    where the "film_id" matches "film_id" on film table
				  WHERE inventory_id IN (SELECT inventory_id -- SUB-SUBQUERY - select only those rows from the rental table 
										 FROM rental))		 --    where the "inventory_id" matches "inventory_id" on rental table
AND rental_rate < (SELECT AVG(rental_rate)::numeric(10,2)	 -- BACK TO MAIN QUERY - select only those rows where the "rental_rate"
					   FROM film);							 -- is less than the average "rental_rate" on rental table	
----------------------------------------------------------------------------------------------

-- 7. Write a join statement to show which moves are rented below the average price for all movies.

SELECT f.title,												 	-- select title from film table aliased as "f"
		f.rental_rate										 	-- select rental_rate from film table aliased as "f"
FROM rental AS r											 	-- rental table aliased as "r"
	JOIN inventory AS i										 	-- inventory table aliased as "i"
		ON r.inventory_id = i.inventory_id					 	-- join rental table and inventory table on "inventory_id"
	JOIN film as f											 	-- film table aliased as "f"
		ON i.film_id = f.film_id							 	-- join inventory table and film table on "film_id"
WHERE f.rental_rate < (SELECT AVG(rental_rate)::numeric(10,2)	-- SUBQUERY - select only those rows where "rental_rate" from
					   FROM film)								--   film table is less than the average "rental rate"
GROUP BY f.film_id,												-- group by film_id from film table aliased as "f"
		f.title,												-- group by title from film table aliased as "f"
		f.rental_rate											-- group by rental_rate from film table aliased as "f"
ORDER BY f.film_id;												-- order by film_id from film table aliased as "f"
---------------------------------------------------------------------------------------------

--8. Perform an explain plan on 6 and 7, and describe what you’re seeing and important ways they differ.

-- Looking at the Explain for both 6 & 7, I noticed that both run at the same time of 100 to 120 ms.
-- Both have 4 sequence scans (2 for film, 1 for inventory, and 1 for rental), but they differ on 
-- aggrigates with Subqueries having 3, and Joins having only 2. Subqueries have a total of 11 actions
-- while joins have 10. Of the differences, the largest is that, while Joins start at film, Subqueries
-- start with rental. The importance of this is that Subqueries start with the largest amount of rows
-- and data, and whittles things downwards to the result, while Joins go from the least to most.
-- It takes less effort to start from the most data and cut it down to only what is neaded, than having
-- only a little data, and adding on to what is neccessary. In a far larger set of data, subqueries would
-- save time and computing space.
---------------------------------------------------------------------------------------------

--9. With a window function, write a query that shows the film, its duration, and what 
--   percentile the duration fits into. 
--   This may help https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank 

-- for DURATION of RENTAL time
SELECT title,														-- select title from film table
		rental_duration,											-- select rental_duration from film table
		NTILE(100) OVER (ORDER BY rental_duration) as percentile	-- order rental_duration to create a rank, and return a percentile
FROM film															-- film table has no alias because there are no joins
ORDER BY title,														-- order by title
		 rental_duration;											-- then order by rental_duration
		 
-- For LENGTH of Film		 
SELECT title,														-- select title from film table
		length,														-- select length from film table
		NTILE(100) OVER (ORDER BY length) as percentile				-- order length to create a rank, and return a percentile
FROM film															-- film table has no alias because there are no joins
ORDER BY title,														-- order by title
		 length;													-- then order by length	
-------------------------------------------------------------------------------------------------

-- 10. In under 100 words, explain what the difference is between set-based and procedural programming. 
--       Be sure to specify which sql and python are.

-- SQL uses set-based programming, while Python uses both procedural and object-oriented programming.   
-- Set-based programming moves over whole sets of data, namely in the form of tables, looking at each 
-- full row in turn. Procedural programming goes step by step in order of action, touching only those 
-- things required to complete its task. Commands differ - SQL uses aggregates, Python uses IF-ELSE, 
-- and BREAK. Compare what one does with a word-circle puzzle, where one scans the whole puzzle, to a 
-- crossword puzzle, or Sudoku, where solves one item before moving on to the next. 


-- 1. Create a new column called “status” in the rental table that uses a 
--    case statement to indicate if a film was returned late, early, or on time. 
SELECT r.*,
		CASE WHEN CAST(r.return_date AS date) 
				> (r.rental_date:: date + f.rental_duration) THEN 'Late'
			WHEN CAST(r.return_date AS date) 
				< (r.rental_date:: date + f.rental_duration) THEN 'Early'
			WHEN CAST(r.return_date AS date) 
				= (r.rental_date:: date + f.rental_duration) THEN 'On Time'
		ELSE 'Not Yet Returned'
		END AS status
FROM rental AS r
	JOIN inventory AS i
		ON r.inventory_id = i.inventory_id
	JOIN film AS f
		ON i.film_id = f.film_id;
--------------------------------------------------------------------------------

-- 2. Show the total payment amounts for people who live in Kansas City or Saint Louis. 
SELECT cty.city,
		SUM(f.rental_rate) AS rental_rate
FROM film AS f
	JOIN inventory AS i
		ON f.film_id = i.film_id
	JOIN rental AS r
		ON i.inventory_id = r.inventory_id
	JOIN customer AS cst
		ON r.customer_id = cst.customer_id
	JOIN address AS a
		ON cst.address_id = a.address_id
	JOIN city AS cty
		ON a.city_id = cty.city_id
WHERE cty.city ='Saint Louis' OR
	cty.city = 'Kansas City'
GROUP BY cty.city;
------------------------------------------------------------

-- 3.	How many film categories are in each category? 
--      Why do you think there is a table for category and a table for film category?
--   		1000 movies with 16 categories - and while this database does not do it, each movie
--  		could easily have a number of categories attached to it. Sci-fi/Horror, New/Music
-- 			And when the New isn't new any more, a film can be removed from the category.
SELECT c.name,
		count(f.film_id) AS number_of_films
FROM film AS f
	JOIN film_category AS fc
		ON f.film_id = fc.film_id
	JOIN category as c
		ON fc.category_id = c.category_id
GROUP by c.name
ORDER BY c.name;
---------------------------------------------------------------------------

-- 4. Show a roster for the staff that includes their email, address, city, 
--	  and country (not ids)
SELECT s.first_name,
		s.last_name,
		s.email,
		a.address,
		ct.city,
		cy.country
FROM staff AS s
	JOIN address AS a
		ON s.address_id = a.address_id
	JOIN city AS ct
		ON a.city_id = ct.city_id
	JOIN country AS cy
		ON ct.country_id = cy.country_id;
----------------------------------------------------------------------------		

-- 5. Show the film_id, title, and length for the movies that were returned 
--     from May 15 to 31, 2005  ####  395 films were returned between the dates
SELECT f.film_id,
		f.title AS "Movie Title",
		f.length AS "Minutes",
		r.return_date
FROM rental as r
	JOIN inventory as i
		ON r.inventory_id = i.inventory_id
	JOIN film as f
		ON i.film_id = f.film_id
WHERE r.return_date
	BETWEEN '05/15/2005' AND '06/01/2005' --- End date DOES NOT include the date
ORDER BY r.return_date
-------------------------------------------------------------------------------------	

-- 6. Write a subquery to show which movies are rented below the average price for all movies.
SELECT title,
	   rental_rate
FROM film
WHERE film_id IN (SELECT film_id
				  FROM inventory
				  WHERE inventory_id IN (SELECT inventory_id
										 FROM rental))
AND rental_rate < (SELECT AVG(rental_rate)::numeric(10,2)
					   FROM film);
----------------------------------------------------------------------------------------------

-- 7. Write a join statement to show which moves are rented below the average price for all movies.
SELECT f.title,
		f.rental_rate
FROM rental AS r
	JOIN inventory AS i
		ON r.inventory_id = i.inventory_id
	JOIN film as f
		ON i.film_id = f.film_id
WHERE f.rental_rate < (SELECT AVG(rental_rate)::numeric(10,2)
					   FROM film)
GROUP BY f.film_id,
		f.title,
		f.rental_rate
ORDER BY f.film_id;
---------------------------------------------------------------------------------------------

--8. Perform an explain plan on 6 and 7, and describe what you’re seeing and important ways they differ.
-- Looking at the Explain for both 6 & 7, I noticed that both run at the same time of 100 to 120 ms,
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
SELECT title,
		rental_duration,
		NTILE(100) OVER (ORDER BY rental_duration) as percentile
FROM film
ORDER BY title,
		 rental_duration;
		 
-- For LENGTH of Film		 
SELECT title,
		length,
		NTILE(100) OVER (ORDER BY length) as percentile
FROM film
ORDER BY title,
		 length;
-------------------------------------------------------------------------------------------------

-- 10. In under 100 words, explain what the difference is between set-based and procedural programming. 
--       Be sure to specify which sql and python are.

-- SQL uses set-based programming, while Python uses both procedural and object-oriented programming.   
-- Set-based programming moves over whole sets of data, namely in the form of tables, looking at each 
-- full row in turn. Procedural programming goes step by step in order of action, touching only those 
-- things required to complete its task. Commands differ - SQL uses aggregates, Python uses IF-ELSE, 
-- and BREAK. Compare what one does with a word-circle puzzle, where one scans the whole puzzle, to a 
-- crossword puzzle, or Sudoku, where solves one item before moving on to the next. 


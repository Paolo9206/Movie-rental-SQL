/* QUERY 1) We want to understand more about the movies that families are watching.
The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.*/

WITH t1 AS (SELECT f.title AS movie_name,
            c.name AS category_name
            FROM film f
            JOIN film_category  fc
            ON f.film_id = fc.film_id
            JOIN category c
            ON fc.category_id = c.category_id
            JOIN inventory i
		      	ON i.film_id = f.film_id
			      JOIN rental r
			      ON i.inventory_id = r.inventory_id)
SELECT  DISTINCT
t1.movie_name,
t1.category_name,
COUNT(*) OVER (PARTITION BY t1.movie_name) AS rental_count
FROM t1
WHERE t1.category_name ='Animation'
 OR t1.category_name = 'Children'
 OR t1.category_name = 'Classics'
 OR t1.category_name = 'Comedy'
 OR t1.category_name = 'Family'
 OR t1.category_name = 'Music'
ORDER BY 2, 1

/* QUERY 2) Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for.
 Can you provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter)
 based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories?
 Make sure to also indicate the category that these family-friendly movies fall into. */

 WITH t1 AS (SELECT f.title title,
             c.name category,
             f.rental_duration rental_duration
             FROM film f
             JOIN film_category fc
             ON fc.film_id = f.film_id
             JOIN category c
             ON fc.category_id = c.category_id)
 SELECT t1.title,
        t1.category,
        t1.rental_duration,
 NTILE(4) OVER (ORDER BY t1.rental_duration) AS level
 FROM t1
 WHERE t1.category ='Animation'
  OR t1.category = 'Children'
  OR t1.category = 'Classics'
  OR t1.category = 'Comedy'
  OR t1.category = 'Family'
  OR t1.category = 'Music'


  /* QUERY 3) Finally, provide a table with the family-friendly film category, each of the quartiles,
   and the corresponding count of movies within each combination of film category for each corresponding rental duration category */

   SELECT t2.category,
          t2.level,
          CASE WHEN NTILE(4) OVER level = '1' THEN COUNT(*)
          WHEN NTILE(4) OVER level = '2' THEN COUNT(*)
          WHEN NTILE(4) OVER level = '3' THEN COUNT(*)
          WHEN NTILE(4) OVER level = '4' THEN COUNT(*)
          ELSE '0' END AS count
    FROM
            (SELECT
                  t1.category,
                  t1.rental_duration,
                  NTILE(4) OVER (ORDER BY t1.rental_duration) AS level
            FROM (SELECT
                       c.name category,
                       f.rental_duration AS rental_duration
                 FROM film f
                 JOIN film_category fc
                 ON fc.film_id = f.film_id
                 JOIN category c
                 ON fc.category_id = c.category_id) AS t1
   WHERE t1.category ='Animation'
   OR t1.category = 'Children'
   OR t1.category = 'Classics'
   OR t1.category = 'Comedy'
   OR t1.category = 'Family'
   OR t1.category = 'Music') AS t2
   GROUP BY 1,2
   WINDOW level AS (ORDER BY t2.level)
   ORDER BY 1,2


/* QUERY 4) We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for.
 Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month.
 Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month. */

SELECT DATE_PART('month',rental_date) AS rental_month,
       DATE_PART('year',rental_date) AS rental_year,
       s.store_id AS store_id,
       COUNT(r.rental_id) AS count_rentals
FROM staff s
JOIN rental r
ON s.staff_id = r.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC

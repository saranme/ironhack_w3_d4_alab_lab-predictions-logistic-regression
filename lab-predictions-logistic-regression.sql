WITH n_inventory AS (
SELECT f.film_id, COUNT(i.inventory_id) n_inventory
FROM film f
LEFT JOIN inventory i
ON f.film_id = i.film_id
GROUP BY film_id),

n_rentals AS (
SELECT f.film_id, COUNT(r.rental_id) n_rental,
CASE WHEN r.rental_date BETWEEN '2005-03-01' AND '2006-02-14' THEN 1
    ELSE 0 END AS time_movies_rented
FROM film f
LEFT JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY film_id,3),

x AS (
SELECT DISTINCT i.film_id, i.n_inventory, r.n_rental, c.name category, f.rating, f.length, f.title movie, f.release_year, f.rental_rate, r.time_movies_rented
FROM n_inventory i
LEFT JOIN n_rentals r
ON i.film_id = r.film_id
JOIN film_category fc
ON i.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id
JOIN film f
ON i.film_id = f.film_id
JOIN inventory inv
ON i.film_id = inv.film_id
JOIN rental r
ON r.inventory_id = inv.inventory_id),

y AS (SELECT RANK() OVER (PARTITION BY film_id ORDER BY time_movies_rented) AS x, film_id, n_inventory, n_rental, category, rating, length, movie, release_year, rental_rate, time_movies_rented
FROM x)

SELECT film_id, n_inventory, n_rental, category, rating, length, movie, release_year, rental_rate, time_movies_rented
FROM y
WHERE x = 1
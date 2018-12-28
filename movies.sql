-- 1a. Display the first and last names of all actors from the table actor.
use sakila;

select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT * FROM actor;

select concat(first_name, ' ', last_name) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 

SELECT * FROM actor;

select actor_id, first_name, last_name 
from actor 
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

select * from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT * FROM actor;

select last_name, first_name from actor
where last_name like '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT * FROM country;

select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh','China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

SELECT * FROM actor;

alter table actor 
add column description BLOB not null;
select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.

alter table actor 
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name from actor;
select count(last_name) as frequency, last_name
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors.

select count(last_name) as frequency, last_name
from actor 
group by last_name
having frequency >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

SET SQL_SAFE_UPDATES=0;
update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO';

select * from actor where last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

select * from address;

/*
drop table if exist address;
create table address; 
*/

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select a.first_name, a.last_name, b.address
from staff a 
inner join address b 
on a.address_id = b.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select sum(b.amount) as collected, a.first_name, a.last_name 
from staff a 
inner join payment b on a.staff_id = b.staff_id
and payment_date like '2005-08%'
group by a.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select count(b.actor_id) as 'number of actors', a.title
from film a 
inner join film_actor b on a.film_id = b.film_id
group by a.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select * from inventory;
select * from film;

select count(a.film_id) as 'number of copies', b.title
from film b 
inner join inventory a on a.film_id = b.film_id
where b.title = 'Hunchback Impossible';

-- alternative;

select count(film_id) as 'number of coppies Hunchback Impossible'
from inventory 
where film_id in
 (
  select film_id
  from film
  where title = 'Hunchback Impossible'
  );
  
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

select * from payment;
select * from customer;

select b.first_name, b.last_name, sum(a.amount) as 'Total Amount Paid' 
from payment a 
inner join customer b on a.customer_id = b. customer_id
group by b.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT * FROM sakila.language;
SELECT * FROM sakila.film;

select a.title, b.name as 'language'
from film a 
inner join language b on a.language_id = b.language_id 
where title like 'K%' or 'Q%' and b.name = 'English';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT * FROM sakila.film;
SELECT * FROM sakila.actor;
SELECT * FROM sakila.film_actor;

select first_name, last_name
from actor 
where actor_id in
  (
   select actor_id
   from film_actor 
   where film_id in
    (
     select actor_id
     from film
     where title = 'Alone Trip'
	)
);

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT * FROM sakila.customer;
SELECT * FROM sakila.address;
SELECT * FROM sakila.city;
SELECT * FROM sakila.country;

create view customer_canada as select first_name, last_name, email
from customer 
where address_id in 
(
 select address_id 
 from address
 where city_id in
  (
   select city_id 
   from city 
   where country_id in
    (
     select country_id 
     from country
     where country ='Canada'
     )
	)
);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT * FROM sakila.film;
SELECT * FROM sakila.film_category;
SELECT * FROM sakila.category;

select title
from film 
where film_id in
  (
   select film_id 
   from film_category
   where category_id in
    (
     select category_id 
     from category
     where name = 'Family'
     )
	);
    
-- 7e. Display the most frequently rented movies in descending order.

SELECT * FROM sakila.film;

select title, rental_duration
from film
order by rental_duration desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT * FROM sakila.payment;
SELECT * FROM sakila.staff;
SELECT * FROM sakila.store;
SELECT * FROM sakila.sales_by_store;

select sum(payment.amount) as sales, store.store_id
from payment 
join staff
using(staff_id)
join store
using(store_id)
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country
from store
join address
using(address_id) 
join city
using(city_id)
join country 
using(country_id);

-- 7h. List the top five genres in gross revenue in descending order.

SELECT * FROM sakila.category;
SELECT * FROM sakila.film_category;
SELECT * FROM sakila.inventory;
SELECT * FROM sakila.payment;
SELECT * FROM sakila.rental;

select category.name as genres, sum(payment.amount) as total
from payment
join rental
using(rental_id)
join inventory
using(inventory_id)
join film_category
using(film_id)
join category
using(category_id)
group by category.name
order by total desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.


SELECT * FROM sakila.category;
SELECT * FROM sakila.film_category;
SELECT * FROM sakila.inventory;
SELECT * FROM sakila.payment;
SELECT * FROM sakila.rental;

create view top_five_genres as select category.name as genres, sum(payment.amount) as total
from payment
join rental
using(rental_id)
join inventory
using(inventory_id)
join film_category
using(film_id)
join category
using(category_id)
group by category.name
order by total desc
limit 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM sakila.top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

drop view top_five_genres;



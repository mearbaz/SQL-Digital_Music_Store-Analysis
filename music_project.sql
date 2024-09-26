/* Q1: Who is the senior most employee based on job title? */

SELECT TOP 1 * FROM employee
order by levels desc

/* Q2: Which countries have the most Invoices? */

SELECT count(*)as c, billing_country
From invoice
group by billing_country
order by c desc

/* Q3: What are top 3 values of total invoice? */

SELECT top 3 total from invoice
order by total desc

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select top 1 billing_city, sum(total) as invo_total 
from invoice
group by billing_city
order by invo_total desc


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select top 1 customer.customer_id, first_name, last_name, sum(total) as s_total
from customer
join invoice 
on customer.customer_id = invoice.customer_id
group by customer.customer_id,first_name, last_name
order by s_total desc


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select email, first_name,last_name, genre.name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on  invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by email asc

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select top 10 
	artist.artist_id, 
	artist.name ,
	count(artist.artist_id) as number 
from track
join 
	Album on track.album_id = Album.album_id
join 
	artist on Album.artist_id = artist.artist_id
join
	genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id, artist.name
order by number desc



/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select 
	name,
	milliseconds
from track
where milliseconds > (
						select AVG(milliseconds) as aver 
						from track )
order by milliseconds desc;


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT 
    customer.first_name , customer.last_name,
    artist.name AS artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
FROM 
    customer
JOIN 
    invoice ON customer.customer_id = invoice.customer_id
JOIN 
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN 
    track ON invoice_line.track_id = track.track_id
JOIN 
    album ON track.album_id = album.album_id
JOIN 
    artist ON album.artist_id = artist.artist_id
GROUP BY 
    customer.customer_id, artist.artist_id, customer.first_name,customer.last_name,artist.name 
ORDER BY 
    customer.last_name, artist_name;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH GenrePurchases AS (
    SELECT 
        customer.country,
        genre.name AS genre_name,
        SUM(invoice_line.quantity) AS total_purchases
    FROM 
        customer
    JOIN 
        invoice ON customer.customer_id = invoice.customer_id
    JOIN 
        invoice_line ON invoice.invoice_id = invoice_line.invoice_id
    JOIN 
        track ON invoice_line.track_id = track.track_id
    JOIN 
        album ON track.album_id = album.album_id
    JOIN 
        genre ON track.genre_id = genre.genre_id
    GROUP BY 
        customer.country, genre.name
),

MaxGenrePurchases AS (
    SELECT 
        country,
        genre_name,
        total_purchases,
        RANK() OVER (PARTITION BY country ORDER BY total_purchases DESC) AS genre_rank
    FROM 
        GenrePurchases
)

SELECT 
    country,
    genre_name
FROM 
    MaxGenrePurchases
WHERE 
    genre_rank = 1
ORDER BY 
    country;


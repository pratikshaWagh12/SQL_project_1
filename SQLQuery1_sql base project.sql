 SELECT name from sys.Databases;

 USE Spotify;

 --***************************** QUESTION SET 1 *************************************
 -- Problem 1 : who is senior most employee based on job profile
 SELECT TOP 1 first_name, last_name, hire_date,title FROM employee1
 ORDER BY hire_date ASC;

 --problem 2: which countries has the most invoices
 
 SELECT COUNT(*) AS No_of_invoices ,billing_country FROM invoice
 GROUP BY billing_country
 ORDER BY No_of_invoices DESC;


-- problem 3: what are 3 values of top invoice.
SELECT * FROM invoice;
SELECT * FROM customer;

SELECT TOP 3 total FROM invoice
ORDER BY total DESC; 

-- problem 4 : which city has the best customers
SELECT  TOP 1  SUM(total) FROM invoice
GROUP BY customer_id
ORDER BY SUM(total) DESC;


--Problem 5:who is best customer ? who spent most of the monney
SELECT first_name, last_name FROM customer 
WHERE customer_id= 
 (SELECT  TOP 1 customer.customer_id FROM customer 
JOIN invoice 
ON customer.customer_id= invoice.customer_id
GROUP BY customer.customer_id
ORDER BY SUM(invoice.total) DESC  )

-- ********************************* QUESTION SET 2************************************

/*problem 1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
Return your list ordered alphabetically by email starting with A.
*/
SELECT * FROM customer;

SELECT * FROM genre;
SELECT * FROM album2;
SELECT * FROM track;

 SELECT DISTINCT c.email, c.first_name, c.last_name FROM customer c
 JOIN invoice i on c.customer_id=i.customer_id
 Join invoice_line l on l.invoice_id=i.invoice_id
 WHERE l.track_id IN(
 SELECT  t.track_id FROM track t
INNER JOIN genre g
ON g.genre_id= t.track_id
WHERE g.name LIKE 'ROCK')


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT * FROM artist;
SELECT * FROM album2;
SELECT * FROM track;

SELECT TOP 10  b.artist_id, b.name , COUNT(b.artist_id)  
FROM track t 
JOIN album a on a.album_id= t.album_id
join artist b on a.artist_id=b.artist_id
join genre g on g.genre_id=t.genre_id 
WHERE g.name LIKE 'Rock'
GROUP BY b.artist_id,b.name
ORDER by COUNT(b.artist_id) DESC 





/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT * FROM album;
SELECT * FROM track;

SELECT name,milliseconds
FROM track
WHERE milLiseconds > (
	SELECT AVG(miLliseconds) AS avg_track_length
	FROM track )
ORDER BY milLiseconds DESC;






/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

SELECT * FROM artist;
SELECT * FROM album2;
SELECT * FROM track;

SELECT * FROM invoice_line;
SELECT * FROM invoice;
SELECT * FROM customer;


 
 WITH best_artist AS 
 (
	SELECT TOP 1 artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1,2
	ORDER BY 3 DESC
	
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;





/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1




/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */



WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

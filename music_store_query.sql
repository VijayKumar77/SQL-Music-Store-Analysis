/*	Question Set 1 - Easy */

-- Q1: Who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1;

-- Q2: Which countries have the most Invoices?
select billing_country,count(*) as c from invoice
group by billing_country
order by c desc;

-- Q3: What are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select * from invoice;
select billing_city,sum(total) as sum_of_total from invoice
group by billing_city
order by sum_of_total desc
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select * from customer;
select concat(first_name,' ',last_name) as full_name,sum(total) as total from customer,invoice
where customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select distinct email,first_name,last_name,genre.name 
from customer,invoice,invoice_line,track,genre
where customer.customer_id=invoice.customer_id
and invoice.invoice_id=invoice_line.invoice_id
and invoice_line.track_id=track.track_id
and track.genre_id=genre.genre_id
and genre.name='Rock'
order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select artist.name, count(track_id) as c
from artist,album,track,genre
where artist.artist_id=album.artist_id
and album.album_id=track.album_id
and track.genre_id=genre.genre_id
and genre.name='Rock'
group by artist.name
order by c desc
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name,milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;



/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
with best_selling_artist as (
	select artist.artist_id,artist.name as artist_name,sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from artist,album,track,invoice_line
	where artist.artist_id=album.artist_id
	and album.album_id=track.album_id
	and track.track_id=invoice_line.track_id
	group by 1
	order by 3 desc
	limit 1
	)
select first_name,last_name,artist_name,sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from customer,best_selling_artist,invoice_line,track,album,artist,invoice
where customer.customer_id=invoice.customer_id
and invoice.invoice_id=invoice_line.invoice_id
and invoice_line.track_id=track.track_id
and track.album_id=album.album_id
and artist.artist_id=album.artist_id
and artist.artist_id=best_selling_artist.artist_id
group by 1,2,3
order by total_sales desc;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
with popular_genre as (
	select count(invoice_line.invoice_id) as purchase,customer.country,genre.name,genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
	from invoice_line,customer,genre,track,invoice
	where  customer.customer_id=invoice.customer_id
	and invoice.invoice_id=invoice_line.invoice_id
	and invoice_line.track_id=track.track_id
	and track.genre_id=genre.genre_id
	group by 2,3,4
	order by 2 asc,1 desc
	)
select * from popular_genre where RowNo = 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
with Customer_with_country as (
		select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
	    row_number() over(partition by billing_country order by sum(total) desc) as RowNo 
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 4 asc,5 desc)
select * from Customer_with_country where RowNo = 1;

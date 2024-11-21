Create database Music_Database;
use Music_Database;

#Easy Questions
#Q1: Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;


#Q2: which countries have the most Invoices?

select count(billing_country) as C, billing_country from invoice
group by billing_country
order by C desc;


#Q3: What are the top 3 values of total invoice?

select total from invoice
order by total desc
limit 3;


#Q4: City that has highest sum of invoice total?

select billing_city,  sum(total) as Total_Invoice
from invoice
group by billing_city
order by Total_Invoice desc
limit 1;


#Q5: Find the customer who has spent the most money?

select c.customer_id, c.first_name, c.last_name,  sum(total) as Total_Invoice 
from invoice as i
right join customer as c
on i.customer_id = c.customer_id
group by c.customer_id, c.first_name, c.last_name
order by Total_Invoice desc
limit 1;




#Moderate Questions
#Q1: Write a query to return the email, first_name, last_name, & genre of all Rock Music listners.
#Return your list Ordered alphabetically by email starting with A.

select distinct email, first_name, last_name
from customer as c
join invoice as i
on c.customer_id = i.customer_id
join invoice_line as il
on i.invoice_id = il.invoice_id
where track_id in(
	select track_id from track as t
    join genre as g
    on t.genre_id = g.genre_id
    where g.name like "Rock")
order by email;


#Q2:Lets invite the artists who have wrtten the most rock music in our dataset.
#Write a query that returns the Artist name and total track count of the top 10 rock bands.

select artist.artist_id ,artist.name, count(artist.artist_id) as total
from artist
join album2 
on artist.artist_id = album2.artist_id
join track
on album2.album_id = track.album_id
join genre
on genre.genre_id = track.genre_id
where genre.name like "Rock"
group by artist.artist_id, artist.name
order by total desc
limit 10;


#Q3: Return all the track names that have a song length longer than the average song length.
#Return the Name and Milliseconds for each track. 
#Order by the song length with the longer songs listed first.

select track.name, milliseconds
from track
where milliseconds > (
	select avg(milliseconds) from track)
order by milliseconds desc;



#Advance Questions
#Q1: Find how much amount spent by each customer on artist? 
#write a query to return customer name, artist name and total spent.

with best_selling_artist as (
	select ar.artist_id, ar.name as artist_name, 
    sum(il.unit_price * il.quantity) as total_sales
    from invoice_line as il
    join track as t
    on t.track_id = il.track_id
    join album2 as ab
    on ab.album_id = t.album_id
    join artist as ar
    on ar.artist_id = ab.artist_id
    group by ar.artist_id, artist_name
    order by total_sales desc
    limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price * il.quantity) as amount_spent
from invoice as i
join customer as c
on c.customer_id = i.customer_id
join invoice_line as il
on il.invoice_id = i.invoice_id
join track as t
on t.track_id = il.track_id
join album2 as ab
on ab.album_id = t.album_id
join best_selling_artist as bsa
on bsa.artist_id = ab.artist_id
group by c.customer_id, c.first_name, c.last_name, bsa.artist_name
order by amount_spent desc;


#Q2: We want to find out the most popular music Genre for each country.
#we detremine the most popular genre as the genre with the highest amount of purchases.
#Write a query that returns each country along with the top Genre.
#For countries where the maximum number of purchases is shared return all Genres.

with popular_genre As (
	select count(il.quantity) as Purchases, c.country, g.name, g.genre_id,
    row_number() over(partition by c.country order by count(il.quantity)desc) as RowNo
    from invoice_line as il
    join invoice as i
    on i.invoice_id = il.invoice_id
    join customer as c
    on c.customer_id = i.customer_id
    join track as t
    on t.track_id = il.track_id
    join genre as g
    on g.genre_id = t.genre_id
    group by c.country, g.name, g.genre_id
    order by c.country asc, count(il.quantity) desc
    )
    select * from popular_genre where RowNo <= 1;
    
    
#Q3: Write a query that determines the customer that has spent the most on music for each country.
#Write a query that returns the country along with the top customer and how much they spent.
#for country where the top amount spent is shared, provide all customers who spent this amount
with Customer_country as (
	select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(i.total) as Total_spending,
    Row_number() over(partition by i.billing_country order by sum(i.total) desc) as RowNo
    from invoice as i
    join customer as c
    on c.customer_id = i.customer_id
    group by c.customer_id, c.first_name, c.last_name, i.billing_country
    order by i.billing_country asc, sum(i.total) desc
)
select * from Customer_country where RowNo <= 1;
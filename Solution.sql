--Count the total number of customers who joined in 2023.
select count(*) as customers_2023
from customers
where extract(year from join_date) = 2023;

--For each customer return customer_id, full_name, total_revenue (sum of total_amount from orders). Sort descending.
select c.customer_id, 
	   c.full_name, 
	   SUM(o.total_amount) as total_revenue
from customers as c
left join orders as o on c.customer_id = o.customer_id
group by c.customer_id, c.full_name 
order by total_revenue desc

--Return the top 5 customers by total_revenue with their rank.
with total_revenue as (
	select c.customer_id as customer_id, 
		   c.full_name as full_name, 
		   SUM(o.total_amount) as total_revenue
	from customers as c
	left join orders as o on c.customer_id = o.customer_id
	group by c.customer_id, c.full_name 
	)
select customer_id, 
	   full_name, 
	   total_revenue,
	   rank() over (order by total_revenue desc) as revenue_rank
from total_revenue
order by total_revenue desc
limit 5

--Produce a table with year, month, monthly_revenue for all months in 2023 ordered chronologically.
with monthly_revenue as (
	select extract(year from order_date) as order_year, 
		   extract(month from order_date) as order_month, 
		   sum(total_amount) as monthly_revenue
	from orders
	where extract(year from order_date) = 2023 
	group by order_year, order_month
	)
select order_year, 
	   order_month, 
	   monthly_revenue
from monthly_revenue
order by order_year, order_month

--Find customers with no orders in the last 60 days relative to 2023-12-31 (i.e., consider last active date up to 2023-12-31). Return customer_id, full_name, last_order_date.

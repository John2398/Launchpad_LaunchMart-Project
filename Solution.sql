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
with last_orders as (
    select 
        c.customer_id,
        c.full_name,
        max(o.order_date) as last_order_date
    from customers as c
    left join orders as o 
        on c.customer_id = o.customer_id
    group by c.customer_id, c.full_name
)
select 
    customer_id,
    full_name,
    last_order_date
from last_orders
where 
    last_order_date is null 
    or last_order_date < date '2023-12-31' - interval '60 day'
order by last_order_date nulls first

--Calculate average order value (AOV) for each customer: return customer_id, full_name, aov (average total_amount of their orders). Exclude customers with no orders.
select 
    c.customer_id,
    c.full_name,
    avg(o.total_amount) as aov 
from customers as c 
inner join orders as o 
    on c.customer_id = o.customer_id 
group by c.customer_id, c.full_name
order by aov desc

--For all customers who have at least one order, compute customer_id, full_name, total_revenue, spend_rank where spend_rank is a dense rank, highest spender = rank 1.
with customer_spend as (
    select 
        c.customer_id,
        c.full_name,
        sum(o.total_amount) as total_revenue
    from customers as c
    join orders as o
        on c.customer_id = o.customer_id
    group by c.customer_id, c.full_name
)
select 
    customer_id,
    full_name,
    total_revenue,
    dense_rank() over (order by total_revenue desc) as spend_rank
from customer_spend
order by spend_rank

--List customers who placed more than 1 order and show customer_id, full_name, order_count, first_order_date, last_order_date.
select 
    c.customer_id,
    c.full_name,
    count(o.order_id) as order_count,
    min(o.order_date) as first_order_date,
    max(o.order_date) as last_order_date
from customers as c
join orders as o
    on c.customer_id = o.customer_id
group by c.customer_id, c.full_name
having count(o.order_id) > 1
order by order_count desc

--Compute total loyalty points per customer. Include customers with 0 points.
select 
    c.customer_id,
    c.full_name,
    coalesce(sum(lp.points_earned), 0) as total_points
from customers as c
left join loyalty_points as lp
    on c.customer_id = lp.customer_id
group by c.customer_id, c.full_name
order by total_points desc

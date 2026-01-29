SELECT * FROM `customer_order&revenue_analysis`.customers ;
SELECT count(*) as total_rows, count(customer_unique_id),count(customer_id) FROM `customer_order&revenue_analysis`.customers ;
-- Find unique voters
SELECT count(*) as customer_rows, count(distinct customer_id) as distinct_customer_id, 
count(distinct customer_unique_id) as distinct_customer_unique_id 
FROM `customer_order&revenue_analysis`.customers ;
-- how many unique customer
SELECT
  COUNT(DISTINCT c.customer_unique_id) AS ordering_unique_customers
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id;
-- Activation rate(% of customers who ordered)
SELECT 
ROUND(
100.0 * COUNT(DISTINCT c.customer_unique_id)/
(SELECT COUNT(DISTINCT customer_unique_id) FROM customers),2
) as activation_rate_pct
FROM orders O
JOIN customers c
on o.customer_id=c.customer_id;

-- How many customers actually make a order?

select 
 count(distinct c.customer_unique_id) as ordering_unique_customers
from 
`customer_order&revenue_analysis`.orders o
join `customer_order&revenue_analysis`.customers c 
on o.customer_id=c.customer_id;

-- Make sure that there are any null value
SELECT count(*) as customer_ids_without_orders
from customers c 
left join orders o
on c.customer_id=o.customer_id
where o.order_id IS NULL;

SELECT 
count(DISTINCT C.Customer_unique_id) as ordering_unique_customers
FROM 
ORDERS O
join CUSTOMERS C
ON O.customer_id=C.customer_id;

-- Repeat vs One-time customers
SELECT 
c.customer_unique_id,
count(o.order_id) as Order_count
FROM 
ORDERS O
JOIN CUSTOMERS C 
ON O.customer_id=c.customer_id
group by c.customer_unique_id;
-- Find out the customers more than one time
WITH FILTER_ORDER_COUNT AS (
SELECT 
c.customer_unique_id,
count(o.order_id) as Order_count
FROM 
ORDERS O
JOIN CUSTOMERS C 
ON O.customer_id=c.customer_id
group by c.customer_unique_id)
SELECT 
*
FROM
FILTER_ORDER_COUNT
Where Order_count>1
order by order_count desc;

-- percentage of Repeat customers revenue
WITH customer_orders AS (
SELECT
c.customer_unique_id,
COUNT(DISTINCT o.order_id) as order_count
FROM customers c
JOIN orders o
 ON c.customer_id=o.customer_id
GROUP BY c.customer_unique_id
),
customer_revenue as (
SELECT 
c.customer_unique_id,
SUM(oi.price) AS revenue
FROM customers c
JOIN orders o 
on c.customer_id=o.customer_id
join order_items oi
on o.order_id= oi.order_id
group by c.customer_unique_id 
),
customer_type_revenue AS (
SELECT 
CASE WHEN co.order_count =1 THEN 'One-Time'
	ELSE 'Repeat'
    END AS customer_type,
    SUM(cr.revenue) AS total_revenue
  FROM customer_orders co
  JOIN customer_revenue cr
    ON co.customer_unique_id = cr.customer_unique_id
  GROUP BY customer_type
    
)
SELECT
  customer_type,
  ROUND(
    100.0 * total_revenue /
    SUM(total_revenue) OVER (),
  2) AS revenue_pct
FROM customer_type_revenue;

-- Check one time and repeated customer 
WITH customer_summary AS(
SELECT 
 c.customer_unique_id,
 COUNT(o.order_id) AS order_count
FROM 
customers c
JOIN orders o 
ON c.customer_id=o.customer_id
GROUP BY c.customer_unique_id
)
SELECT 
	CASE WHEN order_count=1 
    THEN 'One-Time' 
    ELSE 'Repeat' END AS customer_type,
    COUNT(*) AS customers
FROM customer_summary
GROUP BY customer_type;

-- Average revenue per repeat vs one-time customer 
WITH customer_summary AS(
SELECT 
 c.customer_unique_id,
 COUNT(DISTINCT o.order_id) AS order_count,
 sum(oi.price) as total_price
FROM customers c
JOIN orders o 
ON c.customer_id=o.customer_id
JOIN order_items oi
on o.order_id=oi.order_id
GROUP BY c.customer_unique_id
)
SELECT 
	CASE WHEN order_count=1
    THEN 'One-Time'
    ELSE 'Repeat' END AS customer_type,
    COUNT(*) AS customers,
      ROUND(SUM(total_price), 2) AS total_revenue,
  ROUND(AVG(total_price), 2) AS avg_revenue_per_customer
FROM customer_summary
GROUP BY customer_type;

-- 🔹 A) Top 10 customers by revenue
-- require tables customers → orders → order_items
WITH customer_summary AS(
SELECT 
 c.customer_unique_id,
 sum(oi.price) as total_revenue
FROM customers c
JOIN orders o 
ON c.customer_id=o.customer_id
JOIN order_items oi
on o.order_id=oi.order_id
GROUP BY c.customer_unique_id
)
SELECT 
	ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as ranking,
	customer_summary.customer_unique_id,
	ROUND(total_revenue, 2) AS total_revenue
FROM customer_summary
order by total_revenue DESC LIMIT 10;

-- 🔹 B) Top 10 customers revenue % of total
WITH customer_revenue AS(
SELECT 
 c.customer_unique_id,
 sum(oi.price) as revenue
FROM customers c
JOIN orders o 
ON c.customer_id=o.customer_id
JOIN order_items oi
on o.order_id=oi.order_id
GROUP BY c.customer_unique_id
),
ranked as (
SELECT 
	customer_unique_id,
    revenue,
    row_number() OVER (ORDER BY revenue DESC) AS rn
    from customer_revenue
)
select 
    ROUND(SUM(revenue),2) AS total_revenue,
    ROUND(SUM(CASE WHEN rn<=10 THEN revenue ELSE 0 END),2) AS top_10_revenue,
    ROUND( 100.0 * SUM(CASE WHEN rn<=10 THEN revenue ELSE 0 END) / SUM(revenue),2) as top_10_revenue_pct
    from ranked;

-- 🔹 C)Top 10 vs Others breakdown
WITH customer_revenue AS(
SELECT 
 c.customer_unique_id,
 sum(oi.price) as revenue
FROM customers c
JOIN orders o 
ON c.customer_id=o.customer_id
JOIN order_items oi
on o.order_id=oi.order_id
GROUP BY c.customer_unique_id
),
ranked as(
SELECT 
revenue, 
ROW_NUMBER() OVER (order by revenue DESC) as rn 
from customer_revenue
)
SELECT
  CASE WHEN rn <= 10 THEN 'Top 10 customers' ELSE 'All other customers' END AS customer_group,
  ROUND(100.0 * SUM(revenue) / (SELECT SUM(revenue) FROM ranked), 2) AS revenue_pct
FROM ranked
GROUP BY customer_group;

-- To further validate revenue distribution, a broader concentration check was performed.

WITH customer_revenue AS (
  SELECT 
    c.customer_unique_id,
    SUM(oi.price) AS revenue
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY c.customer_unique_id
),
ranked AS (
  SELECT
    revenue,
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn
  FROM customer_revenue
)
SELECT
  ROUND(
    100.0 * SUM(CASE WHEN rn <= 100 THEN revenue ELSE 0 END) / SUM(revenue),
  2) AS top_100_revenue_pct
FROM ranked;


-- To check the upper query I use two quick sanity check
-- Who is really top 10 customers
SELECT 
	customer_unique_id,
    ROUND(revenue,2) AS revenue
	FROM(
		SELECT 
		 c.customer_unique_id,
		SUM(oi.price) AS revenue
		FROM customers c
		JOIN orders o ON c.customer_id = o.customer_id
		JOIN order_items oi ON o.order_id = oi.order_id
		GROUP BY c.customer_unique_id
	) t
ORDER BY revenue DESC
LIMIT 10;
-- Revenue is highly fragmented across customers
WITH customer_revenue AS (
  SELECT 
    c.customer_unique_id,
    SUM(oi.price) AS revenue
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY c.customer_unique_id
),
ranked AS (
  SELECT
    revenue,
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn
  FROM customer_revenue
)
SELECT
  ROUND(
    100.0 * SUM(CASE WHEN rn <= 100 THEN revenue ELSE 0 END) / SUM(revenue),
  2) AS top_100_revenue_pct
FROM ranked;

-- 1. business-level Total Revenue (baseline KPI)
-- পুরো dataset-এ মোট কত টাকা বিক্রি হয়েছে
select round(sum(price),2) FROM `customer_order&revenue_analysis`.order_items;
-- 2. Total Orders (volume KPI)
-- মোট কয়টা order হয়েছে
  SELECT COUNT(DISTINCT order_id) as total_orders FROM `customer_order&revenue_analysis`.orders;
-- 3.Monthly Revenue Trend (time-series)
-- মাসে মাসে revenue কেমন বদলেছে
-- (উঠেছে? নামছে? stable?)

SELECT 
	DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS yearmonth,
	ROUND(SUM(oi.price),2) as total_revenue
FROM 
	orders o
    JOIN
	order_items oi
ON o.order_id=oi.order_id
GROUP BY yearmonth
order by yearmonth;

-- 4.Monthly Orders Trend (time-series)
-- মাসে মাসে order সংখ্যা কেমন বদলেছে
SELECT 
DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS yearmonth,
count(DISTINCT o.order_id) AS total_order
FROM orders o
GROUP BY yearmonth
order by yearmonth; 


-- 5.Peak Month / Seasonality
-- in which month more revenue or order generate 
-- ( one or two peak month identify sufficiant)
SELECT 
MONTHNAME(o.order_purchase_timestamp) AS month,
count(DISTINCT o.order_id) AS total_count
FROM orders o
GROUP BY MONTH(o.order_purchase_timestamp),monthname(o.order_purchase_timestamp)
order by month(o.order_purchase_timestamp);  

	
    WITH aov_details AS(
    SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS yearmonth,
    count(DISTINCT o.order_id) AS total_orders,
    ROUND(sum(oi.price),2) as total_revenue 
    FROM 
    ORDERS o 
    JOIN
    order_items oi
    on o.order_id=oi.order_id
    group by yearmonth
    )
	
    SELECT
    yearmonth, 
    round((total_revenue/total_orders),2) as AOV 
    from
    aov_details;

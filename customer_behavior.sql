-- select * from dataset_table limit 20 

-- 1. what is the total revenue of male and female
select gender , sum(purchase_amount) as revenue
from dataset_table 
group by gender 

-- 2 which customer use a discount but still spend more then averange 
select customer_id , purchase_amount
from dataset_table
where discount_applied = "yes" and purchase_amount >= (select avg(purchase_amount) from dataset_table)


--  3 which are the top 5 product with the highest average review rating 

select item_purchased , round(avg(review_rating),2) as "average product rating "
from dataset_table
group by item_purchased 
order by avg(review_rating) desc
limit 5 ;

-- 4 compare the average purached amout betweem standard and express shipping 

select shipping_type,
round(avg(purchase_amount),2)
from dataset_table
where shipping_type in ("Standard","Express")
group by shipping_type

-- 5 de subscribe customer spend more ? compare average spend and total revenue between subscribers and non-subscribe 

SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount),2) AS avg_spend,
       ROUND(SUM(purchase_amount),2) AS total_revenue
FROM dataset_table
GROUP BY subscription_status
ORDER BY total_revenue,avg_spend DESC

-- 6 which 5 producthave the higgest percentage of purchased with discount applied 
select item_purchased,
round(100*sum(case when discount_applied = "yes" then 1 else 0 end ) /count(*),2) as discount_rate
from dataset_table 
group by item_purchased
order by discount_rate desc 
limit 5

-- 7 segment customer into new , returning and loyal based on their total number of previous purchased , and show the count of each segment 

with customer_type as (
SELECT customer_id, previous_purchases,
CASE 
    WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
FROM dataset_table)

select customer_segment,count(*) AS "Number of Customers" 
from customer_type 
group by customer_segment;

-- 8 what are the top 3 most purchased product from each categrory 

WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM dataset_table
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;
 
 
-- --Q9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM dataset_table
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- Q10. What is the revenue contribution of each age group? 
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM dataset_table
GROUP BY age_group
ORDER BY total_revenue desc;
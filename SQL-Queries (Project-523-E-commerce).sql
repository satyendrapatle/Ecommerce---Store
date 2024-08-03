create database olist_database;
use olist_database;

# olist_Store_Ecommerce

-- KPIs --

# 1. Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
# 2. Number of Orders with review score 5 and payment type as credit card.
# 3. Average number of days taken for order_delivered_customer_date for pet_shop
# 4. Average price and payment values from customers of sao paulo city
# 5. Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.





# 1. Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

SELECT * FROM olist_database.olist_orders_dataset;
SELECT * FROM olist_database.olist_order_payments_dataset;


select 
    kpi1.day_end,
    concat(round(kpi1.total_payments / (select sum(payment_value) from olist_database.olist_order_payments_dataset) * 100, 2), '%') as percentage_values
from (
    select 
        ord.day_end, 
        sum(pmt.payment_value) as total_payments
    from 
        olist_database.olist_order_payments_dataset as pmt
    join (
        select 
            distinct order_id,
            case
                when WEEKDAY(order_purchase_timestamp) in (5, 6) then 'Weekend'
                ELSE 'Weekday'
            end as day_end
        from 
            olist_database.olist_orders_dataset
    ) as ord
    on ord.order_id = pmt.order_id
    group by ord.day_end
) as kpi1;









# 2. Number of Orders with review score 5 and payment type as credit card.

SELECT * FROM olist_database.olist_order_reviews_dataset;

SELECT 
    COUNT(pmt.order_id) AS Total_Orders
FROM 
    olist_database.olist_order_payments_dataset pmt
INNER JOIN 
    olist_database.olist_order_reviews_dataset rev 
    ON pmt.order_id = rev.order_id
WHERE 
    rev.review_score = 5
    AND pmt.payment_type = 'credit_card';










# 3. Average number of days taken for order_delivered_customer_date for pet_shop

select * from olist_orders_dataset;

select
    prod.product_category_name,
    round(avg(datediff(ord.order_delivered_carrier_date, ord.order_purchase_timestamp)),0)
as 
    avg_delivery_date
from 
    olist_orders_dataset 
    as ord 
join (
    select 
        product_id, order_id, product_category_name 
from 
    olist_products_dataset 
join 
    olist_order_items_dataset 
    using 
      (product_id)) 
        as prod
on 
    ord.order_id=prod.order_id 
where 
    prod.product_category_name = "pet_shop"
group by 
    prod.product_category_name;










# 4. Average price and payment values from customers of sao paulo city


-- For Average Price --
select 
    cust.customer_city, 
    round(avg(pmt_price.price),0) as avg_price
from 
    olist_customers_dataset as cust
join (
     select 
        pymt.customer_id, pymt.payment_value, item.price 
          from 
             olist_order_items_dataset 
             as 
                item 
          join
(select 
    ord.order_id, ord.customer_id, pmt.payment_value 
        from 
           olist_orders_dataset 
            as ord
join 
   olist_order_payments_dataset 
    as 
      pmt 
       on 
         ord.order_id=pmt.order_id) 
          as pymt
       on 
         item.order_id=pymt.order_id) 
	as 
      pmt_price 
on 
	cust.customer_id=pmt_price.customer_id 
where 
    cust.customer_city = "sao paulo";




-- For Average payment --
select 
    cust.customer_city, 
    round(avg(pmt.payment_value),0) 
       as 
          avg_payment_value
from 
    olist_customers_dataset cust 
        inner join 
            olist_orders_dataset ord
        on cust.customer_id = ord.customer_id 
inner join
    olist_order_payments_dataset 
        as pmt 
on 
   ord.order_id = pmt.order_id
where 
   customer_city = "sao paulo";










# 5. Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.



select 
    rw.review_score,
    round(avg(datediff(ord.order_delivered_customer_date, ord.order_purchase_timestamp)),0)
as 
    avg_Shipping_Days
from 
    olist_orders_dataset 
         as ord 
	join 
        olist_order_reviews_dataset rw 
        on 
             rw.order_id=ord.order_id 
	group by 
        rw.review_score 
order by 
    rw.review_score;




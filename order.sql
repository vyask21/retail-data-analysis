select * from retail_data_analysis.df_orders;

# Drop table as by default columns consume large space
drop table retail_data_analysis.df_orders;

# Create new table with existing column names with smaller data type
create table retail_data_analysis.df_orders(
	order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7, 2),
    sales_price DECIMAL(7, 2),
    profit DECIMAL(7, 2)
);

# top 10 highest revenue generating products
select product_id, sum(sales_price) as sales
from retail_data_analysis.df_orders
group by product_id
order by sales desc;

# top 5 highest selling products in each region
with cte as (
select region, product_id, sum(sales_price) as sales
from retail_data_analysis.df_orders
group by region, product_id
)
select * from (
select * , row_number() over (partition by region order by sales desc) as rn
from cte) A
where rn <= 5;

# find month over month growth comparison for 2022 and 2023
with cte as (
select year(order_date) as order_year, month(order_date) as order_month,
sum(sales_price) as sales 
from retail_data_analysis.df_orders
group by year(order_date), month(order_date)
-- order by year(order_date), month(order_date)
)
select order_month
,  sum(case when order_year = 2022 then sales else 0 end) as sales_2022
,  sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

# for each category, which month has highest sales
with cte as(
select category, date_format(order_date, '%Y-%m') as order_year_month, sum(sales_price) as sales
from retail_data_analysis.df_orders
group by category, order_year_month
-- order by category, order_year_month
)
select * from (
select *, 
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1;

# which sub category has highest growth by profit in 2023 compared to 2022
with cte1 as (
select sub_category, year(order_date) as order_year,
sum(sales_price) as sales 
from retail_data_analysis.df_orders
group by sub_category, year(order_date)
-- order by year(order_date), month(order_date)
),
cte2 as (
select sub_category
,  sum(case when order_year = 2022 then sales else 0 end) as sales_2022
,  sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte1
group by sub_category
)
select *
, ((sales_2023 - sales_2022)*100/sales_2022) as profit_percent
from cte2
order by profit_percent desc limit 1;
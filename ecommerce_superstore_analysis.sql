SELECT * FROM data_analytics.superstore;


-- superstore analysis


-- update column into date format
update superstore set `Ship Date` = str_to_date(`Ship Date`, "%d/%m/%Y");




-- 1) Sales Analysis

--    a)Total Sales
select round(sum(Sales)) as `total sales` from superstore; 

--    b)Monthly Sales
with temp as (select date_format(`Ship Date`, '%Y-%m') as `date`, round(sum(Sales),2) as total from superstore
group by `date` order by `date`)
select *, round((sum(total) over(order by `date`)),2) as roll_total from temp;

--    c)Sales by Category and Sales by Region
select Region, Category, (sum(Sales)) as `total sales`, Category, Region 
from superstore group by Category, Region;  




-- 2) Profit Analysis

--    a)Total Profit
select round(sum(Profit),2) from superstore;

--    b)Profit Margin
with temp as (select `Product Name`, round(Profit / Sales * 100,2) as profit_margin
from superstore order by `Product Name`)
select `Product Name`, avg(profit_margin) from temp 
group by `Product Name`;

--    c)Profit by Category with Sub-Category
select round(sum(Profit)) as `total profit`, Category, `Sub-Category` from superstore group by Category, `Sub-Category`; 




-- 3)Customer Analysis

--   a)Top 10 Customer by Sales
select `Customer Name`, `Customer ID`, round(sum(Sales)) as total_purchase from superstore
group by `Customer ID`, `Customer Name`
order by total_purchase desc limit 10;

--   b)Top Customer by Profit
select `Customer Name`, `Customer ID`, round(sum(Profit)) as total_profit from superstore
group by `Customer ID`, `Customer Name`
order by total_profit desc limit 2;




-- 4)Order Analysis

--   a)Order Freq per Customer
select `Customer Name`, count(`Order ID`) as order_count, 
round(avg(Sales),2) as avg_purchase 
from superstore
group by `Customer ID`, `Customer Name`
order by avg_purchase desc limit 10;


--   b)Avg Order value per customer





-- 5) Product Analysis

--   a)Top Selling Product
select `Product ID`, `Product Name`, count(`Product ID`) as top_selling from superstore
group by `Product ID`, `Product Name`
order by top_selling desc limit 10;

--   b)Most Profitable Product
select `Product ID`, `Product Name`, avg(`Profit`) as avg_profit from superstore
group by `Product ID`, `Product Name`
order by avg_profit desc limit 10;




-- 6) Regional Performance



-- 7) find Sales over month between year jan - 2022, 2023, 2024
									--   Fab - 2022, 2023, 2024
								
with cte as (select year(`Order Date`) as order_year, date_format(`Order Date`, '%m') as order_month, 
round(sum(Sales),2) as total_sales from superstore
group by order_year, order_month
)
select order_month,
	sum(case when order_year = 2011 then total_sales else 0 end) as `2011`,
    sum(case when order_year = 2012 then total_sales else 0 end) as `2012`,
    sum(case when order_year = 2013 then total_sales else 0 end) as `2013`
    
from cte
group by order_month;						
                            
                            
                            
-- 8) find Sales of each category in yearMonth

with cte as (select Category, date_format(`Order Date`, '%M-%Y') as month_year, round(sum(Sales),2) as total_sale
from superstore
group by Category, month_year)

select Category, month_year, total_sale from
	(select *, 
    dense_rank() over( partition by Category order by total_sale desc) as rnk
    from cte) as cte2
where rnk = 1;


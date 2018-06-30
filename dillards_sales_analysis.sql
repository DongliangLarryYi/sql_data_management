Database ua_dillards;


# Exercise 1. How many distinct dates are there in the saledate column of the transaction
# table for each month/year combination in the database?
select count(distinct saledate), EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num
from trnsact
group by month_num, year_num
order by year_num asc, month_num asc

# determine which sku had the greatest total sales during the combined summer months of June, 
# July, and August.
select sku, sum(amt) as total_amount
from trnsact
WHERE stype = 'p' and (EXTRACT(MONTH from saledate) = 6 or EXTRACT(MONTH from saledate) = 7 or EXTRACT(MONTH from saledate) = 8)
group by sku
order by total_amount desc

# These queries are used to analyze dillards sales.
Database ua_dillards;

# How many distinct dates are there in the saledate column of the transaction
# table for each month/year combination in the database?
select count(distinct saledate), EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num
from trnsact
group by month_num, year_num
order by year_num asc, month_num asc

# Determine which sku had the greatest total sales during the combined summer months of June, July, and August.
select sku, sum(amt) as total_amount
from trnsact
WHERE stype = 'p' and (EXTRACT(MONTH from saledate) = 6 or EXTRACT(MONTH from saledate) = 7 or EXTRACT(MONTH from saledate) = 8)
group by sku
order by total_amount desc

# How many distinct dates are there in the saledate column of the transaction
# table for each month/year/store combination in the database
select count(distinct saledate) as number_date, EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num, store
from trnsact
group by month_num, year_num, store
order by number_date asc

# Modify the query that remove all data from Aug, 2005 and only include purchase in store 204
select EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num, store, sum(amt)/COUNT(DISTINCT saledate) as amount
from trnsact
group by month_num, year_num, store
WHERE stype = 'p' and store = '204' and (EXTRACT(MONTH from saledate) ne 8 or EXTRACT(YEAR from saledate) ne 2005)
order by amount desc;

# Population statistics of the geographical location and sales performance
select count(distinct t.saledate) as number_date, EXTRACT(MONTH from t.saledate) as month_num, EXTRACT(YEAR from t.saledate) as year_num, t.store, sum(t.amt) as amount,
(case 
when newmsa.msa_high > 50 and newmsa.msa_high <= 60 then 'low'
when newmsa.msa_high > 60 and newmsa.msa_high <= 70 then 'medium'
when newmsa.msa_high > 70 then 'high'
end) as msa_level
from trnsact t join (select msa_high, store from store_msa) as newmsa
on newmsa.store = t.store
WHERE t.stype = 'p' and (EXTRACT(MONTH from t.saledate) ne 8 or EXTRACT(YEAR from t.saledate) ne 2005)
group by month_num, year_num, t.store, msa_level
order by amount desc
having number_date >= 20

# Relations between average daily revenue of the stores and median msa_income of different cities
select count(distinct t.saledate) as number_date, sum(t.amt)/COUNT(DISTINCT t.saledate) as Ave_amount, newmsa.msa_income, newmsa.state, newmsa.city
from trnsact t join (select msa_high, store, msa_income, state, city
from store_msa) as newmsa
on newmsa.store = t.store
group by newmsa.msa_income, newmsa.state, newmsa.city
WHERE t.stype = 'p' and (EXTRACT(MONTH from t.saledate) ne 8 or EXTRACT(YEAR from t.saledate) ne 2005)
order by newmsa.msa_income asc

# What is the brand of the sku with the greatest standard deviation in sprice?
# Only examine skus that have been part of over 100 transactions.
select count(distinct trannum) as trn_num, sku, stddev_samp(sprice) as std, avg(sprice) as avg_price, max(sprice), min(sprice)
from trnsact
WHERE stype = 'p' and (EXTRACT(MONTH from saledate) ne 8 or EXTRACT(YEAR from saledate) ne 2005)
group by sku
order by std desc
having trn_num > 100

# Which department, in which city and state of what store, had the greatest %
# increase in average daily sales revenue from November to December?
select con_data.dept, con_data.store, sum(con_data.nov_amount) as nov_value, sum(con_data.dec_amount) as dec_value, sum(con_data.dec_amount)*100/sum(con_data.nov_amount) as percentage
from (select newdata.dept as dept, newdata.store as store, case 
when newdata.month_num = 11 then amount
end as nov_amount, case
when newdata.month_num = 12 then amount
end as dec_amount
from (select EXTRACT(MONTH from t.saledate) as month_num, EXTRACT(YEAR from t.saledate) as year_num, t.store as store, sum(t.amt)/COUNT(DISTINCT t.saledate) as amount, s.dept as dept
from trnsact t, skuinfo s 
WHERE t.sku = s.sku and t.stype = 'p' and (EXTRACT(MONTH from t.saledate) ne 8 or EXTRACT(YEAR from t.saledate) ne 2005)
group by month_num, year_num, store, dept
having month_num = 11 or month_num = 12) as newdata) as con_data
group by con_data.dept, con_data.store
having nov_value is not null and dec_value is not null
order by percentage desc

# What is the city and state of the store that had the greatest decrease in average daily revenue from August to September?
select con_data.dept, con_data.store, sum(con_data.aug_amount) as aug_value, sum(con_data.sep_amount) as sep_value, sum(con_data.sep_amount)*100/sum(con_data.aug_amount) as percentage
from (select newdata.dept as dept, newdata.store as store, case 
when newdata.month_num = 8 then amount
end as aug_amount, case
when newdata.month_num = 9 then amount
end as sep_amount
from (select EXTRACT(MONTH from t.saledate) as month_num, EXTRACT(YEAR from t.saledate) as year_num, t.store as store, sum(t.amt)/COUNT(DISTINCT t.saledate) as amount, s.dept as dept
from trnsact t, skuinfo s 
WHERE t.sku = s.sku and t.stype = 'p' and (EXTRACT(MONTH from t.saledate) ne 8 or EXTRACT(YEAR from t.saledate) ne 2005)
group by month_num, year_num, store, dept
having month_num = 8 or month_num = 9) as newdata) as con_data
group by con_data.dept, con_data.store
having aug_value is not null and sep_value is not null
order by percentage desc

# Store’s largest monthly sales, month and year
select agg_data.store, max(agg_data.month_value) 
from (select EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num, store, sum(amt)/COUNT(DISTINCT saledate) as month_value
from trnsact
group by month_num, year_num, store
WHERE stype = 'p' and (EXTRACT(MONTH from saledate) ne 8 or EXTRACT(YEAR from saledate) ne 2005)) as agg_data 
group by agg_data.store

# Store with the max sales, month and year
select *
from (select agg_data.store as newstore, max(agg_data.month_value) as newmaxvalue 
from (select EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num, store, sum(amt)/COUNT(DISTINCT saledate) as month_value
from trnsact
group by month_num, year_num, store
WHERE stype = 'p' and (EXTRACT(MONTH from saledate) ne 8 or EXTRACT(YEAR from saledate) ne 2005)) as agg_data 
group by agg_data.store) as match_data, (select EXTRACT(MONTH from saledate) as month_num, EXTRACT(YEAR from saledate) as year_num, store, sum(amt)/COUNT(DISTINCT saledate) as month_value
from trnsact
group by month_num, year_num, store
WHERE stype = 'p' and (EXTRACT(MONTH from saledate) ne 8 or EXTRACT(YEAR from saledate) ne 2005)) as agg_data 
where match_data.newstore = agg_data.store and match_data.newmaxvalue = agg_data.month_value and agg_data.month_num = 12

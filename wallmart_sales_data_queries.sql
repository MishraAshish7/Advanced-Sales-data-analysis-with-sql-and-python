-- Range of data values inside table
select count(*)
from wallmartsales;

-- Analyzing nature of data
select *
from wallmartsales
limit 10;

-- Easy Level

-- Summary Statistics:
-- Question: What are the mean, median, and standard deviation of Weekly_Sales, Temperature, Fuel_Price, CPI, and Unemployment?
with average_of_data as (
	select ï»¿store as Store,
		avg(Weekly_Sales) as average_Weekly_sales,
		avg(Temperature) as average_Temperature,
        avg(Fuel_Price) as average_FuelPrice,
        avg(CPI) as average_CPI,
        avg(Unemployment) as average_Unemployment
	from wallmartsales
	group by ï»¿store
),
standard_deviation as (
	select ï»¿store as Store,
		   stddev(Weekly_Sales) as stddev_of_WeeklySales,
           stddev(Temperature) as stddev_of_Temperature,
           stddev(Fuel_Price) as stddev_of_FuelPrice,
           stddev(CPI) as stddev_of_CPI,
           stddev(Unemployment) as stddeb_of_Unemployment
    from wallmartsales
    group by ï»¿store
)
select *
from standard_deviation;


-- Distribution of Weekly Sales:
-- Question: What is the frequency distribution of Weekly_Sales over different stores?
select ï»¿store as Store,
		count(*) as frequency
from wallmartsales
group by ï»¿store
order by frequency desc;

-- Trend of Weekly Sales Over Time:
-- Question: How do Weekly_Sales values change over time?

select year(date2) as Years, 
		month(date2) as Months, 
        round(sum(Weekly_Sales)) as total_sales_over_time
from wallmartsales
group by year(date2), month(date2);

-- Intermediate Level
-- Correlation Analysis:

-- Question: What are the correlations between Weekly_Sales and other variables like Temperature, Fuel_Price, CPI, and Unemployment over each store?
with corr_stats as (
		select ï»¿store as Store,
				count(*) as n,
        
				-- Calculating stats for Weekly_Sales
				sum(Weekly_Sales) as total_sales,
                sum(Weekly_Sales * Weekly_Sales) as total_sales_sq,
                
                -- Calculating stats for Temperature
                sum(Temperature) as tot_temp,
                sum(Temperature * Temperature) as tot_temp_sq,
                sum(Weekly_Sales * Temperature) as total_temp_sales,
                
                -- Calculating stats for Fuel_Price
                sum(Fuel_Price) as tot_Fuel,
                sum(Fuel_Price * Fuel_Price) as tot_fuel_sq,
                sum(Weekly_Sales * Fuel_Price) as tot_fuel_sales,
                
                -- Calculating stats for CPI
                sum(CPI) as tot_cpi,
                sum(CPI * CPI) as tot_cpi_sq,
                sum(Weekly_Sales * CPI) as tot_cpi_sales,
                
                -- Calculating stats for Unemployment rate
                sum(Unemployment) as tot_unemp,
                sum(Unemployment * Unemployment) as tot_unemp_sq,
                sum(Weekly_Sales * Unemployment) as tot_unemp_sales
                
        from wallmartsales
        group by ï»¿store
),

correlation as (
		select 
			Store,
            
            -- correlation between Temperature and Weekly Sales
            (n * total_temp_sales - tot_temp * total_sales) /
            (sqrt((n * tot_temp_sq - tot_temp * tot_temp) * 
				 (n * total_sales_sq - total_sales * total_sales))) as Corr_Temperature_Sales,
                
			-- correlation between Fuel_Price and Weekly Sales
            (n * tot_fuel_sales - tot_fuel * total_sales) /
            (sqrt((n * tot_fuel_sq - tot_fuel * tot_fuel) *
				 (n * total_sales_sq - total_sales * total_sales))) as Corr_FuelPrice_Sales,
                        
			-- correlation between CPI and Weekly Sales
            (n * tot_cpi_sales - tot_cpi * total_sales) /
            (sqrt((n * tot_cpi_sq - tot_cpi * tot_cpi) *
				 (n * total_sales_sq - total_sales * total_sales))) as Corr_CPI_Sales,
            
			-- correlation between Unemployment and Weekly Sales
			(n * tot_unemp_sales - tot_unemp * total_sales) /
            (sqrt((n * tot_unemp_sq - tot_unemp * tot_unemp) *
				 (n * total_sales_sq - total_sales * total_sales))) as Corr_Unemployment_Sales
                        
        from corr_stats
        group by Store
)

select *
from correlation;

-- Sales Comparison on Holidays vs. Non-Holidays:
-- Question: How do Weekly_Sales compare on holidays versus non-holidays?

select ï»¿store as Store,
			round(sum(case when Holiday_Flag = True then Weekly_Sales else 0 end)) as Sales_on_Holiday,
            round(sum(case when Holiday_Flag = False then Weekly_Sales else 0 end)) as Sales_on_NonHoliday
from wallmartsales
group by ï»¿store;

-- Average Sales by Store:
-- Question: What is the average Weekly_Sales for each store?

select ï»¿store as Store,
		avg(Weekly_Sales) as average_sales
from wallmartsales
group by ï»¿store;

-- Sales by Temperature Ranges:
-- Question: How do Weekly_Sales vary within different temperature ranges?
select ï»¿store as Store,
		round(sum(case when Temperature >= -5 and Temperature <= 25 then Weekly_Sales else 0 end )) as temp0to25,
        round(sum(case when Temperature >= 25 and Temperature <= 40 then Weekly_Sales else 0 end)) as temp25to40,
        round(sum(case when Temperature >= 40 and Temperature <= 60 then Weekly_Sales else 0 end)) as temp40to60,
        round(sum(case when Temperature >= 60 and Temperature <= 80 then Weekly_Sales else 0 end)) as temp60to80,
        round(sum(case when Temperature >= 80 and Temperature <= 100 then Weekly_Sales else 0 end)) as temp80to100
from wallmartsales
group by ï»¿store;

-- Advanced Level

-- Impact Analysis by Store:
-- Question: How does the impact of Temperature on Weekly_Sales vary across different stores?
with corr_stats as (
    select
        ï»¿store as Store,
        COUNT(*) as total_entry,
        SUM(Temperature) as tot_temp,
        SUM(Weekly_Sales) as tot_sales,
        SUM(Temperature * Weekly_Sales) as tot_temp_sales,
        SUM(Temperature * Temperature) as tot_temp_sq,
        SUM(Weekly_Sales * Weekly_Sales) as tot_sales_sq
    from wallmartsales
    group by ï»¿store
),

correlation as (
    select
        store,
        (total_entry * tot_temp_sales - tot_temp * tot_sales) / 
        (SQRT((total_entry * tot_temp_sq - tot_temp * tot_temp) * 
              (total_entry * tot_sales_sq - tot_sales * tot_sales))) as relationship
    from corr_stats
)

select *
from correlation;



-- Predictive Modeling Preparation:
-- Question: How can you aggregate and prepare data for predictive modeling, including calculating rolling averages or creating lagged variables?
-- Objective: Prepare data for predictive modeling and time-series analysis.

select date2 as Date, 
	   avg(Weekly_Sales) over (order by date2 asc rows between 3 preceding and current row) as rolling_average_weekly_sales,
       lag(Weekly_Sales,1) over (order by date2 asc) as lagged_sales
from wallmartsales
order by date2 asc;


-- Time Series Forecasting Data Preparation:
-- Question: How can you prepare your data for time series forecasting, such as creating features for trends or seasonal effects?

select date2,
	   Weekly_Sales,
       # Extracting date and time features
	   extract(year from date2) as Years,
	   extract(month from date2) as Months,
       extract(week from date2 ) as WeekofYears,
       extract(quarter from date2) as Quarters,
       
       # Calculating lagged features
       lag(Weekly_Sales, 1) over (order by date2) as lag_1,
       lag(Weekly_Sales, 2) over (order by date2) as lag_2,
       lag(Weekly_Sales, 3) over (order by date2) as lag_3,
       
       # Calculating rolling statistics
       avg(Weekly_Sales) over (order by date2 rows between 6 preceding and current row) AS rolling_avg_7d,
       STDDEV(Weekly_Sales) OVER (order by date2 rows between 6 preceding and current row) AS rolling_stddev_7d
       
from wallmartsales
order by date2 asc;
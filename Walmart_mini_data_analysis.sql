CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
	gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 5) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT(11, 9),
    gross_income DECIMAL(12, 2) NOT NULL,
    rating FLOAT(2, 1)
);

-- --------------------------------------------------------------------------
-- ----------------------Feature Engineering---------------------------------

--  time_of_day

SELECT 
	time,
    ( CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	  END
    ) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20); 

UPDATE sales
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
);

-- day_name
SELECT date, DAYNAME(date) as day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- month_name
SELECT date, MONTHNAME(date) as month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- ------------------------------------------------------------------------------

-- -----------------------------------Generic Questions--------------------------

-- How many unique cities does the data have?

SELECT DISTINCT city
FROM sales;

-- In which city is each branch?


-- ---------------------------------------Product--------------------------------

-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line)
FROM sales;

-- What is the count of each products in product line?
SELECT product_line, COUNT(product_line)
FROM sales
GROUP BY product_line;

-- what is the most common payment method?
SELECT payment_method, COUNT(payment_method) as method_count
FROM sales
GROUP BY payment_method
ORDER BY method_count DESC;

-- What is the most selling product line?
SELECT product_line, COUNT(product_line) as sale_count
FROM sales
GROUP BY product_line
ORDER BY sale_count DESC;

-- What is the total revenue by month?
SELECT month_name as month , SUM(total) as total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT month_name as month, SUM(cogs) as cogs
FROM sales
GROUP BY month
ORDER BY cogs DESC;

-- Which product line had the largest revenue?
SELECT product_line, SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with largest revenue?
SELECT city, branch, SUM(total) as total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT product_line, AVG(VAT) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product_line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good" -- try with 5.6
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) as qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales)
ORDER BY qty DESC;

-- What is the most common product line by gender?
SELECT gender,product_line, SUM(quantity) as product_line_qty, COUNT(gender) as total_count
FROM sales
GROUP BY gender, product_line
ORDER BY gender DESC, total_count DESC ;

-- What is the average rating of each product line?
SELECT product_line , Round(AVG(rating), 2) as avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- -------------------------------------------Sales-------------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT day_name, time_of_day, Count(*) as total_sales
FROM sales
WHERE day_name NOT IN ("Saturday", "Sunday")
GROUP BY day_name,time_of_day
ORDER BY FIELD(day_name, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), FIELD(time_of_day, 'Morning', 'Afternoon', 'Evening');

-- Which of the customer types brings most revenue?
SELECT customer_type, SUM(total) as total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent / VAT (Value Added Tax) ?
SELECT city, AVG(VAT) as VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which type of customer pays the most in VAT?
SELECT customer_type , AVG(VAT) as VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- ---------------------------Customer--------------------------------

-- How many unique customer types does the data have
SELECT DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment_method
FROM sales;

-- What is the common customer type?
SELECT customer_type, Count(*) as count
FROM sales
GROUP BY customer_type
ORDER By count DESC;

-- Which customer type buys the most?
SELECT customer_type, Count(*) as count, SUM(quantity) as total_quantity
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- What is the gender of most of the customer?
SELECT gender, COUNT(*) as total_count
FROM sales
GROUP BY gender
ORDER BY total_count DESC;

-- What is the gender distribution per branch?
SELECT branch, gender, count(*)
FROM sales
GROUP BY branch, gender
ORDER BY branch;

-- Which time of the day do customers give more ratings?
SELECT time_of_day, AVG(rating) as avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, AVG(rating) as avg_rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch,avg_rating DESC;

-- Which day of the week has the best avg rating?
SELECT day_name, AVG(rating) as avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;


-- Which day of the week has the best avg ratings per branch?
SELECT branch, day_name, AVG(rating) as avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;




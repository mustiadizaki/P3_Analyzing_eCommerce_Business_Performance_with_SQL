DATA PREPARATION
---Subtask 1
	*Create a new database and its tables for the data that has been prepared

	create database ecommerce;

	* Create a table for nine csv records. There are 9 datasets with the csv extension, so we also create 9 tables to store these datasets, and adjust the type of each column based on the dataset in the csv file.

	create table customers (
		customer_id varchar(250),
		customer_unique_id varchar(250),
		customer_zip_code_prefix int,
		customer_city varchar(250),
		customer_state varchar(250)
	);
	
	create table geolocation (
		geo_zip_code_prefix varchar(250),
		geo_lat varchar(250),
		geo_lng varchar(250),
		geo_city varchar(250),
		geo_state varchar(250)
	);

	create table order_item (
		order_id varchar(250),
		order_item_id int,
		product_id varchar(250),
		seller_id varchar(250),
		shipping_limit_date timestamp,
		price float,
		freight_value float
	);

	create table payments (
		order_id varchar(250),
		payment_sequential int,
		payment_type varchar(250),
		payment_installment int,
		payment_value float
	);


	create table reviews (
		review_id varchar(250),
		order_id varchar(250),
		review_score int, 
		review_comment_title varchar(250),
		review_comment_message text,
		review_creation_date timestamp,
		review_answer timestamp
	);

	create table orders (
		order_id varchar(250),
		customers_id varchar(250),
		order_status varchar(250),
		order_purchase_timestamp timestamp,
		order_approved_at timestamp,
		order_delivered_carrier_date timestamp,
		order_delivered_customer_date timestamp,
		order_estimated_delivered_date timestamp
	);

	create table products (
		product_id varchar(250),
		product_category_name varchar(250),
		product_name_length int,
		product_description_length int,
		product_photos_qty int,
		product_weight_g int,
		product_length_cm int,
		product_height_cm int,
		product_width_cm int
	);

	create table sellers (
		seller_id varchar(250),
		seller_zip_code int,
		seller_city varchar(250),
		seller_state varchar(250)
	);




---Subtask 2: 
	Importing csv data into database

	In importing csv data to the database, the data type of the columns in the database must be the same as the dataset type in the csv file. If there is a difference then the import process will error. In addition, the dataset storage folder path must be complete until nama_file.csv.
	
	copy customers(
		customer_id,
		customer_unique_id,
		customer_zip_code_prefix,
		customer_city,
		customer_state
	)
	from 'D:\Minpro1\customers_dataset.csv'
	delimiter ','
	csv header;

	copy geolocation(
		geo_zip_code_prefix,
		geo_lat,
		geo_lng,
		geo_city,
		geo_state
	)
	from 'D:\Minpro1\customers_dataset.csv'
	delimiter ','
	csv header;

---Subtask 3:
	Create an entity relationship between tables, based on the schema below. Then export the Entity Relationship Diagram (ERD) in image form.

	alter table products add constraint pk_products primary key (product_id);
	alter table order_items add foreign key (product_id) references products;

	For relationships between other datasets, you can use the same method as the previous example in determining the primary key and foreign key, so that the right query is obtained as follows:

	Primary key untuk tabel lainnya
	alter table customers add constraint pk_cust primary key (customer_id);
	alter table geolocation add constraint pk_geo primary key (geo_zip_code_prefix);
	alter table orders add constraint pk_orders primary key (order_id);
	alter table sellers add constraint pk_seller primary key (seller_id);


	Foreign key for relationships between other tables
	alter table customers add foreign key (customer_zip_code_prefix) references geolocation;
	alter table orders add foreign key (customer_id) references customers;
	alter table order_items add foreign key (order_id) references orders;
	alter table order_items add foreign key (seller_id) references sellers;
	alter table sellers add foreign key (seller_zip_code_prefix) references geolocation;
	alter table payments add foreign key (order_id) references orders;
	alter table order_items add foreign key (product_id) references products;
	alter table reviews add foreign key (order_id) references order 

Annual Customer Ativity Grouth Analysis
--Subtask 1
--Show amount of average monthly active (MAU) user per year.
WITH mau AS(SELECT
				DATE_PART('month', o.order_purchase_timestamp) AS month,
				DATE_PART('year', o.order_purchase_timestamp) AS year,
				COUNT(DISTINCT c.customer_unique_id) AS monthly_active_user
			FROM orders AS o
			JOIN customers AS c ON c.customer_id = o.customer_id
			GROUP BY 1, 2
		   )
SELECT
	year,
	ROUND(AVG(monthly_active_user), 2) AS average_mau
FROM mau
GROUP BY 1
ORDER BY 1 ASC;

--Subtask 2
--Show new customer (first time transaction) per year.
WITH new_customers AS(SELECT
					  	MIN(o.order_purchase_timestamp) AS first_order,
					 	c.customer_unique_id
					  FROM orders AS o
					  JOIN customers AS c ON c.customer_id = o.customer_id
					  GROUP BY 2
					 )	
SELECT
	DATE_PART('year', first_order) AS year,
	COUNT(1) AS new_customers
FROM new_customers
GROUP BY 1
ORDER BY 1 ASC;

--Subtask 3
--Show amount of customer who orders more than one (repeat order) per year.
WITH repeat_order AS(SELECT
						DATE_PART('year', o.order_purchase_timestamp) AS year,
					 	c.customer_unique_id AS customer_repeat,
						COUNT(o.order_id) AS total_order
					FROM orders AS o
					JOIN customers AS c ON c.customer_id = o.customer_id
					GROUP BY 1, 2
					HAVING COUNT(o.order_id) > 1
					)
SELECT
	year,
	COUNT(DISTINCT customer_repeat) AS repeat_customers
FROM repeat_order
GROUP BY 1;

--Subtask 4
--Show average orders of customer per year.
WITH orders AS(SELECT
			  	c.customer_unique_id AS customer,
			   	DATE_PART('year', o.order_purchase_timestamp) AS year,
			   	COUNT(1) AS frequency_purchase
			  FROM orders AS o
			  JOIN customers AS c ON c.customer_id = o.customer_id
			  GROUP BY 1, 2
			  )
SELECT
	year,
	ROUND(AVG(frequency_purchase), 3) AS average_orders
FROM orders
GROUP BY 1
ORDER BY 1 ASC;

--Subtask 5
--Group 3 metrics in one display table
WITH mau AS(SELECT
				year,
				ROUND(AVG(monthly_active_user), 1) AS average_mau
			FROM(SELECT
				 	DATE_PART('month', o.order_purchase_timestamp) AS month,
				 	DATE_PART('year', o.order_purchase_timestamp) AS year,
				 	COUNT(DISTINCT c.customer_unique_id) AS monthly_active_user
				 FROM orders AS o
				 JOIN customers AS c ON c.customer_id = o.customer_id
				 GROUP BY 1, 2
				 ) AS subq
			GROUP BY 1
),
new_customers AS(SELECT
				 	year,
				 	COUNT(new_customers) AS new_customers
				 FROM(SELECT
					  	MIN(DATE_PART('year', o.order_purchase_timestamp)) AS year,
					 	c.customer_unique_id AS new_customers
					  FROM orders AS o
					  JOIN customers AS c ON c.customer_id = o.customer_id
					  GROUP BY 2
					  ) AS subq
				 GROUP BY 1
),
repeat_order AS(SELECT
					year,
					COUNT(DISTINCT customer_repeat) AS repeat_customers
				FROM(SELECT
					 	DATE_PART('year', o.order_purchase_timestamp) AS year,
					 	c.customer_unique_id AS customer_repeat,
						COUNT(o.order_id) AS total_order
					 FROM orders AS o
					 JOIN customers AS c ON c.customer_id = o.customer_id
					 GROUP BY 1, 2
					 HAVING COUNT(o.order_id) > 1
					 ) AS subq
				GROUP BY 1
),
avg_orders AS(SELECT
			  	year,
			  	round(AVG(total_order),3) AS average_orders
			  FROM(SELECT
				   	DISTINCT c.customer_unique_id AS customer,
				   	DATE_PART('year', o.order_purchase_timestamp) AS year,
			   		COUNT(DISTINCT o.order_id) AS total_order
				   FROM orders AS o
				   JOIN customers AS c ON c.customer_id = o.customer_id
				   GROUP BY 1, 2
				   ) AS subq
			  GROUP BY 1
)
SELECT 
	m.year AS year,
	average_mau,
	new_customers,
	repeat_customers,
	average_orders
FROM mau AS m
JOIN new_customers AS nc ON nc.year = m.year
JOIN repeat_order AS ro ON ro.year = m.year
JOIN avg_orders AS ao ON ao.year = m.year
GROUP BY 1, 2, 3, 4, 5;


Annual Product Category Quality Analysis
--Subtask 1
--Create table with information of total revenue each year.
--Make sure filter order status with delivered.
CREATE TABLE revenue_per_year AS
SELECT
	DATE_PART('year', o.order_purchase_timestamp) AS year,
	SUM(oi.price + oi.freight_value) AS revenue
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY year ASC;

--Subtask 2
--Create table with information of total canceled order each year.
--Make sure filter order status with canceled.
CREATE TABLE cancel_per_year AS
SELECT
	DATE_PART('year', order_purchase_timestamp) AS year,
	COUNT(order_id) AS canceled_order
FROM orders
WHERE order_status = 'canceled'
GROUP BY 1
ORDER BY year ASC;

--Subtask 3
--Create table with product category name that give total most revenue each year.
CREATE TABLE most_product_category_by_revenue_per_year AS
SELECT
	year,
	most_product_category_by_revenue,
	product_category_revenue
FROM(SELECT
		DATE_PART('year', o.order_purchase_timestamp) AS year,
	 	p.product_category_name AS most_product_category_by_revenue,
	 	SUM(price + freight_value) AS product_category_revenue,
	 	RANK() OVER(PARTITION BY DATE_PART('year', o.order_purchase_timestamp)
				    ORDER BY SUM(oi.price + oi.freight_value) DESC
					) AS rank
	 FROM orders AS o
	 JOIN order_items AS oi ON oi.order_id = o.order_id
	 JOIN product AS p ON p.product_id = oi.product_id
	 WHERE order_status = 'delivered'
	 GROUP BY 1, 2
	 ) AS subq
WHERE rank = 1;

--Subtask 4
--Create table product category name with total most cancel order each year.

CREATE TABLE most_canceled_product_category_by_per_year AS
SELECT
	year,
	most_canceled_product_category,
	canceled_product_category
FROM(SELECT
		DATE_PART('year', o.order_purchase_timestamp) AS year,
	 	p.product_category_name AS most_canceled_product_category,
	 	COUNT(o.order_id) AS canceled_product_category,
	 	RANK() OVER(PARTITION BY DATE_PART('year', order_purchase_timestamp)
				    ORDER BY COUNT(o.order_id) DESC
					) AS rank
	 FROM orders AS o
	 JOIN order_items AS oi ON oi.order_id = o.order_id
	 JOIN product AS p ON p.product_id = oi.product_id
	 WHERE order_status = 'canceled'
	 GROUP BY 1, 2
	 ) AS subq
WHERE rank = 1;

--Subtask 5
--Group completed information in one display.
SELECT
	rpy.year,
	mpcbrpy.most_product_category_by_revenue,
	mpcbrpy.product_category_revenue,
	rpy.revenue AS total_revenue,
	mcpcbpy.most_canceled_product_category,
	mcpcbpy.canceled_product_category,
	cpy.canceled_order AS total_canceled_order
FROM revenue_per_year AS rpy
JOIN cancel_per_year AS cpy ON cpy.year = rpy.year
JOIN most_product_category_by_revenue_per_year AS mpcbrpy ON mpcbrpy.year = rpy.year
JOIN most_canceled_product_category_by_per_year AS mcpcbpy ON mcpcbpy.year = rpy.year;


Annual Payment Type Usage Analysis
--Subtask 1
--Show total payment type usage of all the time sorted by the most favorite.
SELECT
	payment_type,
	COUNT(order_id) AS payment_type_usage
FROM order_payments
GROUP BY 1
ORDER BY 2 DESC;				   

--Subtask 2
--Show information detail of total payment type usage each year.
SELECT
	payment_type,
	SUM(CASE WHEN year = 2016 THEN payment_type_usage ELSE 0 END) AS "year_2016",
	SUM(CASE WHEN year = 2017 THEN payment_type_usage ELSE 0 END) AS "year_2017",
	SUM(CASE WHEN year = 2018 THEN payment_type_usage ELSE 0 END) AS "year_2018",
	SUM(payment_type_usage) AS sum_payment_type_usage
FROM (SELECT
	  	DATE_PART('year', order_purchase_timestamp) AS year,
	 	payment_type,
	 	COUNT(payment_type) AS payment_type_usage
	  FROM orders AS o
	  JOIN order_payments AS op ON op.order_id = o.order_id
	  GROUP BY 1, 2
	 ) AS subq
GROUP BY 1
ORDER BY 2 DESC;
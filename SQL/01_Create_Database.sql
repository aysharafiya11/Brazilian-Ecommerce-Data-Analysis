-- E-Commerce Analytics Project
-- Create a new database for the E-Commerce Analytics Project
CREATE DATABASE ecommerce_project;

-- Select the newly created database to perform all operations
-- such as creating tables, importing data, and running queries
USE ecommerce_project;

-- Create Customers Table
-- Stores customer demographic and location information
CREATE TABLE customers
	(
		customer_id	VARCHAR(50) PRIMARY KEY,
        customer_unique_id	VARCHAR(50) NOT NULL,
        customer_zip_code_prefix INT,
        customer_city VARCHAR(50),
        customer_state CHAR(2)
	);

-- Create Orders Table
-- Stores order details, order status, and delivery timestamps
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- Create Order Items Table
-- Stores product-level details for each order
-- Each order can contain multiple products
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY (order_id, order_item_id)
);   

-- Create Products Table
-- Stores product specifications and category information
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- Create Sellers Table
-- Stores seller location and identification details
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

-- Create Payments Table
-- Stores payment method, installments, and payment amount
-- One order may have multiple payment transactions
CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
	payment_type VARCHAR(30),
    payment_installments INT,
    payment_value FLOAT,
	PRIMARY KEY (order_id, payment_sequential)
);

-- Create Reviews Table
-- Stores customer ratings and review timestamps for orders
CREATE TABLE reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    PRIMARY KEY (review_id, order_id)
);

-- Create Geolocation Table
-- Stores geographical coordinates and location information
-- based on ZIP code prefixes
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,8),
    geolocation_lng DECIMAL(11,8),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

-- Create Product Category Translation Table
-- Maps Portuguese product categories to English names
CREATE TABLE product_category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

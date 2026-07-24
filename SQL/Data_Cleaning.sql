-- Data Cleaning

-- Check Total Records
-- Ensure every table was imported completely.
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sellers;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM reviews;
SELECT COUNT(*) FROM geolocation;
SELECT COUNT(*) FROM product_category_translation;

-- Check for Duplicate Records

-- Check for duplicate customer records
-- Each customer_id should appear only once
SELECT
customer_id,
COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*)>1;

-- Check for duplicate order records
SELECT
order_id,
COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*)>1;

-- Check for duplicate products
SELECT
product_id,
COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*)>1;

-- Check for duplicate sellers
SELECT
seller_id,
COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*)>1;

-- Check for duplicate category names
SELECT
product_category_name,
COUNT(*) AS duplicate_count
FROM product_category_translation
GROUP BY product_category_name
HAVING COUNT(*)>1;

-- Composite Primary Key Tables

-- Check duplicate order items
SELECT
order_id,
order_item_id,
COUNT(*) AS duplicate_count
FROM order_items
GROUP BY
order_id,
order_item_id
HAVING COUNT(*)>1;

-- Check duplicate reviews
SELECT
review_id,
order_id,
COUNT(*) AS duplicate_count
FROM reviews
GROUP BY
review_id,
order_id
HAVING COUNT(*)>1;

-- Check duplicate geolocation records
-- It has no primary key. Check for completely duplicated rows.

-- Count the number of duplicate groups in geolocation table:
SELECT COUNT(*) AS duplicate_groups
FROM (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    FROM geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    HAVING COUNT(*) > 1
) AS duplicates;

-- Calculate the number of extra duplicate rows in geolocation table:
SELECT
    SUM(duplicate_count - 1) AS duplicate_rows
FROM (
    SELECT
        COUNT(*) AS duplicate_count
    FROM geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    HAVING COUNT(*) > 1
) AS d;

-- Check Missing Values 

-- Check missing customer location information
SELECT
COUNT(*) AS Missing_City
FROM customers
WHERE customer_city IS NULL;

SELECT
COUNT(*) AS Missing_State
FROM customers
WHERE customer_state IS NULL;

SELECT
COUNT(*) AS Missing_Zipcode
FROM customers
WHERE customer_zip_code_prefix IS NULL;

-- Check missing details in orders table
SELECT COUNT(*) AS Missing_Purchase_Date
FROM orders
WHERE order_purchase_timestamp IS NULL;

-- Some orders might have been: cancelled, unavailable or not approved
-- Therefore, Approval Date may be NULL. No need to replace these values.
SELECT COUNT(*) AS Missing_Approval_Date
FROM orders
WHERE order_approved_at IS NULL;

-- Cancelled or unavailable orders have no delivery date. So, no need to replace them.
SELECT COUNT(*) AS Missing_Delivery_Date
FROM orders
WHERE order_delivered_customer_date IS NULL;

-- Every order should have an estimated delivery date.
SELECT COUNT(*) AS Missing_Estimated_Date
FROM orders
WHERE order_estimated_delivery_date IS NULL;

-- Check missing details in Products Table
-- These NULL values are common. Some sellers do not provide complete product specifications.
SELECT COUNT(*) AS Missing_Category
FROM products
WHERE product_category_name IS NULL;

SELECT COUNT(*) AS Missing_Name_Length
FROM products
WHERE product_name_length IS NULL;

SELECT COUNT(*) AS Missing_Description
FROM products
WHERE product_description_length IS NULL;

SELECT COUNT(*) AS Missing_Photos
FROM products
WHERE product_photos_qty IS NULL;

SELECT COUNT(*) AS Missing_Weight
FROM products
WHERE product_weight_g IS NULL;

SELECT
COUNT(*) AS Missing_Length
FROM products
WHERE product_length_cm IS NULL;

SELECT
COUNT(*) AS Missing_Height
FROM products
WHERE product_height_cm IS NULL;

SELECT
COUNT(*) AS Missing_Width
FROM products
WHERE product_width_cm IS NULL;

-- Check missing details in Seller table:
SELECT COUNT(*) AS Missing_Seller_City
FROM sellers
WHERE seller_city IS NULL;

SELECT COUNT(*) AS Missing_Seller_State
FROM sellers
WHERE seller_state IS NULL;

-- Check missing details in Payments table:
SELECT COUNT(*) AS Missing_Payment_Type
FROM payments
WHERE payment_type IS NULL;

SELECT COUNT(*) AS Missing_Installments
FROM payments
WHERE payment_installments IS NULL;

SELECT COUNT(*) AS Missing_Payment_Value
FROM payments
WHERE payment_value IS NULL;

-- Check missing details in Reviews Table:
SELECT COUNT(*) AS Missing_Review_Score
FROM reviews
WHERE review_score IS NULL;

-- Check missing details in Geolocation Table:
SELECT COUNT(*) AS Missing_Latitude
FROM geolocation
WHERE geolocation_lat IS NULL;

SELECT COUNT(*) AS Missing_Longitude
FROM geolocation
WHERE geolocation_lng IS NULL;

-- Check missing values in Product Category Translation
SELECT COUNT(*) AS Missing_English_Name
FROM product_category_translation
WHERE product_category_name_english IS NULL;

-- Validate Date Columns
SELECT *
FROM orders
WHERE order_delivered_customer_date
<
order_purchase_timestamp;

-- Check Numeric Values
SELECT *
FROM order_items
WHERE price<0;

SELECT *
FROM payments
WHERE payment_value<0;

SELECT *
FROM products
WHERE product_weight_g<0;



-- Check the secure_file_priv system variable
-- This displays the directory from which MySQL allows
-- importing and exporting files using LOAD DATA INFILE
SHOW VARIABLES LIKE 'secure_file_priv';

-- DATA IMPORT USING LOAD DATA INFILE
-- Import all CSV files into their respective tables

-- Import Customer Data
-- Loads customer demographic and location information
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Orders Data
-- Handles NULL values and converts timestamp strings into
-- MySQL DATETIME format using STR_TO_DATE()
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
order_id,
customer_id,
order_status,
@purchase,
@approved,
@carrier,
@delivered,
@estimated
)
SET
order_purchase_timestamp =
CASE
    WHEN @purchase='' THEN NULL
    ELSE STR_TO_DATE(@purchase,'%Y-%m-%d %H:%i:%s')
END,

order_approved_at =
CASE
    WHEN @approved='' THEN NULL
    ELSE STR_TO_DATE(@approved,'%Y-%m-%d %H:%i:%s')
END,

order_delivered_carrier_date =
CASE
    WHEN @carrier='' THEN NULL
    ELSE STR_TO_DATE(@carrier,'%Y-%m-%d %H:%i:%s')
END,

order_delivered_customer_date =
CASE
    WHEN @delivered='' THEN NULL
    ELSE STR_TO_DATE(@delivered,'%Y-%m-%d %H:%i:%s')
END,

order_estimated_delivery_date =
CASE
    WHEN @estimated='' THEN NULL
    ELSE STR_TO_DATE(@estimated,'%Y-%m-%d %H:%i:%s')
END;

-- Import Products Data
-- Handles missing numeric values by converting empty strings
-- into NULL before inserting into the table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
product_id,
product_category_name,
@name_len,
@desc_len,
@photos_qty,
@weight,
@length,
@height,
@width
)
SET
product_name_length =
CASE
WHEN @name_len='' THEN NULL
ELSE @name_len
END,

product_description_length =
CASE
WHEN @desc_len='' THEN NULL
ELSE @desc_len
END,

product_photos_qty =
CASE
WHEN @photos_qty='' THEN NULL
ELSE @photos_qty
END,

product_weight_g =
CASE
WHEN @weight='' THEN NULL
ELSE @weight
END,

product_length_cm =
CASE
WHEN @length='' THEN NULL
ELSE @length
END,

product_height_cm =
CASE
WHEN @height='' THEN NULL
ELSE @height
END,

product_width_cm =
CASE
WHEN @width='' THEN NULL
ELSE @width
END;

-- Import Sellers Data
-- Loads seller information and location details
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
INTO TABLE sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Product Category Translation Data
-- Loads Portuguese product categories and their English translations
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE product_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Geolocation Data
-- Loads ZIP code prefixes with latitude and longitude
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_geolocation_dataset.csv'
INTO TABLE geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Payments Data
-- Loads payment method, installments and payment value
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Order Items Data
-- Converts shipping_limit_date into DATETIME format
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
order_id,
order_item_id,
product_id,
seller_id,
@shipping_limit_date,
price,
freight_value
)
SET shipping_limit_date =
CASE
    WHEN @shipping_limit_date='' THEN NULL
    ELSE STR_TO_DATE(@shipping_limit_date,'%Y-%m-%d %H:%i:%s')
END;

-- Import Reviews Data
-- Converts review dates into DATETIME format while importing
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv'
INTO TABLE reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    review_id,
    order_id,
    review_score,
    @review_creation_date,
    @review_answer_timestamp
)
SET
review_creation_date =
CASE
    WHEN @review_creation_date = '' THEN NULL
    ELSE STR_TO_DATE(@review_creation_date, '%d-%m-%Y %H:%i')
END,
review_answer_timestamp =
CASE
    WHEN @review_answer_timestamp = '' THEN NULL
    ELSE STR_TO_DATE(@review_answer_timestamp, '%d-%m-%Y %H:%i')
END;
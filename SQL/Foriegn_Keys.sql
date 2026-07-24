-- CREATE FOREIGN KEY CONSTRAINTS
-- Establish relationships between tables to maintain
-- referential integrity

-- Orders → Customers
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- Order Items → Orders
ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- Order Items → Products
ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- Order Items → Sellers
ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_seller
FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id);

-- Payments → Orders
ALTER TABLE payments
ADD CONSTRAINT fk_payments_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- Reviews → Orders
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- Products → Product Category Translation
ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (product_category_name)
REFERENCES product_category_translation(product_category_name);

-- DATA QUALITY CHECK
-- Validate product categories before creating foreign key

-- Check number of rows in translation table
SELECT COUNT(*) FROM product_category_translation;

-- Check number of rows in products table
SELECT COUNT(*) FROM products;

-- Find product categories that do not exist in the
-- translation table
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN product_category_translation pct
ON p.product_category_name = pct.product_category_name
WHERE pct.product_category_name IS NULL
AND p.product_category_name IS NOT NULL;

-- CHECK FOR MISSING PRODUCT CATEGORIES
-- Empty strings cannot satisfy foreign key constraints
SELECT COUNT(*)
FROM products
WHERE product_category_name = '';

-- Disable Safe Update Mode temporarily to clean data
SET SQL_SAFE_UPDATES = 0;

-- Replace empty product categories with NULL
-- NULL values are allowed in foreign keys
UPDATE products
SET product_category_name = NULL
WHERE product_category_name = '';

-- Re-enable Safe Update Mode
SET SQL_SAFE_UPDATES = 1;

-- Verify data cleaning results

-- Confirm no empty strings remain
SELECT COUNT(*)
FROM products
WHERE product_category_name = '';

-- Count NULL product categories
SELECT COUNT(*)
FROM products
WHERE product_category_name IS NULL;

-- Insert missing product categories found during validation
-- This ensures referential integrity before adding the
-- foreign key constraint
INSERT INTO product_category_translation
(product_category_name, product_category_name_english)
VALUES
('pc_gamer', 'pc_gamer'),
('portateis_cozinha_e_preparadores_de_alimentos',
 'portable_kitchen_and_food_preparers');
 
-- Final validation
-- Confirm that every product category has a matching record
-- in the translation table 
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN product_category_translation pct
ON p.product_category_name = pct.product_category_name
WHERE pct.product_category_name IS NULL
AND p.product_category_name IS NOT NULL;

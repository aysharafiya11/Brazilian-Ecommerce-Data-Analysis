-- BEGINNER LEVEL
-- Order Analysis
-- Total number of orders.
SELECT COUNT(*) AS total_orders FROM orders;

-- Total number of delivered orders.
SELECT COUNT(*) AS delivered_orders
FROM orders
WHERE order_status = 'delivered';

-- Total cancelled orders.
SELECT COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'canceled';

-- Total unavailable orders.
SELECT COUNT(*) AS unavailable_orders
FROM orders
WHERE order_status = 'unavailable';

-- Number of order statuses.
SELECT COUNT(DISTINCT order_status) AS total_order_statuses
FROM orders;

-- Count of each order statuses
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Average order processing time.
SELECT ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, 
									order_delivered_customer_date)) , 2) 
			AS avg_processing_time
FROM orders
WHERE order_status = 'delivered' 
		AND order_delivered_customer_date IS NOT NULL;

-- Earliest order date.
SELECT
    MIN(order_purchase_timestamp) AS earliest_order
FROM orders;

-- Latest order date.
SELECT
    MAX(order_purchase_timestamp) AS latest_order
FROM orders;

-- Number of orders placed each month
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_year_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_year_month
ORDER BY order_year_month;

-- Customer Analysis
-- Total customers.
SELECT COUNT(*) AS total_customers FROM customers;

-- Total unique customer cities.
SELECT COUNT(DISTINCT customer_city) AS total_unique_customer_cities 
FROM customers;

-- Total unique customer states.
SELECT COUNT(DISTINCT customer_state) AS total_unique_customer_states 
FROM customers;

-- Customers by state.
SELECT customer_state, COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Top 10 cities by customer count.
SELECT customer_city, COUNT(*) AS total_customers
FROM customers
GROUP BY customer_city
ORDER BY total_customers DESC
LIMIT 10;

-- Top 10 States by Percentage of Customers
SELECT customer_state, COUNT(*) AS total_customers,
ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM customers), 2) AS percentage_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC
LIMIT 10;

-- Top 10 Cities Within Each State based on number of customers
SELECT  customer_state, customer_city, total_customers, city_rank 
FROM
(SELECT customer_state, customer_city, COUNT(*) AS total_customers, 
ROW_NUMBER() OVER (PARTITION BY customer_state ORDER BY COUNT(*) DESC) AS city_rank
FROM customers
GROUP BY customer_state, customer_city) AS t1
WHERE city_rank <= 10
ORDER BY customer_state, city_rank;

-- Product Analysis
-- Total products.
SELECT COUNT(*) AS total_products 
FROM products;

-- Total product categories.
SELECT COUNT(DISTINCT product_category_name) AS total_product_categories 
FROM products;

-- Products in each category.
SELECT pct.product_category_name_english AS category, COUNT(*) AS total_products
FROM products p
LEFT JOIN product_category_translation pct
ON p.product_category_name = pct.product_category_name
GROUP BY p.product_category_name
ORDER BY total_products DESC;

-- Products with missing dimensions.
SELECT COUNT(*) AS products_with_missing_dimensions
FROM products
WHERE product_weight_g IS NULL OR 
product_length_cm IS NULL OR
product_height_cm IS NULL OR
product_width_cm IS NULL;

-- Average product weight in kilograms
SELECT ROUND(AVG(product_weight_g)/1000,2) AS average_product_weight_kg
FROM products;

-- Products Missing Category Name
SELECT COUNT(*) AS missing_category_name
FROM products
WHERE product_category_name IS NULL;

-- Average Dimensions by Category
SELECT
    pct.product_category_name_english AS category,
    ROUND(AVG(product_weight_g), 2) AS avg_weight_g,
    ROUND(AVG(product_length_cm), 2) AS avg_length_cm,
    ROUND(AVG(product_height_cm), 2) AS avg_height_cm,
    ROUND(AVG(product_width_cm), 2) AS avg_width_cm
FROM products p
JOIN product_category_translation pct
ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY avg_weight_g DESC;

-- INTERMEDIATE LEVEL
-- Revenue Analysis
-- Total revenue.
SELECT ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- Monthly revenue.
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- Revenue by year.
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    ROUND(SUM(oi.price), 2) AS yearly_revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_year
ORDER BY order_year;

-- Revenue by state.
SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- Revenue by city (Top 10).
SELECT
    c.customer_city,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_city
ORDER BY total_revenue DESC
LIMIT 10;

-- Revenue by payment type.
SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- Average payment value.
SELECT ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments;

-- Highest payment.
SELECT
    order_id,
    payment_type,
    payment_value
FROM payments
ORDER BY payment_value DESC
LIMIT 1;

-- Lowest payment.
SELECT
    order_id,
    payment_type,
    payment_value
FROM payments
ORDER BY payment_value 
LIMIT 1;

-- Revenue contribution by category.
SELECT
    pct.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(
        SUM(oi.price) * 100 /
        (SELECT SUM(price) FROM order_items),
        2
    ) AS revenue_percentage
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
JOIN product_category_translation pct
ON p.product_category_name = pct.product_category_name
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY total_revenue DESC;

-- Revenue Including Freight
SELECT
    ROUND(SUM(price + freight_value), 2) AS total_revenue_with_freight
FROM order_items;

-- Customer Analysis
-- Top 10 customers by spending.
SELECT
    c.customer_unique_id,
    ROUND(SUM(p.payment_value), 2) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

-- Customers with orders more than 5.
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 5
ORDER BY total_orders DESC;

-- Average orders per customer.
SELECT
    ROUND(COUNT(o.order_id) / COUNT(DISTINCT c.customer_unique_id), 2) AS avg_orders_per_customer
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;
    
-- Customer lifetime value (Top 20).
SELECT
    c.customer_unique_id,
    ROUND(SUM(p.payment_value), 2) AS customer_lifetime_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY customer_lifetime_value DESC
LIMIT 20;

-- Repeat customer percentage.
SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_unique_id END) * 100.0
        / COUNT(DISTINCT customer_unique_id),
        2
    ) AS repeat_customer_percentage
FROM
(
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o
	ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;

-- Seller Analysis
-- Total sellers.
SELECT COUNT(*) AS total_sellers
FROM sellers;

-- Sellers by state.
SELECT seller_state, COUNT(*) AS total_sellers
FROM sellers
GROUP BY seller_state
ORDER BY total_sellers DESC;

-- Top 10 sellers by revenue.
SELECT
    oi.seller_id,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 sellers by number of orders.
SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;

-- Seller average order value.
SELECT
    seller_id,
    ROUND(AVG(price), 2) AS average_order_value
FROM order_items
GROUP BY seller_id
ORDER BY average_order_value DESC;

-- Product Analysis
-- Top 10 selling products.
SELECT
    product_id,
    COUNT(*) AS total_units_sold
FROM order_items
GROUP BY product_id
ORDER BY total_units_sold DESC
LIMIT 10;

-- Least-selling products.
SELECT
    product_id,
    COUNT(*) AS total_units_sold
FROM order_items
GROUP BY product_id
ORDER BY total_units_sold 
LIMIT 10;

-- Products generating highest revenue (Top 10).
SELECT
    product_id,
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Best-selling categories.
SELECT
    pct.product_category_name_english AS category,
    COUNT(*) AS total_products_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY category
ORDER BY total_products_sold DESC
LIMIT 10;

-- Lowest-selling categories.
SELECT
    pct.product_category_name_english AS category,
    COUNT(*) AS total_products_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY category
ORDER BY total_products_sold 
LIMIT 10;

-- Average product price.
SELECT
    ROUND(AVG(price), 2) AS average_product_price
FROM order_items;

-- Most expensive products (Top 10).
SELECT
    product_id,
    MAX(price) AS highest_price
FROM order_items
GROUP BY product_id
ORDER BY highest_price DESC
LIMIT 10;

-- Cheapest products.
SELECT
    product_id,
    MIN(price) AS lowest_price
FROM order_items
GROUP BY product_id
ORDER BY lowest_price 
LIMIT 10;

-- Average freight cost.
SELECT
    ROUND(AVG(freight_value), 2) AS average_freight_cost
FROM order_items;

-- Average Freight cost by state.
SELECT
    c.customer_state,
    ROUND(AVG(oi.freight_value), 2) AS average_freight_cost
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY average_freight_cost DESC;
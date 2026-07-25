-- ADVANCED JOIN QUESTIONS
-- Customer name, city, order date and status.
SELECT
    c.customer_unique_id,
    c.customer_city,
    o.order_purchase_timestamp,
    o.order_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;

-- Customer purchases with payment details.
SELECT
    c.customer_unique_id,
    o.order_id,
    p.payment_type,
    p.payment_installments,
    p.payment_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id;

-- Product, seller and category details.
SELECT
    oi.product_id,
    oi.seller_id,
    pct.product_category_name_english AS category,
    oi.price
FROM order_items oi
JOIN products pr
ON oi.product_id = pr.product_id
JOIN product_category_translation pct
ON pr.product_category_name = pct.product_category_name;

-- Orders with review score.
SELECT
    o.order_id,
    o.order_status,
    r.review_score
FROM orders o
JOIN reviews r
ON o.order_id = r.order_id;

-- Orders with multiple payment methods.
SELECT
    order_id,
    COUNT(DISTINCT payment_type) AS payment_methods
FROM payments
GROUP BY order_id
HAVING COUNT(DISTINCT payment_type) > 1;

-- Seller revenue by category.
SELECT
    oi.seller_id,
    pct.product_category_name_english AS category,
    ROUND(SUM(oi.price),2) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id=p.product_id
JOIN product_category_translation pct
ON p.product_category_name=pct.product_category_name
GROUP BY oi.seller_id, category
ORDER BY revenue DESC;

-- Customer purchase history.
SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp,
    o.order_status
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
ORDER BY c.customer_unique_id,o.order_purchase_timestamp;

-- Seller performance by state.
SELECT
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price),2) AS revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id=oi.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC;

-- Product sales by category.
SELECT
    pct.product_category_name_english AS category,
    COUNT(*) AS products_sold,
    ROUND(SUM(oi.price),2) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id=p.product_id
JOIN product_category_translation pct
ON p.product_category_name=pct.product_category_name
GROUP BY category
ORDER BY revenue DESC;

-- Revenue by seller state.
SELECT
    s.seller_state,
    ROUND(SUM(oi.price),2) AS revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id=oi.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC;

-- Customer and seller located in same state.
SELECT
    c.customer_unique_id,
    c.customer_state,
    s.seller_id
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN order_items oi
ON o.order_id=oi.order_id
JOIN sellers s
ON oi.seller_id=s.seller_id
WHERE c.customer_state=s.seller_state;

-- Average delivery days by seller.
SELECT
    oi.seller_id,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                o.order_purchase_timestamp,
                o.order_delivered_customer_date
            )
        ),2
    ) AS avg_delivery_days
FROM order_items oi
JOIN orders o
ON oi.order_id=o.order_id
WHERE o.order_status='delivered'
GROUP BY oi.seller_id
ORDER BY avg_delivery_days;

-- Product category with highest freight.
SELECT
    pct.product_category_name_english AS category,
    ROUND(AVG(oi.freight_value),2) AS avg_freight
FROM order_items oi
JOIN products p
ON oi.product_id=p.product_id
JOIN product_category_translation pct
ON p.product_category_name=pct.product_category_name
GROUP BY category
ORDER BY avg_freight DESC
LIMIT 1;

-- Orders containing multiple sellers.
SELECT
    order_id,
    COUNT(DISTINCT seller_id) AS sellers
FROM order_items
GROUP BY order_id
HAVING COUNT(DISTINCT seller_id)>1;

-- Orders with multiple products.
SELECT
    order_id,
    COUNT(DISTINCT product_id) AS products
FROM order_items
GROUP BY order_id
HAVING COUNT(DISTINCT product_id)>1;

-- Highest revenue order.
SELECT
    order_id,
    ROUND(SUM(price),2) AS revenue
FROM order_items
GROUP BY order_id
ORDER BY revenue DESC
LIMIT 1;

-- Average order value by state.
SELECT
    c.customer_state,
    ROUND(AVG(order_value),2) AS avg_order_value
FROM
(
    SELECT
        order_id,
        SUM(price) AS order_value
    FROM order_items
    GROUP BY order_id
) t
JOIN orders o
ON t.order_id=o.order_id
JOIN customers c
ON o.customer_id=c.customer_id
GROUP BY c.customer_state
ORDER BY avg_order_value DESC;

-- Top categories by customer state.
WITH ranked_categories AS
(
    SELECT
        c.customer_state,
        pct.product_category_name_english AS category,
        COUNT(*) AS total_sales,
        DENSE_RANK() OVER
        (
            PARTITION BY c.customer_state
            ORDER BY COUNT(*) DESC
        ) AS category_rank
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN product_category_translation pct
        ON p.product_category_name = pct.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY
        c.customer_state,
        pct.product_category_name_english
)

SELECT
    customer_state,
    category,
    total_sales
FROM ranked_categories
WHERE category_rank = 1
ORDER BY total_sales DESC;

-- Seller handling highest number of unique customers.
SELECT
    oi.seller_id,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM order_items oi
JOIN orders o
ON oi.order_id=o.order_id
JOIN customers c
ON o.customer_id=c.customer_id
GROUP BY oi.seller_id
ORDER BY unique_customers DESC
LIMIT 1;

-- Customer purchasing from multiple sellers.
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT oi.seller_id) AS total_sellers
FROM order_items oi
JOIN orders o
ON oi.order_id=o.order_id
JOIN customers c
ON o.customer_id=c.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT oi.seller_id) > 1
ORDER BY total_sellers DESC;

-- CASE Statement Questions
-- Categorize customers based on their total spending
SELECT
    c.customer_unique_id,
    ROUND(SUM(p.payment_value),2) AS total_spent,
    CASE
        WHEN SUM(p.payment_value) > 5000 THEN 'Gold'
        WHEN SUM(p.payment_value) > 2000 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_category
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC;

-- Classify orders based on their total value.
SELECT
    order_id,
    order_value,
    CASE
        WHEN order_value < 100 THEN 'Low'
        WHEN order_value BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'High'
    END AS order_category
FROM
(
    SELECT
        order_id,
        ROUND(SUM(price), 2) AS order_value
    FROM order_items
    GROUP BY order_id
) t;

-- Group review scores into satisfaction levels.
SELECT
    review_id,
    review_score,
    CASE
        WHEN review_score = 5 THEN 'Excellent'
        WHEN review_score = 4 THEN 'Good'
        WHEN review_score IN (2,3) THEN 'Average'
        ELSE 'Poor'
    END AS review_category
FROM reviews;

-- Determine whether deliveries were early, on time, or late.
SELECT
    order_id,
    order_estimated_delivery_date,
    order_delivered_customer_date,
    CASE
        WHEN order_delivered_customer_date < order_estimated_delivery_date THEN 'Early'
        WHEN order_delivered_customer_date = order_estimated_delivery_date THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status
FROM orders
WHERE order_status='delivered';

-- Categorize freight charges.
SELECT
    order_id,
    freight_value,
    CASE
        WHEN freight_value < 20 THEN 'Low'
        WHEN freight_value BETWEEN 20 AND 50 THEN 'Medium'
        ELSE 'High'
    END AS freight_category
FROM order_items;

-- Categorize sellers based on total revenue.
SELECT
    seller_id,
    ROUND(SUM(price), 2) AS total_revenue,
    CASE
        WHEN SUM(price) > 100000 THEN 'Excellent'
        WHEN SUM(price) > 50000 THEN 'Good'
        ELSE 'Average'
    END AS seller_performance
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC;

-- Classify customers based on the number of orders.
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders,
    CASE
        WHEN COUNT(o.order_id) >= 10 THEN 'Highly Loyal'
        WHEN COUNT(o.order_id) BETWEEN 5 AND 9 THEN 'Loyal'
        ELSE 'Occasional'
    END AS loyalty_status
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;

-- Classify products by selling price.
SELECT
    product_id,
    price,
    CASE
        WHEN price_group = 1 THEN 'Budget'
        WHEN price_group = 2 THEN 'Standard'
        WHEN price_group = 3 THEN 'Premium'
    END AS price_category
FROM
(
    SELECT
        product_id,
        price,
        NTILE(3) OVER (ORDER BY price) AS price_group
    FROM order_items
) t;

-- Classify deliveries based on the number of days taken.
SELECT
    order_id,
    TIMESTAMPDIFF(
        DAY,
        order_purchase_timestamp,
        order_delivered_customer_date
    ) AS delivery_days,
    CASE
        WHEN TIMESTAMPDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) <= 3 THEN 'Fast'
        WHEN TIMESTAMPDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) <= 7 THEN 'Moderate'
        ELSE 'Slow'
    END AS delivery_speed
FROM orders
WHERE order_status='delivered';

-- Classify payment transactions based on value.
SELECT
    order_id,
    payment_type,
    payment_value,
    CASE
        WHEN payment_value < 100 THEN 'Low Risk'
        WHEN payment_value BETWEEN 100 AND 1000 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS payment_risk
FROM payments;

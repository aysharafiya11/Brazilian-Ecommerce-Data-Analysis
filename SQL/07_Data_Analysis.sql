-- SUBQUERIES
-- Which products have never been purchased?
SELECT
    product_id
FROM products
WHERE product_id NOT IN
(
    SELECT DISTINCT product_id
    FROM order_items
);

-- Which customers have spent more than the average customer?
SELECT customer_unique_id, total_spent
FROM
(
    SELECT c.customer_unique_id, SUM(p.payment_value) AS total_spent
    FROM customers c
    JOIN orders o
	ON c.customer_id = o.customer_id
    JOIN payments p
	ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) AS customer_spending
WHERE total_spent >
(
    SELECT AVG(total_spent)
    FROM
    (
        SELECT SUM(p.payment_value) AS total_spent
        FROM customers c
        JOIN orders o
		ON c.customer_id = o.customer_id
        JOIN payments p
		ON o.order_id = p.order_id
        WHERE o.order_status = 'delivered'
        GROUP BY c.customer_unique_id
    ) AS avg_spending
)
ORDER BY total_spent DESC;

-- Sellers Earning Above Average Revenue
SELECT
    seller_id,
    total_revenue
FROM
(
    SELECT
        seller_id,
        SUM(price) AS total_revenue
    FROM order_items
    GROUP BY seller_id
) seller_revenue
WHERE total_revenue >
(
    SELECT AVG(total_revenue)
    FROM
    (
        SELECT
            SUM(price) AS total_revenue
        FROM order_items
        GROUP BY seller_id
    ) avg_revenue
)
ORDER BY total_revenue DESC;

-- Highest Selling Category
SELECT
    product_category_name_english,
    total_sales
FROM
(
    SELECT
        pct.product_category_name_english,
        COUNT(*) AS total_sales
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN product_category_translation pct
        ON p.product_category_name = pct.product_category_name
    GROUP BY pct.product_category_name_english
) category_sales
WHERE total_sales =
(
    SELECT MAX(total_sales)
    FROM
    (
        SELECT
            COUNT(*) AS total_sales
        FROM order_items oi
        JOIN products p
            ON oi.product_id = p.product_id
        GROUP BY p.product_category_name
    ) t
);

-- Most Expensive Product in Each Category
SELECT
    p.product_id,
    pct.product_category_name_english,
    oi.price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
WHERE oi.price =
(
    SELECT MAX(oi.price)
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
	JOIN product_category_translation pct
    ON p.product_category_name = pct.product_category_name
);

-- Customers with Highest Order Value
SELECT
    customer_unique_id,
    order_value
FROM
(
    SELECT
        c.customer_unique_id,
        o.order_id,
        SUM(oi.price) AS order_value
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_unique_id,
        o.order_id
) customer_orders
WHERE order_value =
(
    SELECT MAX(order_value)
    FROM
    (
        SELECT
            SUM(price) AS order_value
        FROM order_items
        GROUP BY order_id
    ) t
);

-- Orders Above Average Payment
SELECT
    order_id,
    payment_value
FROM payments
WHERE payment_value >
(
    SELECT AVG(payment_value)
    FROM payments
)
ORDER BY payment_value DESC;

-- States with Revenue Above National Average
SELECT
    customer_state,
    state_revenue
FROM
(
    SELECT
        c.customer_state,
        SUM(oi.price) AS state_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
) state_sales
WHERE state_revenue >
(
    SELECT AVG(state_revenue)
    FROM
    (
        SELECT
            SUM(oi.price) AS state_revenue
        FROM customers c
        JOIN orders o
            ON c.customer_id = o.customer_id
        JOIN order_items oi
            ON o.order_id = oi.order_id
        WHERE o.order_status = 'delivered'
        GROUP BY c.customer_state
    ) avg_state_sales
)
ORDER BY state_revenue DESC;

-- Products Sold Only Once
SELECT
    product_id
FROM order_items
GROUP BY product_id
HAVING COUNT(*) = 1;

-- Sellers Without Reviews
SELECT DISTINCT
    oi.seller_id
FROM order_items oi
WHERE oi.seller_id NOT IN
(
    SELECT DISTINCT
        oi.seller_id
    FROM order_items oi
    JOIN reviews r
        ON oi.order_id = r.order_id
);

-- CTE QUESTIONS
-- What is the monthly sales revenue?
WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
        ROUND(SUM(oi.price),2) AS total_sales
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)

SELECT *
FROM monthly_sales
ORDER BY sales_month;

-- What is the cumulative monthly revenue over time?
WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS sales_month,
        ROUND(SUM(oi.price), 2) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id=oi.order_id
    WHERE o.order_status='delivered'
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m')
)

SELECT
    sales_month,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER(ORDER BY sales_month), 2) AS running_revenue
FROM monthly_sales;

-- Rank customers by total spending.
WITH customer_sales AS
(
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id=o.customer_id
    JOIN payments p
        ON o.order_id=p.order_id
    WHERE o.order_status='delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(total_spent,2) AS total_spent,
    DENSE_RANK() OVER(ORDER BY total_spent DESC) AS customer_rank
FROM customer_sales;

-- Rank sellers by revenue.
WITH seller_sales AS
(
    SELECT
        seller_id,
        SUM(price) AS total_revenue
    FROM order_items
    GROUP BY seller_id
)

SELECT
    seller_id,
    ROUND(total_revenue,2) AS total_revenue,
    DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS seller_rank
FROM seller_sales;

-- Rank products based on revenue.
WITH product_sales AS
(
    SELECT
        product_id,
        SUM(price) AS total_revenue
    FROM order_items
    GROUP BY product_id
)

SELECT
    product_id,
    ROUND(total_revenue,2) AS total_revenue,
    DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS product_rank
FROM product_sales;

-- Calculate month-over-month sales growth.
WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
        SUM(oi.price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

monthly_growth AS
(
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER(ORDER BY sales_month) AS previous_month_revenue
    FROM monthly_sales
)

SELECT
    sales_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        ((monthly_revenue - previous_month_revenue)
        / previous_month_revenue) * 100,
        2
    ) AS growth_percentage
FROM monthly_growth;

-- Find the top 5 revenue-generating sellers in each state.
WITH seller_revenue AS
(
    SELECT
        s.seller_state,
        s.seller_id,
        SUM(oi.price) AS revenue
    FROM sellers s
    JOIN order_items oi
        ON s.seller_id=oi.seller_id
    GROUP BY
        s.seller_state,
        s.seller_id
)

SELECT
    seller_state,
    seller_id,
    ROUND(revenue,2) AS revenue,
    seller_rank
FROM
(
    SELECT *,
        ROW_NUMBER() OVER
        (
            PARTITION BY seller_state
            ORDER BY revenue DESC
        ) AS seller_rank
    FROM seller_revenue
) t
WHERE seller_rank<=5;

-- Find the highest revenue-generating product in each category.
WITH product_revenue AS
(
    SELECT
        pct.product_category_name_english AS category,
        oi.product_id,
        SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id=p.product_id
    JOIN product_category_translation pct
        ON p.product_category_name=pct.product_category_name
    GROUP BY
        category,
        oi.product_id
)

SELECT
    category,
    product_id,
    ROUND(revenue,2) AS revenue
FROM
(
    SELECT *,
        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS product_rank
    FROM product_revenue
) t
WHERE product_rank=1;

-- What percentage of total revenue does each category contribute?
WITH category_sales AS
(
    SELECT
        pct.product_category_name_english AS category,
        SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id=p.product_id
    JOIN product_category_translation pct
        ON p.product_category_name=pct.product_category_name
    GROUP BY category
)

SELECT
    category,
    ROUND(revenue,2) AS revenue,
    ROUND(
        revenue*100/
        SUM(revenue) OVER(),
        2
    ) AS revenue_percentage
FROM category_sales
ORDER BY revenue DESC;

-- Identify customers who have placed more than one order.
WITH customer_orders AS
(
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id=o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    total_orders
FROM customer_orders
WHERE total_orders>1
ORDER BY total_orders DESC;

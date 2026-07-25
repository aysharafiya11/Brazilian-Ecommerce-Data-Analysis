-- WINDOW FUNCTIONS 
-- Assign a unique row number to customers based on total spending.
WITH customer_sales AS
(
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(total_spent,2) AS total_spent,
    ROW_NUMBER() OVER(ORDER BY total_spent DESC) AS row_num
FROM customer_sales;

-- RANK() Sellers by Revenue
WITH seller_sales AS
(
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
)

SELECT
    seller_id,
    ROUND(revenue,2) AS revenue,
    RANK() OVER(ORDER BY revenue DESC) AS seller_rank
FROM seller_sales;

-- DENSE_RANK() Products
WITH product_sales AS
(
    SELECT
        product_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY product_id
)

SELECT
    product_id,
    ROUND(revenue,2) AS revenue,
    DENSE_RANK() OVER(ORDER BY revenue DESC) AS product_rank
FROM product_sales;

-- LAG() Monthly Sales
WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS sales_month,
        SUM(price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status='delivered'
    GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m')
)

SELECT
    sales_month,
    revenue,
    LAG(revenue) OVER(ORDER BY sales_month) AS previous_month
FROM monthly_sales;

-- LEAD() Monthly Sales
WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS sales_month,
        SUM(price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status='delivered'
    GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m')
)

SELECT
    sales_month,
    revenue,
    LEAD(revenue) OVER(ORDER BY sales_month) AS next_month
FROM monthly_sales;

-- FIRST_VALUE() Highest Payment
SELECT
    order_id,
    payment_value,
    FIRST_VALUE(payment_value)
    OVER(
        ORDER BY payment_value DESC
    ) AS highest_payment
FROM payments;

-- LAST_VALUE() Lowest Payment
SELECT
    order_id,
    payment_value,
    LAST_VALUE(payment_value)
    OVER
    (
        ORDER BY payment_value DESC
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS lowest_payment
FROM payments;

-- NTILE(4) Customer Spending
WITH customer_sales AS
(
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
    WHERE o.order_status='delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(total_spent,2) AS total_spent,
    NTILE(4) OVER(ORDER BY total_spent DESC) AS spending_quartile
FROM customer_sales;

-- Running Revenue
WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS sales_month,
        SUM(price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id=oi.order_id
    WHERE o.order_status='delivered'
    GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m')
)

SELECT
    sales_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(SUM(revenue) OVER(ORDER BY sales_month), 2) AS running_revenue
FROM monthly_sales;

-- Running Order Count
WITH monthly_orders AS
(
    SELECT
        DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS sales_month,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m')
)

SELECT
    sales_month,
    total_orders,
    SUM(total_orders) OVER(ORDER BY sales_month) AS running_orders
FROM monthly_orders;

-- Cumulative Customers
WITH monthly_customers AS
(
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS sales_month,
        COUNT(DISTINCT c.customer_unique_id) AS customers
    FROM customers c
    JOIN orders o
        ON c.customer_id=o.customer_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m')
)

SELECT
    sales_month,
    customers,
    SUM(customers) OVER(ORDER BY sales_month) AS cumulative_customers
FROM monthly_customers;

-- Moving Average Revenue
WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS sales_month,
        SUM(price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id=oi.order_id
    WHERE o.order_status='delivered'
    GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m')
)

SELECT
    sales_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        AVG(revenue)
        OVER(
            ORDER BY sales_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_average
FROM monthly_sales;

-- Rank States by Revenue
WITH state_sales AS
(
    SELECT
        c.customer_state,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id=o.customer_id
    JOIN order_items oi
        ON o.order_id=oi.order_id
    WHERE o.order_status='delivered'
    GROUP BY c.customer_state
)

SELECT
    customer_state,
    ROUND(revenue,2) AS revenue,
    DENSE_RANK() OVER(ORDER BY revenue DESC) AS state_rank
FROM state_sales;

-- Rank Categories by Sales
WITH category_sales AS
(
    SELECT
        pct.product_category_name_english AS category,
        COUNT(*) AS total_sales
    FROM order_items oi
    JOIN products p
        ON oi.product_id=p.product_id
    JOIN product_category_translation pct
        ON p.product_category_name=pct.product_category_name
    GROUP BY category
)

SELECT
    category,
    total_sales,
    DENSE_RANK() OVER(ORDER BY total_sales DESC) AS category_rank
FROM category_sales;

-- Views (5)
-- Create a reusable view for monthly revenue.
CREATE VIEW monthly_sales_view AS
SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price),2) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id=oi.order_id
WHERE o.order_status='delivered'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m');

SELECT *
FROM monthly_sales_view;

-- Customer Summary View
CREATE VIEW customer_summary_view AS
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value),2) AS total_spent,
    ROUND(AVG(p.payment_value),2) AS avg_order_value
FROM customers c
JOIN orders o
    ON c.customer_id=o.customer_id
JOIN payments p
    ON o.order_id=p.order_id
WHERE o.order_status='delivered'
GROUP BY c.customer_unique_id;

SELECT *
FROM customer_summary_view;

-- Seller Performance View
CREATE VIEW seller_performance_view AS
SELECT
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price),2) AS revenue,
    ROUND(AVG(oi.price),2) AS avg_order_value
FROM sellers s
JOIN order_items oi
    ON s.seller_id=oi.seller_id
GROUP BY
    s.seller_id,
    s.seller_state;
    
SELECT * 
FROM seller_performance_view; 

-- Product Summary View
CREATE VIEW product_summary_view AS
SELECT
    oi.product_id,
    pct.product_category_name_english AS category,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price),2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id=p.product_id
JOIN product_category_translation pct
    ON p.product_category_name=pct.product_category_name
GROUP BY
    oi.product_id,
    category;
    
SELECT *
FROM product_summary_view;

-- Revenue Dashboard View
CREATE VIEW revenue_dashboard_view AS
SELECT
    c.customer_state,
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS sales_month,
    ROUND(SUM(oi.price),2) AS revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id=o.customer_id
JOIN order_items oi
    ON o.order_id=oi.order_id
WHERE o.order_status='delivered'
GROUP BY
    c.customer_state,
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m');
    
SELECT *
FROM revenue_dashboard_view;

-- Cohort Analysis
-- Determine retention based on the customer's first purchase month.
WITH first_purchase AS
(
SELECT
	customer_id,
	MIN(order_purchase_timestamp) AS first_order
FROM orders
GROUP BY customer_id
)

SELECT
	DATE_FORMAT(first_order,'%Y-%m') AS cohort_month,
	COUNT(*) AS customers
FROM first_purchase
GROUP BY cohort_month;

-- ABC Product Classification
WITH product_sales AS
(
SELECT
	product_id,
	ROUND(SUM(price),2) AS revenue
FROM order_items
GROUP BY product_id
)

SELECT
	product_id,
	revenue,
    NTILE(10) OVER(ORDER BY revenue DESC) AS percentile_10,
	CASE
		WHEN NTILE(10) OVER(ORDER BY revenue DESC)<=2 THEN 'A'
		WHEN NTILE(10) OVER(ORDER BY revenue DESC)<=5 THEN 'B'
		ELSE 'C'
	END AS product_class
FROM product_sales;

-- Delivery Delay Analysis
WITH delivery_delay AS
(
    SELECT
        order_id,
        DATEDIFF(
            order_delivered_customer_date,
            order_estimated_delivery_date
        ) AS delay_days
    FROM orders
    WHERE order_status = 'delivered'
)

SELECT
    order_id,
    delay_days,
    CASE
        WHEN delay_days > 0 THEN 'Late'
        WHEN delay_days = 0 THEN 'On Time'
        ELSE 'Early'
    END AS delivery_status
FROM delivery_delay;

-- Payment Method Preference by State
SELECT
	c.customer_state,
	p.payment_type,
	COUNT(*) AS total_payments,
	DENSE_RANK() OVER
				(
					PARTITION BY c.customer_state
					ORDER BY COUNT(*) DESC
				) AS payment_rank
FROM customers c
JOIN orders o
	ON c.customer_id=o.customer_id
JOIN payments p
	ON o.order_id=p.order_id
GROUP BY
	c.customer_state,
    p.payment_type;
  
-- Seller Retention Analysis  
WITH seller_activity AS
(
    SELECT
        oi.seller_id,
        MIN(o.order_purchase_timestamp) AS first_sale_date,
        MAX(o.order_purchase_timestamp) AS latest_sale_date,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        DATEDIFF(
            MAX(o.order_purchase_timestamp),
            MIN(o.order_purchase_timestamp)
        ) AS active_days
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
)

SELECT
    seller_id,
    first_sale_date,
    latest_sale_date,
    total_orders,
    active_days,
    CASE
        WHEN active_days >= 365 THEN 'Highly Retained'
        WHEN active_days >= 180 THEN 'Moderately Retained'
        ELSE 'Low Retention'
    END AS retention_status
FROM seller_activity
ORDER BY active_days DESC;

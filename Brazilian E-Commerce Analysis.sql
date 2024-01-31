/* Customer behavior and preferences analysis */ 

-- How many items do customers order?
SELECT 
	order_item_id AS number_of_items,
	COUNT(order_id) AS orders,
	ROUND((COUNT(order_id) / SUM(COUNT(order_id)) OVER ()) * 100, 2) AS percentage_of_orders
FROM olist_orders_items
GROUP BY order_item_id
ORDER BY orders DESC;

-- What is the average order value?
WITH total_order_values AS (
	SELECT 
		order_id,
		SUM(price) AS total_product_value, -- Sum of product prices for each item in the order
		SUM(freight_value) AS total_freight_value -- Sum of freight values for each item in the order
	FROM olist_orders_items
	GROUP BY order_id
)
SELECT ROUND(AVG(total_product_value + total_freight_value), 2) AS avg_order_value
FROM total_order_values;

-- What is the average order value per payment method?
WITH order_values AS (
	SELECT 
		o.order_id,
		SUM(o.price) + SUM(o.freight_value) AS total_order_value
	FROM olist_orders_items AS o
	GROUP BY o.order_id
)

SELECT 
	p.payment_type,
	ROUND(AVG(v.total_order_value), 2) AS avg_order_value
FROM order_values AS v
JOIN olist_order_payments AS p ON v.order_id = p.order_id
GROUP BY p.payment_type
ORDER BY avg_order_value DESC;

-- What are the preferred payment methods among customers?
SELECT
    payment_type,
    COUNT(order_id) AS total_orders,
	ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER (), 2) AS percentage_of_orders
FROM olist_order_payments
GROUP BY payment_type
ORDER BY total_orders DESC;

-- Do customers pay in full or in installments?
SELECT
    payment_installments,
    COUNT(order_id) AS total_orders,
	ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER (), 2) AS percentage_of_orders
FROM olist_order_payments
GROUP BY payment_installments
ORDER BY total_orders DESC;

-- Do the number of payment installments depend on the order value?
WITH order_values AS (
	SELECT 
		o.order_id,
		SUM(o.price) + SUM(o.freight_value) AS total_order_value
	FROM olist_orders_items AS o
	GROUP BY o.order_id
)

SELECT 
	p.payment_installments,
	ROUND(AVG(v.total_order_value), 2) AS avg_order_value
FROM order_values AS v
JOIN olist_order_payments AS p ON v.order_id = p.order_id
GROUP BY p.payment_installments
ORDER BY avg_order_value DESC;
	
-- On which days do customers order the most?
SELECT
	COUNT(DISTINCT order_id) AS orders,
	TO_CHAR(order_purchase_timestamp, 'Day') AS day
FROM olist_orders
GROUP BY TO_CHAR(order_purchase_timestamp, 'Day')
ORDER BY orders DESC;

-- What types of products do customers order the most?
SELECT
	t.product_category_name_english AS product_category,
	COUNT(DISTINCT i.order_id) AS orders
FROM olist_orders_items AS i
JOIN olist_products AS p ON i.product_id = p.product_id
JOIN olist_product_category_name_translation AS t ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY orders DESC;

-- What is the average order value for each product category?
WITH order_values AS (
    SELECT 
        i.order_id,
        p.product_category_name,
        SUM(i.price) + SUM(i.freight_value) AS total_order_value  -- Calculate the total value for each order
    FROM olist_orders_items AS i
    JOIN olist_products AS p ON i.product_id = p.product_id
    GROUP BY i.order_id, p.product_category_name
)

SELECT
    t.product_category_name_english AS product_category,
    ROUND(AVG(v.total_order_value), 2) AS avg_order_value  -- Calculate the average order value for each category
FROM order_values AS v
JOIN olist_product_category_name_translation AS t ON v.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY avg_order_value DESC;

-- What is the total order value for each product category?
SELECT
    t.product_category_name_english AS product_category,
    ROUND(SUM(i.price + i.freight_value), 2) AS total_category_value  -- Calculate the total value for each category
FROM olist_orders_items AS i
JOIN olist_products AS p ON i.product_id = p.product_id
JOIN olist_product_category_name_translation AS t ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY total_category_value DESC;

-- How does customer retention vary over time?
WITH ordered_customers AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase,
        MAX(o.order_purchase_timestamp) AS last_purchase
    FROM olist_customers AS c
	JOIN olist_orders AS o ON c.customer_id = o.customer_id 
    GROUP BY customer_unique_id
)
SELECT
    EXTRACT(YEAR FROM first_purchase) AS year,
    COUNT(customer_unique_id) AS total_customers,
    COUNT(CASE WHEN first_purchase <> last_purchase THEN 1 END) AS returning_customers
FROM ordered_customers
GROUP BY year
ORDER BY year;


/* How efficient is the order delivery process? */

-- What is the average delivery time by year?
SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    AVG(order_purchase_timestamp - order_delivered_customer_date) AS average_delivery_time,
	AVG(order_purchase_timestamp - order_estimated_delivery_date) AS average_expected_delivery_time
FROM olist_orders
WHERE order_status = 'delivered'
GROUP BY year
ORDER BY year;

-- How many orders are delivered late?
SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
	COUNT(order_id) AS total_orders,
    COUNT(CASE WHEN order_estimated_delivery_date::date < order_delivered_customer_date::date THEN 1 END) AS delivered_late,
	ROUND(COUNT(CASE WHEN order_estimated_delivery_date::date < order_delivered_customer_date::date THEN 1 END) * 100.0 / COUNT(order_id), 2) AS percentage_late
FROM olist_orders
WHERE order_status = 'delivered'
GROUP BY year
ORDER BY year;

-- How do late deliveries affect client's reviews?  
SELECT
    r.review_score,
    COUNT(o.order_id) AS total_orders,
    COUNT(CASE WHEN o.order_estimated_delivery_date < o.order_delivered_customer_date THEN 1 END) AS delivered_late,
    ROUND(COUNT(CASE WHEN o.order_estimated_delivery_date < o.order_delivered_customer_date THEN 1 END) * 100.0 / COUNT(o.order_id), 2) AS percentage_late,
    ROUND(AVG(CASE WHEN o.order_estimated_delivery_date < o.order_delivered_customer_date THEN EXTRACT(DAY FROM o.order_delivered_customer_date - o.order_estimated_delivery_date) END), 2) AS average_days_late
FROM olist_orders o
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score;

/* Geographical analysis */

-- Orders by state
SELECT 
	c.customer_state AS state,
	COUNT(DISTINCT o.order_id) AS orders
FROM olist_orders AS o
JOIN olist_customers AS c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY orders DESC;

-- Average order value by state
WITH order_values AS (
    SELECT 
        i.order_id,
        c.customer_state,
        SUM(i.price) + SUM(i.freight_value) AS total_order_value  -- Calculate the total value for each order
    FROM olist_orders_items AS i
	JOIN olist_orders AS o ON i.order_id = o.order_id
    JOIN olist_customers AS c ON o.customer_id = c.customer_id
    GROUP BY i.order_id, c.customer_state
)

SELECT
	customer_state AS state,
	ROUND(AVG(total_order_value), 2) AS avg_value
FROM order_values
GROUP BY customer_state
ORDER BY avg_value DESC;

-- Total order value by state
WITH order_values AS (
    SELECT 
        i.order_id,
        c.customer_state,
        SUM(i.price) + SUM(i.freight_value) AS total_order_value  -- Calculate the total value for each order
    FROM olist_orders_items AS i
    JOIN olist_orders AS o ON i.order_id = o.order_id
    JOIN olist_customers AS c ON o.customer_id = c.customer_id
    GROUP BY i.order_id, c.customer_state
)

SELECT
    customer_state AS state,
    ROUND(SUM(total_order_value), 2) AS total_value
FROM order_values
GROUP BY customer_state
ORDER BY total_value DESC;




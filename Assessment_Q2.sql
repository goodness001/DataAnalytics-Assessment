-- CTE 1: Calculate monthly transaction counts per customer
WITH cust_counts AS (
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS month, -- Extract year-month from transaction date
        COUNT(DISTINCT b.id) AS tran_count
    FROM users_customuser a, savings_savingsaccount b
    where a.id = b.owner_id
    -- WHERE transaction_status = 'success'
    GROUP BY owner_id, month
),
-- CTE 2: Aggregate total transactions and active months per customer
customer_activity AS (
    SELECT
        owner_id,
        SUM(tran_count) AS total_transactions,
        COUNT(DISTINCT month) AS active_months
    FROM cust_counts
    GROUP BY owner_id
),
-- CTE 3: Calculate average monthly transactions and categorize customers by frequency
categorized_customer AS (
    SELECT 
        owner_id,
        total_transactions,
        active_months,
        total_transactions / NULLIF(active_months, 0) AS avg_transactions_per_month, -- Avoid division by zero
        CASE 
            WHEN total_transactions / NULLIF(active_months, 0) >= 10 THEN 'High Frequency'
            WHEN total_transactions / NULLIF(active_months, 0) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_activity
)
-- Final output - count of customers and average transaction frequency per category
SELECT 
    frequency_category,
    COUNT(DISTINCT owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month -- Average of averages, rounded to 2 decimals
FROM categorized_customer
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');

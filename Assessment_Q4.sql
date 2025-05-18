-- CTE 1: Get successful transaction count and transaction value per customer
WITH customer_transactions AS (
    SELECT 
        owner_id,
        COUNT(*) AS total_transactions,
        SUM(confirmed_amount) AS total_amount  
    FROM savings_savingsaccount
    WHERE transaction_status = 'success'
      AND confirmed_amount > 0
    GROUP BY owner_id
),
-- CTE 2: Calculate tenure in months for each customer based on their signup date
tenure AS (
    SELECT 
        id AS customer_id,
        CONCAT(first_name, ' ', last_name) AS name,
        TIMESTAMPDIFF(MONTH, date_joined, CURDATE()) AS tenure_months  -- calculate number of Months since joining --
    FROM users_customuser
),
-- CTE 3: Compute estimated CLV for each customer --details below
customer_clv AS (
    SELECT 
        tenure.customer_id,
        name,
        ct.total_transactions,
        ct.total_amount,
        -- Average profit per transaction = 0.1% of transaction value (total transactions)
        ct.total_amount * 0.001 / NULLIF(ct.total_transactions, 0) AS avg_profit_per_transaction,
        tenure.tenure_months,
        -- CLV formula: divide total transactions by tenure, multiply by 12, then multiply by the average profit per transactions
        ROUND(
            (ct.total_transactions / NULLIF(tenure.tenure_months, 0)) * 12 *
            (ct.total_amount * 0.001 / NULLIF(ct.total_transactions, 0))
        , 2) AS estimated_clv
    FROM customer_transactions ct
    JOIN tenure ON ct.owner_id = tenure.customer_id
)
-- STEP 4: Final output
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM customer_clv
ORDER BY estimated_clv DESC;

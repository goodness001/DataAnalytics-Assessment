-- CTE 1: Combine all accounts (savings and investments) with their latest inflow transaction
WITH all_accounts AS (
    SELECT 
        DISTINCT s.plan_id,
        s.owner_id,
        'Savings' AS type, -- Identify savings tran type
        MAX(s.transaction_date) AS last_transaction_date  -- Most recent inflow date
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE p.is_regular_savings = 1 -- confirm savings accounts
        AND s.confirmed_amount > 0
    GROUP BY s.plan_id, s.owner_id
    UNION ALL
    SELECT 
        DISTINCT p.id AS plan_id,
        p.owner_id,
        'Investment' AS type, -- identify investment tran type
        MAX(s.transaction_date) AS last_transaction_date -- Most recent inflow date
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE p.is_a_fund = 1               -- confirm investment accounts
        AND s.confirmed_amount > 0
    GROUP BY p.id, p.owner_id
),
-- CTE 2: Calculate inactivity days for each account
inactivity_flags AS (
    SELECT 
        plan_id,
        owner_id,
        type,
        last_transaction_date,
        DATEDIFF(CURRENT_DATE(), last_transaction_date) AS inactivity_days -- Days since last inflow
    FROM all_accounts
)
-- Final Step: Join with users_customer table to select only active customers whose accounts have had no inflow for over 1 year
SELECT uf.*
FROM inactivity_flags uf
JOIN users_customuser uc ON uf.owner_id = uc.id
WHERE uc.is_active = 1                     -- Only currently active customers
  AND inactivity_days > 365                -- Flag accounts with no inflows in over a year
ORDER BY last_transaction_date;      -- Show most recently inactive accounts first

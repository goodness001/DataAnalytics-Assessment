-- Assessment_Q1.sql
-- CTE 1: Customers with at least one funded savings plan
WITH savings AS (
    SELECT 
        sa.owner_id,
        COUNT(DISTINCT sa.id) AS savings_count,
        SUM(sa.confirmed_amount) AS savings_amount
    FROM savings_savingsaccount sa
    JOIN plans_plan p ON sa.plan_id = p.id
    WHERE p.is_regular_savings = 1
      AND sa.confirmed_amount > 0
    GROUP BY sa.owner_id
),
-- CTE 2: Customers with at least one funded investment plan
investments AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS investment_count
    FROM plans_plan p
    WHERE p.is_a_fund = 1
    GROUP BY p.owner_id
)
-- Final Join: Only customers who have both
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    s.savings_count,
    i.investment_count,
    s.savings_amount AS total_deposits
FROM users_customuser u
JOIN savings s ON u.id = s.owner_id
JOIN investments i ON u.id = i.owner_id
ORDER BY total_deposits DESC;

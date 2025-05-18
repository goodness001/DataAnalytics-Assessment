# DataAnalytics-Assessment
Cowrywise Data Analyst Assessment

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
Assessment_Q1: High-Value Customers with Multiple Products
OBJECTIVE
1. Identify customers who have both:
- At least one funded savings plan
- At least one funded investment plan
2. Rank them by their total deposit value, sorted in descending order.

MY APPROACH
1. Data Separation with CTEs:  
   I used two Common Table Expressions (CTEs) to isolate savings-related and investment-related data. This helped cleanly apply conditions specific to each product type.
   - Savings CTE filters 'savings_savingsaccount' linked to 'plans_plan' marked as 'is_regular_savings = 1', ensuring only funded accounts (`confirmed_amount > 0`) are included.
   - Investments CTE filters directly from plans_plan where 'is_a_fund = 1'.
2. Joining to 'users_customuser' on Owner ID:  
   Both datasets are joined to 'users_customuser' on 'owner_id' to find customers who meet both criteria. This ensures we only include customers with at least one of each type.
3. Aggregation:
   - Count of distinct savings and investment products
   - sum of confirmed_amount to show total deposits.
4. Final Output:
   - Display includes owner ID, full name, count of each product type, and total deposits.
   - Results are sorted by 'total_deposits' in descending order.

CHALLENGES AND RESOLUTION
Combining Different Plan Types:  
Attempting to count both plan types in a single join query led to double-counting and inflated results. Splitting them into separate CTEs solved this and improved clarity.


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
Assessment_Q2: Transaction Frequency analysis
OBJECTIVE
The finance team wants to segment customers by how frequently they transact. Customers are to be classified as:
- High Frequency: Greater than or equal 10 transactions per month
- Medium Frequency: 3–9 transactions per month
- Low Frequency: ≤ 2 transactions per month
The goal is to calculate the average number of transactions per month for each customer and categorize them as stated above.

MY APPROACH
1. Identify Monthly Transaction Volume Per Customer
2. Used DATE_FORMAT(transaction_date, '%Y-%m') to extract 'year-month' from each transaction.
3. Grouped by 'owner_id' and 'month' to calculate the number of transactions per month per customer.
4. Compute Customer Activity Summary
5. Calculated 'total_transactions' and 'active_months' for each customer using a second CTE.
6. active_months is the number of distinct months in which the customer transacted.
7. Classify Customers by Frequency
8. Calculated average monthly transactions: 'total_transactions / active_months'.
9. Used a CASE statement to assign customers into one of three frequency categories: "High Frequency" (≥10 transactions/month), "Medium Frequency" (3-9 transactions/month), "Low Frequency" (≤2 transactions/month)
10. Calculated the average of their average monthly transactions for reporting clarity.

CHALLENGES AND RESOLUTION
Avoiding division by zero: Used NULLIF(active_months, 0) to handle edge cases where a customer may have transactions recorded but an invalid or single-month history.
Accurately counting month was proving difficult: splitting month_count into a separate CTE ensured the month grouping was done correctly before summarizing to avoid incorrect active_months results.


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
Assessment_Q3: Account Inactivity Alert
OBJECTIVE
The operations team needs to identify active customers who have not made any inflow transactions into their savings or investment plans in the past year(365 days).

MY APPROACH
1. Used CTEs to identify and Extract 'Savings' and 'Investment accounts', as well as flag inactivity.
2. Used 'UNION ALL' to combine savings and investment accounts.
3. Included only transactions where 'confirmed_amount > 0' to represent actual inflows.
4. Used 'MAX(transaction_date)' grouped by 'plan_id' and 'owner_id' to find the most recent deposit date for each account.
5. Calculated DATEDIFF(CURRENT_DATE(), last_transaction_date) to determine days since the last inflow.
6. Included only accounts where 'inactivity_days > 365'.
7. Joined with 'users_customuser' to identify customers marked as 'active' in the users_customuser table.

CHALLENGES AND RESOLUTION
Ensuring that only inflow transactions were counted (some transactions might not be true deposits): using confirmed_amount > 0 resolved that.
Joining users_customuser: This was to make use of 'is_active' filtering  to ensure we only capture legitimately active accounts.


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
Assessment_Q4: Customer Lifetime Value (CLV) Estimation
OBJECTIVE
1. To estimate the lifetime value of each customer using the formula below:
   CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
   To achieve this successfully, calculate:
   - Tenure in months since account signup
   - Total transactions (Successful)
2. Order by estimated CLV from highest to lowest
    
MY APPROACH
1. Transaction Summary with CTEs:
The first CTE (customer_transactions) aggregates the number of successful deposit transactions and their total value from the savings_savingsaccount table.
The second CTE (tenure) extracted the number of month since Customer first joined.
The third CTE completed the Estimated CLV calculations giving the final output.
2. Tenure Calculation:
Used TIMESTAMPDIFF to compute the number of months between date_joined and the current date for each user.
3. Profit(0.1%) & CLV Computation:
The avg_profit_per_transaction is calculated as 0.1% of the average transaction value. The stated CLV formula scales this profit across the customer’s monthly activity level.
4. Ordered by estimated_clv in descending order to prioritize high-value users.

CHALLENGES AND RESOLUTION
Precision in Calculations:
Initially, combining profit per transaction and CLV logic directly caused inaccuracies and division by zero errors, wrapping calculations in NULLIF() ensured we avoided division errors while maintaining logical accuracy.

-- =====================================================================
-- Revolut-Style Fintech Unit Economics — SQL Analysis
-- Database: SQLite (fintech.db)
-- Tables: users, transactions, marketing
-- =====================================================================


-- ---------------------------------------------------------------------
-- Query 1: Cohort retention
-- For users grouped by their signup month, calculates what % of the
-- cohort was still transacting N months after signup. Used to calibrate
-- the monthly churn assumption in the forecast model.
-- ---------------------------------------------------------------------

WITH cohort_sizes AS (
    SELECT strftime('%Y-%m', signup_date) AS cohort_month,
           COUNT(*) AS cohort_size
    FROM users
    GROUP BY cohort_month
),
cohort_activity AS (
    SELECT 
        strftime('%Y-%m', u.signup_date) AS cohort_month,
        CAST((julianday(strftime('%Y-%m-01', t.transaction_date)) - 
              julianday(strftime('%Y-%m-01', u.signup_date))) / 30 AS INTEGER) AS months_since_signup,
        COUNT(DISTINCT u.user_id) AS active_users
    FROM users u
    JOIN transactions t ON u.user_id = t.user_id
    GROUP BY cohort_month, months_since_signup
)
SELECT ca.cohort_month,
       ca.months_since_signup,
       ca.active_users,
       cs.cohort_size,
       ROUND(100.0 * ca.active_users / cs.cohort_size, 1) AS retention_pct
FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
WHERE ca.months_since_signup BETWEEN 0 AND 12
ORDER BY ca.cohort_month, ca.months_since_signup;


-- ---------------------------------------------------------------------
-- Query 2: Monthly ARPU trend
-- Calculates total revenue, monthly active users, and average revenue 
-- per active user (ARPU) for each month. The most recent month becomes 
-- the starting point for the forecast model.
-- ---------------------------------------------------------------------

SELECT strftime('%Y-%m', transaction_date) AS month,
       SUM(revenue) AS total_revenue,
       COUNT(DISTINCT user_id) AS active_users,
       ROUND(SUM(revenue) / COUNT(DISTINCT user_id), 2) AS arpu
FROM transactions
GROUP BY month
ORDER BY month;


-- ---------------------------------------------------------------------
-- Query 3: Lifetime Value (LTV) by acquisition channel
-- Calculates average total revenue per user, broken down by the channel 
-- through which they were acquired. Used to evaluate the relative 
-- profitability of acquisition channels.
-- ---------------------------------------------------------------------

WITH user_lifetime_revenue AS (
    SELECT u.user_id, 
           u.channel, 
           COALESCE(SUM(t.revenue), 0) AS lifetime_revenue
    FROM users u
    LEFT JOIN transactions t ON u.user_id = t.user_id
    GROUP BY u.user_id, u.channel
)
SELECT channel,
       COUNT(*) AS users,
       ROUND(AVG(lifetime_revenue), 2) AS avg_ltv,
       ROUND(SUM(lifetime_revenue), 2) AS total_revenue
FROM user_lifetime_revenue
GROUP BY channel
ORDER BY avg_ltv DESC;


-- ---------------------------------------------------------------------
-- Query 4: LTV-to-CAC ratio by channel
-- Joins user lifetime revenue with channel marketing spend to compute 
-- customer acquisition cost (CAC) and the LTV:CAC ratio per channel. 
-- The headline unit economics output — identifies which channels deliver 
-- positive returns and which destroy value.
-- ---------------------------------------------------------------------

WITH ltv AS (
    SELECT u.channel,
           AVG(user_revenue.total) AS avg_ltv,
           COUNT(DISTINCT u.user_id) AS users_acquired
    FROM users u
    LEFT JOIN (
        SELECT user_id, SUM(revenue) AS total
        FROM transactions
        GROUP BY user_id
    ) user_revenue ON u.user_id = user_revenue.user_id
    GROUP BY u.channel
),
cac AS (
    SELECT channel,
           SUM(spend) AS total_spend
    FROM marketing
    GROUP BY channel
)
SELECT l.channel,
       l.users_acquired,
       ROUND(l.avg_ltv, 2) AS avg_ltv,
       c.total_spend,
       ROUND(c.total_spend / l.users_acquired, 2) AS cac,
       ROUND(l.avg_ltv / (c.total_spend / l.users_acquired), 2) AS ltv_to_cac_ratio
FROM ltv l
JOIN cac c ON l.channel = c.channel
ORDER BY ltv_to_cac_ratio DESC;
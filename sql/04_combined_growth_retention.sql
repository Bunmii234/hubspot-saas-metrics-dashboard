-- combined view - growth + retention together
-- this is basically the "main" query, puts the quarterly growth stuff next to the yearly nrr stuff
-- so you can see both stories in one place

USE hubspot_saas_project;

SELECT
    qf.quarter,
    CAST(SUBSTRING(qf.quarter, 1, 4) AS UNSIGNED) AS year, -- pulling year out of the quarter text so i can join on it
    qf.total_revenue,
    qf.subscription_revenue,
    ROUND(
        (qf.total_revenue - LAG(qf.total_revenue, 1) OVER (ORDER BY qf.quarter))
        / LAG(qf.total_revenue, 1) OVER (ORDER BY qf.quarter) * 100
    , 2) AS qoq_growth_pct,
    ROUND(
        (qf.total_revenue - LAG(qf.total_revenue, 4) OVER (ORDER BY qf.quarter))
        / LAG(qf.total_revenue, 4) OVER (ORDER BY qf.quarter) * 100
    , 2) AS yoy_growth_pct,
    am.customers,
    am.net_revenue_retention, -- this is the churn/retention story - annual only
    am.avg_subscription_revenue_per_customer
FROM quarterly_financials qf
LEFT JOIN annual_metrics am
    ON am.year = CAST(SUBSTRING(qf.quarter, 1, 4) AS UNSIGNED) -- joining quarterly to yearly by matching the year
ORDER BY qf.quarter;

-- note: nrr will look the same for all 4 quarters in a given year since its only reported once a year
-- thats expected, not a bug - just how the data is

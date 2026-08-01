-- turning the combined query into an actual view
-- so power bi can just connect to this instead of me re running the raw query every time

USE hubspot_saas_project;

DROP VIEW IF EXISTS saas_metrics_summary;

CREATE VIEW saas_metrics_summary AS
SELECT
    qf.quarter,
    CAST(SUBSTRING(qf.quarter, 1, 4) AS UNSIGNED) AS year,
    qf.total_revenue,
    qf.subscription_revenue,
    qf.sales_marketing_expense,
    ROUND(
        (qf.total_revenue - LAG(qf.total_revenue, 1) OVER (ORDER BY qf.quarter))
        / LAG(qf.total_revenue, 1) OVER (ORDER BY qf.quarter) * 100
    , 2) AS qoq_growth_pct,
    ROUND(
        (qf.total_revenue - LAG(qf.total_revenue, 4) OVER (ORDER BY qf.quarter))
        / LAG(qf.total_revenue, 4) OVER (ORDER BY qf.quarter) * 100
    , 2) AS yoy_growth_pct,
    am.customers,
    am.net_revenue_retention,
    am.avg_subscription_revenue_per_customer,
    qf.derivation, -- keeping this in so i can still see which rows were calculated vs direct
    qf.source_accession -- and this so i can always trace back to the real filing
FROM quarterly_financials qf
LEFT JOIN annual_metrics am
    ON am.year = CAST(SUBSTRING(qf.quarter, 1, 4) AS UNSIGNED);

-- checking the view actually works
SELECT * FROM saas_metrics_summary ORDER BY quarter;

-- revenue growth query
-- basically checking how revenue moved quarter to quarter and year to year

USE hubspot_saas_project;

SELECT
    quarter,
    total_revenue,
    subscription_revenue,
    -- grabs the row right before this one = last quarter's revenue
    LAG(total_revenue, 1) OVER (ORDER BY quarter) AS prev_quarter_revenue,
    -- % change vs last quarter
    ROUND(
        (total_revenue - LAG(total_revenue, 1) OVER (ORDER BY quarter))
        / LAG(total_revenue, 1) OVER (ORDER BY quarter) * 100
    , 2) AS qoq_growth_pct,
    -- grabs the row from 4 back = same quarter last year (since its 1 row per qtr)
    LAG(total_revenue, 4) OVER (ORDER BY quarter) AS same_quarter_last_year_revenue,
    -- % change vs same quarter last year - this is the number companies usually brag about
    ROUND(
        (total_revenue - LAG(total_revenue, 4) OVER (ORDER BY quarter))
        / LAG(total_revenue, 4) OVER (ORDER BY quarter) * 100
    , 2) AS yoy_growth_pct
FROM quarterly_financials
ORDER BY quarter;

-- note: first row (2023-Q1) will show NULL for both, thats normal, theres nothing before it to compare to
-- checked the yoy numbers against hubspot's own press releases and they lined up, good sign the logic is right

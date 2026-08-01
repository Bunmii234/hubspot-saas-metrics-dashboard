-- sanity checks before i touch power bi
-- basically just making sure nothing is broken/missing before i build the dashboard on top of it

USE hubspot_saas_project;

-- 1. row counts - should be 13 and 4, if not something didnt load right
SELECT 'quarterly_financials row count' AS check_name, COUNT(*) AS result FROM quarterly_financials
UNION ALL
SELECT 'annual_metrics row count', COUNT(*) FROM annual_metrics;

-- 2. checking for nulls where there shouldnt be any
SELECT * FROM quarterly_financials
WHERE total_revenue IS NULL
   OR subscription_revenue IS NULL
   OR sales_marketing_expense IS NULL;
-- should come back empty

SELECT * FROM annual_metrics
WHERE customers IS NULL
   OR net_revenue_retention IS NULL;
-- should come back empty too

-- 3. making sure only the 2 rows i actually calculated are marked as derived
SELECT quarter, derivation FROM quarterly_financials
WHERE derivation LIKE 'derived%';
-- should only show 2023-Q4 and 2024-Q4, nothing else

-- 4. sub revenue should never be bigger than total revenue, that wouldnt make sense
SELECT * FROM quarterly_financials
WHERE subscription_revenue > total_revenue;
-- should come back empty

-- 5. double checking theres no missing quarter in the middle somewhere
SELECT quarter FROM quarterly_financials ORDER BY quarter;
-- eyeball it - should go 2023-Q1 all the way to 2026-Q1 with nothing skipped, 13 rows total

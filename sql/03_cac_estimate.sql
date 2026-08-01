-- cac estimate (fixed version)
-- dont have new customers per quarter, only per year, so doing this one at the annual level instead
--
-- bug i found: the first version dropped 2022 before LAG could use it as the baseline for 2023,
-- because the JOIN to annual_sm (which starts at 2023) removed 2022 before the window function ran.
-- fix: calculate net_new_customers against the FULL annual_metrics table first, then join/filter after.

USE hubspot_saas_project;

WITH annual_sm AS (
    -- adds up the 4 quarters of s&m spend into one yearly total
    SELECT
        CAST(SUBSTRING(quarter, 1, 4) AS UNSIGNED) AS year,
        SUM(sales_marketing_expense) AS annual_sm_expense,
        COUNT(*) AS quarters_included
    FROM quarterly_financials
    GROUP BY CAST(SUBSTRING(quarter, 1, 4) AS UNSIGNED)
),
customer_deltas AS (
    -- this runs LAG over the FULL annual_metrics table (2022-2025), so 2023 still has
    -- 2022 available as its lookback baseline before anything gets filtered out
    SELECT
        year,
        customers,
        customers - LAG(customers) OVER (ORDER BY year) AS net_new_customers
    FROM annual_metrics
)
SELECT
    cd.year,
    cd.customers,
    cd.net_new_customers,
    asm.annual_sm_expense,
    asm.quarters_included,
    ROUND(
        asm.annual_sm_expense / NULLIF(cd.net_new_customers, 0)
    , 2) AS cac_estimate
FROM customer_deltas cd
JOIN annual_sm asm ON asm.year = cd.year   -- this join is what limits us to years with full quarterly S&M data (2023-2025)
ORDER BY cd.year;

-- note to self: this isnt a "real" cac, its rough - it assumes ALL the s&m spend went to
-- getting new customers, but really some of that spend goes toward keeping/growing existing ones too
-- (thats basically what nrr being over 100% means). good thing to mention if asked about it

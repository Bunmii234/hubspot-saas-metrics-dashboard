# HubSpot SaaS Metrics Dashboard

A data analyst portfolio project analyzing HubSpot's real, publicly disclosed
financial and business metrics — revenue growth, customer acquisition cost
(CAC), and net revenue retention (NRR) — sourced directly from HubSpot's SEC
filings.

**Live dashboard:** [HubSpot SaaS Metrics Dashboard on Tableau Public](https://public.tableau.com/app/profile/daniel.ogunsaju/viz/HubSpotSaaSMetricsDashboard/Dashboard1)

---

## Why this project

Most of my other portfolio projects (Vendor Billing, Insured Jewelry
Logistics, HCBS Billing Compliance) are billing- and insurance-flavored. The
data/business analyst roles I'm targeting now are SaaS-focused — the job
descriptions ask specifically about MRR, churn, CAC, and LTV. This project
was built to speak that language directly, using real SaaS company data
rather than a simulated dataset.

## A note on the data

Every number in this project traces back to an actual SEC filing —
HubSpot's quarterly (10-Q) and annual (10-K) reports, pulled directly from
[HubSpot Investor Relations](https://ir.hubspot.com) and
[SEC EDGAR](https://www.sec.gov/edgar/browse/?CIK=0001404655). Nothing here
is simulated or estimated from scratch. Where a number had to be derived
(explained below), it's clearly flagged in the data itself.

## Methodology

**Data extraction:** 9 filings covering Q1 2023 through Q1 2026 (7 quarterly
10-Qs + 2 annual 10-Ks). Quarterly figures (revenue, subscription revenue,
sales & marketing expense) came from each filing's "Statements of
Operations." Annual-only figures (customer count, average subscription
revenue per customer, Net Revenue Retention) came from the 10-K's "Key
Business Metrics" section — HubSpot discloses these once a year, not
quarterly.

**Handling missing quarters:** HubSpot doesn't report Q4 as a standalone
quarter, only as part of the full-year 10-K. Q4 2023 and Q4 2024 were
derived as `Full Year − Q1 − Q2 − Q3`, and cross-checked against HubSpot's
own Q4 2024 press release to confirm accuracy. Every row in the database
includes a `derivation` column noting whether it came directly from a
filing or was calculated.

**Database:** MySQL, with two tables (`quarterly_financials`,
`annual_metrics`) and a combined SQL view (`saas_metrics_summary`) joining
them. SQL work included window functions (`LAG()` for QoQ/YoY growth and
net-new-customer calculations), CTEs, and a CAC estimate at the annual
level (S&M spend ÷ net new customers).

**Dashboard:** Built in Tableau, published live to Tableau Public.

## Key insight

HubSpot's Net Revenue Retention tells a real story: **110.3% (2022) →
103.9% (2023) → 102.2% (2024) → 103.5% (2025)** — a retention slowdown
over 2022–2024, followed by a recovery in 2025. Over the same period, the
estimated CAC rose from ~$28,340 (2023) to ~$33,836 (2025) — worth
investigating further as a possible driver of the retention trend.

## Tech stack

- **SQL:** MySQL — window functions, CTEs, views
- **Dashboard:** Tableau (published to Tableau Public)
- **Source data:** SEC EDGAR / HubSpot Investor Relations filings

## Folder structure

```
HUBSPOT - SAAS - PROJECT/
├── XLS/        # 9 raw SEC filing exports (primary source documents)
├── data/       # Cleaned CSVs and the final Excel export used for Tableau
├── sql/        # All SQL scripts, numbered in the order they're run
│   ├── 01_setup_and_load.sql
│   ├── 02_revenue_growth.sql
│   ├── 03_cac_estimate.sql
│   ├── 04_combined_growth_retention.sql
│   ├── 05_create_view.sql
│   └── 06_data_quality_checks.sql
└── README.md
```

## Limitations

- CAC is a rough estimate — it assumes all sales & marketing spend went
  toward acquiring new customers, when in reality some of that spend also
  goes toward retaining and expanding existing customers (part of why NRR
  runs above 100%).
- Customer count and NRR are only available at annual granularity, since
  that's the frequency HubSpot discloses them at.

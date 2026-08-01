-- hubspot saas project - setup script
-- this creates the db, makes the 2 tables, and loads in all the real data
-- pulled from hubspot's actual sec filings (10-Q / 10-K)

CREATE DATABASE IF NOT EXISTS hubspot_saas_project;
USE hubspot_saas_project;

-- table for the quarterly stuff - revenue, sub revenue, s&m spend
-- 13 rows, one per quarter, q1 2023 to q1 2026
DROP TABLE IF EXISTS quarterly_financials;
CREATE TABLE quarterly_financials (
    quarter VARCHAR(10) PRIMARY KEY,
    total_revenue BIGINT,
    subscription_revenue BIGINT,
    sales_marketing_expense BIGINT,
    derivation VARCHAR(255), -- says if the row came straight from a filing or if i had to calculate it
    source_accession VARCHAR(255) -- which sec filing this came from, so i can prove its real
);

-- table for the yearly stuff - customer count, nrr etc
-- only 4 rows bc hubspot only reports these once a year not quarterly
DROP TABLE IF EXISTS annual_metrics;
CREATE TABLE annual_metrics (
    year INT PRIMARY KEY,
    customers INT,
    avg_subscription_revenue_per_customer NUMERIC(10,2),
    net_revenue_retention VARCHAR(10),
    source_accession VARCHAR(255)
);

-- loading in the quarterly data, pulled by hand from each filing
INSERT INTO quarterly_financials (quarter, total_revenue, subscription_revenue, sales_marketing_expense, derivation, source_accession) VALUES
('2023-Q1', 501620000, 489743000, 250683000, 'direct from filing', '0000950170-24-057772 (prior-year column)'),
('2023-Q2', 529138000, 517678000, 265294000, 'direct from filing', '0000950170-24-092843 (prior-year column)'),
('2023-Q3', 557557000, 545832000, 271448000, 'direct from filing', '0000950170-24-122373 (prior-year column)'),
('2023-Q4', 581915000, 570226000, 281137000, 'derived: FY2023 minus Q1-Q3 2023', '0000950170-25-018873 (FY2023 column)'), -- hubspot doesnt report q4 alone, had to calc it
('2024-Q1', 617414000, 603798000, 300282000, 'direct from filing', '0000950170-24-057772'),
('2024-Q2', 637230000, 623763000, 293794000, 'direct from filing', '0000950170-24-092843'),
('2024-Q3', 669721000, 654738000, 309928000, 'direct from filing', '0000950170-24-122373'),
('2024-Q4', 703178000, 687305000, 314834000, 'derived: FY2024 minus 9mo-2024', '0000950170-25-018873'), -- same deal, calculated this one too
('2025-Q1', 714137000, 698728000, 326697000, 'direct from filing', '0000950170-25-067055'),
('2025-Q2', 760866000, 744532000, 339879000, 'direct from filing', '0000950170-25-104104'),
('2025-Q3', 809518000, 791678000, 355268000, 'direct from filing', '0001193125-25-267056'),
('2025-Q4', 846746000, 828980000, 357531000, 'direct from press release (cross-checked against FY2025 minus 9mo-2025)', '0001193125-26-046646'),
('2026-Q1', 880995000, 862264000, 386431000, 'direct from filing', '0001193125-26-212122');

-- loading in the yearly data - straight from the 10-k "key business metrics" section
INSERT INTO annual_metrics (year, customers, avg_subscription_revenue_per_customer, net_revenue_retention, source_accession) VALUES
(2022, 167386, 11163, '110.3%', '0000950170-25-018873 (FY2024 10-K comparative column)'),
(2023, 205091, 11384, '103.9%', '0000950170-25-018873 (FY2024 10-K comparative column)'),
(2024, 247939, 11343, '102.2%', '0000950170-25-018873'),
(2025, 288706, 11414, '103.5%', '0001193125-26-046646');

-- quick check everything loaded right - should say 13 and 4
SELECT 'quarterly_financials row count:' AS label, COUNT(*) AS count FROM quarterly_financials;
SELECT 'annual_metrics row count:' AS label, COUNT(*) AS count FROM annual_metrics;

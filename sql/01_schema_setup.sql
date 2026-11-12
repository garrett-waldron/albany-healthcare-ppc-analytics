//1.Table Creation (Staging Schema)

//Because public health datasets often contain numbers formatted with commas (e.g., 36,247), we ingest all columns as TEXT initially to prevent import failures. We then cast and clean them during analysis.

-- Drop table if resetting
DROP TABLE IF EXISTS hospital_ppc_discharges;

-- Create staging table with TEXT types
CREATE TABLE hospital_ppc_discharges (
    discharge_year TEXT,
    ppc_version TEXT,
    hospital_name TEXT,
    facility_id TEXT,
    major_ppc_discharges TEXT,
    at_risk_ppc_discharges TEXT,
    observed_rate_per_10k TEXT,
    expected_major_ppc_discharges TEXT,
    expected_rate_per_10k TEXT,
    risk_adjusted_rate_per_10k TEXT,
    difference_in_discharges TEXT
);


//2. Data Validation & Row Count Check

//Verify that the CSV file imported successfully into PostgreSQL.

SELECT COUNT(*) AS total_rows 
FROM hospital_ppc_discharges;


//3. Core Analytical Query: Capital Region Risk-Adjusted Complications

//This query cleans the text-formatted columns by stripping out commas (REPLACE) and casting them to numeric data types (::NUMERIC), filtering specifically for Capital Region hospitals in New York, and ordering by risk-adjusted complication rates.

SELECT 
    hospital_name,
    discharge_year,
    REPLACE(at_risk_ppc_discharges, ',', '')::NUMERIC AS clean_at_risk,
    REPLACE(risk_adjusted_rate_per_10k, ',', '')::NUMERIC AS clean_risk_adj_rate,
    REPLACE(difference_in_discharges, ',', '')::NUMERIC AS clean_diff_discharges
FROM 
    hospital_ppc_discharges
WHERE 
    hospital_name ILIKE '%albany%' 
    OR hospital_name ILIKE '%troy%' 
    OR hospital_name ILIKE '%saratoga%'
    OR hospital_name ILIKE '%schenectady%'
ORDER BY 
    clean_risk_adj_rate DESC;


//4. Advanced Analytical Query: Multi-Year Trend Analysis

//To evaluate whether hospital performance improved or worsened over time, this query aggregates the average risk-adjusted rate per 10,000 at-risk discharges by year across the entire state dataset.

SELECT 
    discharge_year,
    COUNT(DISTINCT hospital_name) AS reporting_hospitals,
    ROUND(AVG(REPLACE(risk_adjusted_rate_per_10k, ',', '')::NUMERIC), 2) AS avg_state_risk_adj_rate
FROM 
    hospital_ppc_discharges
WHERE 
    risk_adjusted_rate_per_10k IS NOT NULL
GROUP BY 
    discharge_year
ORDER BY 
    discharge_year DESC;


//5. Creating a Clean Permanent SQL View

//To make reporting in Tableau easier, you can materialize these transformations into a clean view so you don't have to rewrite the REPLACE and cast functions every time.

CREATE OR REPLACE VIEW v_clean_hospital_ppc AS
SELECT 
    discharge_year::INTEGER AS discharge_year,
    ppc_version,
    hospital_name,
    facility_id::INTEGER AS facility_id,
    REPLACE(major_ppc_discharges, ',', '')::NUMERIC AS major_ppc_discharges,
    REPLACE(at_risk_ppc_discharges, ',', '')::NUMERIC AS at_risk_ppc_discharges,
    REPLACE(observed_rate_per_10k, ',', '')::NUMERIC AS observed_rate_per_10k,
    REPLACE(expected_major_ppc_discharges, ',', '')::NUMERIC AS expected_major_ppc_discharges,
    REPLACE(expected_rate_per_10k, ',', '')::NUMERIC AS expected_rate_per_10k,
    REPLACE(risk_adjusted_rate_per_10k, ',', '')::NUMERIC AS risk_adjusted_rate_per_10k,
    REPLACE(difference_in_discharges, ',', '')::NUMERIC AS difference_in_discharges
FROM 
    hospital_ppc_discharges;


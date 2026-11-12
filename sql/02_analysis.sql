-- =========================================================================
-- Project: NYS Hospital Potentially Preventable Complications (PPC) Analysis
-- Script: 02_analysis.sql
-- Purpose: Data cleaning, casting, and exploratory analysis of NYS SPARCS data
-- =========================================================================

-- 1. DATA CLEANING & CASTING VIEW
-- Creates a reusable view that cleans text formatting (stripping commas) 
-- and casts metrics into proper numeric data types for analysis.
CREATE OR REPLACE VIEW v_cleaned_hospital_ppc AS
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


-- 2. CAPITAL REGION BENCHMARK ANALYSIS
-- Analyzes hospitals in the Albany / Capital Region (Albany, Troy, Schenectady, Saratoga)
-- sorted by highest risk-adjusted complication rates.
SELECT 
    hospital_name,
    discharge_year,
    at_risk_ppc_discharges,
    observed_rate_per_10k,
    risk_adjusted_rate_per_10k,
    difference_in_discharges
FROM 
    v_cleaned_hospital_ppc
WHERE 
    hospital_name ILIKE '%albany%' 
    OR hospital_name ILIKE '%troy%' 
    OR hospital_name ILIKE '%saratoga%'
    OR hospital_name ILIKE '%schenectady%'
ORDER BY 
    risk_adjusted_rate_per_10k DESC;


-- 3. STATEWIDE PERFORMANCE RANKING (WINDOW FUNCTION)
-- Uses window functions to rank hospitals statewide by risk-adjusted rates per year.
SELECT 
    discharge_year,
    hospital_name,
    risk_adjusted_rate_per_10k,
    RANK() OVER (PARTITION BY discharge_year ORDER BY risk_adjusted_rate_per_10k DESC) AS statewide_risk_rank
FROM 
    v_cleaned_hospital_ppc
WHERE 
    risk_adjusted_rate_per_10k IS NOT NULL;

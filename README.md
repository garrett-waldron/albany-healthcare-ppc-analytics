NYS Hospital Potentially Preventable Complications (PPC) & Quality Analysis

🎯 Executive Summary

This project analyzes New York State (NYS) Department of Health SPARCS (Statewide Planning and Research Cooperative System) data focusing on Potentially Preventable Complications (PPCs) across hospitals. Built specifically to demonstrate end-to-end data analytics capabilities for healthcare and public sector employers in the Capital Region (Albany, NY), this project covers server-side data ingestion, complex SQL data cleaning/casting, and executive-level visualization.

🛠️ Tech Stack & Architecture

Database & Data Management: PostgreSQL 18 / pgAdmin 4

Data Transformation & Analysis: SQL (Data hygiene, string replacement, type casting, aggregate functions)

Data Visualization: Tableau Public

Dataset Source: Open NY (NYS Hospital Inpatient Discharges - Major PPC Rates)

📂 Repository Structure

nys-hospital-ppc-quality-analysis/
│
├── README.md               # Project overview, methodology, and key insights
├── sql/
│   ├── 01_schema_setup.sql   # Staging table creation scripts
│   └── 02_analysis.sql       # Data cleaning, casting, and aggregation queries
└── tableau/
    └── dashboard_preview.png # Executive dashboard preview


🔍 Key Data Engineering & SQL Challenges

Public health datasets frequently introduce real-world data hygiene hurdles. This project addresses two primary challenges:

Handling Commas in Numeric Data: Ingested columns containing large comma-separated numbers (e.g., "36,247") as raw TEXT staging data to prevent batch import failures.

Dynamic SQL Casting: Utilized PostgreSQL REPLACE() and ::NUMERIC type casting inside analytical queries to cleanly convert text strings into actionable numerical metrics.

Sample Analysis Query

SELECT 
    hospital_name,
    discharge_year,
    REPLACE(at_risk_ppc_discharges, ',', '')::NUMERIC AS clean_at_risk,
    REPLACE(risk_adjusted_rate_per_10k, ',', '')::NUMERIC AS clean_risk_adj_rate
FROM 
    hospital_ppc_discharges
WHERE 
    hospital_name ILIKE '%albany%' 
    OR hospital_name ILIKE '%troy%' 
    OR hospital_name ILIKE '%saratoga%'
ORDER BY 
    clean_risk_adj_rate DESC;


📊 Key Insights & Findings

Regional Benchmarking: Evaluated risk-adjusted complication variance across Albany and Capital Region medical centers against statewide baselines.

Longitudinal Trends: Assessed multi-year performance trajectories to identify clinical quality improvements and areas requiring intervention.

🚀 How to Run This Project

Clone or download this repository.

Set up a local PostgreSQL database (portfolio_health).

Run the scripts located in the sql/ directory sequentially.

Connect Tableau Public to your local PostgreSQL instance using the provided schema view.

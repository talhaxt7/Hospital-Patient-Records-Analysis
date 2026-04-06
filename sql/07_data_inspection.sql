-- ============================================
-- 07_data_inspection.sql
-- Purpose: Validation queries to verify data
--          loaded correctly and views work
-- Run these after completing all previous scripts
-- ============================================

USE hospital_analysis;

-- ----------------------
-- 1. Row counts per table
-- ----------------------
SELECT 'patients'       AS table_name, COUNT(*) AS row_count FROM raw_patients
UNION ALL
SELECT 'encounters',                    COUNT(*)             FROM raw_encounters
UNION ALL
SELECT 'procedures',                    COUNT(*)             FROM raw_procedures
UNION ALL
SELECT 'payers',                        COUNT(*)             FROM raw_payers
UNION ALL
SELECT 'organizations',                 COUNT(*)             FROM raw_organizations;

-- ----------------------
-- 2. Verify all views exist
-- ----------------------
SHOW FULL TABLES IN hospital_analysis WHERE TABLE_TYPE = 'VIEW';

-- ----------------------
-- 3. Preview each view
-- ----------------------
SELECT * FROM dim_patients      LIMIT 5;
SELECT * FROM dim_payers        LIMIT 5;
SELECT * FROM dim_organizations LIMIT 5;
SELECT * FROM fact_encounters   LIMIT 5;
SELECT * FROM fact_procedures   LIMIT 5;
SELECT * FROM fact_readmissions LIMIT 5;

-- ----------------------
-- 4. Date range check
-- ----------------------
SELECT
    MIN(encounter_start)    AS earliest_encounter,
    MAX(encounter_start)    AS latest_encounter
FROM fact_encounters;

-- ----------------------
-- 5. NULL check on key columns
-- ----------------------
SELECT
    COUNT(*)                                                        AS total_encounters,
    SUM(CASE WHEN payer_id IS NULL THEN 1 ELSE 0 END)              AS missing_payer,
    SUM(CASE WHEN total_cost IS NULL THEN 1 ELSE 0 END)            AS missing_cost,
    SUM(CASE WHEN encounter_start IS NULL THEN 1 ELSE 0 END)       AS missing_start_date
FROM fact_encounters;

-- ----------------------
-- 6. Encounter class breakdown
-- ----------------------
SELECT
    encounter_class,
    COUNT(*)                AS total_encounters,
    ROUND(AVG(los_days), 2) AS avg_los
FROM fact_encounters
GROUP BY encounter_class
ORDER BY total_encounters DESC;

-- ----------------------
-- 7. Payer coverage summary
-- ----------------------
SELECT
    p.payer_name,
    COUNT(e.encounter_id)           AS total_encounters,
    ROUND(SUM(e.total_cost), 2)     AS total_billed,
    ROUND(SUM(e.payer_coverage), 2) AS total_covered,
    ROUND(AVG(e.coverage_pct), 2)   AS avg_coverage_pct
FROM fact_encounters e
JOIN dim_payers p ON e.payer_id = p.payer_id
GROUP BY p.payer_name
ORDER BY total_billed DESC;

-- ----------------------
-- 8. Readmission summary
-- ----------------------
SELECT
    readmission_status,
    COUNT(*) AS count
FROM fact_readmissions
GROUP BY readmission_status;

-- ----------------------
-- 9. Living vs Deceased patients
-- ----------------------
SELECT
    vital_status,
    COUNT(*) AS count
FROM dim_patients
GROUP BY vital_status;

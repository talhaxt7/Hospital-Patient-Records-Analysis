-- ============================================
-- 02_dim_patients.sql
-- Purpose: Clean patient demographics view
-- Adds: age calculation, age band, vital status
-- ============================================

USE hospital_analysis;

CREATE OR REPLACE VIEW dim_patients AS
SELECT
    Id                                                      AS patient_id,
    CONCAT(First, ' ', Last)                                AS full_name,
    BirthDate                                               AS birth_date,
    DeathDate                                               AS death_date,
    Gender                                                  AS gender,
    Race                                                    AS race,
    Ethnicity                                               AS ethnicity,
    Marital                                                 AS marital_status,
    City                                                    AS city,
    State                                                   AS state,
    County                                                  AS county,
    Lat                                                     AS latitude,
    Lon                                                     AS longitude,

    -- Age at death if deceased, otherwise age today
    TIMESTAMPDIFF(YEAR,
        BirthDate,
        COALESCE(DeathDate, CURDATE())
    )                                                       AS age_years,

    -- Age band for grouping in Power BI
    CASE
        WHEN TIMESTAMPDIFF(YEAR, BirthDate, COALESCE(DeathDate, CURDATE())) < 18 THEN 'Under 18'
        WHEN TIMESTAMPDIFF(YEAR, BirthDate, COALESCE(DeathDate, CURDATE())) < 35 THEN '18-34'
        WHEN TIMESTAMPDIFF(YEAR, BirthDate, COALESCE(DeathDate, CURDATE())) < 50 THEN '35-49'
        WHEN TIMESTAMPDIFF(YEAR, BirthDate, COALESCE(DeathDate, CURDATE())) < 65 THEN '50-64'
        ELSE '65+'
    END                                                     AS age_band,

    -- Deceased flag
    CASE
        WHEN DeathDate IS NOT NULL THEN 'Deceased'
        ELSE 'Living'
    END                                                     AS vital_status

FROM raw_patients;

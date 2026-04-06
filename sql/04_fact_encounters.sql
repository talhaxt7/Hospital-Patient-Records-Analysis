-- ============================================
-- 04_fact_encounters.sql
-- Purpose: Core encounter fact table
-- Adds: proper dates, LOS, cost calculations,
--       coverage %, year/month for time analysis
-- ============================================

USE hospital_analysis;

CREATE OR REPLACE VIEW fact_encounters AS
SELECT
    e.Id                                                        AS encounter_id,
    e.Patient                                                   AS patient_id,
    e.Payer                                                     AS payer_id,
    e.Organization                                              AS organization_id,
    e.EncounterClass                                            AS encounter_class,
    e.Description                                               AS encounter_description,
    e.ReasonDescription                                         AS reason,

    -- Convert ISO 8601 format to proper DATETIME
    -- Raw format: 2011-01-02T09:26:36Z
    -- Converted:  2011-01-02 09:26:36
    STR_TO_DATE(e.Start, '%Y-%m-%dT%H:%i:%sZ')                 AS encounter_start,
    STR_TO_DATE(e.Stop,  '%Y-%m-%dT%H:%i:%sZ')                 AS encounter_end,

    -- Extract year and month for time intelligence in Power BI
    YEAR(STR_TO_DATE(e.Start, '%Y-%m-%dT%H:%i:%sZ'))            AS encounter_year,
    MONTH(STR_TO_DATE(e.Start, '%Y-%m-%dT%H:%i:%sZ'))           AS encounter_month,

    -- Length of stay in days
    DATEDIFF(
        STR_TO_DATE(e.Stop,  '%Y-%m-%dT%H:%i:%sZ'),
        STR_TO_DATE(e.Start, '%Y-%m-%dT%H:%i:%sZ')
    )                                                           AS los_days,

    -- Cost columns
    e.Base_Encounter_Cost                                       AS base_cost,
    e.Total_Claim_Cost                                          AS total_cost,
    e.Payer_Coverage                                            AS payer_coverage,
    (e.Total_Claim_Cost - e.Payer_Coverage)                     AS out_of_pocket,

    -- Coverage percentage (excludes zero cost encounters)
    CASE
        WHEN e.Total_Claim_Cost > 0
        THEN ROUND(e.Payer_Coverage / e.Total_Claim_Cost * 100, 2)
        ELSE 0
    END                                                         AS coverage_pct

FROM raw_encounters e;

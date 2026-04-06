-- ============================================
-- 05_fact_procedures.sql
-- Purpose: Procedure fact table
-- Adds: proper dates, procedure duration
-- ============================================

USE hospital_analysis;

CREATE OR REPLACE VIEW fact_procedures AS
SELECT
    p.Patient                                               AS patient_id,
    p.Encounter                                             AS encounter_id,
    p.Code                                                  AS procedure_code,
    p.Description                                           AS procedure_name,
    p.ReasonDescription                                     AS procedure_reason,

    -- Convert ISO 8601 format to proper DATETIME
    STR_TO_DATE(p.Start, '%Y-%m-%dT%H:%i:%sZ')             AS procedure_start,
    STR_TO_DATE(p.Stop,  '%Y-%m-%dT%H:%i:%sZ')             AS procedure_end,

    -- Procedure duration in minutes
    TIMESTAMPDIFF(
        MINUTE,
        STR_TO_DATE(p.Start, '%Y-%m-%dT%H:%i:%sZ'),
        STR_TO_DATE(p.Stop,  '%Y-%m-%dT%H:%i:%sZ')
    )                                                       AS duration_minutes,

    -- Cost
    p.Base_Cost                                             AS procedure_cost

FROM raw_procedures p;

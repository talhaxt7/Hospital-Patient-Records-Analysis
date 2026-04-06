-- ============================================
-- 06_fact_readmissions.sql
-- Purpose: 30-day readmission analysis
-- Method: LAG() window function to find previous
--         discharge date per patient, then flag
--         if new encounter starts within 30 days
--
-- Notes:
-- - NULL prev_discharge_date = patient's first ever encounter (no previous visit)
-- - Negative days_since_last_discharge = overlapping encounters in synthetic data
-- - These are handled in Power BI DAX measures
-- ============================================

USE hospital_analysis;

CREATE OR REPLACE VIEW fact_readmissions AS
SELECT
    encounter_id,
    patient_id,
    encounter_class,
    reason,
    encounter_start,
    encounter_end,
    prev_discharge_date,

    -- Days between previous discharge and current admission
    DATEDIFF(encounter_start, prev_discharge_date)          AS days_since_last_discharge,

    -- Readmission flag: admitted within 30 days of previous discharge
    CASE
        WHEN DATEDIFF(encounter_start, prev_discharge_date) <= 30
        THEN 'Readmitted'
        ELSE 'Not Readmitted'
    END                                                     AS readmission_status

FROM (
    -- Subquery: order encounters per patient and pull previous discharge date
    SELECT
        Id                                                  AS encounter_id,
        Patient                                             AS patient_id,
        EncounterClass                                      AS encounter_class,
        ReasonDescription                                   AS reason,

        STR_TO_DATE(Start, '%Y-%m-%dT%H:%i:%sZ')           AS encounter_start,
        STR_TO_DATE(Stop,  '%Y-%m-%dT%H:%i:%sZ')           AS encounter_end,

        -- LAG() looks at the previous row for the same patient
        -- PARTITION BY Patient = reset for each patient
        -- ORDER BY Start = go in chronological order
        LAG(STR_TO_DATE(Stop, '%Y-%m-%dT%H:%i:%sZ'))
        OVER (
            PARTITION BY Patient
            ORDER BY Start
        )                                                   AS prev_discharge_date

    FROM raw_encounters
) AS encounter_ordered;

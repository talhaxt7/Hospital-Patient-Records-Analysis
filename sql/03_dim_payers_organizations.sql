-- ============================================
-- 03_dim_payers_organizations.sql
-- Purpose: Clean reference views for payers
-- and organizations (hospitals)
-- ============================================

USE hospital_analysis;

-- ----------------------
-- dim_payers
-- ----------------------
CREATE OR REPLACE VIEW dim_payers AS
SELECT
    Id                      AS payer_id,
    Name                    AS payer_name,
    City                    AS payer_city,
    State_Headquartered     AS payer_state,
    Phone                   AS payer_phone
FROM raw_payers;

-- ----------------------
-- dim_organizations
-- ----------------------
CREATE OR REPLACE VIEW dim_organizations AS
SELECT
    Id      AS organization_id,
    Name    AS organization_name,
    City    AS city,
    State   AS state,
    Lat     AS latitude,
    Lon     AS longitude
FROM raw_organizations;

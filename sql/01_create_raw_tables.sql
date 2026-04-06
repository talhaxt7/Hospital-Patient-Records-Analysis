-- ============================================
-- 01_create_raw_tables.sql
-- Purpose: Create raw tables to load CSV data
-- Database: hospital_analysis
-- ============================================

CREATE DATABASE IF NOT EXISTS hospital_analysis;
USE hospital_analysis;

-- ----------------------
-- Raw Patients Table
-- ----------------------
CREATE TABLE IF NOT EXISTS raw_patients (
    Id                      VARCHAR(100),
    BirthDate               DATE,
    DeathDate               DATE,
    Prefix                  VARCHAR(20),
    First                   VARCHAR(100),
    Middle                  VARCHAR(100),
    Last                    VARCHAR(100),
    Suffix                  VARCHAR(20),
    Maiden                  VARCHAR(100),
    Marital                 VARCHAR(5),
    Race                    VARCHAR(50),
    Ethnicity               VARCHAR(50),
    Gender                  VARCHAR(5),
    BirthPlace              VARCHAR(200),
    Address                 VARCHAR(200),
    City                    VARCHAR(100),
    State                   VARCHAR(50),
    County                  VARCHAR(100),
    FIPS                    VARCHAR(20),
    Zip                     VARCHAR(20),
    Lat                     DOUBLE,
    Lon                     DOUBLE,
    Healthcare_Expenses     DECIMAL(12,2),
    Healthcare_Coverage     DECIMAL(12,2),
    Income                  DECIMAL(12,2)
);

-- ----------------------
-- Raw Payers Table
-- ----------------------
CREATE TABLE IF NOT EXISTS raw_payers (
    Id                      VARCHAR(100),
    Name                    VARCHAR(200),
    Address                 VARCHAR(200),
    City                    VARCHAR(100),
    State_Headquartered     VARCHAR(50),
    Zip                     VARCHAR(20),
    Phone                   VARCHAR(30)
);

-- ----------------------
-- Raw Organizations Table
-- ----------------------
CREATE TABLE IF NOT EXISTS raw_organizations (
    Id          VARCHAR(100),
    Name        VARCHAR(200),
    Address     VARCHAR(200),
    City        VARCHAR(100),
    State       VARCHAR(50),
    Zip         VARCHAR(20),
    Lat         DOUBLE,
    Lon         DOUBLE
);

-- ----------------------
-- Raw Encounters Table
-- Note: Start and Stop stored as VARCHAR
-- because CSV uses ISO 8601 format (2011-01-02T09:26:36Z)
-- Conversion happens in the fact_encounters view
-- ----------------------
CREATE TABLE IF NOT EXISTS raw_encounters (
    Id                  VARCHAR(100),
    Start               VARCHAR(50),
    Stop                VARCHAR(50),
    Patient             VARCHAR(100),
    Organization        VARCHAR(100),
    Provider            VARCHAR(100),
    Payer               VARCHAR(100),
    EncounterClass      VARCHAR(50),
    Code                VARCHAR(50),
    Description         TEXT,
    Base_Encounter_Cost DECIMAL(12,2),
    Total_Claim_Cost    DECIMAL(12,2),
    Payer_Coverage      DECIMAL(12,2),
    ReasonCode          VARCHAR(50),
    ReasonDescription   TEXT
);

-- ----------------------
-- Raw Procedures Table
-- Note: Start and Stop stored as VARCHAR (same reason as above)
-- ----------------------
CREATE TABLE IF NOT EXISTS raw_procedures (
    Start               VARCHAR(50),
    Stop                VARCHAR(50),
    Patient             VARCHAR(100),
    Encounter           VARCHAR(100),
    Code                VARCHAR(50),
    Description         TEXT,
    Base_Cost           DECIMAL(12,2),
    ReasonCode          VARCHAR(50),
    ReasonDescription   TEXT
);

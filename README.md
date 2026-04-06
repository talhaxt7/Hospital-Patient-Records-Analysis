# 🏥 Hospital Patient Records Analysis

A full end-to-end data analysis project using **MySQL** and **Power BI**, based on synthetic patient records from Massachusetts General Hospital (MGH). The project transforms raw clinical data into a 7-page interactive dashboard with actionable insights across admissions, costs, readmissions, health equity, and procedures.

---

## 📌 Problem Statement

Massachusetts General Hospital generates thousands of patient records across admissions, procedures, and insurance claims. Without structured analysis, the executive team lacks visibility into key operational and clinical performance indicators — such as which patient segments are being readmitted most, which payers leave patients with the highest out-of-pocket burden, and whether health outcomes differ across demographic groups.

This project aims to transform raw synthetic patient records into a structured, insight-driven case study using SQL and Power BI.

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **MySQL 8.0** | Data storage, cleaning, transformation, SQL view creation |
| **MySQL Workbench** | Query editor and database management |
| **Power BI Desktop** | Dashboard building, DAX measures, data modelling |
| **MySQL Connector for Power BI** | Live connection between Power BI and MySQL |
| **GitHub** | Version control — SQL scripts, screenshots, README |

---

## 📂 Dataset

**Source:** Maven Analytics / Synthea (fully synthetic — not real patient data)  
**Scope:** Massachusetts General Hospital (MGH), 2011–2022

| File | Description | Rows |
|---|---|---|
| `patients.csv` | Patient demographics — age, gender, race, location | 154 |
| `encounters.csv` | Every hospital visit — class, cost, payer, dates | 27,891 |
| `procedures.csv` | Procedures performed per encounter | 47,701 |
| `payers.csv` | Insurance providers | 10 |
| `organizations.csv` | Hospital details | 1 |

> ⚠️ Data is synthetic. All findings are directional and for analytical demonstration only.

---

## 🗄️ Data Architecture

### Approach: Raw → Views (Two-Layer Design)

Raw CSVs are imported as-is into MySQL. All cleaning, transformation, and calculation happen in SQL **views** — keeping the raw data untouched and all logic in a separate, reusable layer.

```
raw_patients        →   dim_patients        (cleaned demographics, age bands, vital status)
raw_payers          →   dim_payers          (payer reference data)
raw_organizations   →   dim_organizations   (hospital reference data)
raw_encounters      →   fact_encounters     (LOS, costs, coverage %, fixed ISO dates)
raw_procedures      →   fact_procedures     (procedure costs, duration)
raw_encounters      →   fact_readmissions   (30-day readmission flag via window function)
```

### Star Schema (Power BI Model)

```
         dim_patients
              |
dim_payers ── fact_encounters ── dim_organizations
              |
         fact_procedures
              |
        fact_readmissions
```

---

## 🔧 SQL Transformations

Key transformations applied in the views layer:

- **ISO 8601 date fix** — `STR_TO_DATE(Start, '%Y-%m-%dT%H:%i:%sZ')` converts `2011-01-02T09:26:36Z` to proper `DATETIME`
- **Length of Stay** — `DATEDIFF(encounter_end, encounter_start)` in days
- **Out of Pocket** — `Total_Claim_Cost - Payer_Coverage`
- **Coverage %** — `ROUND(Payer_Coverage / Total_Claim_Cost * 100, 2)`
- **Age & Age Band** — `TIMESTAMPDIFF(YEAR, BirthDate, COALESCE(DeathDate, CURDATE()))`
- **30-Day Readmission Flag** — `LAG()` window function partitioned by patient, ordered chronologically

---

## 📊 Dashboard Pages

### Page 1 — Executive Summary
High-level KPIs with encounter trends, encounter class breakdown, and payer volume.

![Executive Summary](screenshots/01_executive_summary.png)

### Page 2 — Patient Demographics & Mortality
Patient age, gender, race, ethnicity distribution, mortality rate by age band, and geographic map.

![Patient Demographics](screenshots/02_patient_demographics.png)

### Page 3 — Admissions & LOS
Monthly and yearly admission trends, average LOS by encounter class, seasonal patterns, and top reasons for encounter.

![Admissions & LOS](screenshots/03_admissions_los.png)

### Page 4 — Payer & Cost Analysis
Total cost billed vs. covered by payer, out-of-pocket burden, cost trends over time, and most expensive encounter reasons.

![Payer Cost Analysis](screenshots/04_payer_cost.png)

### Page 5 — Readmission Analysis
30-day readmission rate by age band, encounter class, payer, and reason.

![Readmission Analysis](screenshots/05_readmissions.png)

### Page 6 — Health Equity
LOS, cost, readmission rate, and mortality rate broken down by race and gender.

![Health Equity](screenshots/06_health_equity.png)

### Page 7 — Procedures & Geography
Most frequent and expensive procedures, procedure cost by encounter class, and patient geographic distribution.

![Procedures & Geography](screenshots/07_procedures_geography.png)

---

## 📈 Key Findings

### Admissions & LOS
- The hospital managed **27,891 encounters** across **154 patients** between 2011 and 2022 — reflecting Synthea's lifetime simulation model where each patient accumulates hundreds of visits over decades
- Admissions **peaked in 2014 at 3.9K** and again in **2021 at 3.5K**, with a sharp drop in 2022 reflecting the end of the simulation period — not real operational decline
- **Inpatient encounters have the highest average LOS at 1.54 days**, followed by ambulatory at 0.39 days — urgentcare and wellness visits are almost always same-day
- **February sees the highest monthly admissions at 3K** — possible seasonal respiratory illness effect
- The most common reason for encounter with 19.5K visits has no reason code, followed by **Chronic Congestive Heart Failure (1.7K)** and **Hyperlipidemia (1.6K)**

### Payer & Cost Analysis
- Total cost billed across all encounters is **$101.51M**, with total payer coverage of only **$31.10M** — leaving **$70.42M in out-of-pocket costs**
- Average payer coverage is only **32%** — meaning patients bear 68% of costs on average
- **NO_INSURANCE accounts for $49M in out-of-pocket costs** — the single largest burden, affecting 8.8K encounters
- **Medicare covers the most encounters at 11.4K** but its coverage rate still leaves significant gaps
- **Medicaid shows the best coverage ratio** — $8M covered against $9M billed (~89% coverage)
- **Normal pregnancy is the most expensive encounter reason at $21M total**, followed by COVID-19 at $1M

### Readmission Analysis
- Overall **30-day readmission rate is 0.74%** — very low, consistent with a synthetic dataset
- **65+ age band has the highest readmission rate at 0.22%** — expected given elderly patients have more complex conditions
- **Outpatient encounters drive the most readmissions** at 0.048%
- **Dual Eligible patients have the highest readmission rate by payer at 0.81%** — these are patients enrolled in both Medicare and Medicaid, typically the most complex cases

### Health Equity
- **Female patients have a higher readmission rate (2.6%) vs Male (0.3%)** — a notable disparity worth investigating in a real dataset
- Average LOS is similar across racial groups — white patients average 0.19 days, black 0.16 days, suggesting no significant LOS disparity in this dataset
- **Mortality rate is 100% across all racial groups** — expected in Synthea as it simulates full lifetimes
- **White patients account for $8M in out-of-pocket costs** — proportional to their share of the patient population (103 of 154 patients)

### Procedures & Geography
- **48K total procedures performed** with a total cost of **$105.52M** and average procedure cost of **$2,210**
- The most frequently performed procedures are **Assessment and admission procedures** — 4.6K and 4.1K respectively
- **Admit to ICU is the most expensive procedure at $210K average cost** — followed by Coronary Artery Bypass at $50K
- **Ambulatory encounters drive the most procedure cost at $36M**, followed by urgentcare at $23M
- Procedures peaked in **2014 at 6.3K** mirroring the admission trend
- Patients are geographically concentrated in **Boston and surrounding suburbs** — consistent with MGH's location in Massachusetts

---

## ⚙️ DAX Measures

```dax
Total Patients         = COUNTROWS(dim_patients)
Total Encounters       = COUNTROWS(fact_encounters)
Avg Length of Stay     = AVERAGEX(FILTER(fact_encounters, fact_encounters[los_days] >= 0), fact_encounters[los_days])
Total Cost Billed      = SUM(fact_encounters[total_cost])
Total Payer Coverage   = SUM(fact_encounters[payer_coverage])
Total Out of Pocket    = SUM(fact_encounters[out_of_pocket])
Avg Coverage %         = AVERAGE(fact_encounters[coverage_pct])
Total Readmissions     = COUNTROWS(FILTER(fact_readmissions, fact_readmissions[readmission_status] = "Readmitted"))
Readmission Rate %     = DIVIDE([Total Readmissions], [Total Encounters]) * 100
Deceased Patients      = COUNTROWS(FILTER(dim_patients, dim_patients[vital_status] = "Deceased"))
Mortality Rate %       = DIVIDE([Deceased Patients], [Total Patients]) * 100
Total Procedures       = COUNTROWS(fact_procedures)
Avg Procedure Cost     = AVERAGE(fact_procedures[procedure_cost])
Total Procedure Cost   = SUM(fact_procedures[procedure_cost])
```

---

## ⚠️ Assumptions & Limitations

- Data is **fully synthetic** (Synthea) — findings are for demonstration only and should not be used for clinical decisions
- **Readmission** is defined as the same patient returning within **30 days** of a prior discharge
- **LOS for same-day encounters** is 0 — these are kept in the dataset but filtered from averages using `los_days >= 0`
- **Coverage %** excludes encounters where `Total_Claim_Cost = 0` to avoid division errors
- The **100% mortality rate** across all patients reflects Synthea's lifetime simulation — not real hospital outcomes
- The **sharp drop in 2022** in admissions and procedures reflects the simulation end date, not real performance
- **Negative days_since_last_discharge** values exist due to overlapping encounters in synthetic data — these are excluded from readmission calculations

---

## 📁 Repository Structure

```
hospital-patient-records-analysis/
├── sql/
│   ├── 01_create_raw_tables.sql
│   ├── 02_dim_patients.sql
│   ├── 03_dim_payers.sql
│   ├── 04_dim_organizations.sql
│   ├── 05_fact_encounters.sql
│   ├── 06_fact_procedures.sql
│   └── 07_fact_readmissions.sql
├── powerbi/
│   └── hospital_analysis.pbix
├── screenshots/
│   ├── 01_executive_summary.png
│   ├── 02_patient_demographics.png
│   ├── 03_admissions_los.png
│   ├── 04_payer_cost.png
│   ├── 05_readmissions.png
│   ├── 06_health_equity.png
│   └── 07_procedures_geography.png
└── README.md
```

---

## 🚀 How to Reproduce

1. Download the Synthea dataset from [Maven Analytics](https://www.mavenanalytics.io/)
2. Create a MySQL database: `CREATE DATABASE hospital_analysis;`
3. Run SQL scripts in order from the `/sql` folder
4. Install [MySQL Connector for Power BI](https://dev.mysql.com/downloads/connector/net/)
5. Open `hospital_analysis.pbix` in Power BI Desktop
6. Update the MySQL connection to point to your local instance (`127.0.0.1:3306`)

---

## 👤 Author

**Syed Abdul Hannan (Aka)**  
Data Analyst | Email Marketing Strategist | Growth Consultant  
[GitHub](https://github.com/) · [LinkedIn](https://linkedin.com/)

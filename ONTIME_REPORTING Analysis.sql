/*==============================================================================
Airline On‑Time Performance (BTS) — SQL EDA (Analysis)
Author: Kabir
Database: SQL Server (SSMS)
Table: dbo.ONTIME_REPORTING (row granularity: 1 row = 1 flight)
Goal of this file:
  - Turn exploration findings into “analysis” outputs that a business team can use.
  - Keep the raw table untouched (no UPDATEs here). We handle NULLs safely in queries.
Notes:
  - CANCELLED is treated as 0/1.
  - FLIGHTS is usually 1 per row; we still SUM() it so the logic is explicit.
  - NULLIF(x,0) prevents divide-by-zero when calculating rates
==============================================================================*/

-- Optional: set schema/table here so you can change it in one place later
-- (If you don’t want this, just ignore and use dbo.ONTIME_REPORTING directly.)
-- DECLARE @tbl SYSNAME = 'dbo.ONTIME_REPORTING';


/*==============================================================================
1) Cancellation analysis
   Question: Which origin airports have the highest cancellation RATE, and how
   does that compare to cancellation COUNT and flight VOLUME?
==============================================================================*/

-- 1A) Cancellation rate by origin airport
SELECT
    ot.ORIGIN_AIRPORT_ID,
    ot.ORIGIN,
    ot.ORIGIN_CITY_NAME,

    SUM(ot.FLIGHTS)   AS total_flights,
    SUM(ot.CANCELLED) AS total_cancelled_flights,

    -- Use 100.0 to force decimal math + NULLIF to avoid divide by zero
    ROUND(100.0 * SUM(ot.CANCELLED) / NULLIF(SUM(ot.FLIGHTS), 0), 2) AS cancellation_rate_pct
FROM dbo.ONTIME_REPORTING AS ot
GROUP BY
    ot.ORIGIN_AIRPORT_ID,
    ot.ORIGIN,
    ot.ORIGIN_CITY_NAME
ORDER BY
    cancellation_rate_pct DESC;

-- Observation template you can write in README:
-- “Highest cancellation *rates* tend to appear at low-volume airports, while
-- high-volume airports contribute more to total cancellations (count) even if
-- their cancellation rate is lower.”


-- 1B) Same output, but prioritize “impact” (total cancelled flights) instead of rate
SELECT
    ot.ORIGIN_AIRPORT_ID,
    ot.ORIGIN,
    ot.ORIGIN_CITY_NAME,

    SUM(ot.FLIGHTS)   AS total_flights,
    SUM(ot.CANCELLED) AS total_cancelled_flights,
    ROUND(100.0 * SUM(ot.CANCELLED) / NULLIF(SUM(ot.FLIGHTS), 0), 2) AS cancellation_rate_pct
FROM dbo.ONTIME_REPORTING AS ot
GROUP BY
    ot.ORIGIN_AIRPORT_ID,
    ot.ORIGIN,
    ot.ORIGIN_CITY_NAME
ORDER BY
    total_cancelled_flights DESC;


/*==============================================================================
2) Delay analysis (departures and arrivals)
   You’re using “industry thresholds”:
     - 15+ minutes late = delayed (common KPI)
     - 60+ minutes late = severe / escalated delay (ops attention)
   Important:
     - Negative delay values mean the flight left/arrived EARLY (not a bug).
     - NULL delays often happen for CANCELLED flights (not applicable).
==============================================================================*/

-- 2A) Detail view: Moderate departure delays (15–60), non-cancelled flights
-- Purpose: sanity check rows + see airports/carriers with delays in this band.
SELECT
    ot.ORIGIN_AIRPORT_ID,
    ot.ORIGIN,
    ot.ORIGIN_CITY_NAME,
    ot.DEP_DELAY AS dep_delay_minutes,
    ot.ARR_DELAY AS arr_delay_minutes
FROM dbo.ONTIME_REPORTING AS ot
WHERE
    ot.CANCELLED = 0
    AND ot.DEP_DELAY >= 15
    AND ot.DEP_DELAY <= 60
ORDER BY
    ot.DEP_DELAY DESC;


-- 2B) Summary: Top origins by volume for moderate delays (15–60)
-- “Bucket size” matters: COUNT(*) tells you if a nice average is based on
-- 5 flights or 5,000 flights.
SELECT TOP (50)
    COUNT(*) AS flights_in_bucket,

    ROUND(AVG(ot.DEP_DELAY), 2) AS avg_dep_delay_minutes,
    ROUND(AVG(ot.ARR_DELAY), 2) AS avg_arr_delay_minutes,

    -- Recovery metric:
    -- If (avg_arr - avg_dep) is negative, operations recovered time in the air.
    ROUND(AVG(ot.ARR_DELAY) - AVG(ot.DEP_DELAY), 2) AS avg_arr_minus_dep_minutes,

    ot.ORIGIN
FROM dbo.ONTIME_REPORTING AS ot
WHERE
    ot.CANCELLED = 0
    AND ot.DEP_DELAY >= 15
    AND ot.DEP_DELAY <= 60
GROUP BY
    ot.ORIGIN
ORDER BY
    flights_in_bucket DESC;

-- Observation template:
-- “For moderate delays, many high-volume origins show avg_arr_delay < avg_dep_delay,
-- suggesting partial ‘recovery’ during taxi/airtime (small but consistent).”


-- 2C) Summary: Top origins by volume for severe delays (>60)
SELECT TOP (50)
    COUNT(*) AS flights_in_bucket,

    ROUND(AVG(ot.DEP_DELAY), 2) AS avg_dep_delay_minutes,
    ROUND(AVG(ot.ARR_DELAY), 2) AS avg_arr_delay_minutes,
    ROUND(AVG(ot.ARR_DELAY) - AVG(ot.DEP_DELAY), 2) AS avg_arr_minus_dep_minutes,

    ot.ORIGIN
FROM dbo.ONTIME_REPORTING AS ot
WHERE
    ot.CANCELLED = 0
    AND ot.DEP_DELAY > 60
GROUP BY
    ot.ORIGIN
ORDER BY
    flights_in_bucket DESC;

-- Observation template:
-- “For severe departure delays, avg_arr_delay is often similar to or higher than
-- avg_dep_delay, indicating limited ability to recover time once delays cross
-- the 60-minute threshold.”


/*==============================================================================
3) Optional: Compare cancellation + delay together (ops friction)
   Question: Are cancellations concentrated where delay is missing / not applicable?
   (You already noticed DEP_DELAY NULL aligns strongly with CANCELLED = 1.)
==============================================================================*/

-- 3A) Check the relationship between cancellation and missing DEP_DELAY
  
-- Expected interpretation:
-- If most rows here are CANCELLED=1, then DEP_DELAY NULL usually means “not applicable”
-- rather than “bad data”.

/* End of file */

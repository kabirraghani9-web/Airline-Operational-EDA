
/* Airline On-Time Performance – SQL EDA
Section: Data Exploration
======================================================== */


-- 1. Row Count Check
--------------------------------------------------------
SELECT 
    COUNT(*) AS total_rows
FROM ONTIME_REPORTING

-- 2. Core Identifier NULL Check
--------------------------------------------------------
SELECT 
    COUNT(*) AS core_identifier_nulls
FROM ONTIME_REPORTING
WHERE ORIGIN IS NULL
   OR DEST IS NULL
   OR FL_DATE IS NULL

-- 3. Cancellation Overview
--------------------------------------------------------
SELECT 
    SUM(CANCELLED) AS total_cancelled,
    COUNT(*) AS total_flights,
    ROUND(100 * SUM(CANCELLED) / COUNT(*),2) AS cancellation_rate_percentage
FROM ONTIME_REPORTING

-- 4. Delay NULL Behavior (Validation)
--------------------------------------------------------
SELECT 
    COUNT(*) AS dep_delay_nulls
FROM ONTIME_REPORTING
WHERE DEP_DELAY IS NULL

-- 5. Delays
--------------------------------------------------------
-- Moderate Delay (15–60 mins)
SELECT 
    COUNT(*) AS moderate_delay_count
FROM ONTIME_REPORTING
WHERE CANCELLED = 0
  AND DEP_DELAY >= 15
  AND DEP_DELAY <= 6

-- Severe Delay (>60 mins)
SELECT 
    COUNT(*) AS severe_delay_count
FROM ONTIME_REPORTING
WHERE CANCELLED = 0
  AND DEP_DELAY > 60

-- 6. Early vs On-Time Flights
--------------------------------------------------------
SELECT 
    COUNT(*) AS early_departures
FROM ONTIME_REPORTING
WHERE CANCELLED = 0
  AND DEP_DELAY < 0

SELECT 
    COUNT(*) AS on_time_departures
FROM ONTIME_REPORTING
WHERE CANCELLED = 0
  AND DEP_DELAY = 0

-- 7. Extreme Delays
--------------------------------------------------------
SELECT TOP 10
    ORIGIN,
    DEST,
    DEP_DELAY,
    ARR_DELAY
FROM ONTIME_REPORTING
WHERE CANCELLED = 0
ORDER BY DEP_DELAY DESC

--------------------------------------------------------
-- End of Exploration Queries

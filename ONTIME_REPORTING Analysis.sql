/* Airline On‑Time Performance (BTS) — SQL EDA (Analysis)
==============================================================================*/
/* 1) Cancellation analysis
   Question: Which origin airports have the highest cancellation RATE?
==============================================================================*/

-- 1A) Cancellation rate by origin airport
SELECT
    ot.ORIGIN_AIRPORT_ID,
    ot.ORIGIN,
    ot.ORIGIN_CITY_NAME,
    SUM(ot.FLIGHTS)   AS total_flights,
    SUM(ot.CANCELLED) AS total_cancelled_flights,
    ROUND(100.0 * SUM(ot.CANCELLED) / SUM(ot.FLIGHTS), 2) AS cancellation_rate_pct
FROM dbo.ONTIME_REPORTING AS ot
GROUP BY
    ot.ORIGIN_AIRPORT_ID,
    ot.ORIGIN,
    ot.ORIGIN_CITY_NAME
ORDER BY
    cancellation_rate_pct DESC;

-- Highest cancellation rates tend to appear at low-volume airports, while
-- high-volume airports contribute more to total cancellations (count) even if
-- their cancellation rate is lower.


-- 1B) Same output, but “count” (total cancelled flights) instead of rate
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


/* 2) Delay analysis (departures and arrivals)
==============================================================================*/

-- 2A) Detail view: Moderate departure delays (15–60), non-cancelled flights
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
    ot.DEP_DELAY DESC


-- 2B) Summary: Top airports by volume for moderate delays (15–60 mins) 
SELECT TOP (50)
    COUNT(*) AS total_flights
    ROUND(AVG(ot.DEP_DELAY), 2) AS avg_dep_delay_minutes,
    ROUND(AVG(ot.ARR_DELAY), 2) AS avg_arr_delay_minutes,
    ROUND(AVG(ot.ARR_DELAY) - AVG(ot.DEP_DELAY), 2) AS avg_arr_minus_dep_minutes,
    ot.ORIGIN
FROM ONTIME_REPORTING AS ot
WHERE
    ot.CANCELLED = 0
    AND ot.DEP_DELAY >= 15
    AND ot.DEP_DELAY <= 60
GROUP BY
    ot.ORIGIN
ORDER BY
    total_flights DESC


-- 2C) Top origins by volume for severe delays (>60)
SELECT TOP (50)
    COUNT(*) AS total_flights
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
    total_flights DESC

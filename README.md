# Airline-Operational-EDA
# Airline Operational Performance Analysis (SQL EDA)

## Objective
Airlines operate on tight schedules, and delays can affect thousands of passengers daily. I wanted to understand how often flights exceed standard delays and how severe those delays are.

This project explores:
- Cancellation patterns across airports
- Delay severity (15+ mins, 60+ mins)
- Departure vs Arrival delay comparison
- Data quality and NULL behavior
- Airtime recovery patterns

## Dataset
Source: ONTIME_REPORTING, Airline Stats.

## Tools Used
- SQL Server
- Aggregations (SUM, COUNT, AVG)
- NULL handling
- Grouping and ordering
- Basic operational interpretation

## Key Findings
- ~18.46% of flights delayed 15+ mins
- ~4.86% delayed 60+ mins
- Cancellation rate higher in low-volume airports and lower in high volume airports
- Severe delays often show arrival delay slightly lower than departure delay (possible schedule recovery)
- Cancelled flights show NULL in delay fields but still have scheduled distance

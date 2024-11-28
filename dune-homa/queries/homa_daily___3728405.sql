-- part of a query repo
-- query name: homa_daily
-- query link: https://dune.com/queries/3728405


WITH daily_stats AS (
    SELECT
        DATE_TRUNC('day', hs."timestamp") AS "day_timestamp",
        AVG(hs.exchange_rate) AS "exchange_rate",
        AVG(hs.total_dot) AS "total_dot", 
        AVG(hs.total_ldot) AS "total_ldot"
    FROM query_3728345 as hs -- homa_states
    GROUP BY 1
    ORDER BY 1
),

stats_with_prev AS (
    SELECT 
        *,
        LAG(exchange_rate, 60) OVER (ORDER BY day_timestamp) AS exchange_rate_60d_ago
    FROM daily_stats
),

stats_with_apy AS (
    SELECT
        *,
        CASE 
            WHEN exchange_rate_60d_ago IS NULL THEN 0.2 -- default 20% APY when no 60-day history
            ELSE POW(exchange_rate / exchange_rate_60d_ago, 365.0/60.0) - 1
        END AS apy
    FROM stats_with_prev
)

SELECT
    day_timestamp,
    exchange_rate,
    total_dot,
    total_ldot,
    apy
FROM stats_with_apy
ORDER BY day_timestamp
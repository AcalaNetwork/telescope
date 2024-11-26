-- part of a query repo
-- query name: latest_euphrates_stats
-- query link: https://dune.com/queries/3397059


-- somehow LIMIT is not applied before sum
-- so has to seperate the query
WITH latest_pool_stats_8 AS (
    SELECT *
    FROM query_3988572 AS eps   -- euphrates pool stats
    ORDER BY 1 DESC 
    LIMIT 8                     -- 8 pools
),

latest_pool_stats AS (
    SELECT
        SUM(dot_amount_ui) AS total_dot_staked,
        SUM(dot_usd) AS dot_tvl,
        SUM(total_usd) AS tvl
    FROM latest_pool_stats_8
),

latest_cumulative_stats_8 AS (
    SELECT *
    FROM query_3393781 AS tdl   -- total dot locked
    ORDER BY 1 DESC 
    LIMIT 8                     -- 8 pools
),

latest_cumulative_stats AS (
    SELECT SUM(cumulative_dot_staked) AS cumulative_dot_staked
    FROM latest_cumulative_stats_8
),

latest_tx_stats AS (
    SELECT cumulative_tx_count
    FROM query_3397026          -- users and transactions
    ORDER BY 1 DESC 
    LIMIT 1
),

latest_claim_stats AS (
    SELECT cumulative_aca
    FROM query_4333164
    ORDER BY 1 DESC 
    LIMIT 1
)

SELECT *
FROM latest_pool_stats
CROSS JOIN latest_cumulative_stats
CROSS JOIN latest_tx_stats
CROSS JOIN latest_claim_stats
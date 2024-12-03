-- part of a query repo
-- query name: homa_latest_stats
-- query link: https://dune.com/queries/3731304


WITH latest_cumulative_tx AS (
    SELECT cumulative_tx_count
    FROM query_4360604
    ORDER BY day DESC
    LIMIT 1
)

SELECT
    hds.day_timestamp,
    hds.total_dot,
    hds.total_ldot,
    hds.apy * 100 as apy,
    hds.exchange_rate,
    lct.cumulative_tx_count AS cumulative_tx_count
FROM query_3728405 as hds -- homa_daily_states
CROSS JOIN latest_cumulative_tx AS lct
ORDER BY hds.day_timestamp DESC 
LIMIT 1;
-- part of a query repo
-- query name: homa_latest_stats
-- query link: https://dune.com/queries/3731304


SELECT
    hds.day_timestamp,
    hds.total_dot,
    hds.total_ldot,
    hds.apy * 100 as apy,
    hds.exchange_rate
FROM query_3728405 as hds -- homa_daily_states
ORDER BY hds.day_timestamp DESC 
LIMIT 1;
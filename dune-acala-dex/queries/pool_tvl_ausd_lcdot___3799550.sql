-- part of a query repo
-- query name: pool_tvl_ausd_lcdot
-- query link: https://dune.com/queries/3799550


SELECT
    day_timestamp,
    token0_tvl AS aseed_tvl,
    token1_tvl AS lcdot_tvl
FROM query_3782346 AS pool_tvl
WHERE pool_name = 'AUSD/lcDOT'
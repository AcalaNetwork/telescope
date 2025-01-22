-- part of a query repo
-- query name: pool_tvl_ausd_ldot
-- query link: https://dune.com/queries/3799555


SELECT
    date,
    token0_tvl AS aseed_tvl,
    token1_tvl AS ldot_tvl
FROM query_3782346 AS pool_tvl
WHERE pool_name = 'AUSD/LDOT'
AND token0_tvl > 0
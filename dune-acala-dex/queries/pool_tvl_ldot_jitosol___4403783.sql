-- part of a query repo
-- query name: pool_tvl_ldot_jitosol
-- query link: https://dune.com/queries/4403783


SELECT
    date,
    token0_tvl AS ldot_tvl,
    token1_tvl AS jitosol_tvl,
    usd_tvl
FROM query_3782346 AS pool_tvl
WHERE pool_name = 'LDOT/JITOSOL'
AND token0_tvl > 0
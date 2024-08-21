-- part of a query repo
-- query name: pool_tvl_aca_usdc
-- query link: https://dune.com/queries/3799539


SELECT
    day_timestamp,
    token0_tvl AS aca_tvl,
    token1_tvl AS usdc_tvl
    -- usd_value AS usd_tvl
FROM query_3782346 AS pool_tvl
WHERE pool_name = 'ACA/USDC'
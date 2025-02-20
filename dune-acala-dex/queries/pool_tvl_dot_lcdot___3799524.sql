-- part of a query repo
-- query name: pool_tvl_dot_lcdot
-- query link: https://dune.com/queries/3799524


SELECT
    date,
    token0_tvl AS dot_tvl,
    token1_tvl AS lcdot_tvl
FROM dune.euphrates.result_dex_pool_tvl AS pool_tvl
WHERE pool_name = 'DOT/lcDOT'
AND token0_tvl > 0
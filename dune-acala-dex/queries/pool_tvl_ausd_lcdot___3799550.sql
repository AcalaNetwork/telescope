-- part of a query repo
-- query name: pool_tvl_ausd_lcdot
-- query link: https://dune.com/queries/3799550


SELECT
    date,
    token0_tvl AS aseed_tvl,
    token1_tvl AS lcdot_tvl
FROM dune.euphrates.result_dex_pool_tvl AS pool_tvl
WHERE pool_name = 'AUSD/lcDOT'
AND token0_tvl > 0
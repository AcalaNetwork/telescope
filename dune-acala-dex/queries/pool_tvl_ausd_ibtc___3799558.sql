-- part of a query repo
-- query name: pool_tvl_ausd_ibtc
-- query link: https://dune.com/queries/3799558


SELECT
    date,
    token0_tvl AS aseed_tvl,
    token1_tvl AS ibtc_tvl
FROM dune.euphrates.result_dex_pool_tvl AS pool_tvl
WHERE pool_name = 'AUSD/IBTC'
AND token0_tvl > 0
-- part of a query repo
-- query name: pool_tvl_aca_ausd
-- query link: https://dune.com/queries/3799554


SELECT
    date,
    token0_tvl AS aca_tvl,
    token1_tvl AS aseed_tvl
FROM dune.euphrates.result_dex_pool_tvl AS pool_tvl
WHERE pool_name = 'ACA/AUSD'
AND token0_tvl > 0
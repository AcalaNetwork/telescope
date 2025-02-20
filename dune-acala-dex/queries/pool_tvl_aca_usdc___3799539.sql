-- part of a query repo
-- query name: pool_tvl_aca_usdc
-- query link: https://dune.com/queries/3799539


SELECT
    date,
    token0_tvl AS aca_tvl,
    token1_tvl AS usdc_tvl
FROM dune.euphrates.result_dex_pool_tvl AS pool_tvl
WHERE pool_name = 'ACA/USDC'
AND token0_tvl > 0
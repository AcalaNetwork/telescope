-- part of a query repo
-- query name: pool_tvl_dot_unq
-- query link: https://dune.com/queries/3799556


SELECT
    day_timestamp,
    token0_tvl AS dot_tvl,
    token1_tvl AS unq_tvl
FROM query_3782346 AS pool_tvl
WHERE pool_name = 'DOT/UNQ'
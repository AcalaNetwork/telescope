-- part of a query repo
-- query name: pool_tvl
-- query link: https://dune.com/queries/3782346


WITH liquidity_txs AS (
    SELECT
        block_time,
        block_number,
        token0,
        token1,
        amount0 * CASE WHEN method = 'AddLiquidity' THEN 1 ELSE -1 END AS net_amount0,
        amount1 * CASE WHEN method = 'AddLiquidity' THEN 1 ELSE -1 END AS net_amount1
    FROM query_3769045 -- dex liquidity tx
),

provision_txs AS (
    SELECT
        block_time,
        block_number,
        token0,
        token1,
        amount0 AS net_amount0,  -- provision only increases liquidity
        amount1 AS net_amount1
    FROM query_3782192 -- add provision tx
),

dex_txs AS (
    SELECT
        A.block_time,
        A.block_number,
        B.token0,
        B.token1,
        CASE 
            WHEN A.token_in = B.token0 THEN A.amount_in 
            WHEN A.token_out = B.token0 THEN -A.amount_out 
            ELSE 0 
        END AS net_amount0,
        CASE 
            WHEN A.token_in = B.token1 THEN A.amount_in 
            WHEN A.token_out = B.token1 THEN -A.amount_out 
            ELSE 0 
        END AS net_amount1
    FROM query_3787671 A -- dex_swap splitted tx
    JOIN (
        SELECT DISTINCT token0, token1
        FROM query_3769045 -- dex liquidity tx
        UNION
        SELECT DISTINCT token0, token1
        FROM query_3782192 -- add provision tx
    ) B
    ON (A.token_in = B.token0 AND A.token_out = B.token1) 
    OR (A.token_in = B.token1 AND A.token_out = B.token0)
),

all_txs AS (
    SELECT * FROM liquidity_txs
    UNION ALL
    SELECT * FROM provision_txs
    UNION ALL
    SELECT * FROM dex_txs
    UNION ALL
    SELECT * FROM query_3784244 AS admin_txs
),

pool_tvl AS (
    SELECT
        block_time,
        block_number,
        token0,
        token1,
        CONCAT(token0, '/', token1) AS pool_name,
        SUM(net_amount0) OVER (PARTITION BY token0, token1 ORDER BY block_time) AS token0_tvl,
        SUM(net_amount1) OVER (PARTITION BY token0, token1 ORDER BY block_time) AS token1_tvl
    FROM all_txs
)
SELECT
    DATE_TRUNC('day', block_time) AS day_timestamp,
    pool_name,
    AVG(token0_tvl) AS token0_tvl,
    AVG(token1_tvl) AS token1_tvl
    -- AVG(usd_value) AS usd_tvl
FROM pool_tvl
-- WHERE pool_name = {{pool_name}}
GROUP BY 1, pool_name
ORDER BY 1


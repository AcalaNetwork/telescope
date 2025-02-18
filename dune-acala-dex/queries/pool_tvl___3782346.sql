-- part of a query repo
-- query name: dex_pool_tvl
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
    FROM dune.euphrates.result_dex_swap_splitted A
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
    ORDER BY 1 ASC
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
),

pool_tvl_usd AS (
    SELECT
        block_time,
        block_number,
        token0,
        token1,
        pool_name,
        token0_tvl,
        token1_tvl,
        CASE
            WHEN E.token0 IN ('DOT', 'lcDOT') THEN E.token0_tvl * dot_price.price * 2
            WHEN E.token0 IN ('JITOSOL') THEN E.token0_tvl * jitosol_price.price * 2
            WHEN E.token0 IN ('AUSD', 'USDC', 'USDT') THEN E.token0_tvl * 2
            WHEN E.token1 IN ('DOT', 'lcDOT') THEN E.token1_tvl * dot_price.price * 2
            WHEN E.token1 IN ('JITOSOL') THEN E.token1_tvl * jitosol_price.price * 2
            WHEN E.token1 IN ('AUSD', 'USDC', 'USDT') THEN E.token1_tvl * 2
            ELSE 0
        END AS usd_tvl
    FROM pool_tvl E
    LEFT JOIN query_3989007 as dot_price
        ON DATE_TRUNC('day', E.block_time) = dot_price.day
        AND dot_price.symbol = 'DOT'
    LEFT JOIN query_3989007 as jitosol_price
        ON DATE_TRUNC('day', E.block_time) = jitosol_price.day
        AND jitosol_price.symbol = 'JITOSOL'
),

daily_pool_tvl AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        pool_name,
        AVG(token0_tvl) AS token0_tvl,
        AVG(token1_tvl) AS token1_tvl,
        AVG(usd_tvl) AS usd_tvl
    FROM pool_tvl_usd
    WHERE pool_name != 'AUSD/IBTC'
    GROUP BY 1, 2
    UNION
    SELECT * FROM query_4419518  -- tdot_tvl
),

date_range AS (
    SELECT
        MIN(DATE_TRUNC('day', block_time)) AS start_date,
        MAX(DATE_TRUNC('day', block_time)) AS end_date
    FROM pool_tvl_usd
    WHERE pool_name != 'AUSD/IBTC'  -- Add filter here
),

all_dates AS (
    SELECT
        DATE_TRUNC('day', DATE_ADD('day', value, start_date)) AS date
    FROM date_range
    CROSS JOIN UNNEST(sequence(0, date_diff('day', start_date, end_date))) AS t(value)
),

all_pool_names AS (
    SELECT DISTINCT pool_name
    FROM daily_pool_tvl
    WHERE pool_name != 'AUSD/IBTC'  -- Add filter here
),

full_date_pool_combination AS (
    SELECT date, pool_name
    FROM all_dates
    CROSS JOIN all_pool_names
    ORDER BY date ASC
),

historical_values AS (
    SELECT
        d1.date as ref_date,
        d2.date as data_date,
        d2.pool_name,
        d2.token0_tvl,
        d2.token1_tvl,
        d2.usd_tvl,
        ROW_NUMBER() OVER (
            PARTITION BY d1.date, d2.pool_name
            ORDER BY d2.date DESC
        ) as rn
    FROM (SELECT DISTINCT date FROM full_date_pool_combination) d1
    CROSS JOIN daily_pool_tvl d2
    WHERE d2.date <= d1.date
),

latest_historical AS (
    SELECT
        ref_date as date,
        pool_name,
        token0_tvl as historical_token0_tvl,
        token1_tvl as historical_token1_tvl,
        usd_tvl as historical_usd_tvl
    FROM historical_values
    WHERE rn = 1
),

daily_pool_tvl_complete AS (
    SELECT
        f.date,
        f.pool_name,
        COALESCE(d.token0_tvl, h.historical_token0_tvl, 0) AS token0_tvl,
        COALESCE(d.token1_tvl, h.historical_token1_tvl, 0) AS token1_tvl,
        COALESCE(d.usd_tvl, h.historical_usd_tvl, 0) AS usd_tvl
    FROM full_date_pool_combination f
    LEFT JOIN daily_pool_tvl d
        ON f.date = d.date
        AND f.pool_name = d.pool_name
    LEFT JOIN latest_historical h
        ON f.date = h.date
        AND f.pool_name = h.pool_name
)

SELECT
    date,
    pool_name,
    token0_tvl,
    token1_tvl,
    usd_tvl
FROM daily_pool_tvl_complete
-- WHERE date >= date_add('month', -1 * {{show data for how many months:}}, current_date)
ORDER BY date DESC, pool_name;
-- part of a query repo
-- query name: dex_liquidity_tx
-- query link: https://dune.com/queries/3769045


WITH liquidity_tx_raw AS (
    SELECT
        block_time,
        block_number,
        method,
        block_hash,
        extrinsic_id,
        extrinsic_hash,
        event_id,
        JSON_EXTRACT_SCALAR(data, '$[0]') AS address,
        JSON_EXTRACT(data, '$[1]') AS token0_json,
        CAST(JSON_EXTRACT(data, '$[2]') AS VARCHAR) AS amount0_varchar,
        JSON_EXTRACT(data, '$[3]') AS token1_json,
        CAST(JSON_EXTRACT(data, '$[4]') AS VARCHAR) AS amount1_varchar,
        CAST(JSON_EXTRACT(data, '$[5]') AS VARCHAR) AS share_diff_varchar
    FROM acala.events
    WHERE section = 'dex'
    AND   (method = 'AddLiquidity' OR method = 'RemoveLiquidity')
),

liquidity_tx_extracted AS (
    SELECT
        *,
        CASE
          WHEN JSON_EXTRACT_SCALAR(X.token0_json, '$.token') IS NOT NULL THEN (
            CONCAT(
              '{"Token":"',
              JSON_EXTRACT_SCALAR(X.token0_json, '$.token'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token0_json, '$.liquidCrowdloan') IS NOT NULL THEN (
            CONCAT(
              '{"LiquidCrowdloan":"',
              JSON_EXTRACT_SCALAR(X.token0_json, '$.liquidCrowdloan'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token0_json, '$.foreignAsset') IS NOT NULL THEN (
            CONCAT(
              '{"ForeignAsset":"',
              JSON_EXTRACT_SCALAR(X.token0_json, '$.foreignAsset'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token0_json, '$.erc20') IS NOT NULL THEN (
            CONCAT(
              '{"Erc20":"',
              JSON_EXTRACT_SCALAR(X.token0_json, '$.erc20'),
              '"}'
            )
          )
          ELSE '???'
        END AS token0_varchar,

        CASE
          WHEN JSON_EXTRACT_SCALAR(X.token1_json, '$.token') IS NOT NULL THEN (
            CONCAT(
              '{"Token":"',
              JSON_EXTRACT_SCALAR(X.token1_json, '$.token'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token1_json, '$.liquidCrowdloan') IS NOT NULL THEN (
            CONCAT(
              '{"LiquidCrowdloan":"',
              JSON_EXTRACT_SCALAR(X.token1_json, '$.liquidCrowdloan'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token1_json, '$.foreignAsset') IS NOT NULL THEN (
            CONCAT(
              '{"ForeignAsset":"',
              JSON_EXTRACT_SCALAR(X.token1_json, '$.foreignAsset'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token1_json, '$.erc20') IS NOT NULL THEN (
            CONCAT(
              '{"Erc20":"',
              JSON_EXTRACT_SCALAR(X.token1_json, '$.erc20'),
              '"}'
            )
          )
          ELSE '???'
        END AS token1_varchar
    FROM liquidity_tx_raw X
),

liquidity_tx_parsed AS (
    SELECT 
        *,
        B.symbol AS token0,
        B.decimals AS decimals0,
        C.symbol AS token1,
        C.decimals AS decimals1,
        CASE
            WHEN starts_with(amount0_varchar, '0x') 
            THEN varbinary_to_uint256(FROM_HEX(amount0_varchar))
            ELSE CAST(amount0_varchar as uint256)
        END AS amount0_uint256,
        CASE
            WHEN starts_with(amount1_varchar, '0x') 
            THEN varbinary_to_uint256(FROM_HEX(amount1_varchar))
            ELSE CAST(amount1_varchar as uint256)
        END AS amount1_uint256
    FROM liquidity_tx_extracted A
    LEFT JOIN query_4397191 B  -- acala assets
    ON A.token0_varchar = B.asset
    LEFT JOIN query_4397191 C  -- acala assets
    ON A.token1_varchar = C.asset
)

SELECT
    D.block_time,
    D.method,
    D.address,
    CONCAT(token0, '/', token1) AS pool_name,
    D.token0,
    D.token1,
    amount0_uint256 / POWER(10, D.decimals0) AS amount0,
    amount1_uint256 / POWER(10, D.decimals1) AS amount1,
    D.block_number,
    D.extrinsic_hash as tx_hash
FROM liquidity_tx_parsed D
-- WHERE D.amount0_varchar NOT LIKE '0x%'
-- AND D.amount1_varchar NOT LIKE '0x%'
ORDER BY 1 DESC
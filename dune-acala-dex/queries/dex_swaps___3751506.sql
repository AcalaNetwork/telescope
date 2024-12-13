-- part of a query repo
-- query name: dex_swaps
-- query link: https://dune.com/queries/3751506


WITH dex_swap_raw AS (
    SELECT 
        block_time,
        block_number,
        block_hash,
        extrinsic_id,
        extrinsic_hash,
        event_id,
        JSON_EXTRACT_SCALAR(data, '$[0]') AS address,
        JSON_EXTRACT(data, '$[1][0]') AS token_in_json,
        JSON_ARRAY_GET(JSON_EXTRACT(data, '$[1]'), -1) AS token_out_json,
        JSON_VALUE(data, 'strict $[2][0]') AS amount_in_varchar,
        JSON_VALUE(data, 'strict $[2][last]') AS amount_out_varchar
    FROM acala.events
    WHERE section = 'dex'
    AND   method = 'Swap'
),

dex_swap_raw_extracted AS (
    SELECT
        *,
        CASE
          WHEN JSON_EXTRACT_SCALAR(X.token_in_json, '$.token') IS NOT NULL THEN (
            CONCAT(
              '{"Token":"',
              JSON_EXTRACT_SCALAR(X.token_in_json, '$.token'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token_in_json, '$.liquidCrowdloan') IS NOT NULL THEN (
            CONCAT(
              '{"LiquidCrowdloan":"',
              JSON_EXTRACT_SCALAR(X.token_in_json, '$.liquidCrowdloan'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token_in_json, '$.foreignAsset') IS NOT NULL THEN (
            CONCAT(
              '{"ForeignAsset":"',
              JSON_EXTRACT_SCALAR(X.token_in_json, '$.foreignAsset'),
              '"}'
            )
          )
        WHEN JSON_EXTRACT_SCALAR(X.token_in_json, '$.erc20') IS NOT NULL THEN (
            CONCAT(
              '{"Erc20":"',
              JSON_EXTRACT_SCALAR(X.token_in_json, '$.erc20'),
              '"}'
            )
          )
        END AS token_in_varchar,

        CASE
          WHEN JSON_EXTRACT_SCALAR(X.token_out_json, '$.token') IS NOT NULL THEN (
            CONCAT(
              '{"Token":"',
              JSON_EXTRACT_SCALAR(X.token_out_json, '$.token'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token_out_json, '$.liquidCrowdloan') IS NOT NULL THEN (
            CONCAT(
              '{"LiquidCrowdloan":"',
              JSON_EXTRACT_SCALAR(X.token_out_json, '$.liquidCrowdloan'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token_out_json, '$.foreignAsset') IS NOT NULL THEN (
            CONCAT(
              '{"ForeignAsset":"',
              JSON_EXTRACT_SCALAR(X.token_out_json, '$.foreignAsset'),
              '"}'
            )
          )
          WHEN JSON_EXTRACT_SCALAR(X.token_out_json, '$.erc20') IS NOT NULL THEN (
            CONCAT(
              '{"Erc20":"',
              JSON_EXTRACT_SCALAR(X.token_out_json, '$.erc20'),
              '"}'
            )
          )
        END AS token_out_varchar
    FROM dex_swap_raw X
),

dex_swap_parsed AS (
    SELECT 
        *,
        CASE
            WHEN starts_with(amount_in_varchar, '0x') 
            THEN varbinary_to_uint256(FROM_HEX(amount_in_varchar))
            ELSE CAST(amount_in_varchar as uint256)
        END AS amount_in_uint256,
        CASE
            WHEN starts_with(amount_out_varchar, '0x') 
            THEN varbinary_to_uint256(FROM_HEX(amount_out_varchar))
            ELSE CAST(amount_out_varchar as uint256)
        END AS amount_out_uint256 ,
        B.symbol AS token_in,
        B.decimals AS decimals_in,
        C.symbol AS token_out,
        C.decimals AS decimals_out
    FROM dex_swap_raw_extracted A
    LEFT JOIN query_4397191 B  -- acala assets
    ON A.token_in_varchar = B.asset
    LEFT JOIN query_4397191 C  -- acala assets
    ON A.token_out_varchar = C.asset
),

dex_swap_formatted AS (
  SELECT
      D.block_time,
      D.address,
      D.amount_in_uint256 / POWER(10, D.decimals_in) AS amount_in,
      D.token_in,
      D.amount_out_uint256 / POWER(10, D.decimals_out) AS amount_out,
      D.token_out,
      D.block_number,
      D.extrinsic_hash as tx_hash,
      DATE_TRUNC('day', D.block_time) AS day
  FROM dex_swap_parsed D
)


SELECT
    E.block_time,
    E.address,
    E.amount_in,
    E.token_in,
    E.amount_out,
    E.token_out,
    CASE
        WHEN E.token_in IN ('DOT', 'lcDOT') THEN E.amount_in * dot_price.price
        WHEN E.token_in IN ('JITOSOL') THEN E.amount_in * jitosol_price.price
        WHEN E.token_in IN ('AUSD', 'USDC') THEN E.amount_in
        WHEN E.token_out IN ('DOT', 'lcDOT') THEN E.amount_out * dot_price.price
        WHEN E.token_out IN ('JITOSOL') THEN E.amount_out * jitosol_price.price
        WHEN E.token_out IN ('AUSD', 'USDC') THEN E.amount_out
        ELSE 0
    END AS usd_value,
    E.block_number,
    E.tx_hash
FROM dex_swap_formatted E
LEFT JOIN query_3989007 as dot_price
    ON E.day = dot_price.day 
    AND dot_price.symbol = 'DOT'
LEFT JOIN query_3989007 as jitosol_price
    ON E.day = jitosol_price.day 
    AND jitosol_price.symbol = 'JITOSOL'
WHERE E.day != DATE '2022-08-14'
ORDER BY 1 DESC
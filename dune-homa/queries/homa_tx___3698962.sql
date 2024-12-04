-- part of a query repo
-- query name: homa_txs
-- query link: https://dune.com/queries/3698962


WITH mint_txs AS (
  SELECT
    block_time,
    block_number,
    data_decoded,
    data,
    'mint' AS method,
    TRY_CAST(JSON_VALUE(E.data, 'strict $[1]') AS DOUBLE) AS dot_amount,
    TRY_CAST(JSON_VALUE(E.data, 'strict $[2]') AS DOUBLE) AS ldot_amount,
    JSON_VALUE(E.data, 'strict $[0]') AS account,
    extrinsic_hash
  FROM acala.events AS E
  WHERE section = 'homa'
  AND method = 'Minted'
  ORDER BY 1 DESC
),

redeem_unbond_txs AS (
  SELECT
    block_time,
    block_number,
    data_decoded,
    data,
    'redeem' AS method,
    TRY_CAST(JSON_VALUE(E.data, 'strict $[3]') AS DOUBLE) AS dot_amount,
    TRY_CAST(JSON_VALUE(E.data, 'strict $[2]') AS DOUBLE) AS ldot_amount,
    JSON_VALUE(E.data, 'strict $[0]') AS account,
    extrinsic_hash
  FROM acala.events AS E
  WHERE section = 'homa'
  AND method = 'RedeemedByUnbond'
  ORDER BY 1 DESC
),

redeem_fast_txs AS (
  SELECT
    block_time,
    block_number,
    data_decoded,
    data,
    'fast redeem' AS method,
    TRY_CAST(JSON_VALUE(E.data, 'strict $[3]') AS DOUBLE) AS dot_amount,
    TRY_CAST(JSON_VALUE(E.data, 'strict $[1]') AS DOUBLE) AS ldot_amount,
    JSON_VALUE(E.data, 'strict $[0]') AS account,
    extrinsic_hash
  FROM acala.events AS E
  WHERE section = 'homa'
  AND method = 'RedeemedByFastMatch'
  ORDER BY 1 DESC
),

homa_txs AS (
  SELECT * FROM mint_txs
  UNION ALL
  SELECT * FROM redeem_unbond_txs
  UNION ALL
  SELECT * FROM redeem_fast_txs
)

SELECT
  block_time,
  block_number,
  method,
  dot_amount,
  ldot_amount,
  dot_amount / 1e10 AS dot_amount_ui,
  ldot_amount / 1e10 AS ldot_amount_ui,
  account,
  extrinsic_hash
FROM homa_txs
ORDER BY 1 DESC
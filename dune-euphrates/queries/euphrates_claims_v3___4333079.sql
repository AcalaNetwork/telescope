-- part of a query repo
-- query name: euphrates_claims_v3
-- query link: https://dune.com/queries/4333079


SELECT
  FROM_ISO8601_TIMESTAMP("timestamp") AS "timestamp",
  block_number,
  pool_id,
  amount,
  amount_ui,
  reward_type,
  CASE
    WHEN reward_type = 0x0000000000000000000100000000000000000000 THEN 'aca'
    WHEN reward_type = 0x892ddd9387dbdecedaef878bd7acf8603109227f THEN 'tai'
    ELSE '???'
  END AS reward,
  recipient,
  tx_hash
FROM dune.euphrates.dataset_euphrates_claims_v3
ORDER BY 1 DESC
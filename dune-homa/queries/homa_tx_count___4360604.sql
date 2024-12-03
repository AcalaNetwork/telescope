-- part of a query repo
-- query name: homa_tx_count
-- query link: https://dune.com/queries/4360604


WITH daily_tx_count AS (
  SELECT
    DATE_TRUNC('week', block_time) AS day,
    method,
    COUNT(extrinsic_hash) AS daily_count,
    SUM(CASE WHEN method = 'mint' THEN dot_amount_ui ELSE 0 END) AS total_staked_ui,
    SUM(CASE WHEN method != 'mint' THEN dot_amount_ui ELSE 0 END) AS total_unstaked_ui
  FROM query_3698962
  GROUP BY 1, 2
),

daily_count_by_method AS (
  SELECT
    day,
    SUM(CASE WHEN method = 'mint' THEN daily_count ELSE 0 END) AS mint_count,
    SUM(CASE WHEN method = 'redeem' THEN daily_count ELSE 0 END) AS redeem_count,
    SUM(CASE WHEN method = 'fast_redeem' THEN daily_count ELSE 0 END) AS fast_redeem_count,
    SUM(total_staked_ui) AS total_staked_ui,
    SUM(total_unstaked_ui) AS total_unstaked_ui
  FROM daily_tx_count
  GROUP BY day
),

cumulative_tx_count AS (
  SELECT
    day,
    mint_count,
    redeem_count,
    fast_redeem_count,
    total_staked_ui,
    total_unstaked_ui,
    SUM(mint_count + redeem_count + fast_redeem_count) OVER (ORDER BY day) AS cumulative_tx_count
  FROM daily_count_by_method
)

SELECT
  day,
  mint_count,
  redeem_count,
  fast_redeem_count,
  total_staked_ui,
  total_unstaked_ui,
  cumulative_tx_count
FROM cumulative_tx_count
ORDER BY 1
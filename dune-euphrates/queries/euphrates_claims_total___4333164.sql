-- part of a query repo
-- query name: euphrates_claims_total
-- query link: https://dune.com/queries/4333164


SELECT 
  DATE_TRUNC('week', timestamp) AS day,
  SUM(amount_ui) as aca_amount,
  SUM(SUM(amount_ui)) OVER (ORDER BY DATE_TRUNC('week', timestamp)) as cumulative_aca
FROM query_4333079    /* euphrates claims v3 */
WHERE reward_type = 0x0000000000000000000100000000000000000000
GROUP BY 1
ORDER BY 1
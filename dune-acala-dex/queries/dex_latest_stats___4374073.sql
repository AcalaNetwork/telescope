-- part of a query repo
-- query name: dex_latest_stats
-- query link: https://dune.com/queries/4374073


WITH latest_volume AS (
  SELECT
    date,
    volume,
    total_volume
  FROM query_4373515
  ORDER BY 1 DESC
  LIMIT 1
)

SELECT
    date,
    volume,
    total_volume
FROM latest_volume
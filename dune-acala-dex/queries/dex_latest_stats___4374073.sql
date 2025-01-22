-- part of a query repo
-- query name: dex_latest_stats
-- query link: https://dune.com/queries/4374073


WITH latest_volume AS (
  SELECT
    date,
    volume,
    total_volume
  FROM query_4373515
  ORDER BY date DESC
  LIMIT 1
),

latest_tvl AS (
  SELECT
    date AS tvl_date,
    SUM(usd_tvl) AS usd_tvl
  FROM query_3782346
  WHERE date = (SELECT MAX(date) FROM query_3782346)
  GROUP BY date
),

latest_stats AS (
  SELECT
    A.date,
    A.volume,
    A.total_volume,
    B.usd_tvl
  FROM latest_volume A
  CROSS JOIN latest_tvl B
)

SELECT *
FROM latest_stats
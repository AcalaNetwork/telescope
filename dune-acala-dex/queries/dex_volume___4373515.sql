-- part of a query repo
-- query name: dex_volume
-- query link: https://dune.com/queries/4373515


WITH daily_volume AS (
    SELECT 
        date_trunc({{interval}}, block_time) as date,
        SUM(usd_value) AS volume
    FROM query_3751506
    GROUP BY 1
),

cumulative_volume AS (
    SELECT 
        date,
        volume,
        SUM(volume) OVER (ORDER BY date) AS cumulative_volume
    FROM daily_volume
)

SELECT 
    date,
    volume,
    cumulative_volume as total_volume
FROM cumulative_volume
WHERE date >= date_add('month', -1 * {{show data for how many months:}}, current_date)
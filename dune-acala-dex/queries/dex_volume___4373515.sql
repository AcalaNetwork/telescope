-- part of a query repo
-- query name: dex_volume
-- query link: https://dune.com/queries/4373515


WITH daily_volume AS (
    SELECT 
        date_trunc('day', block_time) as date,
        pool_name,
        SUM(usd_value) AS volume
    FROM dune.euphrates.result_dex_swap_splitted
    GROUP BY 1, 2
),

date_range AS (
    SELECT 
        MIN(date) AS start_date,
        MAX(date) AS end_date
    FROM daily_volume
),

all_dates AS (
    SELECT 
        DATE_TRUNC('day', DATE_ADD('day', value, start_date)) AS date
    FROM date_range
    CROSS JOIN UNNEST(sequence(0, date_diff('day', start_date, end_date))) AS t(value)
),

all_pool_names AS (
    SELECT DISTINCT pool_name
    FROM daily_volume
),

full_date_pool_combination AS (
    SELECT date, pool_name
    FROM all_dates
    CROSS JOIN all_pool_names
    ORDER BY date ASC
),

daily_volume_filled AS (
    SELECT 
        f.date,
        f.pool_name,
        COALESCE(d.volume, 0) AS volume
    FROM full_date_pool_combination f
    LEFT JOIN daily_volume d
        ON f.date = d.date
        AND f.pool_name = d.pool_name
),

cumulative_volume_by_pool AS (
    SELECT 
        date,
        pool_name,
        volume,
        SUM(volume) OVER (
            PARTITION BY pool_name 
            ORDER BY date
        ) AS cumulative_volume
    FROM daily_volume_filled
),

daily_total_volume AS (
    SELECT 
        date,
        SUM(volume) as total_volume,
        SUM(SUM(volume)) OVER (
            ORDER BY date
        ) AS cumulative_total_volume
    FROM daily_volume_filled
    GROUP BY 1
),

all_volume AS (
    SELECT 
        A.date,
        A.pool_name,
        A.volume AS daily_volume,
        A.cumulative_volume,
        B.total_volume AS daily_total_volume,
    B.cumulative_total_volume
    FROM cumulative_volume_by_pool A
    LEFT JOIN daily_total_volume B 
        ON A.date = B.date
    ORDER BY A.date DESC, A.pool_name
),

volume_with_apr AS (
    SELECT 
        A.date,
        A.pool_name,
        A.daily_volume,
        A.cumulative_volume,
        A.daily_total_volume,
        A.cumulative_total_volume,
        B.token0_tvl,
        B.token1_tvl,
        B.usd_tvl,
        -- APR: use7-day moving sum
        CASE
            WHEN B.usd_tvl > 0 THEN SUM(A.daily_volume) OVER (
                PARTITION BY A.pool_name 
                ORDER BY A.date 
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ) / B.usd_tvl / 7 * 365 * 0.003
            ELSE 0
        END AS apr
    FROM all_volume A
    LEFT JOIN dune.euphrates.result_dex_pool_tvl B
        ON A.date = B.date 
    AND A.pool_name = B.pool_name
    ORDER BY A.date DESC, A.pool_name
)

SELECT * FROM volume_with_apr
-- WHERE date >= date_add('month', -1 * {{show data for how many months:}}, current_date)
-- WHERE date >= date_add('month', -1 * 1, current_date)
ORDER BY 1, 2 DESC
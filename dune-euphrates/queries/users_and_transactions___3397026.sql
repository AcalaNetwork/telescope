-- part of a query repo
-- query name: users_and_transactions
-- query link: https://dune.com/queries/3397026


WITH daily_stats AS (
    SELECT
        DATE_TRUNC('day', "timestamp") as day,
        COUNT(*) AS daily_tx_count,
        COUNT(DISTINCT "recipient") AS daily_users
    FROM query_3988562  /* euphrates tx v2 */
    GROUP BY 1
),

cumulative_stats AS (
    SELECT
        day,
        SUM(daily_tx_count) OVER (ORDER BY day) AS cumulative_tx_count,
        SUM(daily_users) OVER (ORDER BY day) AS cumulative_users
    FROM daily_stats
)
SELECT
    ds.day,
    ds.daily_tx_count,
    cs.cumulative_tx_count,
    ds.daily_users,
    cs.cumulative_users
FROM
    daily_stats ds
JOIN
    cumulative_stats cs ON ds.day = cs.day
ORDER BY
    ds.day ASC;

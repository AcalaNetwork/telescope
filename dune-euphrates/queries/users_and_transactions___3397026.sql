-- part of a query repo
-- query name: euphrates_users_and_txs
-- query link: https://dune.com/queries/3397026


WITH weekly_stats AS (
    SELECT
        DATE_TRUNC('week', "timestamp") as day,
        COUNT(*) AS weekly_tx_count,
        COUNT(DISTINCT "recipient") AS weekly_users
    FROM (
        SELECT "timestamp", "recipient" FROM query_3988562  /* euphrates tx v3 */
        UNION ALL 
        SELECT "timestamp", "recipient" FROM query_4333079  /* euphrates claims v3 */
    )  
    GROUP BY 1
),

cumulative_stats AS (
    SELECT
        day,
        SUM(weekly_tx_count) OVER (ORDER BY day) AS cumulative_tx_count,
        SUM(weekly_users) OVER (ORDER BY day) AS cumulative_users,
        (
            SELECT COUNT(DISTINCT recipient)
            FROM (
                SELECT "recipient", "timestamp" FROM query_3988562  /* euphrates tx v3 */
                UNION ALL 
                SELECT "recipient", "timestamp" FROM query_4333079  /* euphrates claims v3 */
            ) all_tx
            WHERE "timestamp" <= day
        ) AS cumulative_distinct_users
    FROM weekly_stats
)

SELECT
    ds.day,
    ds.weekly_tx_count,
    cs.cumulative_tx_count,
    ds.weekly_users,
    cs.cumulative_users
FROM
    weekly_stats ds
JOIN
    cumulative_stats cs ON ds.day = cs.day
ORDER BY
    ds.day ASC;

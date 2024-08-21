-- part of a query repo
-- query name: euphrates_pool_stats
-- query link: https://dune.com/queries/3988572


With pool_stats AS (
SELECT
    from_iso8601_timestamp("timestamp") as "timestamp",
    "pool_id",
    "dot_amount",
    "token_amount",
    "dot_amount_ui",
    "token_amount_ui",
    CASE
        WHEN "pool_id" = 0 THEN 'lcdot_ldot'
        WHEN "pool_id" = 1 THEN 'lcdot_tdot'
        WHEN "pool_id" = 2 THEN 'dot_ldot'
        WHEN "pool_id" = 3 THEN 'dot_tdot'
        WHEN "pool_id" = 4 THEN 'dot_starlay'
        WHEN "pool_id" = 5 THEN 'ldot_starlay'
        WHEN "pool_id" = 6 THEN 'jitosol'
        ELSE '???'
    END as "pool_name"
FROM dune.euphrates.dataset_euphrates_pool_stats
ORDER by 1
),

daily_pool_stats AS (
    SELECT
        DATE_TRUNC('day', "timestamp") as "day",
        "pool_id",
        "pool_name",
        CASE
            WHEN "pool_id" in (0, 1, 2, 3, 4, 5) THEN 'DOT'
            WHEN "pool_id" = 6 THEN 'JITOSOL'
            ELSE '???'
        END as "token_symbol",
        AVG("dot_amount") as "dot_amount",
        AVG("token_amount") as "token_amount",
        AVG("dot_amount_ui") as "dot_amount_ui",
        AVG("token_amount_ui") as "token_amount_ui"
    FROM pool_stats
    GROUP BY 1, 2, 3
    ORDER BY 1, 2
)

SELECT
    *,
    "price" * "dot_amount_ui" as "dot_usd",
    CASE
        WHEN "pool_id" in (0, 1, 2, 3, 4, 5) THEN "price" * "dot_amount_ui"
        WHEN "pool_id" = 6 THEN "price" * "token_amount_ui"
        ELSE 0
    END as "token_usd"
FROM daily_pool_stats A
JOIN query_3989007 as B  /* daily token price */
ON A.day = B.day
AND A.token_symbol = B.symbol
ORDER BY 1, 2
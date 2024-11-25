-- part of a query repo
-- query name: euphrates_pool_stats
-- query link: https://dune.com/queries/3988572


With pool_stats AS (
SELECT
    from_iso8601_timestamp("timestamp") as "timestamp",
    "pool_id",
    "token_amount",
    "dot_amount",
    "jitosol_amount",
    "token_amount_ui",
    "dot_amount_ui",
    "jitosol_amount_ui",
    CASE
        WHEN "pool_id" = 0 THEN 'lcdot_ldot'
        WHEN "pool_id" = 1 THEN 'lcdot_tdot'
        WHEN "pool_id" = 2 THEN 'dot_ldot'
        WHEN "pool_id" = 3 THEN 'dot_tdot'
        WHEN "pool_id" = 4 THEN 'dot_starlay'
        WHEN "pool_id" = 5 THEN 'ldot_starlay'
        WHEN "pool_id" = 6 THEN 'jitosol'
        WHEN "pool_id" = 7 THEN 'jitosol_ldot_lp'
        ELSE '???'
    END as "pool_name"
FROM dune.euphrates.dataset_euphrates_pool_stats_v3
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
            WHEN "pool_id" = 7 THEN 'JITOSOL_DOT_LP'
            ELSE '???'
        END as "token_symbol",
        AVG("dot_amount") as "dot_amount",
        AVG("jitosol_amount") as "jitosol_amount",
        AVG("dot_amount_ui") as "dot_amount_ui",
        AVG("jitosol_amount_ui") as "jitosol_amount_ui",
        AVG("token_amount_ui") as "token_amount_ui"
    FROM pool_stats
    GROUP BY 1, 2, 3
    ORDER BY 1, 2
)

SELECT
    A.*,
    dot_price.price * A.dot_amount_ui + jitosol_price.price * A.jitosol_amount_ui as "total_usd",
    dot_price.price * A.dot_amount_ui as "dot_usd"
FROM daily_pool_stats A
LEFT JOIN query_3989007 as dot_price
    ON A.day = dot_price.day 
    AND dot_price.symbol = 'DOT'
LEFT JOIN query_3989007 as jitosol_price
    ON A.day = jitosol_price.day 
    AND jitosol_price.symbol = 'JITOSOL'
ORDER BY 1, 2
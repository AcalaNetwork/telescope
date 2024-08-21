-- part of a query repo
-- query name: daily_usd_flow
-- query link: https://dune.com/queries/3999276


WITH daily_token_flow AS (
    SELECT
        DATE_TRUNC('day', "timestamp") AS day,
        pool_id,
        pool_name,
        CASE
            WHEN "pool_id" in (0, 1, 2, 3, 4, 5) THEN 'DOT'
            WHEN "pool_id" = 6 THEN 'JITOSOL'
            ELSE '???'
        END as "token_symbol",
        SUM(CASE WHEN type = 'stake' THEN token_amount_ui ELSE token_amount_ui * -1 END) AS token_amount,
        SUM(CASE WHEN type = 'stake' THEN dot_amount_ui ELSE dot_amount_ui * -1 END) AS dot_amount
    FROM query_3988562  /* euphrates tx v2 */
    GROUP BY 1, 2, 3
    ORDER BY 1, 2
),

daily_usd_flow AS (
    SELECT
        *,
        CASE
            WHEN "pool_id" in (0, 1, 2, 3, 4, 5) THEN "price" * "dot_amount"
            WHEN "pool_id" = 6 THEN "price" * "token_amount"
            ELSE 0
        END as "token_usd"
    FROM daily_token_flow A
    JOIN query_3989007 as B  /* daily token price */
    ON A.day = B.day
    AND A.token_symbol = B.symbol
    ORDER BY 1, 2
)

SELECT
    *
FROM daily_usd_flow
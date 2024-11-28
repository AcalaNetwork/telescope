-- part of a query repo
-- query name: euphrates_usd_flow
-- query link: https://dune.com/queries/3999276


WITH weekly_token_flow AS (
    SELECT
        DATE_TRUNC('week', "timestamp") AS day,
        pool_id,
        pool_name,
        -- SUM(CASE WHEN type = 'stake' THEN token_amount_ui ELSE token_amount_ui * -1 END) AS token_amount,
        SUM(CASE WHEN type = 'stake' THEN dot_amount_ui ELSE dot_amount_ui * -1 END) AS dot_amount_ui,
        SUM(CASE WHEN type = 'stake' THEN jitosol_amount_ui ELSE jitosol_amount_ui * -1 END) AS jitosol_amount_ui
    FROM query_3988562  /* euphrates tx v3 */
    GROUP BY 1, 2, 3
    ORDER BY 1, 2
),

weekly_usd_flow AS (
    SELECT
        *,
        dot_price.price * A.dot_amount_ui + jitosol_price.price * A.jitosol_amount_ui as "total_usd"
    FROM weekly_token_flow A
    LEFT JOIN query_3989007 as dot_price
        ON A.day = dot_price.day 
        AND dot_price.symbol = 'DOT'
    LEFT JOIN query_3989007 as jitosol_price
        ON A.day = jitosol_price.day 
        AND jitosol_price.symbol = 'JITOSOL'
    ORDER BY 1, 2
)

SELECT *
FROM weekly_usd_flowly_usd_flow
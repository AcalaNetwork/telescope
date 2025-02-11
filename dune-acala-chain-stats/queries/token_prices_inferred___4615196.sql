-- part of a query repo
-- query name: all_token_prices
-- query link: https://dune.com/queries/4615196


WITH ldot_price AS (
    SELECT 
        A.day AS day, 
        'LDOT' AS symbol,
        (A.price * COALESCE(B.exchange_rate, 0.1)) AS price  -- TODO: index all homa data
    FROM query_3989007 A       -- daily token prices
    LEFT JOIN query_3728405 B  -- homa daily
    ON A.day = B.day_timestamp
    WHERE A.symbol = 'DOT'
),

tdot_lcdot_price AS (
    SELECT 
        day,
        v.symbol,
        price
    FROM query_3989007 A       -- daily token prices
    CROSS JOIN (VALUES ('tDOT'), ('lcDOT')) AS v(symbol)
    WHERE A.symbol = 'DOT'
),

date_range AS (
    SELECT 
        TIMESTAMP '2022-02-09' AS start_date,
        current_date AS end_date
),

all_dates AS (
    SELECT 
        DATE_TRUNC('day', DATE_ADD('day', value, start_date)) AS date
    FROM date_range 
    CROSS JOIN UNNEST(sequence(0, date_diff('day', start_date, end_date))) AS t(value)
),

aca_price AS (
    SELECT
        d.date,
        'ACA' AS symbol,
        COALESCE(
            CASE
                WHEN q.usdc_tvl IS NULL OR q.aca_tvl IS NULL OR q.aca_tvl = 0
                THEN 0.1
                ELSE q.usdc_tvl / q.aca_tvl
            END,
            0.1
        ) AS price
    FROM all_dates d
    LEFT JOIN query_3799539 q ON d.date = q.date
),

all_price_inferred AS (
    SELECT * FROM aca_price
    UNION ALL
    SELECT * FROM ldot_price
    UNION ALL
    SELECT * FROM tdot_lcdot_price
),

all_token_price AS (
    SELECT * FROM all_price_inferred
    UNION ALL
    SELECT * FROM query_3989007  -- daily token prices
)

SELECT *
FROM all_token_price
ORDER BY date DESC
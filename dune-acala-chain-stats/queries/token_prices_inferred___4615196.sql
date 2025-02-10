-- part of a query repo
-- query name: token_prices_inferred
-- query link: https://dune.com/queries/4615196


WITH date_range AS (
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

token_prices_inferred AS (
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
)

SELECT
    *
FROM token_prices_inferred
ORDER BY date DESC
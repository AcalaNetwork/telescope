-- part of a query repo
-- query name: lcdot_tvl
-- query link: https://dune.com/queries/4611011


WITH lcdot_tx_in AS (
    SELECT
        TIMESTAMP '2022-02-09 01:18:06' AS block_time,
        369128 AS block_number,
        'Contributed' AS method,
        0x57c61b9fd60cb88cddb6c5411c6b528ecb6b547eace8b9ac4f6e1983f8269b7e AS block_hash,
        CAST('0x' AS varbinary) AS extrinsic_hash,
        '0x' AS event_id,
        -- '216135952356130231' AS amount_varchar
        '241125041757988063' AS amount_varchar
        
),

lcdot_tx_out AS (
    SELECT
        block_time,
        block_number,
        method,
        block_hash,
        extrinsic_hash,
        event_id,
        CAST(JSON_EXTRACT(data, '$[1]') AS VARCHAR) AS amount_varchar
    FROM acala.events
    WHERE section = 'liquidCrowdloan'
    AND   method = 'Redeemed'
),

lcdot_tx_raw AS (
    SELECT * FROM lcdot_tx_in
    UNION ALL
    SELECT * FROM lcdot_tx_out
),

lcdot_tx_parsed AS (
    SELECT
        *,
        CASE
            WHEN starts_with(amount_varchar, '0x')
            THEN varbinary_to_uint256(FROM_HEX(amount_varchar))
        ELSE CAST(amount_varchar as uint256)
        END AS amount_uint256
    FROM lcdot_tx_raw
),

lcdot_tx AS (
    SELECT
        block_time,
        method,
        CASE
            WHEN method = 'Contributed' THEN amount_uint256 / POWER(10, 10)
            WHEN method = 'Redeemed' THEN amount_uint256 / POWER(10, 10) * -1
        END AS amount,
        block_number,
        extrinsic_hash as tx_hash
    FROM lcdot_tx_parsed
    ORDER BY 1 DESC
),

lcdot_daily AS (
    SELECT
        date_trunc('day', block_time) AS day,
        SUM(amount) AS amount
    FROM lcdot_tx
    GROUP BY 1
    ORDER BY 1 DESC
),

lcdot_cumulative AS (
    SELECT
        day,
        SUM(amount) OVER (ORDER BY day) AS tvl
    FROM lcdot_daily
),

date_range AS (
    SELECT 
        MIN(day) AS start_date,
        MAX(day) AS end_date
    FROM lcdot_cumulative
),

all_dates AS (
    SELECT 
        DATE_TRUNC('day', DATE_ADD('day', value, start_date)) AS day
    FROM date_range 
    CROSS JOIN UNNEST(sequence(0, date_diff('day', start_date, end_date))) AS t(value)
),

historical_values AS (
    SELECT 
        d1.day as ref_date,
        d2.day as data_date,
        d2.tvl,
        ROW_NUMBER() OVER (
            PARTITION BY d1.day
            ORDER BY d2.day DESC
        ) as rn
    FROM all_dates d1
    CROSS JOIN lcdot_cumulative d2
    WHERE d2.day <= d1.day
),

latest_historical AS (
    SELECT 
        ref_date as day,
        tvl as historical_tvl
    FROM historical_values
    WHERE rn = 1
),

daily_tvl_filled AS (
    SELECT 
        f.day,
        COALESCE(d.tvl, h.historical_tvl, 0) AS tvl
    FROM all_dates f
    LEFT JOIN lcdot_cumulative d
        ON f.day = d.day
    LEFT JOIN latest_historical h
        ON f.day = h.day
)

SELECT
  A.day AS day,
  A.tvl,
  A.tvl * B.price AS usd_tvl,
  B.symbol,
  B.price
FROM daily_tvl_filled A
JOIN query_3989007 B  -- daily token prices
ON A.day = B.day
AND B.symbol = 'DOT'
ORDER BY A.day DESC

-- part of a query repo
-- query name: aseed_tvl
-- query link: https://dune.com/queries/4608654


WITH loan_tx_raw AS (
    SELECT
        block_time,
        block_number,
        method,
        block_hash,
        extrinsic_id,
        extrinsic_hash,
        event_id,
        JSON_EXTRACT_SCALAR(data, '$[0]') AS address,
        JSON_EXTRACT(data, '$[1]') AS token_json,
        CAST(JSON_EXTRACT(data, '$[2]') AS VARCHAR) AS amount_varchar
    FROM acala.events
    WHERE section = 'loans'
      AND method = 'PositionUpdated'
),

loan_tx_extracted AS (
    SELECT
        *,
        CASE
          WHEN JSON_EXTRACT_SCALAR(token_json, '$.token') IS NOT NULL THEN 
            CONCAT('{"Token":"', JSON_EXTRACT_SCALAR(token_json, '$.token'), '"}')
          WHEN JSON_EXTRACT_SCALAR(token_json, '$.liquidCrowdloan') IS NOT NULL THEN 
            CONCAT('{"LiquidCrowdloan":"', JSON_EXTRACT_SCALAR(token_json, '$.liquidCrowdloan'), '"}')
          WHEN JSON_EXTRACT_SCALAR(token_json, '$.liquidCroadloan') IS NOT NULL THEN 
            CONCAT('{"LiquidCrowdloan":"', JSON_EXTRACT_SCALAR(token_json, '$.liquidCroadloan'), '"}')
          WHEN JSON_EXTRACT_SCALAR(token_json, '$.foreignAsset') IS NOT NULL THEN 
            CONCAT('{"ForeignAsset":"', JSON_EXTRACT_SCALAR(token_json, '$.foreignAsset'), '"}')
          WHEN JSON_EXTRACT_SCALAR(token_json, '$.erc20') IS NOT NULL THEN 
            CONCAT('{"Erc20":"', JSON_EXTRACT_SCALAR(token_json, '$.erc20'), '"}')
          ELSE '{"StableAssetPoolToken":"0"}'
        END AS token_varchar
    FROM loan_tx_raw
),

loan_tx_parsed AS (
    SELECT
        A.block_time AS timestamp,
        A.block_number,
        A.block_hash,
        A.extrinsic_hash AS tx_hash,
        A.address,
        CASE
          WHEN starts_with(amount_varchar, '0x') THEN
            CASE
              WHEN lower(substr(amount_varchar, 3, 1)) = 'f'
                THEN bytearray_to_int256(
                       from_hex('0x' || lpad(substr(amount_varchar, 3), 64, 'f'))
                     )
              ELSE
                varbinary_to_int256(from_hex(amount_varchar))
            END
          ELSE
            CAST(amount_varchar AS int256)
        END AS amount_int256,
        B.symbol AS token,
        B.decimals AS decimal_value
    FROM loan_tx_extracted A
    LEFT JOIN query_4397191 B  -- acala assets lookup
      ON A.token_varchar = B.asset
),

loan_tx AS (
    SELECT
        D.*,
        D.amount_int256 / POWER(10, D.decimal_value) AS amount
    FROM loan_tx_parsed D
    ORDER BY timestamp DESC
),

loan_daily AS (
    SELECT
        DATE_TRUNC('day', timestamp) AS date,
        token,
        SUM(amount) AS amount
    FROM loan_tx
    GROUP BY 1, 2
),

loan_cumulative AS (
    SELECT
        date,
        token,
        amount,
        SUM(amount) OVER (PARTITION BY token ORDER BY date) AS token_tvl
    FROM loan_daily
),

---------------------------------------------
-- fill in the blank for all tokens X dates
---------------------------------------------
date_range AS (
    SELECT 
        MIN(date) AS start_date,
        MAX(date) AS end_date
    FROM loan_cumulative
),


all_dates AS (
    SELECT DATE_ADD('day', value, start_date) AS date
    FROM date_range
    CROSS JOIN UNNEST(sequence(0, date_diff('day', start_date, end_date))) AS t(value)
),

all_tokens AS (
    SELECT DISTINCT token
    FROM loan_cumulative
),

full_date_token_combination AS (
    SELECT d.date, t.token
    FROM all_dates d
    CROSS JOIN all_tokens t
),

historical_values AS (
    SELECT 
        f.date AS ref_date,
        c.date AS data_date,
        c.token,
        c.token_tvl,
        ROW_NUMBER() OVER (PARTITION BY f.date, c.token ORDER BY c.date DESC) AS rn
    FROM full_date_token_combination f
    LEFT JOIN loan_cumulative c
      ON c.date <= f.date AND c.token = f.token
),

latest_historical AS (
    SELECT ref_date AS date, token, token_tvl
    FROM historical_values
    WHERE rn = 1
),

loan_full AS (
    SELECT 
        f.date,
        f.token,
        COALESCE(c.token_tvl, h.token_tvl, 0) AS token_tvl
    FROM full_date_token_combination f
    LEFT JOIN loan_cumulative c 
      ON f.date = c.date AND f.token = c.token
    LEFT JOIN latest_historical h 
      ON f.date = h.date AND f.token = h.token
),

loan_with_usd AS (
    SELECT
        A.date,
        A.token,
        A.token_tvl,
        A.token_tvl * B.price AS usd_tvl
    FROM loan_full A
    LEFT JOIN query_4615196 B
      ON A.date = B.date
      AND A.token = B.symbol
)

SELECT 
    date,
    token,
    token_tvl,
    usd_tvl
FROM loan_with_usd
ORDER BY date DESC, token;
y_3989007 (DOT price),
-- for token USDC we use a fixed price of 1,
-- and for token ACA we join query_4615196 (ACA price) as per the referenced query.
--------------------------------------------------------------------------------

final_with_prices AS (
    SELECT
        f.date,
        f.token,
        f.token_tvl,
        CASE 
          WHEN f.token IN ('tDOT', 'lcDOT', 'LDOT', 'DOT') THEN f.token_tvl * dot_prices.price
          WHEN f.token = 'USDC' THEN f.token_tvl * 1
          WHEN f.token = 'ACA' THEN f.token_tvl * aca_prices.price
          ELSE 0
        END AS usd_tvl
    FROM final f
    LEFT JOIN query_3989007 dot_prices 
      ON f.date = dot_prices.day AND dot_prices.symbol = 'DOT'
    LEFT JOIN query_4615196 aca_prices 
      ON f.date = aca_prices.date AND aca_prices.symbol = 'ACA'
)

SELECT 
    date,
    token,
    token_tvl,
    usd_tvl
FROM final_with_prices
ORDER BY date DESC, token;

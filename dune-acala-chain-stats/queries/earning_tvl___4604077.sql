-- part of a query repo
-- query name: earning_tvl
-- query link: https://dune.com/queries/4604077


WITH staking_tx_raw AS (
    SELECT
        block_time,
        block_number,
        method,
        block_hash,
        extrinsic_id,
        extrinsic_hash,
        event_id,
        JSON_EXTRACT_SCALAR(data, '$[0]') AS address,
        CAST(JSON_EXTRACT(data, '$[1]') AS VARCHAR) AS amount_varchar
    FROM acala.events
    WHERE section = 'earning'
    AND   (method = 'Bonded' OR method = 'Withdrawn')
),

staking_tx_parsed AS (
    SELECT 
        *,
        CASE
            WHEN starts_with(amount_varchar, '0x') 
            THEN varbinary_to_uint256(FROM_HEX(amount_varchar))
            ELSE CAST(amount_varchar as uint256)
        END AS amount_uint256
    FROM staking_tx_raw
),

staking_tx_ui AS (
    SELECT
        D.block_time,
        D.address,
    D.method,
    CASE
      WHEN method = 'Bonded' THEN amount_uint256 / POWER(10, 12)
      WHEN method = 'Withdrawn' THEN -amount_uint256 / POWER(10, 12)
    END AS amount,
    D.block_number,
    D.extrinsic_hash as tx_hash
    FROM staking_tx_parsed D
    ORDER BY 1 DESC
),

staking_daily AS (
    SELECT
        date_trunc('day', block_time) AS day,
        SUM(amount) AS amount
    FROM staking_tx_ui
    GROUP BY 1
),

staking_cumulative AS (
    SELECT
        day,
        SUM(amount) OVER (ORDER BY day) AS tvl
    FROM staking_daily
)

SELECT
    A.day,
    A.tvl,
    B.symbol,
    B.price,
    A.tvl * b.price AS usd_tvl
FROM staking_cumulative A
JOIN query_4615196 B  -- token prices inferred
ON A.day = B.date
AND B.symbol = 'ACA'
ORDER BY 1 ASC
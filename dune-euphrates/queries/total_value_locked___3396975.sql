-- part of a query repo
-- query name: total_value_locked
-- query link: https://dune.com/queries/3396975


SELECT
    dot_tvl."day_timestamp",
    dot_tvl."lcdot_ldot" * lastPrice."dot" AS lcdot_ldot,
    dot_tvl."lcdot_tdot" * lastPrice."dot" AS lcdot_tdot,
    dot_tvl."dot_ldot" * lastPrice."dot" AS dot_ldot,
    dot_tvl."dot_tdot" * lastPrice."dot" AS dot_tdot,
    dot_tvl."dot_starlay" * lastPrice."dot" AS dot_starlay,
    dot_tvl."ldot_starlay" * lastPrice."dot" AS ldot_starlay,

    dot_tvl."lcdot" * lastPrice."dot" AS lcdot,
    dot_tvl."dot" * lastPrice."dot" AS dot,
    dot_tvl."ldot" * lastPrice."dot" AS ldot,

    dot_tvl."total" * lastPrice."dot" AS total
FROM query_3393781 AS dot_tvl
CROSS JOIN (
    SELECT price AS dot
    FROM prices.usd
    WHERE symbol = 'DOT'
    ORDER BY minute DESC
    LIMIT 1
) AS lastPrice
ORDER BY dot_tvl."day_timestamp" ASC
LIMIT 1000
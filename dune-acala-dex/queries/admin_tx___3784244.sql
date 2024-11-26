-- part of a query repo
-- query name: admin_tx
-- query link: https://dune.com/queries/3784244



SELECT
    CAST('2022-09-09 16:35:24' AS timestamp) as block_time,
    1824006 as block_number,
    'DOT' as token0,
    'lcDOT' as token1,
    CAST(66150.33536632179 as DOUBLE) as net_amount0,
    CAST(-123851.06801624346 as DOUBLE) as net_amount1
UNION
SELECT
    CAST('2022-09-09 16:35:24' AS timestamp) as block_time,
    1824006 as block_number,
    'AUSD' as token0,
    'lcDOT' as token1,
    CAST(-7686363.05765165 as DOUBLE) as net_amount0,
    CAST(146791.8226388255 as DOUBLE) as net_amount1
UNION
SELECT
    CAST('2022-09-09 16:35:24' AS timestamp) as block_time,
    1824006 as block_number,
    'AUSD' as token0,
    'LDOT' as token1,
    CAST(-3077826.0616341555 as DOUBLE) as net_amount0,
    CAST(570163.9324303765 as DOUBLE) as net_amount1
UNION
SELECT
    CAST('2022-09-09 16:35:24' AS timestamp) as block_time,
    1824006 as block_number,
    'AUSD' as token0,
    'IBTC' as token1,
    CAST(-13721002.917952676 as DOUBLE) as net_amount0,
    CAST(2.51345675 as DOUBLE) as net_amount1
UNION
SELECT
    CAST('2022-09-09 16:35:24' AS timestamp) as block_time,
    1824006 as block_number,
    'AUSD' as token0,
    'INTR' as token1,
    CAST(-1107986.6931162149 as DOUBLE) as net_amount0,
    CAST(999285.1400314877 as DOUBLE) as net_amount1
UNION
SELECT
    CAST('2022-09-09 16:35:24' AS timestamp) as block_time,
    1824006 as block_number,
    'ACA' as token0,
    'AUSD' as token1,
    CAST(2851872.756224419 as DOUBLE) as net_amount0,
    CAST(-8138304.374647936 as DOUBLE) as net_amount1

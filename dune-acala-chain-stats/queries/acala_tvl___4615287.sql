-- part of a query repo
-- query name: acala_tvl
-- query link: https://dune.com/queries/4615287


WITH dex_tvl AS (
    SELECT 
        date AS day,
        SUM(usd_tvl) AS usd_tvl
    FROM dune.euphrates.result_dex_pool_tvl
    GROUP BY 1
),

euphrates_tvl AS (
    SELECT 
        day AS day,
        SUM(total_usd) AS usd_tvl
    FROM query_3988572
    GROUP BY 1
),

aseed_tvl AS (
    SELECT 
        date AS day,
        SUM(usd_tvl) AS usd_tvl
    FROM query_4608654
    GROUP BY 1
),

acala_tvl AS (
    SELECT A.day, A.usd_tvl, 'aca staking' AS app FROM query_4604077 A -- earning
    UNION ALL
    SELECT B.day, B.usd_tvl, 'lcdot' AS app FROM query_4611011 B -- lcdot
    UNION ALL
    SELECT C.day, C.usd_tvl, 'dex' AS app FROM dex_tvl C
    UNION ALL
    SELECT D.day, D.usd_tvl, 'euphrates' AS app FROM euphrates_tvl D
    UNION ALL
    SELECT E.day, E.usd_tvl, 'aseed' AS app FROM aseed_tvl E
    UNION ALL
    SELECT day_timestamp as day, F.usd_tvl, 'homa' AS app FROM query_3728405 F
)

SELECT * FROM acala_tvl
ORDER BY 1, 2 DESC
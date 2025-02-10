-- part of a query repo
-- query name: acala_tvl
-- query link: https://dune.com/queries/4615287


WITH dex_tvl AS (
    SELECT 
        date AS day,
        SUM(usd_tvl) AS usd_tvl
    FROM query_3782346
    GROUP BY 1
),

euphrates_tvl AS (
    SELECT 
        day AS day,
        SUM(total_usd) AS usd_tvl
    FROM query_3988572
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
)

SELECT * FROM acala_tvl
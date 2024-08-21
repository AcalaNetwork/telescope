-- part of a query repo
-- query name: user_total_staked_dot_distribution
-- query link: https://dune.com/queries/3397041


WITH total_staked_distribution AS (
    SELECT
        COUNT(*) as total_users,
        SUM(CASE WHEN total_staked_dot < 1000 THEN 1 ELSE 0 END) as "<1k",
        SUM(CASE WHEN total_staked_dot BETWEEN 1000 AND 10000 THEN 1 ELSE 0 END) as "1k-10k",
        SUM(CASE WHEN total_staked_dot > 10000 THEN 1 ELSE 0 END) as ">10k"
    FROM query_3397040  -- total_user_staked
)

-- transpose the above table
SELECT 
    '<1k' as total_staked_dot, 
    "<1k" as count, 
    "<1k" * 100.0 / total_users as percentage
FROM total_staked_distribution

UNION ALL

SELECT 
    '1k-10k' as total_staked_dot, 
    "1k-10k" as count, 
    "1k-10k" * 100.0 / total_users as percentage
FROM total_staked_distribution

UNION ALL

SELECT 
    '>10k' as total_staked_dot, 
    ">10k" as count, 
    ">10k" * 100.0 / total_users as percentage
FROM total_staked_distribution;

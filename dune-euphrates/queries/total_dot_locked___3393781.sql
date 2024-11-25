-- part of a query repo
-- query name: total_dot_locked
-- query link: https://dune.com/queries/3393781


WITH daily_staked AS (
    SELECT
        DATE_TRUNC('day', "timestamp") AS day,
        pool_id,
        pool_name,
        SUM(CASE WHEN type = 'stake' THEN dot_amount_ui ELSE dot_amount_ui * -1 END) AS dot_staked
    FROM query_3988562  /* euphrates tx v3 */
    GROUP BY 1, 2, 3
    ORDER BY 1, 2
),

all_pools AS (
    SELECT DISTINCT 
        day,
        pool_id,
        pool_name
    FROM
        (SELECT DISTINCT day FROM daily_staked) AS days,
        (SELECT DISTINCT pool_id, pool_name FROM daily_staked) AS pools
),

/* need to fill all the blanks to make sure every pool has a record every day */
/* otherwise cumulatvie sum will entounter null for some pools and return bad result */
daily_staked_filled AS (
    SELECT
        ap.day,
        ap.pool_id,
        ap.pool_name,
        COALESCE(ds.dot_staked, 0) AS dot_staked
    FROM 
        all_pools ap
    LEFT JOIN 
        daily_staked ds
        ON ap.day = ds.day AND ap.pool_id = ds.pool_id AND ap.pool_name = ds.pool_name
    ORDER BY ap.pool_id, ap.day
)

SELECT
    day,
    pool_id,
    pool_name,
    dot_staked,
    SUM(CASE WHEN dot_staked > 0 THEN dot_staked ELSE 0 END) 
        OVER (PARTITION BY pool_id ORDER BY day ASC) AS cumulative_dot_staked
FROM daily_staked_filled
ORDER BY pool_id, day;


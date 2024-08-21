-- part of a query repo
-- query name: daily_dot_locked
-- query link: https://dune.com/queries/3396989


SELECT
    eds."day_timestamp",
    eds."net_stake" / 1e10 AS "daily_total",
    eds."total_stake" / 1e10 AS "daily_stake",
    eds."total_unstake" / 1e10 AS "daily_unstake",
    (eds."stake_pool_0" - eds."unstake_pool_0") / 1e10 AS "lcdot_ldot",
    (eds."stake_pool_1" - eds."unstake_pool_1") / 1e10 AS "lcdot_tdot",
    (eds."stake_pool_2" - eds."unstake_pool_2") / 1e10 AS "dot_ldot",
    (eds."stake_pool_3" - eds."unstake_pool_3") / 1e10 AS "dot_tdot",
    (eds."stake_pool_4" - eds."unstake_pool_4") / 1e10 AS "dot_starlay",
    (eds."stake_pool_5" - eds."unstake_pool_5") / 1e10 AS "ldot_starlay",
    SUM(eds."net_stake") OVER (ORDER BY eds."day_timestamp" ASC) / 1e10 AS "dot_tvl"
FROM dune.euphrates.result_euphrates_daily_stake AS eds
ORDER BY eds."day_timestamp" ASC
LIMIT 1000
-- part of a query repo
-- query name: euphrates_stake
-- query link: https://dune.com/queries/3393722



SELECT
    from_iso8601_timestamp("timestamp") as "timestamp",
    "pool_id",
    "amount",
    "amount" / 1e10 as "dot_amount",
    "from",
    "from" as "user_addr",
    "type",
    "tx_hash",
    "block_number",
    CASE
        WHEN "pool_id" = 0 THEN 'lcdot_ldot'
        WHEN "pool_id" = 1 THEN 'lcdot_tdot'
        WHEN "pool_id" = 2 THEN 'dot_ldot'
        WHEN "pool_id" = 3 THEN 'dot_tdot'
        WHEN "pool_id" = 4 THEN 'dot_starlay'
        WHEN "pool_id" = 5 THEN 'ldot_starlay'
        WHEN "pool_id" = 7 THEN 'jitosol'
        ELSE '???'
    END as "pool_name",
    CASE 
        WHEN "type" = 1 THEN 'stake' ELSE 'unstake'
    END as "action"
FROM dune.euphrates.dataset_euphrates_txs
ORDER by 1
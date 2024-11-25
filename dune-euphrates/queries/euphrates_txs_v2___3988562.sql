-- part of a query repo
-- query name: euphrates_txs_v3
-- query link: https://dune.com/queries/3988562



SELECT
    from_iso8601_timestamp("timestamp") as "timestamp",
    "block_number",
    "type",
    "pool_id",
    CASE
        WHEN "pool_id" = 0 THEN 'lcdot_ldot'
        WHEN "pool_id" = 1 THEN 'lcdot_tdot'
        WHEN "pool_id" = 2 THEN 'dot_ldot'
        WHEN "pool_id" = 3 THEN 'dot_tdot'
        WHEN "pool_id" = 4 THEN 'dot_starlay'
        WHEN "pool_id" = 5 THEN 'ldot_starlay'
        WHEN "pool_id" = 6 THEN 'jitosol'
        WHEN "pool_id" = 7 THEN 'jitosol_ldot_lp'
        ELSE '???'
    END as "pool_name",
    "share_amount",
    "token_amount",
    "dot_amount",
    "jitosol_amount",
    "token_amount_ui",
    "dot_amount_ui",
    "jitosol_amount_ui",
    "recipient",
    "tx_hash"
FROM dune.euphrates.dataset_euphrates_txs_v3
ORDER by 1 DESC

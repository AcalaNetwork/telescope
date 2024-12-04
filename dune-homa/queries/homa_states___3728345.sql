-- part of a query repo
-- query name: homa_states
-- query link: https://dune.com/queries/3728345


SELECT 
    from_iso8601_timestamp("timestamp") as "timestamp",
    total_bonded,
    liquid_issuance,
    total_bonded / 1e10 as "total_dot",
    liquid_issuance / 1e10 as "total_ldot",
    exchange_rate / 1e10 as "exchange_rate",
    block_number,
    block_hash
FROM dune.euphrates.dataset_acala_homa
order by block_number ASC
-- part of a query repo
-- query name: homa_tx
-- query link: https://dune.com/queries/3698962


SELECT 
    block_time,
    block_number,
    data_decoded,
    data,
    JSON_VALUE(E.data, 'strict $[0]') as account,
    JSON_VALUE(E.data, 'strict $[1]') as dot_staked,
    JSON_VALUE(E.data, 'strict $[2]') as ldot_minted
FROM acala.events E
WHERE section = 'homa'
AND method = 'Minted'
order by block_number desc
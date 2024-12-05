-- part of a query repo
-- query name: daily_token_prices
-- query link: https://dune.com/queries/3989007


SELECT
    date_trunc('day', minute) as day,
    symbol,
    avg(price) as price 
FROM prices.usd
WHERE 
    symbol in ('DOT', 'JITOSOL', 'USDC')
    AND date_trunc('day', minute) BETWEEN TIMESTAMP '2022-02-09' AND current_date
GROUP BY 1, 2
ORDER BY 1, 2;
-- part of a query repo
-- query name: dex_pool_names
-- query link: https://dune.com/queries/4740395


-- derived from query 3782346

SELECT * FROM (
    VALUES 
        ('ACA/Nemo'),
        ('LDOT/JITOSOL'),
        ('DOT/UNQ'),
        ('AUSD/LDOT'),
        ('ACA/USDC'),
        ('DOT/LOTY'),
        ('DOT/lcDOT'),
        ('AUSD/lcDOT'),
        ('DOT/LDOT'),
        ('USDT/LOTY'),
        ('ACA/AUSD'),
        ('AUSD/INTR'),
        ('AUSD/IBTC')
) AS pools(pool_name);
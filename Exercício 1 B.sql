WITH VendasDiarias AS (
    SELECT
        COD_VENDEDOR,
        DATA,
        SUM(QUANTIDADE) AS TotalVendas
    FROM vendas
    WHERE COD_PRODUTO = 1 AND DATA BETWEEN '2023-01-01' AND '2023-01-03'
    GROUP BY COD_VENDEDOR, DATA
),
VendasComparadas AS (
    SELECT
        COD_VENDEDOR,
        DATA,
        TotalVendas,
        LAG(TotalVendas) OVER (PARTITION BY COD_VENDEDOR ORDER BY DATA) AS VendasDiaAnterior
    FROM VendasDiarias
)
SELECT DISTINCT 
    COD_VENDEDOR
FROM VendasComparadas
GROUP BY COD_VENDEDOR
HAVING COUNT(CASE WHEN TotalVendas <= VendasDiaAnterior OR VendasDiaAnterior IS NULL THEN 1 END) = 1

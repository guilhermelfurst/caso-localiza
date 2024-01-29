WITH VendasPorVendedor AS (
    SELECT 
        v.COD_VENDEDOR, 
        v.COD_LOJA,
        v.COD_PRODUTO,
        SUM(v.QUANTIDADE) as TotalVendas
    FROM vendas v
    WHERE v.DATA BETWEEN '2023-01-01' AND '2023-12-31'
    GROUP BY v.COD_VENDEDOR, v.COD_LOJA, v.COD_PRODUTO
),
MediaVendasLoja AS (
    SELECT 
        vv.COD_LOJA,
        vv.COD_PRODUTO,
        AVG(vv.TotalVendas) as MediaVendas
    FROM VendasPorVendedor vv
    GROUP BY vv.COD_LOJA, vv.COD_PRODUTO
),
VendedoresQualificados1 AS (
    SELECT 
        vp.COD_VENDEDOR
    FROM VendasPorVendedor vp
    JOIN MediaVendasLoja mvl ON vp.COD_LOJA = mvl.COD_LOJA AND vp.COD_PRODUTO = mvl.COD_PRODUTO
    WHERE vp.COD_PRODUTO = 1 AND vp.TotalVendas > mvl.MediaVendas
),
LojasComMaisDe1000Vendas AS (
    SELECT 
        v.COD_LOJA
    FROM vendas v
    WHERE v.COD_PRODUTO = 2 AND v.DATA BETWEEN '2023-01-01' AND '2023-12-31'
    GROUP BY v.COD_LOJA
    HAVING SUM(v.QUANTIDADE) > 1000
),
MediaVendasLojasCom1000 AS (
    SELECT 
        AVG(vv.TotalVendas) as MediaVendas
    FROM VendasPorVendedor vv
    JOIN LojasComMaisDe1000Vendas l ON vv.COD_LOJA = l.COD_LOJA
    WHERE vv.COD_PRODUTO = 2
),
VendedoresQualificados2 AS (
    SELECT 
        vp.COD_VENDEDOR
    FROM VendasPorVendedor vp
    CROSS JOIN MediaVendasLojasCom1000 mv1000
    WHERE vp.COD_PRODUTO = 2 AND vp.TotalVendas > mv1000.MediaVendas
)
SELECT 
    v1.COD_VENDEDOR
FROM VendedoresQualificados1 v1
JOIN VendedoresQualificados2 v2 ON v1.COD_VENDEDOR = v2.COD_VENDEDOR

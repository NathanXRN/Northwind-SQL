WITH TOP_10_Produtos AS(
    SELECT
        p.product_name,
        SUM(os.unity_price * os.quantity * (1 - os.discount)) AS Vendas_Totais
    FROM 
        products p
    INNER JOIN
        order_details os
    ON 
        os.product_id = p.product_id
    GROUP BY 
        p.product_name
)
SELECT
    product_name
    Vendas_Totais
FROM
    TOP_10_Produtos
ORDER BY
    Vendas_Totais DESC
LIMIT 10;
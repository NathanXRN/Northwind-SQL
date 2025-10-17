SELECT
    c.company_namy,
    SUM(os.unit_price * os.quantity * (1 - os.discount)) AS Valor_Total,
    NTILE(5) OVER (ORDER BY SUM(os.unit_price * os.quantity * (1 - os.discount)) DESC) AS numero_grupo
FROM
    customers c
INNER JOIN
    orders o
ON
    c.customer_id = o.customer_id
INNER JOIN
    order_details os
ON
    os.order_id = o.order_id
GROUP BY c.company_name
ORDER BY Valor_Total DESC;
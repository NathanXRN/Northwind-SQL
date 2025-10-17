SELECT
    c.company_name,
    SUM(os.unit_price * os.quantity * (1 - os.discount)) AS Valor_Total
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

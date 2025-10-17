SELECT
    c.company_name,
    SUM(os.unit_price * os.quantity * (1 - os.discount)) AS Pagamentos
FROM
    customers c
INNER JOIN
    orders o 
ON
    o.customer_id = c.customer_id
INNER JOIN
    order_details os
ON
    os.order_id = o.order_id 
WHERE
    LOWER(c.country) = 'uk'
GROUP BY
    c.company_name
HAVING SUM(os.unit_price * os.quantity * (1 - os.discount)) > 1000
ORDER BY Pagamentos DESC;
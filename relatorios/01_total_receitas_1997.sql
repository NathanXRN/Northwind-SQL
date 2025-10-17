SELECT 
    SUM(os.unit_price * os.quantity * (1 - discount)) AS total_receitas_1997
FROM order_details os 
INNER JOIN(
    SELECT order_id
    FROM orders 
    WHERE DATE_PART('year', order_date) = 1997
) AS o
ON 
    o.order_id = os.order_id;
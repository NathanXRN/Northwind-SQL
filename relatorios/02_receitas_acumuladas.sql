WITH ReceitasMensais AS(
    SELECT
        DATE_PART('year', order_date) AS Ano,
        DATE_PART('month', order_date) AS Mes,
        SUM(os.unit_price * os.quantity * (1 - discount)) AS Receita_Mensal
    FROM 
        order_details os
    INNER JOIN
        orders o
    ON
        o.order_id = os.order_id
    GROUP BY 
        DATE_PART('year', order_date),
        DATE_PART('month', order_date) 
),
ReceitasAcumuladas AS (
    SELECT 
        Ano,
        Mes,
        Receita_Mensal,
        SUM(Receita_Mensal) OVER (PARTITION BY Ano ORDER BY Mes) AS ReceitaYTD,
    FROM
        Receitas Mensais
)
SELECT 
    Ano,
    Mes,
    Receita_Mensal,
    Receita_Mensal - LAG(Receita_Mensal) OVER (PARTITION BY Ano ORDER BY Mes) AS DiferencaMensal,
    ReceitaYTD,
    (Receita_Mensal - LAG(Receita_Mensal) OVER (PARTITION BY Ano ORDER BY Mes)) / LAG(Receita_Mensal) OVER (PARTITION BY Ano ORDER BY Mes) * 100 AS PercentualEvolucaoMensal
FROM
    ReceitasAcumuladas
ORDER BY 
    Ano, Mes;
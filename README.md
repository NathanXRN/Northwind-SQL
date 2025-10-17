# Relatórios Avançados em SQL Northinwd

## Objetivo

Este repositório reúne relatórios avançados desenvolvidos em SQL, criados para oferecer análises aplicáveis a empresas de qualquer porte.
Por meio desses relatórios, é possível extrair insights valiosos que apoiam a tomada de decisões estratégicas e operacionais.

1. **Análise de Receita**

    * Qual foi o total de receitas no ano de 1997?

    ```sql
    SELECT 
        SUM(os.unit_price * os.quantity * (1 - discount)) AS total_receitas_1997
    FROM order_details os 
    INNER JOIN(
        SELECT order_id
        FROM orders 
        WHERE DATE_PART('year', order_date) = 1997
    ) AS o
    ON o.order_id = os.order_id;
    ```
    * Faça uma análise de crescimento mensal e o cáculo de YTD

    ```sql
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
    ```
2. **Segmentação de Clientes**

    * Qual é o valor que cada cliente já pagou até agora?
    ```sql
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
    ```

    * Separe os clientes em 5 grupos de acordo com o valor pago por cliente

    ```sql
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
    ```

    * Agora somente os clientes que estão nos grupos 3, 4 e 5 para que seja feita uma análise de Marketing especial com eles

    ```sql
    WITH clientes_marketings AS (
        SELECT
            c.company_name,
            SUM(os.unit_price * os.quantity * (1 - os.discount)) AS Valor_Total,
            NTILE(5) OVER (ORDER BY SUM(os.unit_price * os.quantity * (1 - os.discount)) DESC) AS numero_grupo
        FROM customers c
        INNER JOIN
            orders o
        ON
            c.customer_id = o.customer_id
        INNER JOIN 
            order_details os
        ON
            os.order_id = o.order_id
        GROUP BY c.company_name
        ORDER BY Valor_Total DESC
    )
        SELECT *
        FROM clientes_marketings
        WHERE numero_grupo in (3,4,5);
    ```

3. **Top 10 Produtos Mais Vendidos**

    * Identificar os 10 produtos mais vendidos.
    ```sql
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
    ```

4. **Clientes do Reino Unido que pagaram Mais de 1000 Dólares**

    * Quais clientes do Reino Unido pagaram mais de 1000 dólares?

    ```sql
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
    ```

## Contexto 

O banco de dados Northwind simula um sistema ERP completo, com informações sobre clientes, pedidos, estoque, compras, fornecedores, entregas, funcionários e contabilidade.

O conjunto de dados Northwind inclui dados de amostra para o seguinte:

* **Fornecedores:** Fornecedores e vendedores da Northwind
* **Clientes:** Clientes que compram produtos da Northwind
* **Funcionários:** Detalhes dos funcionários da Northwind Traders
* **Produtos:** Informações do produto
* **Transportadoras:** Os detalhes dos transportadores que enviam os produtos dos comerciantes para os clientes finais
* **Pedidos e Detalhes do Pedido:** Transações de pedidos de vendas ocorrendo entre os clientes e a empresa

O banco de dados `Northwind` inclui 14 tabelas e os relacionamentos entre as tabelas são mostrados no seguinte diagrama de relacionamento de entidades.

## Configuração Inicial

Utilize o arquivo SQL fornecido, `nortwhind.sql`, para popular o seu banco de dados.

### Com Docker e Docker Compose

**Pré-requisito**: Instale o Docker e Docker Compose

* [Começar com Docker](https://www.docker.com/get-started)
* [Instalar Docker Compose](https://docs.docker.com/compose/install/)

### Passos para configuração com Docker:

1. **Iniciar o Docker Compose** Execute o comando abaixo para subir os serviços:

    ```
    docker-compose up
    ```
    Aguarde as mensagens de configuração, como:

     ```csharp
    Creating network "northwind_psql_db" with driver "bridge"
    Creating volume "northwind_psql_db" with default driver
    Creating volume "northwind_psql_pgadmin" with default driver
    Creating pgadmin ... done
    Creating db      ... done
    ```

2. **Conectar o PgAdmin** Acesse o PgAdmin pelo URL: [http://localhost:5050](http://localhost:5050), com a senha `postgres`.

Configure um novo servidor no PgAdmin:

    * **Aba General**:
        * Nome: db
    * **Aba Connection**:
        * Nome do host: db
        * Nome de usuário: postgres
        * Senha: postgres Em seguida, selecione o banco de dados "northwind".

3. **Parar o Docker Compose** Pare o servidor iniciado pelo comando `docker-compose up` usando Ctrl-C e remova os contêineres com:
    
    ```
    docker-compose down
    ```
    
4. **Arquivos e Persistência** Suas modificações nos bancos de dados Postgres serão persistidas no volume Docker `postgresql_data` e podem ser recuperadas reiniciando o Docker Compose com `docker-compose up`. Para deletar os dados do banco, execute:
    
    ```
    docker-compose down -v
    ```
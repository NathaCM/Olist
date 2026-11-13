--quantidade ded pedidos por status
SELECT order_status, COUNT(*) qtd_pedidos
FROM orders
GROUP BY order_status
ORDER BY qtd_pedidos DESC;


--Intervalo da primeira a ultima compra, e o total de pedidos nesse intervalo
SELECT MIN(order_purchase_timestamp) AS primeira_compra,
MAX(order_purchase_timestamp) AS ultima_compra,
COUNT(*) AS total_pedidos
FROM orders;


--Pedidos_entregues, Itens_vendidos, Soma_total_compras Soma_total_frete, Faturamento
SELECT 
    COUNT(DISTINCT t1.order_id) AS Pedidos_entregues,
    COUNT(*) AS Itens_vendidos,
    ROUND(SUM(price), 2)AS Soma_total_compras,
    ROUND(SUM(freight_value), 2) Soma_total_frete,
    ROUND(SUM(price + freight_value), 2) AS  total_com_frete
FROM order_items AS t1

INNER JOIN orders AS t2
ON t1.order_id = t2.order_id
WHERE order_status = 'delivered'


---vendas por mes e ticket medio
SELECT  
    COUNT(DISTINCT t1.order_id) AS pedidos_entregues,
    substr(order_purchase_timestamp, 1 , 7 ) AS data_compra,
    ROUND(SUM(price), 2) AS preco_total, 
    ROUND(SUM(freight_value), 2) AS  total_frete,
    ROUND(SUM(price + freight_value) / COUNT(DISTINCT t1.order_id) , 2) AS Ticket_medio
FROM orders AS t1

LEFT JOIN order_items AS t2
ON t1.order_id = t2.order_id
WHERE t1.order_status = 'delivered'
GROUP BY data_compra
ORDER BY data_compra ASC;


-- pedidos entregues por mês de compra;
WITH RECURSIVE calendario(mes) AS (

    SELECT DATE(
        MIN(substr(order_purchase_timestamp, 1, 7)) || '-01'  )
    FROM orders

    UNION ALL

    SELECT DATE(mes, '+1 month')
    FROM calendario
    WHERE mes < (
        SELECT DATE(
            MAX(substr(order_purchase_timestamp, 1, 7)) || '-01' )
        FROM orders
    )
),
entregues AS (
SELECT 
    substr(order_purchase_timestamp,1 , 7) AS data_compra,
    COUNT(order_id) AS pedidos_entregues

FROM orders
WHERE order_status = 'delivered'


GROUP BY substr(order_purchase_timestamp,1 , 7)
ORDER BY substr(order_purchase_timestamp,1 , 7) ASC
)
SELECT  
    strftime('%Y-%m', mes) AS data,
   
    CASE 
        WHEN pedidos_entregues IS NULL THEN 0
        ELSE pedidos_entregues

        END AS pedidos_entregues
    
FROM calendario AS t1

LEFT JOIN entregues AS t2
    ON data_compra = strftime('%Y-%m', mes)
    
-- pedidos realizados
WITH RECURSIVE calendario(mes) AS (

    SELECT DATE(
        MIN(substr(order_purchase_timestamp, 1, 7)) || '-01'  )
    FROM orders

    UNION ALL

    SELECT DATE(mes, '+1 month')
    FROM calendario
    WHERE mes < (
        SELECT DATE(
            MAX(substr(order_purchase_timestamp, 1, 7)) || '-01' )
        FROM orders
    )
),
entregues AS (
SELECT 
    substr(order_purchase_timestamp,1 , 7) AS data_compra,
    COUNT(order_id) AS pedidos_realizados

FROM orders


GROUP BY substr(order_purchase_timestamp,1 , 7)
ORDER BY substr(order_purchase_timestamp,1 , 7) ASC
)
SELECT  
    strftime('%Y-%m', mes) AS data,
   
    CASE 
        WHEN pedidos_realizados IS NULL THEN 0
        ELSE pedidos_realizados

        END AS pedidos_realizados
    
FROM calendario AS t1

LEFT JOIN entregues AS t2
    ON data_compra = strftime('%Y-%m', mes)
    
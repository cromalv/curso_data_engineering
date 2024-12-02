--comprueba si la creacion del pedido es posterior a la entrega, lo que 
--es un sin sentido
--si pasa, you re crazy bro
SELECT *
FROM {{ ref('fact_sales_orders') }}
WHERE delivered_at_utc < created_at_utcQ

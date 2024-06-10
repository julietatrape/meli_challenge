-- Listar los usuarios que cumplan años el día de hoy cuya cantidad de 
-- ventas realizadas en enero 2020 sea superior a 1500.
SELECT 
	c.customer_id
    ,c.name
    ,c.surname
FROM customers AS c
	LEFT JOIN orders AS o
		ON c.customer_id = o.customer_id
WHERE 1=1
	AND c.is_seller
	AND c.date_of_birth = CURRENT_DATE
	AND EXTRACT(YEAR FROM o.order_date) = 2020
	AND EXTRACT(MONTH FROM o.order_date) = 1
GROUP BY 1,2,3
HAVING COUNT(*) > 1500;


-- Por cada mes del 2020, se solicita el top 5 de usuarios que más 
-- vendieron($) en la categoría Celulares. Se requiere el mes y año 
-- de análisis, nombre y apellido del vendedor, cantidad de ventas 
-- realizadas, cantidad de productos vendidos y el monto total transaccionado.
WITH sells AS (
	SELECT 
		EXTRACT(MONTH FROM o.order_date) AS month
        ,EXTRACT(YEAR FROM o.order_date) AS year
        ,c.name
		,c.surname
		,COUNT(*) AS total_sells
		,SUM(i.price) AS total_earn
	FROM customers c
		LEFT JOIN orders o
			ON c.customer_id = o.customer_id
		LEFT JOIN items i
			ON o.item_id = i.item_id
		LEFT JOIN categories ct
			ON i.category_id = ct.category_id
	WHERE 1=1
		AND c.is_seller
		AND EXTRACT(YEAR FROM o.order_date) = 2020
		AND ct.name = 'Celulares'
	GROUP BY 1,2,3,4)

	,sells_refined AS (
	SELECT 
		month
        ,year
        ,name
		,surname
		,total_sells
        -- La cantidad de productos vendidos es igual a la cantidad de ventas realizadas
        -- ya que el modelo de la base de datos no considera carritos de compras
		,total_sells as total_products 
		,total_earn
        ,ROW_NUMBER() OVER(PARTITION BY month ORDER BY total_earn DESC) row_num
	FROM sells)

SELECT *
FROM sells_refined
WHERE row_num <= 5
ORDER BY month, row_num;



-- Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día.
-- Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item,
-- vamos a tener únicamente el último estado informado por la PK definida. (Se puede
-- resolver a través de StoredProcedure)

CREATE OR REPLACE PROCEDURE load_price_control (start_date DATE, end_date DATE)
LANGUAGE plpgsql
AS $$
BEGIN
  CREATE TABLE IF NOT EXISTS price_control(
	item_id INT,
    price FLOAT,
	status VARCHAR(50),
    created_at DATE,
    updated_at DATE
	);

	DROP TABLE IF EXISTS intermediate_items; 

	CREATE TABLE intermediate_items AS(
		SELECT
			item_id
            ,price
            ,CASE WHEN is_published THEN 'Publicado' ELSE 'No publicado' END AS status
        FROM items
        WHERE updated_at >= $1 AND updated_at <= $2);
	
    MERGE INTO price_control as target
    USING intermediate_items AS source
    ON source.item_id = target.item_id
    WHEN MATCHED THEN UPDATE 
    SET
		item_id = source.item_id
        ,price = source.price
        ,status = source.status
        ,updated_at = CURRENT_DATE
    WHEN NOT MATCHED THEN
		INSERT(item_id, price, status, created_at, updated_at)
        VALUES(source.item_id, source.price, source.status, CURRENT_DATE, CURRENT_DATE);
	
    DROP TABLE IF EXISTS intermediate_item;
END;
$$;

       select * from items;
-- Luego podemos correr el Stored Proccedure con las fechas deseadas
-- ya sea para carga inicial (donde start_date = end_date = CURRENT_DATE)
-- o reproceso de lo datos (donde podemos seleccionar las fechas deseadas)
-- Por ejemplo:
CALL load_price_control ('2024-05-10', '2024-05-20');

SELECT * FROM price_control;
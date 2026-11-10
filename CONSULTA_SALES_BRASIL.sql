SELECT * FROM `DATA_SALES_BRAZIL.OLIST_GEOLOCATION`
WHERE geolocation_city<>"sao paulo" AND geolocation_city<>"são paulo"
--01: VALIDACION DE ESTADO DE TABLAS
SELECT
  table_name,
  table_type
FROM `proyecto1-080426.DATA_SALES_BRAZIL.INFORMATION_SCHEMA.TABLES`
ORDER BY table_name
--02:c CONTEO DE REGISTROS
SELECT COUNT(*) AS CONTEO_CUSTOMERS FROM `DATA_SALES_BRAZIL.olist_customers`
SELECT COUNT(*) AS CONTEO_GEOLOC FROM `DATA_SALES_BRAZIL.OLIST_GEOLOCATION`
SELECT COUNT(*) AS CONTEO_ORDERSITEMS FROM `DATA_SALES_BRAZIL.OLIST_ORDER_ITEMS`
SELECT COUNT(*) AS CONTEO_ORDERPAYMENTS FROM `DATA_SALES_BRAZIL.olist_order_payments`
SELECT COUNT(*) AS CONTEO_ORDER_REVIEWS FROM `DATA_SALES_BRAZIL.olist_order_reviews`
SELECT COUNT(*) AS CONTEO_ORDERS FROM `DATA_SALES_BRAZIL.olist_orders`
SELECT COUNT(*) AS CONTEO_PRODUCTS FROM `DATA_SALES_BRAZIL.olist_products`
SELECT COUNT(*) AS CONTEO_SELLERS FROM `DATA_SALES_BRAZIL.olist_sellers`
SELECT COUNT(*) AS CONTEO_PRODUCT_CAT FROM `DATA_SALES_BRAZIL.product_category`

--3: validar la clave primaria de pedidos
SELECT order_id, COUNT(*) AS CONTEO FROM `DATA_SALES_BRAZIL.olist_orders`
WHERE order_id IS NOT NULL
GROUP BY order_id
HAVING COUNT(*)>1;

--4: detectar valores nulos en los pedidos
SELECT COUNT(*) AS CONTEO_NULOS FROM `DATA_SALES_BRAZIL.olist_orders`
WHERE order_id IS NULL;

--5: validar la relación entre pedidos y artículos
SELECT * FROM `DATA_SALES_BRAZIL.OLIST_ORDER_ITEMS` IT
LEFT JOIN `DATA_SALES_BRAZIL.olist_orders` OD
ON IT.order_id=OD.order_id
WHERE OD.order_id IS NULL

--6: validar INVERSA la relación entre pedidos y artículos
SELECT * FROM `DATA_SALES_BRAZIL.olist_orders` OD
LEFT JOIN `DATA_SALES_BRAZIL.OLIST_ORDER_ITEMS` IT
ON OD.order_id=IT.order_id
WHERE IT.order_id IS NULL

--7: validar la unicidad de los clientes
SELECT customer_id, COUNT(*) AS APARICIONES FROM `DATA_SALES_BRAZIL.olist_customers`
GROUP BY customer_id
HAVING COUNT(*)>1;

--8: detectar valores nulos en los clientes
SELECT count(*) AS CANTIDAD_NULOS FROM `DATA_SALES_BRAZIL.olist_customers`
WHERE customer_id IS NULL;

--9: validar la relación entre pedidos y clientes
SELECT * FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_customers` CU ON OD.customer_id=CU.customer_id
WHERE CU.customer_id IS NULL

--10: validar la unicidad de los productos
SELECT product_id, COUNT(*) AS APARICIONES FROM `DATA_SALES_BRAZIL.olist_products`
GROUP BY product_id
HAVING COUNT(*)>1

--11: detectar valores nulos en los productos
SELECT COUNT(*) AS TOTAL_NULOS  FROM `DATA_SALES_BRAZIL.olist_products`
WHERE product_id IS NULL

--12: validar la relación entre artículos y productos
SELECT *  FROM `DATA_SALES_BRAZIL.OLIST_ORDER_ITEMS` IT
LEFT JOIN `DATA_SALES_BRAZIL.olist_products` PR
ON IT.product_id = PR.product_id
WHERE PR.product_id IS NULL

--13: validar la unicidad de los vendedores
SELECT seller_id, COUNT(*) AS APARICIONES  FROM `DATA_SALES_BRAZIL.olist_sellers`
GROUP BY seller_id
HAVING APARICIONES>1

--14: detectar vendedores sin identificador
SELECT COUNT(*) AS TOTAL_NULOS  FROM `DATA_SALES_BRAZIL.olist_sellers`
WHERE seller_id IS NULL

--15: validar la relación entre artículos y vendedores
SELECT * FROM `DATA_SALES_BRAZIL.OLIST_ORDER_ITEMS` IT LEFT JOIN  `DATA_SALES_BRAZIL.olist_sellers` SE ON IT.seller_id =SE.seller_id
WHERE SE.seller_id IS NULL

--16: validar los pagos
SELECT * FROM `DATA_SALES_BRAZIL.olist_order_payments` PA
LEFT JOIN `DATA_SALES_BRAZIL.olist_orders` OD ON PA.order_id=OD.order_id 
WHERE OD.order_id IS NULL

--17: detectar pagos sin identificador de pedido
SELECT COUNT(*) AS PagosSinIdentificador FROM `DATA_SALES_BRAZIL.olist_order_payments`
WHERE order_id IS NULL

--18: validar la relación entre reseñas y pedidos
SELECT * FROM `DATA_SALES_BRAZIL.olist_order_reviews` RE LEFT JOIN `DATA_SALES_BRAZIL.olist_orders` OD
ON RE.order_id=OD.order_id
WHERE OD.order_id IS NULL

--19: detectar reseñas sin identificador de pedido
SELECT COUNT(*) CANTIDAD_NULOS FROM `DATA_SALES_BRAZIL.olist_order_reviews` RE
WHERE  RE.order_id IS NULL

--20: comprobar duplicados en los pagos
SELECT PA.order_id , COUNT(*) AS CONTEO FROM `DATA_SALES_BRAZIL.olist_order_payments` PA
GROUP BY PA.order_id
HAVING COUNT(*)>1
ORDER BY CONTEO DESC

--21: analizar los métodos de pago
SELECT payment_type, count(*) AS CONTEO_MET_PAGO FROM `DATA_SALES_BRAZIL.olist_order_payments`
GROUP BY payment_type
ORDER BY CONTEO_MET_PAGO DESC

--22: analizar el importe total por método de pago
SELECT PA.payment_type,SUM(PA.payment_value) AS MONTO_ACUMULADO FROM `DATA_SALES_BRAZIL.olist_order_payments` PA
GROUP BY PA.payment_type
ORDER BY MONTO_ACUMULADO DESC

--23: Participación porcentual por método de pago
WITH TOTALES_METODO AS (
  SELECT
    payment_type,
    SUM(payment_value) AS MONTO_ACUMULADO
  FROM `DATA_SALES_BRAZIL.olist_order_payments`
  GROUP BY payment_type
), TOT2 AS (SELECT *,(SELECT SUM(MONTO_ACUMULADO) FROM TOTALES_METODO) AS TOTALIZADO FROM TOTALES_METODO)
SELECT payment_type, TOT2.MONTO_ACUMULADO, 100*TOT2.MONTO_ACUMULADO/TOTALIZADO AS PORCENTAJE FROM TOT2
ORDER BY PORCENTAJE DESC

--23(VARIANTE):
WITH TOTALES_METODO AS (
  SELECT
    payment_type,SUM(payment_value) AS MONTO_ACUMULADO
  FROM `DATA_SALES_BRAZIL.olist_order_payments` GROUP BY payment_type
)
SELECT
  payment_type, MONTO_ACUMULADO, 100 * SAFE_DIVIDE(
    MONTO_ACUMULADO,
    SUM(MONTO_ACUMULADO) OVER ()
  ) AS PORCENTAJE
FROM TOTALES_METODO
ORDER BY PORCENTAJE DESC;

--24: importe promedio por pedido
SELECT order_id,SUM(payment_value) AS IMPORTE_TOTAL, count(*) AS CANTIDAD_PAGOS FROM `DATA_SALES_BRAZIL.olist_order_payments`
GROUP BY order_id

--25: Identificar pedidos con más de un registro de pago
SELECT order_id,SUM(payment_value) AS IMPORTE_TOTAL, count(*) AS CANTIDAD_PAGOS FROM `DATA_SALES_BRAZIL.olist_order_payments`
GROUP BY order_id
HAVING CANTIDAD_PAGOS>1
ORDER BY CANTIDAD_PAGOS DESC

--26: Analizar el valor promedio de los pedidos
WITH TA AS (
  SELECT order_id, SUM(payment_value) AS total_pedido
  FROM `DATA_SALES_BRAZIL.olist_order_payments`
  GROUP BY order_id
)
SELECT
  COUNT(*) AS CANTIDAD_PEDIDOS,
  SUM(total_pedido) AS IMPORTE_TOTAL,
  AVG(total_pedido) AS PROMEDIO_POR_PEDIDO
FROM TA;
--27 — Distribución de pedidos por estado
WITH TA AS (SELECT order_status, COUNT(*) AS CONTEO FROM `DATA_SALES_BRAZIL.olist_orders`
GROUP BY order_status
)
SELECT *, 100*CONTEO/(select count(*) from DATA_SALES_BRAZIL.olist_orders ) AS PORCENTAJE FROM TA
ORDER BY PORCENTAJE DESC

--28: Cumplimiento de fechas de entrega
WITH TA AS (
SELECT order_status, order_delivered_customer_date, order_estimated_delivery_date
FROM `DATA_SALES_BRAZIL.olist_orders`
WHERE order_status="delivered" AND ( order_estimated_delivery_date is NOT null AND order_delivered_customer_date IS NOT NULL)
), TB AS (SELECT order_status,COUNTIF(order_delivered_customer_date<=order_estimated_delivery_date) AS A_TIEMPO,
COUNTIF(order_delivered_customer_date>order_estimated_delivery_date) AS TARDE
FROM TA
GROUP BY order_status)
SELECT *, 100*TB.TARDE/(TB.A_TIEMPO+TARDE) AS PORCENTAJE_TARDIAS FROM TB

--29 Promedio de días de retraso
with TA AS (SELECT * FROM `DATA_SALES_BRAZIL.olist_orders` OD
WHERE order_status = "delivered" and DATE(order_purchase_timestamp) IS NOT NULL AND DATE(order_approved_at) IS NOT NULL and DATE(order_delivered_carrier_date) IS NOT NULL and DATE(order_delivered_customer_date) IS NOT NULL and DATE(order_estimated_delivery_date) IS NOT NULL
AND TIMESTAMP_DIFF(order_delivered_customer_date,order_estimated_delivery_date,DAY)>0
), TB AS (
SELECT *, TIMESTAMP_DIFF(order_delivered_customer_date,order_estimated_delivery_date,DAY) AS DIFFEREN FROM TA 
ORDER BY DIFFEREN DESC
)
SELECT AVG(TB.DIFFEREN) AS PROMEDIO_DIAS_RETRASO FROM TB

--30 Retraso promedio por estado del cliente
WITH TA AS (SELECT customer_state, TIMESTAMP_DIFF(OD.order_estimated_delivery_date, order_delivered_customer_date, DAY) AS DIFERENCIA FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_customers` CU
ON OD.customer_id=CU.customer_id
where OD.order_status ="delivered"
), TB AS (SELECT TA.customer_state,COUNTIF(TA.DIFERENCIA<0) AS TARDANZAS,COUNTIF(TA.DIFERENCIA>=0) AS ATIEMPO  FROM TA
GROUP BY TA.customer_state
)
SELECT customer_state,Tardanzas,ATIEMPO, AVG(Tardanzas) OVER() AS PROMEDIO_DIAS_TARDANZA FROM TB
ORDER BY PROMEDIO_DIAS_TARDANZA DESC

--31:Análisis mensual de ventas
WITH TA AS(
SELECT DATE_TRUNC(DATE(OD.order_purchase_timestamp),MONTH) AS MES,SUM(PA.payment_value) AS VENTAS_MENSUALES
FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA  
ON OD.order_id=PA.order_id
WHERE OD.order_status="delivered" AND PA.payment_value IS NOT NULL
GROUP BY MES
), TB AS (SELECT *, SUM(VENTAS_MENSUALES) OVER () AS VENTAS_PERIODO,SUM(VENTAS_MENSUALES) OVER (PARTITION BY EXTRACT(YEAR FROM MES)) AS VENTAS_ANUA FROM TA)
SELECT *,100*TB.VENTAS_MENSUALES/TB.VENTAS_ANUA AS PORCENTAJE_PARTICIPACION_ANUAL,100*TB.VENTAS_MENSUALES/TB.VENTAS_PERIODO AS PORCENTAJE_PARTICIPACION_PERIODO FROM TB
ORDER BY MES ASC

--32: Variación mensual de ventas
WITH TA AS(
SELECT DATE_TRUNC(DATE(OD.order_purchase_timestamp),MONTH) AS MES,SUM(PA.payment_value) AS VENTAS_MENSUALES
FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA  
ON OD.order_id=PA.order_id
WHERE OD.order_status="delivered" AND PA.payment_value IS NOT NULL
GROUP BY MES
), TB AS (SELECT *, LAG(TA.VENTAS_MENSUALES) OVER(ORDER BY MES) AS VENTAS_MES_ANTERIOR FROM TA)
SELECT *, TB.VENTAS_MENSUALES-TB.VENTAS_MES_ANTERIOR AS DIFERENCIA, 100*SAFE_DIVIDE(TB.VENTAS_MENSUALES-TB.VENTAS_MES_ANTERIOR,TB.VENTAS_MES_ANTERIOR) AS VARIACION_PORCENTUAL FROM TB

--33:Ranking de meses por ventas
WITH TA AS (SELECT DATE_TRUNC(DATE(OD.order_purchase_timestamp),MONTH) AS MES,SUM(PA.payment_value) AS VENTAS_MENSUALES
FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA  
ON OD.order_id=PA.order_id
WHERE OD.order_status="delivered" AND PA.payment_value IS NOT NULL
GROUP BY MES), TB AS (SELECT *, RANK() OVER(ORDER BY TA.VENTAS_MENSUALES DESC) AS RANKING FROM TA)
SELECT * FROM TB
WHERE RANKING<=3

--34: Identificar meses atípicos en ventas
WITH TA AS (SELECT DATE_TRUNC(DATE(OD.order_purchase_timestamp),MONTH) AS MES,SUM(PA.payment_value) AS VENTAS_MENSUALES
FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA  
ON OD.order_id=PA.order_id
WHERE OD.order_status="delivered" AND PA.payment_value IS NOT NULL
GROUP BY MES), TB AS (SELECT *, AVG(TA.VENTAS_MENSUALES) OVER() AS PROMEDIO_PERIODO, TA.VENTAS_MENSUALES-AVG(TA.VENTAS_MENSUALES) OVER() AS DIFERENCIA FROM TA
)
SELECT * FROM TB
WHERE DIFERENCIA>0
ORDER BY TB.VENTAS_MENSUALES DESC


--35: Ventas acumuladas por mes
WITH TA AS (SELECT DATE_TRUNC(DATE(OD.order_purchase_timestamp),MONTH) AS MES,SUM(PA.payment_value) AS VENTAS_MENSUALES
FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA  
ON OD.order_id=PA.order_id
WHERE OD.order_status="delivered" AND PA.payment_value IS NOT NULL
GROUP BY MES)
SELECT *, SUM(VENTAS_MENSUALES) OVER(ORDER BY MES ASC) AS VENTAS_ACUMULADAS FROM TA

--36: Comparación con el mes anterior
WITH TA AS (SELECT DATE_TRUNC(DATE(OD.order_purchase_timestamp),MONTH) AS MES,SUM(PA.payment_value) AS VENTAS_MENSUALES
FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA  
ON OD.order_id=PA.order_id
WHERE OD.order_status="delivered" AND PA.payment_value IS NOT NULL
GROUP BY MES), TB AS (SELECT *, LAG(VENTAS_MENSUALES) OVER(ORDER BY MES ASC) AS VENTAS_MES_ANTERIOR FROM TA),
TC AS (
  SELECT *,TB.VENTAS_MENSUALES-VENTAS_MES_ANTERIOR AS DIFERENCIA FROM TB
), TD AS (
  SELECT *,SAFE_DIVIDE((100*DIFERENCIA),VENTAS_MES_ANTERIOR)  AS VARIACIN_PORCENTUAL FROM TC
)
SELECT * FROM TD
ORDER BY MES ASC

-- 37: Detectar meses con caídas consecutivas
WITH TA AS (SELECT DATE_TRUNC(DATE(OD.order_purchase_timestamp),MONTH) AS MES,SUM(PA.payment_value) AS VENTAS_MENSUALES
FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA  
ON OD.order_id=PA.order_id
WHERE OD.order_status="delivered" AND PA.payment_value IS NOT NULL
GROUP BY MES), TB AS (SELECT *, LAG(VENTAS_MENSUALES) OVER(ORDER BY MES ASC) AS VENTAS_MES_ANTERIOR, LAG(VENTAS_MENSUALES,2) OVER(ORDER BY MES ASC) AS VENTAS_DOS_MESES_ANTES FROM TA)
SELECT * FROM TB
WHERE VENTAS_MES_ANTERIOR>VENTAS_MENSUALES AND VENTAS_DOS_MESES_ANTES>VENTAS_MES_ANTERIOR

--38: Clasificar la evolución mensual
WITH TA AS (SELECT DATE_TRUNC(DATE(OD.order_purchase_timestamp),MONTH) AS MES,SUM(PA.payment_value) AS VENTAS_MENSUALES
FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA  
ON OD.order_id=PA.order_id
WHERE OD.order_status="delivered" AND PA.payment_value IS NOT NULL
GROUP BY MES), TB AS (SELECT *, LAG(VENTAS_MENSUALES) OVER(ORDER BY MES ASC) AS VENTAS_MES_ANTERIOR FROM TA), TC AS (
  SELECT *,SAFE_DIVIDE(100*(VENTAS_MENSUALES-VENTAS_MES_ANTERIOR),VENTAS_MES_ANTERIOR) AS VARIACION_PORCENTUAL FROM TB
), TD AS (
  SELECT *,
  CASE
  WHEN (VENTAS_MENSUALES IS NULL) OR (VENTAS_MES_ANTERIOR IS NULL) THEN "SIN REFERENCIA"
  WHEN VENTAS_MENSUALES>VENTAS_MES_ANTERIOR THEN "AUMENTO"
  WHEN VENTAS_MENSUALES<VENTAS_MES_ANTERIOR THEN "DISMINUCION"
  WHEN VENTAS_MENSUALES=VENTAS_MES_ANTERIOR THEN "SIN VARIACION"
  END AS CLASIFIC
  FROM TC
)
SELECT * FROM TD
ORDER BY MES ASC


--39:Identificar meses con variaciones extremas
WITH TA AS (
  SELECT DATE_TRUNC(DATE(OD.order_purchase_timestamp),MONTH) AS MES,SUM(PA.payment_value) AS VENTAS_MENSUALES
FROM `DATA_SALES_BRAZIL.olist_orders` OD LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA  
ON OD.order_id=PA.order_id
WHERE OD.order_status="delivered" AND PA.payment_value IS NOT NULL
GROUP BY MES
), TB AS (
  SELECT *, LAG(TA.VENTAS_MENSUALES) OVER(ORDER BY MES ASC) AS VENTAS_MES_ANTERIOR FROM TA
  ), TC AS (
    SELECT *, SAFE_DIVIDE(100*(TB.VENTAS_MENSUALES-TB.VENTAS_MES_ANTERIOR),TB.VENTAS_MES_ANTERIOR) AS VARIACION_PORCENTUAL FROM TB
  )
SELECT *, CASE
WHEN VARIACION_PORCENTUAL>10 THEN "AUMENTO SIGNIFICATIVO"
WHEN VARIACION_PORCENTUAL<-10 THEN "DISMINUCION SIGNIFICATIVO"
WHEN VARIACION_PORCENTUAL>=-10 AND VARIACION_PORCENTUAL<=10 THEN "VARIACION NORMAL"
WHEN VARIACION_PORCENTUAL IS NULL THEN "SIN REFERENCIA"
END AS ALERTA
FROM TC

--43: Frecuencia de compra por cliente
WITH TA AS(
SELECT CU.customer_unique_id, customer_state, COUNT(*) OVER(PARTITION BY CU.customer_unique_id) AS TOTAL_PEDIDOS FROM `DATA_SALES_BRAZIL.olist_orders` OD left JOIN `DATA_SALES_BRAZIL.olist_customers` CU ON OD.customer_id=CU.customer_id
)
SELECT customer_unique_id,CUSTOMER_STATE, COUNT(total_pedidos) as conteo_total FROM TA
group BY customer_unique_id,CUSTOMER_STATE
HAVING conteo_total>1

--44: Identificar clientes de alto valor

/*SELECT * FROM `DATA_SALES_BRAZIL.olist_customers` CU LEFT JOIN `DATA_SALES_BRAZIL.olist_orders` OD ON CU.customer_id=OD.customer_id LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA ON OD.order_id=PA.order_id
*/
WITH TA AS (
SELECT customer_unique_id, SUM(payment_value) AS MONTO_TOTAL, COUNT(DISTINCT OD.order_id) AS TOTAL_PEDIDOS FROM `DATA_SALES_BRAZIL.olist_customers` CU LEFT JOIN `DATA_SALES_BRAZIL.olist_orders` OD ON CU.customer_id=OD.customer_id LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA ON OD.order_id=PA.order_id
GROUP BY customer_unique_id
), TB AS (
  SELECT *, AVG(MONTO_TOTAL) OVER() AS PROMEDIO_GENERAL  FROM TA
  WHERE customer_unique_id is not null
)
SELECT * FROM TB
WHERE MONTO_TOTAL>PROMEDIO_GENERAL AND TOTAL_PEDIDOS>1
ORDER BY MONTO_TOTAL DESC

--45 Segmentación de clientes por gasto
WITH TA AS (
SELECT customer_unique_id, SUM(payment_value) AS MONTO_TOTAL, COUNT(DISTINCT OD.order_id) AS TOTAL_PEDIDOS FROM `DATA_SALES_BRAZIL.olist_customers` CU LEFT JOIN `DATA_SALES_BRAZIL.olist_orders` OD ON CU.customer_id=OD.customer_id LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA ON OD.order_id=PA.order_id
GROUP BY customer_unique_id
HAVING TOTAL_PEDIDOS>1
ORDER BY TOTAL_PEDIDOS ASC), TB AS (
  SELECT * , PERCENTILE_CONT(MONTO_TOTAL,0.5) OVER() AS PERCENTIL_50,
  PERCENTILE_CONT(MONTO_TOTAL,0.9) OVER() AS PERCENTIL_90
  FROM TA
) 
SELECT *, CASE
WHEN MONTO_TOTAL<=PERCENTIL_50 THEN "CLIENTE DE GASTO BAJO" 
WHEN MONTO_TOTAL>PERCENTIL_90 THEN "CLIENTE DE GASTO ALTO"
ELSE "CLIENTE DE GASTO MEDIO" 
END AS CLASIFICACION_CLIENTES
FROM TB

--46: Segmentación de clientes mediante NTILE():
WITH TA AS (
SELECT customer_unique_id, SUM(payment_value) AS MONTO_TOTAL, COUNT(DISTINCT OD.order_id) AS TOTAL_PEDIDOS FROM `DATA_SALES_BRAZIL.olist_customers` CU LEFT JOIN `DATA_SALES_BRAZIL.olist_orders` OD ON CU.customer_id=OD.customer_id LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA ON OD.order_id=PA.order_id
GROUP BY customer_unique_id
HAVING TOTAL_PEDIDOS>1
ORDER BY TOTAL_PEDIDOS ASC), TB AS (
  SELECT * , ntile(4) OVER(ORDER BY MONTO_TOTAL ASC) AS CLASIFICACION
  FROM TA
) 
SELECT *, CASE
WHEN CLASIFICACION=1 THEN "Clientes con menor gasto"
WHEN CLASIFICACION=2 THEN "Clientes con gasto medio-bajo"
WHEN CLASIFICACION=3 THEN "Clientes con gasto medio-alto"
WHEN CLASIFICACION=4 THEN "Clientes con mayor gasto"
END as SEGMENTACION
from TB


--47: Análisis de concentración de ingresos
WITH TA AS (
SELECT customer_unique_id, SUM(payment_value) AS MONTO_TOTAL, COUNT(DISTINCT OD.order_id) AS TOTAL_PEDIDOS FROM `DATA_SALES_BRAZIL.olist_customers` CU LEFT JOIN `DATA_SALES_BRAZIL.olist_orders` OD ON CU.customer_id=OD.customer_id LEFT JOIN `DATA_SALES_BRAZIL.olist_order_payments` PA ON OD.order_id=PA.order_id
GROUP BY customer_unique_id
HAVING TOTAL_PEDIDOS>1
ORDER BY MONTO_TOTAL ASC), TB AS (
SELECT *, 100*MONTO_TOTAL/(SELECT SUM(MONTO_TOTAL) FROM TA)  AS PORCENTAJE ,SUM(MONTO_TOTAL) OVER(ORDER BY MONTO_TOTAL DESC) AS ACUMULADO FROM TA
), TC AS (
  SELECT *, SUM(PORCENTAJE) OVER(ORDER BY MONTO_TOTAL DESC) AS PORCENTAJE_ACUMULADO FROM TB
)
SELECT * FROM TC
WHERE PORCENTAJE_ACUMULADO<=80

--48: Análisis de retención de clientes
WITH TA AS (
SELECT customer_unique_id, date(order_purchase_timestamp) as fecha FROM `DATA_SALES_BRAZIL.olist_customers` CU LEFT JOIN `DATA_SALES_BRAZIL.olist_orders` OD ON CU.customer_id=OD.customer_id
order BY customer_unique_id , fecha ASC
), TB AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_unique_id ORDER BY FECHA) AS ORDEN_CRONOLOGICO_COMPRAS FROM TA ), TC AS (
SELECT customer_unique_id, MAX(CASE WHEN ORDEN_CRONOLOGICO_COMPRAS=1 THEN fecha END) AS PRIMERA_COMPRA, MAX(CASE WHEN ORDEN_CRONOLOGICO_COMPRAS=2 THEN fecha END) AS SEGUNDA_COMPRA
FROM TB
GROUP BY customer_unique_id), TD AS ( SELECT *, DATE_DIFF(SEGUNDA_COMPRA, PRIMERA_COMPRA, MONTH) AS DIFERENCIA_MESES FROM TC )
SELECT *, CASE
WHEN DIFERENCIA_MESES=0 THEN "Segunda compra en el mismo mes" 
WHEN DIFERENCIA_MESES>0 THEN "Segunda compra en un mes posterior."
END AS RETENCION_CLIENTE
FROM TD
WHERE DIFERENCIA_MESES IS NOT NULL

-- 49: Análisis de cohortes de clientes (Dataset Olist)
WITH TA AS (
  -- 1. Obtener compras válidas con el ID real del cliente (customer_unique_id)
  SELECT DISTINCT
    CU.customer_unique_id,
    DATE_TRUNC(DATE(OD.order_purchase_timestamp), MONTH) AS mes_compra
  FROM `DATA_SALES_BRAZIL.olist_customers` CU
  INNER JOIN `DATA_SALES_BRAZIL.olist_orders` OD
    ON CU.customer_id = OD.customer_id
  WHERE OD.order_purchase_timestamp IS NOT NULL
    AND OD.order_status NOT IN ('canceled', 'unavailable')
),

TB AS (
  -- 2. Identificar la COHORTE (mes de la primera compra de cada cliente)
  SELECT
    customer_unique_id,
    MIN(mes_compra) AS cohorte
  FROM TA
  GROUP BY customer_unique_id
),

TC AS (
  -- 3. Calcular cuántos meses pasaron desde su primera compra (Mes 0, Mes 1, Mes 2...)
  SELECT
    TB.cohorte,
    TA.customer_unique_id,
    DATE_DIFF(TA.mes_compra, TB.cohorte, MONTH) AS mes_numero
  FROM TB
  INNER JOIN TA
    ON TB.customer_unique_id = TA.customer_unique_id
),

TD AS (
  -- 4. Contar clientes únicos por cohorte y mes transcurrido + calcular % de retención
  SELECT
    cohorte,
    mes_numero,
    COUNT(DISTINCT customer_unique_id) AS clientes_activos,
    FIRST_VALUE(COUNT(DISTINCT customer_unique_id)) OVER (
      PARTITION BY cohorte ORDER BY mes_numero
    ) AS tamano_cohorte,
    ROUND(
      SAFE_DIVIDE(
        COUNT(DISTINCT customer_unique_id) * 100.0,
        FIRST_VALUE(COUNT(DISTINCT customer_unique_id)) OVER (PARTITION BY cohorte ORDER BY mes_numero)
      ), 2
    ) AS tasa_retencion
  FROM TC
  GROUP BY cohorte, mes_numero
)

-- 5. Presentar en matriz de cohortes (puedes cambiar tasa_retencion por clientes_activos si prefieres conteo)
SELECT *
FROM (
  SELECT cohorte, tamano_cohorte, mes_numero, tasa_retencion
  FROM TD
)
PIVOT (
  MAX(tasa_retencion)
  FOR mes_numero IN (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
)
ORDER BY cohorte;

--49: ANALISIS COHORTES
WITH TA AS (
  SELECT customer_unique_id, date_trunc( date(OD.order_purchase_timestamp) ,MONTH) as compra_mes
  FROM `DATA_SALES_BRAZIL.olist_customers` CU
  INNER JOIN `DATA_SALES_BRAZIL.olist_orders` OD
    ON CU.customer_id = OD.customer_id
  WHERE OD.order_purchase_timestamp IS NOT NULL
    AND OD.order_status NOT IN ('canceled', 'unavailable')
  ORDER BY customer_unique_id asc, compra_mes ASC
), tb as (
  SELECT customer_unique_id,min(compra_mes) as cohorte
  FROM TA
  group by customer_unique_id
), TC AS (
  SELECT 
  TB.COHORTE,
  ta.customer_unique_id,
  DATE_DIFF(TA.compra_mes,TB.COHORTE,MONTH) AS MES_numero
  FROM TB INNER JOIN TA ON TB.customer_unique_id=TA.customer_unique_id),
TD AS (
  SELECT
    cohorte,
    mes_numero,
    COUNT(DISTINCT customer_unique_id) AS clientes_activos,
    FIRST_VALUE(COUNT(DISTINCT customer_unique_id)) OVER (
      PARTITION BY cohorte ORDER BY mes_numero
    ) AS tamano_cohorte,
    ROUND(
      SAFE_DIVIDE(
        COUNT(DISTINCT customer_unique_id) * 100.0,
        FIRST_VALUE(COUNT(DISTINCT customer_unique_id)) OVER (PARTITION BY cohorte ORDER BY mes_numero)
      ), 2
    ) AS tasa_retencion
  FROM TC
  GROUP BY cohorte, mes_numero 
)
SELECT * 
FROM (
  SELECT cohorte, tamano_cohorte, mes_numero, tasa_retencion
  FROM TD
)
PIVOT (
  MAX(tasa_retencion)
  FOR mes_numero IN (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
)
ORDER BY cohorte
;
























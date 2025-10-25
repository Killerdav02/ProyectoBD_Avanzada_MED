--- 1. qry_TopProductos : Top 10 Productos Más Vendidos: Generar un ranking con los 10 productos que han generado más ingresos.

CREATE OR REPLACE VIEW qry_TopProductos AS
SELECT ...
FROM ...
WHERE ...;

--- 2. qry_ProductosBajos : Productos con Bajas Ventas: Identificar los productos en el 10% inferior de ventas para considerar su descontinuación.

CREATE OR REPLACE VIEW qry_ProductosBajos AS
SELECT ...
FROM ...
WHERE ...;

--- 3. qry_ClientesVIP : Clientes VIP: Listar los 5 clientes con el mayor valor de vida (LTV), basado en su gasto total histórico.

CREATE OR REPLACE VIEW qry_ClientesVIP AS
SELECT ...
FROM ...
WHERE ...;

--- 4. qry_VentasMensuales : Análisis de Ventas Mensuales: Mostrar las ventas totales agrupadas por mes y año.

CREATE OR REPLACE VIEW qry_VentasMensuales AS
SELECT ...
FROM ...
WHERE ...;

--- 5. qry_CrecimientoClientes : Crecimiento de Clientes: Calcular el número de nuevos clientes registrados por trimestre.

CREATE OR REPLACE VIEW qry_CrecimientoClientes AS
SELECT ...
FROM ...
WHERE ...;

--- 6. qry_TasaRecompra : Tasa de Compra Repetida: Determinar qué porcentaje de clientes ha realizado más de una compra.

CREATE OR REPLACE VIEW qry_TasaRecompra AS
SELECT ...
FROM ...
WHERE ...;

--- 7. qry_ProductosFrecuentes : Productos Comprados Juntos Frecuentemente: Identificar pares de productos que a menudo se compran en la misma transacción.

SELECT
    p1.id_producto AS id_producto_1,
    p1.nombre AS producto_1,
    p2.id_producto AS id_producto_2,
    p2.nombre AS producto_2,
    COUNT(*) AS veces_comprados_juntos
FROM
    producto_venta pv1
    INNER JOIN producto_venta pv2 ON pv1.id_venta_fk = pv2.id_venta_fk
    AND pv1.id_producto_fk < pv2.id_producto_fk
    INNER JOIN producto p1 ON pv1.id_producto_fk = p1.id_producto
    INNER JOIN producto p2 ON pv2.id_producto_fk = p2.id_producto
GROUP BY
    p1.id_producto,
    p1.nombre,
    p2.id_producto,
    p2.nombre
HAVING
    COUNT(*) >= 2
ORDER BY veces_comprados_juntos DESC, p1.nombre, p2.nombre
LIMIT 20;

--- 8. qry_RotacionInventario : Rotación de Inventario: Calcular la tasa de rotación de stock para cada categoría de producto.

SELECT 
    c.id_categoria,
    c.nombre AS categoria,
    SUM(pv.cantidad) AS unidades_vendidas,
    AVG(i.stock) AS stock_promedio,
    ROUND(SUM(pv.cantidad) / AVG(i.stock), 2) AS tasa_rotacion,
    CASE 
        WHEN ROUND(SUM(pv.cantidad) / AVG(i.stock), 2) >= 5 THEN 'Alta rotación'
        WHEN ROUND(SUM(pv.cantidad) / AVG(i.stock), 2) >= 2 THEN 'Rotación media'
        ELSE 'Baja rotación'
    END AS clasificacion
FROM categoria c
INNER JOIN producto_categoria pc 
    ON c.id_categoria = pc.id_categoria_fk
INNER JOIN producto p 
    ON pc.id_producto_fk = p.id_producto
INNER JOIN inventario i 
    ON p.id_producto = i.id_producto_fk
LEFT JOIN producto_venta pv 
    ON p.id_producto = pv.id_producto_fk
GROUP BY c.id_categoria, c.nombre
HAVING SUM(pv.cantidad) IS NOT NULL
ORDER BY tasa_rotacion DESC;

--- 9. qry_Reabastecimiento : Productos que Necesitan Reabastecimiento: Listar productos cuyo stock actual esté por debajo de su umbral mínimo.

SELECT 
    p.id_producto,
    p.nombre AS producto,
    i.sku,
    i.stock AS stock_actual,
    10 AS umbral_minimo,
    (10 - i.stock) AS unidades_necesarias,
    CASE 
        WHEN i.stock = 0 THEN 'CRÍTICO - Sin stock'
        WHEN i.stock <= 5 THEN 'URGENTE - Stock muy bajo'
        WHEN i.stock <= 10 THEN 'IMPORTANTE - Por debajo del mínimo'
    END AS prioridad
FROM producto p
INNER JOIN inventario i 
    ON p.id_producto = i.id_producto_fk
WHERE i.stock <= 10
ORDER BY i.stock ASC, p.nombre;

--- 10. qry_CarritosAbandonados : Análisis de Carrito Abandonado (Simulado): Identificar clientes que agregaron productos pero no completaron una venta en un período determinado.

SELECT 
    id_carrito,
    id_cliente_fk,
    fecha_creacion,
    estado
FROM 
    `e_commerce_db`.`carrito`
WHERE 
    estado = 'abandonado'
ORDER BY 
    fecha_creacion DESC;

--- Este evento es que permite la consulta anterior:

CREATE EVENT IF NOT EXISTS carritos_abandonados
ON SCHEDULE EVERY 5 MINUTE
DO
    UPDATE `e_commerce_db`.`carrito`
    SET estado = 'abandonado'
    WHERE estado = 'activo'
    AND TIMESTAMPDIFF(MINUTE, fecha_creacion, NOW()) > 5;

--- 11. qry_RendimientoProveedores : Rendimiento de Proveedores: Clasificar a los proveedores según el volumen de ventas de sus productos.

SELECT 
    p.id_proveedor, 
    p.nombre AS proveedor_nombre,
    SUM(pv.cantidad * pv.precio_unitario) AS volumen_ventas
FROM 
    proveedor p
JOIN 
    proveedor_tienda_producto ptp ON p.id_proveedor = ptp.id_proveedor_fk
JOIN 
    producto pr ON ptp.id_producto_fk = pr.id_producto
JOIN 
    producto_venta pv ON pr.id_producto = pv.id_producto_fk
JOIN 
    venta v ON pv.id_venta_fk = v.id_venta
WHERE 
    v.estado IN ('Enviado', 'Entregado')
GROUP BY 
    p.id_proveedor
ORDER BY 
    volumen_ventas DESC;

--- 12. qry_VentasPorRegion : Análisis Geográfico de Ventas: Agrupar las ventas por ciudad o región del cliente.

SELECT 
    de.ciudad, 
    SUM(v.total) AS total_ventas
FROM 
    venta v
JOIN 
    cliente c ON v.id_cliente_fk = c.id_cliente
JOIN 
    cliente_direccion_envio cde ON c.id_cliente = cde.id_cliente_fk
JOIN 
    direccion_envio de ON cde.id_direccion_envio_fk = de.id_direccion_envio
WHERE 
    v.estado IN ('Enviado', 'Entregado')  -- Considerar solo ventas completadas
GROUP BY 
    de.ciudad
ORDER BY 
    total_ventas DESC;

--- 13. qry_VentasPorHora : Ventas por Hora del Día: Determinar las horas pico de compras para optimizar campañas de marketing.

SELECT 
    HOUR(v.fecha_venta) AS hora_del_dia,
    COUNT(v.id_venta) AS total_ventas,
    SUM(v.total) AS total_ventas_por_hora
FROM 
    venta v
WHERE 
    v.estado IN ('Enviado', 'Entregado')  -- Considerar solo ventas completadas
GROUP BY 
    hora_del_dia
ORDER BY 
    hora_del_dia;

--- 14. qry_ImpactoPromos : Impacto de Promociones: Comparar las ventas de un producto antes, durante y después de una campaña de descuento.

CREATE OR REPLACE VIEW qry_ImpactoPromos AS
SELECT ...
FROM ...
WHERE ...;

--- 15. qry_CohorteClientes : Análisis de Cohorte: Analizar la retención de clientes mes a mes desde su primera compra.

CREATE OR REPLACE VIEW qry_CohorteClientes AS
SELECT ...
FROM ...
WHERE ...;

--- 16. qry_MargenProducto : Margen de Beneficio por Producto: Calcular el margen de beneficio para cada producto (requiere agregar un campo costo a la tabla de productos).

CREATE OR REPLACE VIEW qry_MargenProducto AS
SELECT ...
FROM ...
WHERE ...;

--- 17. qry_TiempoEntreCompras : Tiempo Promedio Entre Compras: Calcular el tiempo medio que tarda un cliente en volver a comprar.

CREATE OR REPLACE VIEW qry_TiempoEntreCompras AS
SELECT ...
FROM ...
WHERE ...;

--- 18. qry_VistosVsComprados : Productos Más Vistos vs. Comprados: Comparar los productos más visitados con los más comprados.

CREATE OR REPLACE VIEW qry_VistosVsComprados AS
SELECT ...
FROM ...
WHERE ...;

--- 19. qry_SegmentacionRFM : Segmentación de Clientes (RFM): Clasificar a los clientes en segmentos según Recencia, Frecuencia y Valor Monetario.

CREATE OR REPLACE VIEW qry_SegmentacionRFM AS
SELECT ...
FROM ...
WHERE ...;

--- 20. qry_PrediccionDemanda : Predicción de Demanda Simple: Utilizar datos de ventas pasadas para proyectar las ventas del próximo mes para una categoría específica.

CREATE OR REPLACE VIEW qry_PrediccionDemanda AS
SELECT ...
FROM ...
WHERE ...;
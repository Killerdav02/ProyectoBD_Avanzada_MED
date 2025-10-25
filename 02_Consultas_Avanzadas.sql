--- 1. qry_TopProductos : Top 10 Productos Más Vendidos: Generar un ranking con los 10 productos que han generado más ingresos.

CREATE OR REPLACE VIEW qry_TopProductos AS
SELECT 
    p.id_producto,
    p.nombre,
    SUM(pv.cantidad * pv.precio_unitario) AS ingreso_total,
    SUM(pv.cantidad) AS total_vendido
FROM producto_venta pv
JOIN producto p ON pv.id_producto_fk = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY ingreso_total DESC
LIMIT 10;

--Verificar que la vista se creó correctamente:

SHOW FULL TABLES IN e_commerce_db WHERE TABLE_TYPE LIKE 'VIEW';

--Consultar los datos de la vista para ver los resultados:

SELECT * FROM qry_TopProductos;


--- 2. qry_ProductosBajos : Productos con Bajas Ventas: Identificar los productos en el 10% inferior de ventas para considerar su descontinuación.

CREATE OR REPLACE VIEW qry_ProductosBajos AS
WITH ranked_products AS (
    SELECT 
        p.id_producto,
        p.nombre,
        COALESCE(SUM(pv.cantidad), 0) AS total_vendido,
        ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(pv.cantidad), 0) ASC) AS rn,
        COUNT(*) OVER () AS total_productos
    FROM producto p
    LEFT JOIN producto_venta pv ON p.id_producto = pv.id_producto_fk
    GROUP BY p.id_producto, p.nombre
)
SELECT id_producto, nombre, total_vendido
FROM ranked_products
WHERE rn <= total_productos * 0.1;

--Luego, para consultar la vista y ver los productos:--

SELECT * 
FROM qry_ProductosBajos;


--- 3. qry_ClientesVIP : Clientes VIP: Listar los 5 clientes con el mayor valor de vida (LTV), basado en su gasto total histórico.

-- Crear o reemplazar la vista
CREATE OR REPLACE VIEW qry_ClientesVIP AS
SELECT 
    c.id_cliente,
    c.nombre,
    c.apellido,
    SUM(v.total) AS total_gastado
FROM cliente c
JOIN venta v ON c.id_cliente = v.id_cliente_fk
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY total_gastado DESC
LIMIT 5;

-- Consultar la vista
SELECT * FROM qry_ClientesVIP;

--- 4. qry_VentasMensuales : Análisis de Ventas Mensuales: Mostrar las ventas totales agrupadas por mes y año.

-- Crear o reemplazar la vista
CREATE OR REPLACE VIEW qry_VentasMensuales AS
SELECT 
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    SUM(total) AS total_ventas
FROM venta
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;

-- Consultar la vista
SELECT * FROM qry_VentasMensuales;

--- 5. qry_CrecimientoClientes : Crecimiento de Clientes: Calcular el número de nuevos clientes registrados por trimestre.

-- Crear o reemplazar la vista
CREATE OR REPLACE VIEW qry_CrecimientoClientes AS
SELECT
    YEAR(fecha_registro) AS anio,
    QUARTER(fecha_registro) AS trimestre,
    COUNT(*) AS nuevos_clientes
FROM cliente
GROUP BY YEAR(fecha_registro), QUARTER(fecha_registro)
ORDER BY anio, trimestre;

-- Consultar la vista
SELECT * FROM qry_CrecimientoClientes;

--- 6. qry_TasaRecompra : Tasa de Compra Repetida: Determinar qué porcentaje de clientes ha realizado más de una compra.

-- Crear o reemplazar la vista
CREATE OR REPLACE VIEW qry_TasaRecompra AS
SELECT 
    ROUND(
        100 * SUM(CASE WHEN num_compras > 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS porcentaje_clientes_recompra
FROM (
    SELECT 
        id_cliente_fk, 
        COUNT(*) AS num_compras
    FROM venta
    GROUP BY id_cliente_fk
) AS subconsulta;

-- Consultar la vista
SELECT * FROM qry_TasaRecompra;

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
SELECT
    p.id_producto,
    p.nombre AS producto,
    d.id_descuento,
    SUM(CASE WHEN v.fecha_venta < d.fecha_inicio THEN pv.cantidad ELSE 0 END) AS ventas_antes,
    SUM(CASE WHEN v.fecha_venta BETWEEN d.fecha_inicio AND d.fecha_fin THEN pv.cantidad ELSE 0 END) AS ventas_durante,
    SUM(CASE WHEN v.fecha_venta > d.fecha_fin THEN pv.cantidad ELSE 0 END) AS ventas_despues
FROM producto p
JOIN producto_venta pv ON p.id_producto = pv.id_producto_fk
JOIN venta v ON pv.id_venta_fk = v.id_venta
JOIN descuento d ON v.id_descuento_fk = d.id_descuento
GROUP BY p.id_producto, p.nombre, d.id_descuento, d.fecha_inicio, d.fecha_fin;


INSERT INTO `e_commerce_db`.`venta` (`fecha_venta`, `estado`,`total`,`id_cliente_fk`,`id_tienda_fk`,`id_descuento_fk`,`id_tarifa_envio_fk`)
VALUES
('2025-09-01', 'Pendiente','0.00','1','1','1','2');
INSERT INTO `e_commerce_db`.`descuento` (`id_descuento`,`tipo`, `valor`, `nombre`, `fecha_inicio`, `fecha_fin`)
VALUES
(3,'producto', 0.10, 'porcentaje', '2025-10-01', '2025-11-01');

SELECT *
FROM qry_ImpactoPromos
WHERE id_descuento = 1;

--- 15. qry_CohorteClientes : Análisis de Cohorte: Analizar la retención de clientes mes a mes desde su primera compra.

CREATE OR REPLACE VIEW qry_CohorteClientes AS
SELECT
    c.id_cliente,
    CONCAT(YEAR(c.fecha_registro), '-', LPAD(MONTH(c.fecha_registro), 2, '0')) AS mes_registro,
    CONCAT(YEAR(v.fecha_venta), '-', LPAD(MONTH(v.fecha_venta), 2, '0')) AS mes_venta,
    TIMESTAMPDIFF(MONTH, c.fecha_registro, v.fecha_venta) AS meses_desde_registro,
    COUNT(v.id_venta) AS total_compras
FROM cliente c
LEFT JOIN venta v ON c.id_cliente = v.id_cliente_fk
GROUP BY c.id_cliente, mes_registro, mes_venta, meses_desde_registro;

SELECT *
FROM qry_CohorteClientes
WHERE mes_registro = '2025-10';

--- 16. qry_MargenProducto : Margen de Beneficio por Producto: Calcular el margen de beneficio para cada producto (requiere agregar un campo costo a la tabla de productos).

CREATE OR REPLACE VIEW qry_MargenProducto AS
SELECT
    p.id_producto,
    p.nombre AS producto,
    p.precio AS costo,
    p.precio_iva AS precio_venta,
    ROUND(((p.precio_iva - p.precio) / p.precio) * 100, 2) AS margen_porcentaje,
    (p.precio_iva - p.precio) AS margen_valor
FROM producto p
WHERE p.precio IS NOT NULL AND p.precio_iva IS NOT NULL;


--- 17. qry_TiempoEntreCompras : Tiempo Promedio Entre Compras: Calcular el tiempo medio que tarda un cliente en volver a comprar.

CREATE OR REPLACE VIEW qry_TiempoEntreCompras AS
SELECT ROUND(AVG(diff_dias), 1) AS promedio_dias_entre_compras
FROM (
    SELECT id_cliente_fk,
          DATEDIFF(
              fecha_venta,
              LAG(fecha_venta) OVER (PARTITION BY id_cliente_fk ORDER BY fecha_venta)
          ) AS diff_dias
    FROM venta
) AS sub
WHERE diff_dias IS NOT NULL;


CREATE OR REPLACE VIEW qry_TiempoEntreCompras_id AS
SELECT
    c.id_cliente,
    ROUND(AVG(DATEDIFF(v2.fecha_venta, v1.fecha_venta)),1) AS promedio_dias_entre_compras
FROM cliente c
JOIN venta v1 ON c.id_cliente = v1.id_cliente_fk
JOIN venta v2 ON c.id_cliente = v2.id_cliente_fk AND v2.fecha_venta > v1.fecha_venta
GROUP BY c.id_cliente;


SELECT *
FROM qry_TiempoEntreCompras_id
WHERE id_cliente = 1;

--- 18. qry_VistosVsComprados : Productos Más Vistos vs. Comprados: Comparar los productos más visitados con los más comprados.

CREATE TABLE IF NOT EXISTS producto_visita (
    id_producto_fk INT NOT NULL,
    cantidad_visitas INT NOT NULL DEFAULT 0,
    fecha_visita DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_producto_fk, fecha_visita),
    FOREIGN KEY (id_producto_fk) REFERENCES producto(id_producto)
);


CREATE OR REPLACE VIEW qry_VistosVsComprados AS
SELECT
    p.id_producto,
    p.nombre AS producto,
    IFNULL(pv_comp.total_comprado, 0) AS total_comprado,
    IFNULL(pv_vis.total_visto, 0) AS total_visto
FROM producto p
LEFT JOIN (
    SELECT id_producto_fk, SUM(cantidad) AS total_comprado
    FROM producto_venta
    GROUP BY id_producto_fk
) pv_comp ON p.id_producto = pv_comp.id_producto_fk
LEFT JOIN (
    SELECT id_producto_fk, SUM(cantidad_visitas) AS total_visto
    FROM producto_visita
    GROUP BY id_producto_fk
) pv_vis ON p.id_producto = pv_vis.id_producto_fk
ORDER BY total_visto DESC, total_comprado DESC;



--- 19. qry_SegmentacionRFM : Segmentación de Clientes (RFM): Clasificar a los clientes en segmentos según Recencia, Frecuencia y Valor Monetario.

CREATE OR REPLACE VIEW qry_SegmentacionRFM AS
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    DATEDIFF(CURDATE(), MAX(v.fecha_venta)) AS recencia,
    COUNT(v.id_venta) AS frecuencia,
    SUM(v.total) AS valor_monetario
FROM cliente c
LEFT JOIN venta v ON c.id_cliente = v.id_cliente_fk
GROUP BY c.id_cliente, c.nombre, c.apellido;

SELECT * FROM qry_SegmentacionRFM;


--- 20. qry_PrediccionDemanda : Predicción de Demanda Simple: Utilizar datos de ventas pasadas para proyectar las ventas del próximo mes para una categoría específica.

CREATE OR REPLACE VIEW qry_PrediccionDemanda AS
SELECT
    c.id_categoria,
    c.nombre AS categoria,
    AVG(pv.cantidad) AS ventas_promedio_ultimo_mes,
    ROUND(AVG(pv.cantidad), 0) AS prediccion_proximo_mes
FROM categoria c
JOIN producto_categoria pc ON c.id_categoria = pc.id_categoria_fk
JOIN producto p ON pc.id_producto_fk = p.id_producto
JOIN producto_venta pv ON p.id_producto = pv.id_producto_fk
JOIN venta v ON pv.id_venta_fk = v.id_venta
WHERE v.fecha_venta >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY c.id_categoria, c.nombre;


SELECT * FROM qry_PrediccionDemanda;


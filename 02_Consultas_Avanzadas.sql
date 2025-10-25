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

CREATE OR REPLACE VIEW qry_ProductosFrecuentes AS
SELECT ...
FROM ...
WHERE ...;


--- 8. qry_RotacionInventario : Rotación de Inventario: Calcular la tasa de rotación de stock para cada categoría de producto.

CREATE OR REPLACE VIEW qry_RotacionInventario AS
SELECT ...
FROM ...
WHERE ...;


--- 9. qry_Reabastecimiento : Productos que Necesitan Reabastecimiento: Listar productos cuyo stock actual esté por debajo de su umbral mínimo.

CREATE OR REPLACE VIEW qry_Reabastecimiento AS
SELECT ...
FROM ...
WHERE ...;


--- 10. qry_CarritosAbandonados : Análisis de Carrito Abandonado (Simulado): Identificar clientes que agregaron productos pero no completaron una venta en un período determinado.

CREATE OR REPLACE VIEW qry_CarritosAbandonados AS
SELECT ...
FROM ...
WHERE ...;


--- 11. qry_RendimientoProveedores : Rendimiento de Proveedores: Clasificar a los proveedores según el volumen de ventas de sus productos.

CREATE OR REPLACE VIEW qry_RendimientoProveedores AS
SELECT ...
FROM ...
WHERE ...;


--- 12. qry_VentasPorRegion : Análisis Geográfico de Ventas: Agrupar las ventas por ciudad o región del cliente.

CREATE OR REPLACE VIEW qry_VentasPorRegion AS
SELECT ...
FROM ...
WHERE ...;


--- 13. qry_VentasPorHora : Ventas por Hora del Día: Determinar las horas pico de compras para optimizar campañas de marketing.

CREATE OR REPLACE VIEW qry_VentasPorHora AS
SELECT ...
FROM ...
WHERE ...;


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


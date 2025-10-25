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

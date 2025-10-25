-- 1. evt_generate_weekly_sales_report: Genera un reporte de ventas semanal.

DROP EVENT IF EXISTS evt_generate_weekly_sales_report;

DELIMITER //

CREATE EVENT evt_generate_weekly_sales_report
ON SCHEDULE
    EVERY 1 WEEK
DO
BEGIN
    -- Lógica para generar el reporte de ventas semanal

END //

DELIMITER ;


-- 2. evt_cleanup_temp_tables_daily: Borra tablas temporales diariamente.

DROP EVENT IF EXISTS evt_cleanup_temp_tables_daily;

DELIMITER //

CREATE EVENT evt_cleanup_temp_tables_daily
ON SCHEDULE
    EVERY 1 DAY
DO
BEGIN
    -- Lógica para eliminar tablas temporales

END //

DELIMITER ;


-- 3. evt_archive_old_logs_monthly: Archiva logs de más de 6 meses.

DROP EVENT IF EXISTS evt_archive_old_logs_monthly;

DELIMITER //

CREATE EVENT evt_archive_old_logs_monthly
ON SCHEDULE
    EVERY 1 MONTH
DO
BEGIN
    -- Lógica para archivar logs antiguos

END //

DELIMITER ;


-- 4. evt_deactivate_expired_promotions_hourly: Desactiva códigos de descuento expirados.

DROP EVENT IF EXISTS evt_deactivate_expired_promotions_hourly;

DELIMITER //

CREATE EVENT evt_deactivate_expired_promotions_hourly
ON SCHEDULE
    EVERY 1 HOUR
DO
BEGIN
    -- Lógica para desactivar promociones vencidas

END //

DELIMITER ;


-- 5. evt_recalculate_customer_loyalty_tiers_nightly: Recalcula niveles de lealtad cada noche.

DROP EVENT IF EXISTS evt_recalculate_customer_loyalty_tiers_nightly;

DELIMITER //

CREATE EVENT evt_recalculate_customer_loyalty_tiers_nightly
ON SCHEDULE
    EVERY 1 DAY
    STARTS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
BEGIN
    -- Lógica para recalcular niveles de lealtad

END //

DELIMITER ;


-- 6. evt_generate_reorder_list_daily: Crea lista de productos para reabastecer.

DROP EVENT IF EXISTS evt_generate_reorder_list_daily;

DELIMITER //

CREATE EVENT evt_generate_reorder_list_daily
ON SCHEDULE
    EVERY 1 DAY
DO
BEGIN
    -- Lógica para generar lista de reorden

END //

DELIMITER ;


-- 7. evt_rebuild_indexes_weekly: Reconstruye índices para optimizar rendimiento.

DROP EVENT IF EXISTS evt_rebuild_indexes_weekly;

DELIMITER //

CREATE EVENT evt_rebuild_indexes_weekly
ON SCHEDULE
    EVERY 1 WEEK
DO
BEGIN
    -- Lógica para reconstruir índices

END //

DELIMITER ;


-- 8. evt_suspend_inactive_accounts_quarterly: Desactiva cuentas sin actividad.

DROP EVENT IF EXISTS evt_suspend_inactive_accounts_quarterly;

DELIMITER //

CREATE EVENT evt_suspend_inactive_accounts_quarterly
ON SCHEDULE
    EVERY 3 MONTH
DO
BEGIN
    -- Lógica para suspender cuentas inactivas

END //

DELIMITER ;


-- 9. evt_aggregate_daily_sales_data: Agrega ventas diarias en tabla resumen.

DROP EVENT IF EXISTS evt_aggregate_daily_sales_data;

DELIMITER //

CREATE EVENT evt_aggregate_daily_sales_data
ON SCHEDULE
    EVERY 1 DAY
DO
BEGIN
    -- Lógica para consolidar datos de ventas del día

END //

DELIMITER ;


-- 10. evt_check_data_consistency_nightly: Busca inconsistencias en los datos.

DROP EVENT IF EXISTS evt_check_data_consistency_nightly;

DELIMITER //

CREATE EVENT evt_check_data_consistency_nightly
ON SCHEDULE
    EVERY 1 DAY
DO
BEGIN
    -- Lógica para verificar consistencia de datos

END //

DELIMITER ;


-- 11. evt_send_birthday_greetings_daily: Envía cupones a clientes que cumplen años.

DROP EVENT IF EXISTS evt_send_birthday_greetings_daily;

DELIMITER //

CREATE EVENT evt_send_birthday_greetings_daily
ON SCHEDULE
    EVERY 1 DAY
DO
BEGIN
    -- Lógica para generar felicitaciones y cupones

END //

DELIMITER ;


-- 12. evt_update_product_rankings_hourly: Actualiza ranking de productos.

DROP EVENT IF EXISTS evt_update_product_rankings_hourly;

DELIMITER //

CREATE EVENT evt_update_product_rankings_hourly
ON SCHEDULE
    EVERY 1 HOUR
DO
BEGIN
    -- Lógica para recalcular popularidad de productos

END //

DELIMITER ;


-- 13. evt_backup_critical_tables_daily: Realiza backup de tablas críticas.

DROP EVENT IF EXISTS evt_backup_critical_tables_daily;

DELIMITER //

CREATE EVENT evt_backup_critical_tables_daily
ON SCHEDULE
    EVERY 1 DAY
DO
BEGIN
    -- Lógica para realizar copias de seguridad

END //

DELIMITER ;


-- 14. evt_clear_abandoned_carts_daily: Limpia carritos abandonados.

DROP EVENT IF EXISTS evt_clear_abandoned_carts_daily;

DELIMITER //

CREATE EVENT evt_clear_abandoned_carts_daily
ON SCHEDULE
    EVERY 1 DAY
DO
BEGIN
    -- Lógica para eliminar carritos de más de 72 horas

END //

DELIMITER ;


-- 15. evt_calculate_monthly_kpis: Calcula KPIs mensuales.

CREATE TABLE KPIs (
    id_kpi INT AUTO_INCREMENT PRIMARY KEY,
    mes INT NOT NULL,
    año INT NOT NULL,
    total_venta DECIMAL(12,2) DEFAULT 0,
    cliente_nuevo INT DEFAULT 0,
    producto_vendido VARCHAR(255),
    fecha_calculo DATETIME DEFAULT CURRENT_TIMESTAMP
);


DROP EVENT IF EXISTS evt_calculate_monthly_kpis;

DELIMITER //

CREATE EVENT evt_calculate_monthly_kpis
ON SCHEDULE
    EVERY 1 MONTH
    STARTS '2025-11-01 00:00:00'
DO
BEGIN
    DECLARE total DECIMAL(12,2);
    DECLARE nuevos_clientes INT;
    DECLARE productos VARCHAR(255);


    SELECT SUM(total) INTO total
    FROM venta
    WHERE MONTH(fecha_venta) = MONTH(CURDATE() - INTERVAL 1 MONTH)
      AND YEAR(fecha_venta) = YEAR(CURDATE() - INTERVAL 1 MONTH);


    SELECT COUNT(*) INTO nuevos_clientes
    FROM cliente
    WHERE MONTH(fecha_registro) = MONTH(CURDATE() - INTERVAL 1 MONTH)
      AND YEAR(fecha_registro) = YEAR(CURDATE() - INTERVAL 1 MONTH);


    SELECT GROUP_CONCAT(p.nombre ORDER BY SUM(pv.cantidad)) INTO productos
    FROM producto_venta pv
    JOIN producto p ON pv.id_producto_fk = p.id_producto
    JOIN venta v ON pv.id_venta_fk = v.id_venta
    WHERE MONTH(v.fecha_venta) = MONTH(CURDATE() - INTERVAL 1 MONTH)
      AND YEAR(v.fecha_venta) = YEAR(CURDATE() - INTERVAL 1 MONTH)
    GROUP BY MONTH(v.fecha_venta), YEAR(v.fecha_venta);

    INSERT INTO KPIs (mes, año, total_venta, cliente_nuevo, producto_vendido)
    VALUES (MONTH(CURDATE() - INTERVAL 1 MONTH),
            YEAR(CURDATE() - INTERVAL 1 MONTH),
            total,
            nuevos_clientes,
            productos);

END //

DELIMITER ;


-- 16. evt_refresh_materialized_views_nightly: Actualiza vistas materializadas.

DROP EVENT IF EXISTS evt_refresh_materialized_views_nightly;

DELIMITER //

CREATE EVENT evt_refresh_materialized_views_nightly
ON SCHEDULE
    EVERY 1 DAY
    STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
BEGIN
    -- Actualizar vistas materializadas (simuladas con tablas)

    -- Refrescar resumen de ventas
    TRUNCATE TABLE mv_resumen_ventas;
    INSERT INTO mv_resumen_ventas
    SELECT * FROM qry_ResumenVentas;  -- o la consulta base que alimenta la vista

    -- Refrescar top productos
    TRUNCATE TABLE mv_top_productos;
    INSERT INTO mv_top_productos
    SELECT * FROM qry_TopProductos;

    -- Refrescar clientes activos
    TRUNCATE TABLE mv_clientes_activos;
    INSERT INTO mv_clientes_activos
    SELECT * FROM qry_ClientesActivos;
END //

DELIMITER ;


-- 17. evt_log_database_size_weekly: Registra el tamaño de la base de datos.

CREATE TABLE IF NOT EXISTS historial_tamano_bd (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    nombre_bd VARCHAR(100),
    tamano_mb DECIMAL(10,2)
);

SET GLOBAL event_scheduler = ON;
SHOW VARIABLES LIKE 'event_scheduler';

DROP EVENT IF EXISTS evt_log_database_size_weekly;

DELIMITER //

CREATE EVENT evt_log_database_size_weekly
ON SCHEDULE
    EVERY 1 WEEK
    STARTS CURRENT_TIMESTAMP + INTERVAL 1 WEEK
DO
BEGIN
    INSERT INTO historial_tamano_bd (nombre_bd, tamano_mb)
    SELECT
        table_schema AS nombre_bd,
        ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS tamano_mb
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
    GROUP BY table_schema;
END //

DELIMITER ;


-- 18. evt_detect_fraudulent_activity_hourly: Detecta actividad sospechosa.

CREATE TABLE IF NOT EXISTS historial_fraude (
    id_fraude INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    total_compras INT,
    fecha_detectado DATETIME DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT
);


DROP EVENT IF EXISTS evt_detect_fraudulent_activity_daily;

DELIMITER //

CREATE EVENT evt_detect_fraudulent_activity_daily
ON SCHEDULE
    EVERY 1 DAY
    STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
BEGIN
    INSERT INTO historial_fraude (id_cliente, total_compras, motivo)
    SELECT
        v.id_cliente_fk,
        COUNT(*) AS total_compras,
        'Cliente con más de 3 compras en un mismo día'
    FROM venta v
    WHERE DATE(v.fecha_venta) = CURDATE() - INTERVAL 1 DAY
    GROUP BY v.id_cliente_fk
    HAVING COUNT(*) > 3;
END //

DELIMITER ;



-- 19. evt_generate_supplier_performance_report_monthly: Genera reporte de proveedores.

CREATE TABLE IF NOT EXISTS reporte_proveedores (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT,
    mes INT,
    anio INT,
    total_productos_entregados INT,
    total_ventas DECIMAL(12,2),
    promedio_precio DECIMAL(12,2),
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP
);


DROP EVENT IF EXISTS evt_generate_supplier_performance_report_monthly;

DELIMITER //

CREATE EVENT evt_generate_supplier_performance_report_monthly
ON SCHEDULE
    EVERY 1 MONTH
    STARTS CURRENT_TIMESTAMP + INTERVAL 1 MONTH
DO
BEGIN
    INSERT INTO reporte_proveedores (id_proveedor, mes, anio, total_productos_entregados, total_ventas, promedio_precio)
    SELECT
        p.id_proveedor_fk,
        MONTH(CURDATE() - INTERVAL 1 MONTH),
        YEAR(CURDATE() - INTERVAL 1 MONTH),
        COUNT(pr.id_producto) AS total_productos_entregados,
        SUM(v.total) AS total_ventas,
        ROUND(AVG(pr.precio), 2) AS promedio_precio
    FROM producto pr
    JOIN proveedor p ON pr.id_proveedor_fk = p.id_proveedor
    JOIN producto_venta pv ON pv.id_producto_fk = pr.id_producto
    JOIN venta v ON v.id_venta = pv.id_venta_fk
    WHERE MONTH(v.fecha_venta) = MONTH(CURDATE() - INTERVAL 1 MONTH)
      AND YEAR(v.fecha_venta) = YEAR(CURDATE() - INTERVAL 1 MONTH)
    GROUP BY p.id_proveedor_fk;
END //

DELIMITER ;



-- 20. evt_purge_soft_deleted_records_weekly: Elimina registros marcados como borrados.

DROP EVENT IF EXISTS evt_purge_old_deleted_sales;

DELIMITER //

CREATE EVENT evt_purge_old_deleted_sales
ON SCHEDULE
    EVERY 1 WEEK
    STARTS CURRENT_TIMESTAMP + INTERVAL 1 WEEK
DO
BEGIN
    DELETE FROM venta_eliminada
    WHERE fecha_eliminacion < (CURDATE() - INTERVAL 6 MONTH);
END //

DELIMITER ;


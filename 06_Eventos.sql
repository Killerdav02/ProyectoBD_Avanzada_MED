evt_generate_weekly_sales_report: Genera un reporte de ventas semanal.

DROP EVENT IF EXISTS evt_generate_weekly_sales_report;

DELIMITER $$
CREATE EVENT evt_generate_weekly_sales_report
ON SCHEDULE EVERY 1 WEEK
STARTS TIMESTAMP(CURRENT_DATE) + INTERVAL 1 WEEK - INTERVAL WEEKDAY(CURRENT_DATE) DAY
DO
BEGIN
    DECLARE v_total_ventas DECIMAL(12,2);
    DECLARE v_total_productos INT;

    -- Calcular total de ventas de la última semana
    SELECT
        COALESCE(SUM(v.total), 0),
        COALESCE(SUM(pv.cantidad), 0)
    INTO v_total_ventas, v_total_productos
    FROM venta v
    LEFT JOIN producto_venta pv ON v.id_venta = pv.id_venta_fk
    WHERE v.fecha_venta >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
    AND v.estado != 'Cancelado';

    -- Insertar reporte en la tabla
    INSERT INTO reporte_ventas_semanal (fecha_reporte, total_ventas, total_productos)
    VALUES (NOW(), v_total_ventas, v_total_productos);
END$$
DELIMITER ;


-- EJECUTAR MANUALMENTE EL REPORTE SEMANAL
INSERT INTO reporte_ventas_semanal (fecha_reporte, total_ventas, total_productos)
SELECT
    NOW() as fecha_reporte,
    COALESCE(SUM(v.total), 0) as total_ventas,
    COALESCE(SUM(pv.cantidad), 0) as total_productos
FROM venta v
LEFT JOIN producto_venta pv ON v.id_venta = pv.id_venta_fk
WHERE v.fecha_venta >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
AND v.estado != 'Cancelado';

-- Ver el resultado
SELECT * FROM reporte_ventas_semanal ORDER BY fecha_reporte DESC;


-- 2. evt_cleanup_temp_tables_daily: Borra tablas temporales diariamente.DROP EVENT IF EXISTS evt_cleanup_temp_tables_daily;

DELIMITER $$
CREATE EVENT evt_cleanup_temp_tables_daily
ON SCHEDULE EVERY 2 MINUTE
STARTS CURRENT_TIMESTAMP + INTERVAL 2 MINUTE
DO
BEGIN
    DECLARE v_count INT DEFAULT 0;

    DELETE FROM carrito
    WHERE id_cliente_fk IN (
        SELECT DISTINCT c.id_cliente_fk
        FROM (SELECT * FROM carrito) c
        LEFT JOIN venta v ON c.id_cliente_fk = v.id_cliente_fk
        WHERE v.id_cliente_fk IS NULL
        OR v.fecha_venta < DATE_SUB(NOW(), INTERVAL 30 DAY)
        GROUP BY c.id_cliente_fk
        HAVING MAX(v.fecha_venta) < DATE_SUB(NOW(), INTERVAL 30 DAY)
        OR MAX(v.fecha_venta) IS NULL
    );

    SET v_count = ROW_COUNT();

    INSERT INTO log_cleanup_temp (fecha_limpieza, tablas_eliminadas, descripcion)
    VALUES (NOW(), v_count, CONCAT('Limpieza automática: ', v_count, ' registros'));
END$$
DELIMITER ;


============ VERSIÓN MANUAL ============
-- Ejecutar para limpiar carritos abandonados INMEDIATAMENTE

DELETE FROM carrito
WHERE id_cliente_fk IN (
    SELECT DISTINCT c.id_cliente_fk
    FROM (SELECT * FROM carrito) c
    LEFT JOIN venta v ON c.id_cliente_fk = v.id_cliente_fk
    WHERE v.id_cliente_fk IS NULL
    OR v.fecha_venta < DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY c.id_cliente_fk
    HAVING MAX(v.fecha_venta) < DATE_SUB(NOW(), INTERVAL 30 DAY)
    OR MAX(v.fecha_venta) IS NULL
);

-- Registrar la limpieza manual
INSERT INTO log_cleanup_temp (fecha_limpieza, tablas_eliminadas, descripcion)
VALUES (NOW(), ROW_COUNT(), CONCAT('Limpieza MANUAL de carritos abandonados: ', ROW_COUNT(), ' registros'));

-- Verificar resultado
SELECT * FROM log_cleanup_temp ORDER BY fecha_limpieza DESC LIMIT 5;

-- 3. evt_archive_old_logs_monthly: Archiva logs de más de 6 meses.


-- Eliminar el evento si ya existe
DROP EVENT IF EXISTS evt_archive_old_logs_monthly;

-- Crear el evento automático
DELIMITER $$
CREATE EVENT evt_archive_old_logs_monthly
ON SCHEDULE EVERY 3 MINUTE  -- Se ejecuta cada 3 minutos automáticamente
STARTS CURRENT_TIMESTAMP + INTERVAL 3 MINUTE  -- Inicia en 3 minutos
DO
BEGIN
    DECLARE v_clientes INT DEFAULT 0;
    DECLARE v_precios INT DEFAULT 0;

    -- Archivar auditoría de clientes mayores a 6 meses
    INSERT INTO auditoria_cliente_historico
        (id_auditoria, id_cliente_fk, nombre, email, fecha_registro, fecha_archivo)
    SELECT
        id_auditoria, id_cliente_fk, nombre, email, fecha_registro, NOW()
    FROM auditoria_cliente
    WHERE fecha_registro < DATE_SUB(NOW(), INTERVAL 6 MONTH);

    SET v_clientes = ROW_COUNT();

    -- Eliminar de tabla activa los registros archivados
    DELETE FROM auditoria_cliente
    WHERE fecha_registro < DATE_SUB(NOW(), INTERVAL 6 MONTH);

    -- Archivar auditoría de precios mayores a 6 meses
    INSERT INTO auditoria_precio_historico
        (id_auditoria, id_producto_fk, precio_anterior, precio_nuevo, fecha_cambio, fecha_archivo)
    SELECT
        id_auditoria, id_producto_fk, precio_anterior, precio_nuevo, fecha_cambio, NOW()
    FROM auditoria_precio
    WHERE fecha_cambio < DATE_SUB(NOW(), INTERVAL 6 MONTH);

    SET v_precios = ROW_COUNT();

    -- Eliminar de tabla activa los registros archivados
    DELETE FROM auditoria_precio
    WHERE fecha_cambio < DATE_SUB(NOW(), INTERVAL 6 MONTH);
END$$
DELIMITER ;

-- =====================================================
-- VERIFICACIÓN: Comprobar que el evento está activo
-- =====================================================

-- Ver si el evento se creó correctamente
SHOW EVENTS FROM e_commerce_db WHERE name = 'evt_archive_old_logs_monthly';

-- Ver detalles completos del evento
SELECT
    EVENT_NAME as 'Nombre del Evento',
    EVENT_TYPE as 'Tipo',
    STATUS as 'Estado',
    INTERVAL_VALUE as 'Cada',
    INTERVAL_FIELD as 'Unidad',
    STARTS as 'Inicia',
    LAST_EXECUTED as 'Última Ejecución',
    EVENT_DEFINITION as 'Definición'
FROM information_schema.EVENTS
WHERE EVENT_SCHEMA = 'e_commerce_db'
AND EVENT_NAME = 'evt_archive_old_logs_monthly';

-- =====================================================
-- DATOS DE PRUEBA: Insertar registros antiguos
-- =====================================================

-- Insertar clientes con fechas antiguas (> 6 meses)
INSERT INTO auditoria_cliente (id_cliente_fk, nombre, email, fecha_registro)
VALUES
(1, 'Auto Cliente 1', 'auto1@example.com', DATE_SUB(NOW(), INTERVAL 7 MONTH)),
(2, 'Auto Cliente 2', 'auto2@example.com', DATE_SUB(NOW(), INTERVAL 8 MONTH)),
(3, 'Auto Cliente 3', 'auto3@example.com', DATE_SUB(NOW(), INTERVAL 9 MONTH)),
(4, 'Cliente Reciente', 'reciente@example.com', NOW());

-- Insertar precios con fechas antiguas (> 6 meses)
INSERT INTO auditoria_precio (id_producto_fk, precio_anterior, precio_nuevo, fecha_cambio)
VALUES
(1, 100000.00, 120000.00, DATE_SUB(NOW(), INTERVAL 7 MONTH)),
(2, 150000.00, 180000.00, DATE_SUB(NOW(), INTERVAL 8 MONTH)),
(3, 200000.00, 220000.00, DATE_SUB(NOW(), INTERVAL 9 MONTH)),
(4, 50000.00, 55000.00, NOW());

-- =====================================================
-- ANTES: Ver registros ANTES del archivado automático
-- =====================================================

SELECT 'ANTES DEL ARCHIVADO AUTOMÁTICO' as estado, '=' as separador;

SELECT
    'Clientes Activos' as tabla,
    COUNT(*) as registros,
    SUM(CASE WHEN fecha_registro < DATE_SUB(NOW(), INTERVAL 6 MONTH) THEN 1 ELSE 0 END) as 'serán_archivados'
FROM auditoria_cliente
UNION ALL
SELECT
    'Clientes Históricos',
    COUNT(*),
    NULL
FROM auditoria_cliente_historico
UNION ALL
SELECT
    'Precios Activos',
    COUNT(*),
    SUM(CASE WHEN fecha_cambio < DATE_SUB(NOW(), INTERVAL 6 MONTH) THEN 1 ELSE 0 END)
FROM auditoria_precio
UNION ALL
SELECT
    'Precios Históricos',
    COUNT(*),
    NULL
FROM auditoria_precio_historico;

-- Ver detalle de registros que serán archivados
SELECT
    ' Estos clientes serán archivados en 3 minutos' as info,
    id_auditoria,
    nombre,
    DATE_FORMAT(fecha_registro, '%Y-%m-%d') as fecha,
    CONCAT(TIMESTAMPDIFF(MONTH, fecha_registro, NOW()), ' meses') as antiguedad
FROM auditoria_cliente
WHERE fecha_registro < DATE_SUB(NOW(), INTERVAL 6 MONTH);

SELECT
    ' Estos precios serán archivados en 3 minutos' as info,
    id_auditoria,
    id_producto_fk,
    precio_anterior,
    precio_nuevo,
    DATE_FORMAT(fecha_cambio, '%Y-%m-%d') as fecha,
    CONCAT(TIMESTAMPDIFF(MONTH, fecha_cambio, NOW()), ' meses') as antiguedad
FROM auditoria_precio
WHERE fecha_cambio < DATE_SUB(NOW(), INTERVAL 6 MONTH);



-- 4. evt_deactivate_expired_promotions_hourly: Desactiva códigos de descuento expirados.
-- =====================================================
-- EVENTO 4: DESACTIVAR PROMOCIONES EXPIRADAS - AUTOMÁTICO
-- =====================================================

-- Eliminar el evento si ya existe
DROP EVENT IF EXISTS evt_deactivate_expired_promotions_hourly;

-- Crear el evento automático
DELIMITER $$
CREATE EVENT evt_deactivate_expired_promotions_hourly
ON SCHEDULE EVERY 1 MINUTE  -- Se ejecuta cada 1 minuto automáticamente (PRUEBA)
STARTS CURRENT_TIMESTAMP + INTERVAL 1 MINUTE  -- Inicia en 1 minuto
DO
BEGIN
    DECLARE v_desactivados INT DEFAULT 0;

    -- Desactivar descuentos que ya expiraron
    UPDATE descuento
    SET activo = 0
    WHERE fecha_fin < NOW()
    AND activo = 1;

    SET v_desactivados = ROW_COUNT();

    -- Opcional: Log del proceso (puedes descomentar si quieres registro)
    -- INSERT INTO log_descuentos_desactivados VALUES (NOW(), v_desactivados);
END$$
DELIMITER ;

-- =====================================================
-- VERIFICACIÓN: Comprobar que el evento está activo
-- =====================================================

-- Ver si el evento se creó correctamente
SHOW EVENTS FROM e_commerce_db WHERE name = 'evt_deactivate_expired_promotions_hourly';

-- Ver detalles completos del evento
SELECT
    EVENT_NAME as 'Nombre del Evento',
    EVENT_TYPE as 'Tipo',
    STATUS as 'Estado',
    INTERVAL_VALUE as 'Cada',
    INTERVAL_FIELD as 'Unidad',
    STARTS as 'Inicia',
    LAST_EXECUTED as 'Última Ejecución'
FROM information_schema.EVENTS
WHERE EVENT_SCHEMA = 'e_commerce_db'
AND EVENT_NAME = 'evt_deactivate_expired_promotions_hourly';

-- =====================================================
-- PREPARACIÓN: Asegurar que existe el campo 'activo'
-- =====================================================

-- Agregar campo activo si no existe
ALTER TABLE descuento
ADD COLUMN IF NOT EXISTS activo TINYINT DEFAULT 1;

-- Verificar estructura de la tabla
DESC descuento;

-- =====================================================
-- DATOS DE PRUEBA: Insertar descuentos con diferentes estados
-- =====================================================

-- Limpiar descuentos de prueba anteriores (opcional)
DELETE FROM descuento WHERE tipo IN ('producto', 'categoria') AND id_descuento > 1;

-- Insertar descuentos EXPIRADOS (serán desactivados automáticamente)
INSERT INTO descuento (id_descuento, tipo, valor, nombre, fecha_inicio, fecha_fin, activo)
VALUES
(2, 'producto', 15.00, 'porcentaje', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 1),
(3, 'categoria', 20.00, 'porcentaje', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 1),
(4, 'producto', 10.00, 'porcentaje', DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), 1);

-- Insertar descuentos VIGENTES (permanecerán activos)
INSERT INTO descuento (id_descuento, tipo, valor, nombre, fecha_inicio, fecha_fin, activo)
VALUES
(5, 'categoria', 25.00, 'porcentaje', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1),
(6, 'producto', 30.00, 'porcentaje', NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), 1);

-- Insertar descuento que EXPIRA EN 10 SEGUNDOS (para ver la desactivación en tiempo real)
INSERT INTO descuento (id_descuento, tipo, valor, nombre, fecha_inicio, fecha_fin, activo)
VALUES
(7, 'cumpleaños', 5.00, 'porcentaje', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 10 SECOND), 1);

-- =====================================================
-- ANTES: Ver descuentos ANTES de la desactivación automática
-- =====================================================

SELECT 'ANTES DE LA DESACTIVACIÓN AUTOMÁTICA' as estado, '=' as separador;

-- Resumen general
SELECT
    'Total Descuentos' as categoria,
    COUNT(*) as cantidad,
    SUM(CASE WHEN activo = 1 THEN 1 ELSE 0 END) as activos,
    SUM(CASE WHEN activo = 0 THEN 1 ELSE 0 END) as inactivos,
    SUM(CASE WHEN fecha_fin < NOW() AND activo = 1 THEN 1 ELSE 0 END) as 'expirados_pero_activos'
FROM descuento;

-- Ver todos los descuentos con su estado
SELECT
    id_descuento,
    tipo,
    valor,
    activo,
    DATE_FORMAT(fecha_inicio, '%Y-%m-%d %H:%i:%s') as inicio,
    DATE_FORMAT(fecha_fin, '%Y-%m-%d %H:%i:%s') as fin,
    CASE
        WHEN fecha_fin < NOW() THEN '⏰ EXPIRADO'
        WHEN fecha_fin > NOW() THEN '✅ VIGENTE'
    END as estado_fecha,
    CASE
        WHEN activo = 1 THEN '🟢 Activo'
        ELSE '🔴 Inactivo'
    END as estado_sistema,
    CASE
        WHEN fecha_fin < NOW() AND activo = 1 THEN '⚠️ Será desactivado en 1 minuto'
        WHEN fecha_fin > NOW() AND activo = 1 THEN '✓ Permanecerá activo'
        ELSE '- Ya está inactivo'
    END as accion_pendiente,
    TIMESTAMPDIFF(SECOND, NOW(), fecha_fin) as 'segundos_para_expirar'
FROM descuento
ORDER BY fecha_fin;

-- Descuentos que serán desactivados
SELECT
    '⏳ Estos descuentos serán desactivados AUTOMÁTICAMENTE en 1 minuto' as info,
    id_descuento,
    tipo,
    CONCAT(valor, '%') as descuento,
    DATE_FORMAT(fecha_fin, '%Y-%m-%d %H:%i:%s') as 'expiró_en',
    CONCAT(TIMESTAMPDIFF(DAY, fecha_fin, NOW()), ' días atrás') as 'hace_cuanto'
FROM descuento
WHERE fecha_fin < NOW()
AND activo = 1;


-- 5. evt_recalculate_customer_loyalty_tiers_nightly: Recalcula niveles de lealtad cada noche.

-- =====================================================
-- EVENTO 5: RECALCULAR NIVELES DE LEALTAD - AUTOMÁTICO
-- =====================================================

-- Eliminar el evento si ya existe
DROP EVENT IF EXISTS evt_recalculate_customer_loyalty_tiers_nightly;

-- Crear el evento automático
DELIMITER $$
CREATE EVENT evt_recalculate_customer_loyalty_tiers_nightly
ON SCHEDULE EVERY 2 MINUTE  -- Se ejecuta cada 2 minutos automáticamente (PRUEBA)
STARTS CURRENT_TIMESTAMP + INTERVAL 2 MINUTE  -- Inicia en 2 minutos
DO
BEGIN
    DECLARE v_actualizados INT DEFAULT 0;

    -- Actualizar membresía y puntos basados en compras del último año
    UPDATE cliente c
    SET
        membresia = CASE
            WHEN (SELECT COALESCE(SUM(v.total), 0)
                  FROM venta v
                  WHERE v.id_cliente_fk = c.id_cliente
                  AND v.estado = 'Entregado'
                  AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)) >= 5000000
            THEN 'oro'
            WHEN (SELECT COALESCE(SUM(v.total), 0)
                  FROM venta v
                  WHERE v.id_cliente_fk = c.id_cliente
                  AND v.estado = 'Entregado'
                  AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)) >= 2000000
            THEN 'plata'
            WHEN (SELECT COALESCE(SUM(v.total), 0)
                  FROM venta v
                  WHERE v.id_cliente_fk = c.id_cliente
                  AND v.estado = 'Entregado'
                  AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)) >= 500000
            THEN 'bronce'
            ELSE NULL
        END,
        puntos = FLOOR((SELECT COALESCE(SUM(v.total), 0)
                        FROM venta v
                        WHERE v.id_cliente_fk = c.id_cliente
                        AND v.estado = 'Entregado'
                        AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)) / 10000)
    WHERE c.estado = 'activo';

    SET v_actualizados = ROW_COUNT();
END$$
DELIMITER ;

-- =====================================================
-- VERIFICACIÓN: Comprobar que el evento está activo
-- =====================================================

-- Ver si el evento se creó correctamente
SHOW EVENTS FROM e_commerce_db WHERE name = 'evt_recalculate_customer_loyalty_tiers_nightly';

-- Ver detalles completos del evento
SELECT
    EVENT_NAME as 'Nombre del Evento',
    EVENT_TYPE as 'Tipo',
    STATUS as 'Estado',
    INTERVAL_VALUE as 'Cada',
    INTERVAL_FIELD as 'Unidad',
    STARTS as 'Inicia',
    LAST_EXECUTED as 'Última Ejecución'
FROM information_schema.EVENTS
WHERE EVENT_SCHEMA = 'e_commerce_db'
AND EVENT_NAME = 'evt_recalculate_customer_loyalty_tiers_nightly';

-- =====================================================
-- PREPARACIÓN: Verificar estructura de tabla cliente
-- =====================================================

-- Ver estructura de la tabla cliente
DESC cliente;

-- Ver clientes actuales y su membresía
SELECT
    id_cliente,
    nombre,
    apellido,
    membresia,
    puntos,
    estado
FROM cliente
LIMIT 10;

-- =====================================================
-- DATOS DE PRUEBA: Crear ventas para simular diferentes niveles
-- =====================================================

-- Primero, vamos a actualizar algunas ventas existentes para tener datos del último año
-- y cambiar su estado a 'Entregado' para que cuenten para la membresía

UPDATE venta
SET estado = 'Entregado',
    fecha_venta = DATE_SUB(NOW(), INTERVAL 3 MONTH)
WHERE id_venta = 1;

-- Crear ventas adicionales para diferentes clientes con diferentes montos

-- Cliente 1: Ventas para nivel ORO (> 5,000,000)
INSERT INTO venta (fecha_venta, estado, total, id_cliente_fk, id_tienda_fk, id_descuento_fk, id_tarifa_envio_fk)
VALUES
(DATE_SUB(NOW(), INTERVAL 2 MONTH), 'Entregado', 2000000.00, 1, 1, 1, 2),
(DATE_SUB(NOW(), INTERVAL 4 MONTH), 'Entregado', 1800000.00, 1, 1, 1, 2),
(DATE_SUB(NOW(), INTERVAL 6 MONTH), 'Entregado', 1500000.00, 1, 1, 1, 2);

-- Cliente 2: Ventas para nivel PLATA (> 2,000,000)
INSERT INTO venta (fecha_venta, estado, total, id_cliente_fk, id_tienda_fk, id_descuento_fk, id_tarifa_envio_fk)
VALUES
(DATE_SUB(NOW(), INTERVAL 1 MONTH), 'Entregado', 1200000.00, 2, 1, 1, 2),
(DATE_SUB(NOW(), INTERVAL 5 MONTH), 'Entregado', 900000.00, 2, 1, 1, 2);

-- Cliente 3: Ventas para nivel BRONCE (> 500,000)
INSERT INTO venta (fecha_venta, estado, total, id_cliente_fk, id_tienda_fk, id_descuento_fk, id_tarifa_envio_fk)
VALUES
(DATE_SUB(NOW(), INTERVAL 2 MONTH), 'Entregado', 350000.00, 3, 1, 1, 2),
(DATE_SUB(NOW(), INTERVAL 7 MONTH), 'Entregado', 200000.00, 3, 1, 1, 2);

-- Cliente 4: Ventas insuficientes (< 500,000) - SIN MEMBRESÍA
INSERT INTO venta (fecha_venta, estado, total, id_cliente_fk, id_tienda_fk, id_descuento_fk, id_tarifa_envio_fk)
VALUES
(DATE_SUB(NOW(), INTERVAL 3 MONTH), 'Entregado', 150000.00, 4, 1, 1, 2),
(DATE_SUB(NOW(), INTERVAL 8 MONTH), 'Entregado', 100000.00, 4, 1, 1, 2);

-- Cliente 5: Ventas muy antiguas (> 1 año) - NO CUENTAN
INSERT INTO venta (fecha_venta, estado, total, id_cliente_fk, id_tienda_fk, id_descuento_fk, id_tarifa_envio_fk)
VALUES
(DATE_SUB(NOW(), INTERVAL 14 MONTH), 'Entregado', 3000000.00, 5, 1, 1, 2);

-- Cliente 6: Ventas pendientes - NO CUENTAN (estado diferente a 'Entregado')
INSERT INTO venta (fecha_venta, estado, total, id_cliente_fk, id_tienda_fk, id_descuento_fk, id_tarifa_envio_fk)
VALUES
(DATE_SUB(NOW(), INTERVAL 2 MONTH), 'Pendiente', 4000000.00, 6, 1, 1, 2);

-- =====================================================
-- ANTES: Ver clientes ANTES del recálculo automático
-- =====================================================

SELECT 'ANTES DEL RECÁLCULO AUTOMÁTICO DE LEALTAD' as estado, '=' as separador;

-- Resumen de membresías actuales
SELECT
    'Total Clientes Activos' as categoria,
    COUNT(*) as cantidad,
    SUM(CASE WHEN membresia = 'oro' THEN 1 ELSE 0 END) as oro,
    SUM(CASE WHEN membresia = 'plata' THEN 1 ELSE 0 END) as plata,
    SUM(CASE WHEN membresia = 'bronce' THEN 1 ELSE 0 END) as bronce,
    SUM(CASE WHEN membresia IS NULL THEN 1 ELSE 0 END) as sin_membresia
FROM cliente
WHERE estado = 'activo';

-- Ver clientes con sus compras del último año y nivel que DEBERÍAN tener
SELECT
    c.id_cliente,
    CONCAT(c.nombre, ' ', c.apellido) as cliente,
    c.membresia as membresia_actual,
    c.puntos as puntos_actuales,
    FORMAT(COALESCE(SUM(CASE
        WHEN v.estado = 'Entregado'
        AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
        THEN v.total ELSE 0 END), 0), 2) as compras_ultimo_año,
    COUNT(CASE
        WHEN v.estado = 'Entregado'
        AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
        THEN 1 END) as num_compras,
    CASE
        WHEN COALESCE(SUM(CASE
            WHEN v.estado = 'Entregado'
            AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
            THEN v.total ELSE 0 END), 0) >= 5000000 THEN '🥇 ORO'
        WHEN COALESCE(SUM(CASE
            WHEN v.estado = 'Entregado'
            AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
            THEN v.total ELSE 0 END), 0) >= 2000000 THEN '🥈 PLATA'
        WHEN COALESCE(SUM(CASE
            WHEN v.estado = 'Entregado'
            AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
            THEN v.total ELSE 0 END), 0) >= 500000 THEN '🥉 BRONCE'
        ELSE '- SIN MEMBRESÍA'
    END as nivel_esperado,
    FLOOR(COALESCE(SUM(CASE
        WHEN v.estado = 'Entregado'
        AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
        THEN v.total ELSE 0 END), 0) / 10000) as puntos_esperados
FROM cliente c
LEFT JOIN venta v ON c.id_cliente = v.id_cliente_fk
WHERE c.estado = 'activo'
GROUP BY c.id_cliente, c.nombre, c.apellido, c.membresia, c.puntos
ORDER BY compras_ultimo_año DESC
LIMIT 10;

-- Ver detalle de ventas por cliente
SELECT
    ' Detalle de ventas del último año' as info,
    v.id_cliente_fk,
    CONCAT(c.nombre, ' ', c.apellido) as cliente,
    v.id_venta,
    DATE_FORMAT(v.fecha_venta, '%Y-%m-%d') as fecha,
    v.estado,
    FORMAT(v.total, 2) as monto,
    CASE
        WHEN v.estado = 'Entregado'
        AND v.fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
        THEN ' Cuenta para membresía'
        WHEN v.estado != 'Entregado'
        THEN ' Estado no válido'
        WHEN v.fecha_venta < DATE_SUB(NOW(), INTERVAL 1 YEAR)
        THEN ' Muy antigua (>1 año)'
        ELSE ' No cuenta'
    END as valida
FROM venta v
JOIN cliente c ON v.id_cliente_fk = c.id_cliente
WHERE v.id_cliente_fk <= 6
ORDER BY v.id_cliente_fk, v.fecha_venta DESC;



-- 6. evt_generate_reorder_list_daily: Crea lista de productos para reabastecer.

DELIMITER $$

CREATE EVENT IF NOT EXISTS evt_generate_reorder_list_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 6 HOUR  -- Se ejecuta a las 6:00 AM diariamente
DO
BEGIN
    -- Marcar registros del día anterior como procesados
    UPDATE lista_reabastecimiento
    SET estado = 'procesado'
    WHERE DATE(fecha_generacion) < CURDATE()
    AND estado = 'pendiente';

    -- Insertar productos que necesitan reabastecimiento
    -- Criterio: stock actual <= 20% del stock promedio o menos de 10 unidades
    INSERT INTO lista_reabastecimiento (
        id_producto_fk,
        nombre_producto,
        stock_actual,
        stock_minimo,
        cantidad_sugerida,
        fecha_generacion
    )
    SELECT
        i.id_producto_fk,
        p.nombre,
        i.stock AS stock_actual,
        20 AS stock_minimo,  -- Stock mínimo establecido en 20 unidades
        GREATEST(
            50 - i.stock,  -- Llevar a 50 unidades como stock óptimo
            20  -- Mínimo a pedir: 20 unidades
        ) AS cantidad_sugerida,
        NOW() AS fecha_generacion
    FROM inventario i
    INNER JOIN producto p ON i.id_producto_fk = p.id_producto
    WHERE
        i.stock <= 20  -- Productos con stock bajo
        AND p.activo = 1  -- Solo productos activos
        AND NOT EXISTS (  -- Evitar duplicados del mismo día
            SELECT 1
            FROM lista_reabastecimiento lr
            WHERE lr.id_producto_fk = i.id_producto_fk
            AND DATE(lr.fecha_generacion) = CURDATE()
            AND lr.estado = 'pendiente'
        )
    ORDER BY i.stock ASC;  -- Priorizar productos con menor stock

END$$

DELIMITER ;

-- ================================================
-- Vista para consultar productos a reabastecer
-- ================================================
CREATE OR REPLACE VIEW v_productos_reabastecer AS
SELECT
    lr.id_lista,
    lr.id_producto_fk,
    lr.nombre_producto,
    lr.stock_actual,
    lr.stock_minimo,
    lr.cantidad_sugerida,
    lr.fecha_generacion,
    lr.estado,
    c.nombre AS categoria,
    pr.nombre AS proveedor,
    pr.email_contacto AS email_proveedor,
    p.precio AS precio_unitario,
    (lr.cantidad_sugerida * p.precio) AS costo_estimado
FROM lista_reabastecimiento lr
INNER JOIN producto p ON lr.id_producto_fk = p.id_producto
INNER JOIN producto_categoria pc ON p.id_producto = pc.id_producto_fk
INNER JOIN categoria c ON pc.id_categoria_fk = c.id_categoria
LEFT JOIN proveedor_tienda_producto ptp ON p.id_producto = ptp.id_producto_fk AND ptp.estado = 'activo'
LEFT JOIN proveedor pr ON ptp.id_proveedor_fk = pr.id_proveedor
WHERE lr.estado = 'pendiente'
ORDER BY lr.stock_actual ASC, lr.fecha_generacion DESC;



-- 7. evt_rebuild_indexes_weekly: Reconstruye índices para optimizar rendimiento.

DELIMITER $$

CREATE EVENT IF NOT EXISTS evt_rebuild_indexes_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_DATE + INTERVAL 1 WEEK + INTERVAL 2 HOUR  -- Se ejecuta los domingos a las 2:00 AM
DO
BEGIN
    DECLARE tabla_actual VARCHAR(100);
    DECLARE done INT DEFAULT FALSE;
    DECLARE mensaje_log TEXT;

    -- Cursor para iterar sobre todas las tablas de la base de datos
    DECLARE cursor_tablas CURSOR FOR
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'e_commerce_db'
        AND table_type = 'BASE TABLE'
        AND table_name NOT LIKE 'log_%';  -- Excluir tablas de log

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Iniciar el proceso
    INSERT INTO log_mantenimiento_indices (tabla_nombre, accion, mensaje)
    VALUES ('SISTEMA', 'INICIO_MANTENIMIENTO', 'Iniciando mantenimiento semanal de índices');

    -- Abrir cursor
    OPEN cursor_tablas;

    read_loop: LOOP
        FETCH cursor_tablas INTO tabla_actual;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Optimizar tabla (reconstruye índices y desfragmenta)
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                INSERT INTO log_mantenimiento_indices (tabla_nombre, accion, estado, mensaje)
                VALUES (tabla_actual, 'OPTIMIZE', 'fallido', CONCAT('Error al optimizar tabla: ', tabla_actual));
            END;

            SET @sql = CONCAT('OPTIMIZE TABLE `', tabla_actual, '`');
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            INSERT INTO log_mantenimiento_indices (tabla_nombre, accion, estado, mensaje)
            VALUES (tabla_actual, 'OPTIMIZE', 'exitoso', CONCAT('Tabla optimizada correctamente: ', tabla_actual));
        END;

        -- Analizar tabla (actualiza estadísticas de índices)
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                INSERT INTO log_mantenimiento_indices (tabla_nombre, accion, estado, mensaje)
                VALUES (tabla_actual, 'ANALYZE', 'fallido', CONCAT('Error al analizar tabla: ', tabla_actual));
            END;

            SET @sql = CONCAT('ANALYZE TABLE `', tabla_actual, '`');
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            INSERT INTO log_mantenimiento_indices (tabla_nombre, accion, estado, mensaje)
            VALUES (tabla_actual, 'ANALYZE', 'exitoso', CONCAT('Tabla analizada correctamente: ', tabla_actual));
        END;

    END LOOP;

    CLOSE cursor_tablas;

    -- Finalizar el proceso
    INSERT INTO log_mantenimiento_indices (tabla_nombre, accion, mensaje)
    VALUES ('SISTEMA', 'FIN_MANTENIMIENTO', 'Mantenimiento semanal de índices completado');

    -- Limpiar logs antiguos (más de 90 días)
    DELETE FROM log_mantenimiento_indices
    WHERE fecha_ejecucion < DATE_SUB(NOW(), INTERVAL 90 DAY);

END$$

DELIMITER ;

-- ================================================
-- Vista para consultar historial de mantenimiento
-- ================================================
CREATE OR REPLACE VIEW v_historial_mantenimiento_indices AS
SELECT
    id_log,
    tabla_nombre,
    accion,
    fecha_ejecucion,
    estado,
    mensaje,
    DATE_FORMAT(fecha_ejecucion, '%Y-%m-%d %H:%i:%s') AS fecha_formateada
FROM log_mantenimiento_indices
ORDER BY fecha_ejecucion DESC;

-- ================================================
-- Vista para resumen de último mantenimiento
-- ================================================
CREATE OR REPLACE VIEW v_ultimo_mantenimiento AS
SELECT
    tabla_nombre,
    accion,
    estado,
    fecha_ejecucion,
    mensaje
FROM log_mantenimiento_indices
WHERE DATE(fecha_ejecucion) = (
    SELECT MAX(DATE(fecha_ejecucion))
    FROM log_mantenimiento_indices
    WHERE accion IN ('OPTIMIZE', 'ANALYZE')
)
ORDER BY fecha_ejecucion DESC;

-- ================================================
-- Procedimiento para ejecutar mantenimiento manual
-- ================================================
DELIMITER $$

CREATE PROCEDURE sp_mantenimiento_indices_manual(
    IN p_tabla VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO log_mantenimiento_indices (tabla_nombre, accion, estado, mensaje)
        VALUES (p_tabla, 'MANUAL', 'fallido', CONCAT('Error en mantenimiento manual de: ', p_tabla));
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Optimizar tabla específica
    SET @sql = CONCAT('OPTIMIZE TABLE `', p_tabla, '`');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Analizar tabla específica
    SET @sql = CONCAT('ANALYZE TABLE `', p_tabla, '`');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    INSERT INTO log_mantenimiento_indices (tabla_nombre, accion, estado, mensaje)
    VALUES (p_tabla, 'MANUAL', 'exitoso', CONCAT('Mantenimiento manual completado para: ', p_tabla));

    COMMIT;

    SELECT 'Mantenimiento completado exitosamente' AS resultado;
END$$

DELIMITER ;


-- 8. evt_suspend_inactive_accounts_quarterly: Desactiva cuentas sin actividad.

DELIMITER $$

CREATE EVENT evt_suspend_inactive_accounts_quarterly
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Desactivar cuentas de clientes sin actividad en más de un año
    UPDATE cliente
    SET estado = 'inactivo'
    WHERE DATEDIFF(NOW(), ultima_compra) > 1 -- toco cambiar estoa  1 para probarlo
    AND estado = 'activo';
END$$

DELIMITER ;

--- como usarlo:
SELECT id_cliente, nombre, estado, ultima_compra
FROM cliente
WHERE estado = 'inactivo';

UPDATE cliente
SET ultima_compra = DATE_SUB(NOW(), INTERVAL 1 YEAR)
WHERE id_cliente = 1;



-- 9. evt_aggregate_daily_sales_data: Agrega ventas diarias en tabla resumen.

DELIMITER $$

CREATE EVENT evt_aggregate_daily_sales_data
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Calcular el total de ventas del día y agregar a la tabla resumen_ventas_diarias
    INSERT INTO resumen_ventas_diarias (fecha, total_ventas, total_productos_vendidos)
    SELECT CURDATE(),
            SUM(v.total),
            SUM(pv.cantidad)  -- Total de productos vendidos
    FROM venta v
    LEFT JOIN producto_venta pv ON v.id_venta = pv.id_venta_fk
    WHERE DATE(v.fecha_venta) = CURDATE()
    ON DUPLICATE KEY UPDATE
        total_ventas = VALUES(total_ventas),
        total_productos_vendidos = VALUES(total_productos_vendidos);
END$$

DELIMITER ;

--- como usarlo:
SELECT fecha, total_ventas, total_productos_vendidos
FROM resumen_ventas_diarias
WHERE fecha = CURDATE();


-- 10. evt_check_data_consistency_nightly: Busca inconsistencias en los datos.

DELIMITER $$

CREATE EVENT evt_check_data_consistency_nightly
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- 1. Buscar ventas sin cliente asociado
    INSERT INTO auditoria_consistencia_datos (tabla, error, descripcion, fecha)
    SELECT 'venta', 'Cliente inexistente', CONCAT('Venta con id_venta ', id_venta, ' no tiene cliente asociado'), NOW()
    FROM venta
    WHERE id_cliente_fk IS NULL;

    -- 2. Buscar ventas sin producto asociado
    INSERT INTO auditoria_consistencia_datos (tabla, error, descripcion, fecha)
    SELECT 'venta', 'Producto inexistente', CONCAT('Venta con id_venta ', id_venta, ' no tiene producto asociado'), NOW()
    FROM venta v
    LEFT JOIN producto_venta pv ON v.id_venta = pv.id_venta_fk
    WHERE pv.id_producto_fk IS NULL;

    -- 3. Buscar productos sin categoría asignada
    INSERT INTO auditoria_consistencia_datos (tabla, error, descripcion, fecha)
    SELECT 'producto', 'Sin categoría asignada', CONCAT('Producto con id_producto ', id_producto, ' no tiene categoría asignada'), NOW()
    FROM producto
    WHERE id_producto NOT IN (SELECT id_producto_fk FROM producto_categoria);

    -- 4. Buscar clientes con datos incompletos (sin nombre o apellido)
    INSERT INTO auditoria_consistencia_datos (tabla, error, descripcion, fecha)
    SELECT 'cliente', 'Datos incompletos', CONCAT('Cliente con id_cliente ', id_cliente, ' tiene nombre o apellido nulos'), NOW()
    FROM cliente
    WHERE nombre IS NULL OR apellido IS NULL;
END$$

DELIMITER ;

--- se pasaron de lanza con este evento, como consultarlo:
SELECT * FROM auditoria_consistencia_datos WHERE fecha >= CURDATE();


-- 11. evt_send_birthday_greetings_daily: Envía cupones a clientes que cumplen años.

DELIMITER $$

CREATE EVENT evt_send_birthday_greetings_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- TODAS LAS DECLARACIONES PRIMERO
    DECLARE cliente_id INT;
    DECLARE cliente_email VARCHAR(120);
    DECLARE cliente_nombre VARCHAR(100);
    DECLARE cupon_codigo VARCHAR(50);
    DECLARE descuento DECIMAL(10,2);
    DECLARE done INT DEFAULT 0;

    -- Declarar el CURSOR después de las variables
    DECLARE cur CURSOR FOR
        SELECT id_cliente, email, nombre
        FROM cliente
        WHERE DATE(fecha_nacimiento) = CURDATE();

    -- Declarar el HANDLER al final de todas las declaraciones
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- AHORA SÍ LAS INSTRUCCIONES EJECUTABLES
    SET descuento = 10.00;

    -- Abrir el cursor y asignar cupones de cumpleaños
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO cliente_id, cliente_email, cliente_nombre;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Generar un código único para el cupón
        SET cupon_codigo = CONCAT('CUPON-', cliente_id, '-', DATE_FORMAT(NOW(), '%Y%m%d'));

        -- Insertar el cupón en la tabla de cupones
        INSERT INTO cupones_cumpleanos (id_cliente_fk, codigo_cupon, descuento)
        VALUES (cliente_id, cupon_codigo, descuento);

    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;
DROP EVENT IF EXISTS evt_send_birthday_greetings_daily;

--- antes de ejecutarlo primero hacer este insert creado especificamente para este evento:
INSERT INTO cliente (
    nombre,
    apellido,
    email,
    clave,
    fecha_registro,
    fecha_nacimiento,
    estado
)
VALUES
    ('Juanito', 'Alcachofa', 'juan.alcachofa@example.com', 'password123', NOW(), NOW(), 'activo');

SELECT * FROM cupones_cumpleanos WHERE id_cliente_fk = (SELECT id_cliente FROM cliente WHERE email = 'juan.alcachofa@example.com');


-- 12. evt_update_product_rankings_hourly: Actualiza ranking de productos.

CREATE TABLE IF NOT EXISTS ranking_productos (
    id_producto_fk INT NOT NULL,
    total_vendido DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_cantidad INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_producto_fk),
    CONSTRAINT fk_ranking_producto FOREIGN KEY (id_producto_fk)
        REFERENCES producto (id_producto)
        ON DELETE CASCADE,
    INDEX idx_total_vendido (total_vendido DESC)
);

DELIMITER $$

CREATE EVENT evt_update_product_rankings_hourly
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO ranking_productos (id_producto_fk, total_vendido, total_cantidad)
    SELECT
        pv.id_producto_fk,
        SUM(pv.cantidad * pv.precio_unitario) AS total_vendido,
        SUM(pv.cantidad) AS total_cantidad
    FROM producto_venta pv
    GROUP BY pv.id_producto_fk
    ON DUPLICATE KEY UPDATE
        total_vendido = VALUES(total_vendido),
        total_cantidad = VALUES(total_cantidad);
END$$

DELIMITER ;

--- como usarlo:
SELECT
    r.id_producto_fk,
    p.nombre AS producto,
    r.total_cantidad,
    r.total_vendido,
    RANK() OVER (ORDER BY r.total_vendido DESC) AS posicion
FROM ranking_productos r
JOIN producto p ON p.id_producto = r.id_producto_fk
ORDER BY r.total_vendido DESC;


-- 13. evt_backup_critical_tables_daily: Realiza backup de tablas críticas.

DELIMITER $$

CREATE EVENT evt_backup_critical_tables_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Copias de seguridad de las tablas críticas en tablas con sufijo "_backup"

    -- Respaldar tabla cliente
    CREATE TABLE IF NOT EXISTS cliente_backup AS
    SELECT * FROM cliente;
    TRUNCATE TABLE cliente_backup;
    INSERT INTO cliente_backup SELECT * FROM cliente;

    -- Respaldar tabla venta
    CREATE TABLE IF NOT EXISTS venta_backup AS
    SELECT * FROM venta;
    TRUNCATE TABLE venta_backup;
    INSERT INTO venta_backup SELECT * FROM venta;

    -- Respaldar tabla producto
    CREATE TABLE IF NOT EXISTS producto_backup AS
    SELECT * FROM producto;
    TRUNCATE TABLE producto_backup;
    INSERT INTO producto_backup SELECT * FROM producto;

    -- Respaldar tabla producto_venta
    CREATE TABLE IF NOT EXISTS producto_venta_backup AS
    SELECT * FROM producto_venta;
    TRUNCATE TABLE producto_venta_backup;
    INSERT INTO producto_venta_backup SELECT * FROM producto_venta;

END$$

DELIMITER ;

--- como usarlo:

SHOW TABLES LIKE '%backup%';

SELECT * FROM venta_backup;


-- 14. evt_clear_abandoned_carts_daily: Limpia carritos abandonados.

DELIMITER $$

CREATE EVENT evt_clear_abandoned_carts_daily
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM carrito
    WHERE estado = 'abandonado'
        AND TIMESTAMPDIFF(MINUTE, fecha_creacion, NOW()) > 1;
END$$

DELIMITER ;

--- para usarlo:
INSERT INTO carrito (id_carrito, id_producto_fk, id_cliente_fk, cantidad, fecha_creacion, fecha_actualizacion, estado)
VALUES
    (1001, 5, 2, 1, NOW(), NOW(), 'abandonado'),
    (1001, 6, 2, 1, NOW(), NOW(), 'abandonado');

SELECT * FROM carrito WHERE id_carrito = 1001;


-- 15. evt_calculate_monthly_kpis: Calcula KPIs mensuales.


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



    TRUNCATE TABLE mv_resumen_ventas;
    INSERT INTO mv_resumen_ventas
    SELECT * FROM qry_ResumenVentas;

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


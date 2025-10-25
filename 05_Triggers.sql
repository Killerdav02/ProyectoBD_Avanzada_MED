-- Active: 1761397960283@@127.0.0.1@3309@e_commerce_db
-- 1. trg_audit_precio_producto_after_update: Guarda un log de cambios de precios.

DROP TRIGGER IF EXISTS trg_audit_precio_producto_after_update;

DELIMITER //
CREATE TRIGGER trg_audit_precio_producto_after_update
AFTER UPDATE ON producto
FOR EACH ROW
BEGIN
    -- Lógica para registrar los cambios de precio

END //
DELIMITER ;

-- 2. trg_check_stock_before_insert_venta: Verifica el stock antes de registrar una venta.

DROP TRIGGER IF EXISTS trg_check_stock_before_insert_venta;

DELIMITER //
CREATE TRIGGER trg_check_stock_before_insert_venta
BEFORE INSERT ON venta_detalle
FOR EACH ROW
BEGIN
    -- Lógica para verificar el stock disponible

END //
DELIMITER ;

-- 3. trg_update_stock_after_insert_venta: Decrementa el stock después de una venta.

DROP TRIGGER IF EXISTS trg_update_stock_after_insert_venta;

DELIMITER //
CREATE TRIGGER trg_update_stock_after_insert_venta
AFTER INSERT ON venta_detalle
FOR EACH ROW
BEGIN
    -- Lógica para disminuir el stock del producto

END //
DELIMITER ;

-- 4. trg_prevent_delete_categoria_with_products: Impide eliminar una categoría si tiene productos asociados.

DROP TRIGGER IF EXISTS trg_prevent_delete_categoria_with_products;

DELIMITER //
CREATE TRIGGER trg_prevent_delete_categoria_with_products
BEFORE DELETE ON categoria
FOR EACH ROW
BEGIN
    -- Lógica para evitar eliminar categorías con productos

END //
DELIMITER ;

-- 5. trg_log_new_customer_after_insert: Registra cada vez que se crea un nuevo cliente.

DROP TRIGGER IF EXISTS trg_log_new_customer_after_insert;

DELIMITER //
CREATE TRIGGER trg_log_new_customer_after_insert
AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
    -- Lógica para registrar el nuevo cliente en la auditoría

END //
DELIMITER ;

-- 6. trg_update_total_gastado_cliente: Actualiza el total gastado por cliente después de una compra.

DROP TRIGGER IF EXISTS trg_update_total_gastado_cliente;

DELIMITER //
CREATE TRIGGER trg_update_total_gastado_cliente
AFTER INSERT ON venta
FOR EACH ROW
BEGIN
    -- Lógica para actualizar total gastado en cliente

END //
DELIMITER ;

-- 7. trg_set_fecha_modificacion_producto: Actualiza la fecha de última modificación de un producto.

DROP TRIGGER IF EXISTS trg_set_fecha_modificacion_producto;

DELIMITER //
CREATE TRIGGER trg_set_fecha_modificacion_producto
BEFORE UPDATE ON producto
FOR EACH ROW
BEGIN
    -- Lógica para establecer la fecha de modificación

END //
DELIMITER ;

-- 8. trg_prevent_negative_stock: Impide que el stock de un producto sea negativo.

DROP TRIGGER IF EXISTS trg_prevent_negative_stock;

DELIMITER //
CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON producto
FOR EACH ROW
BEGIN
    -- Lógica para impedir stock negativo

END //
DELIMITER ;

-- 9. trg_capitalize_nombre_cliente: Convierte la primera letra del nombre y apellido a mayúscula.

DROP TRIGGER IF EXISTS trg_capitalize_nombre_cliente;

DELIMITER //
CREATE TRIGGER trg_capitalize_nombre_cliente
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    -- Lógica para capitalizar nombre y apellido

END //
DELIMITER ;

-- 10. trg_recalculate_total_venta_on_detalle_change: Recalcula el total de una venta al modificar detalles.

DROP TRIGGER IF EXISTS trg_recalculate_total_venta_on_detalle_change;

DELIMITER //
CREATE TRIGGER trg_recalculate_total_venta_on_detalle_change
AFTER UPDATE ON venta_detalle
FOR EACH ROW
BEGIN
    -- Lógica para recalcular el total de la venta

END //
DELIMITER ;

-- 11. trg_log_order_status_change: Audita cada cambio de estado de un pedido.

DROP TRIGGER IF EXISTS trg_log_order_status_change;

DELIMITER //
CREATE TRIGGER trg_log_order_status_change
AFTER UPDATE ON pedido
FOR EACH ROW
BEGIN
    -- Lógica para registrar el cambio de estado

END //
DELIMITER ;

-- 12. trg_prevent_price_zero_or_less: Impide que el precio de un producto sea cero o negativo.

DROP TRIGGER IF EXISTS trg_prevent_price_zero_or_less;

DELIMITER //
CREATE TRIGGER trg_prevent_price_zero_or_less
BEFORE UPDATE ON producto
FOR EACH ROW
BEGIN
    -- Lógica para validar precio mayor a cero

END //
DELIMITER ;

-- 13. trg_send_stock_alert_on_low_stock: Crea una alerta cuando el stock baja de un umbral.

DROP TRIGGER IF EXISTS trg_send_stock_alert_on_low_stock;

DELIMITER //
CREATE TRIGGER trg_send_stock_alert_on_low_stock
AFTER UPDATE ON producto
FOR EACH ROW
BEGIN
    -- Lógica para generar alerta por bajo stock

END //
DELIMITER ;

-- 14. trg_archive_deleted_venta: Mueve una venta eliminada a una tabla de archivo.

DROP TRIGGER IF EXISTS trg_archive_deleted_venta;
DELIMITER //

CREATE TRIGGER trg_archive_deleted_venta
BEFORE UPDATE ON venta
FOR EACH ROW
BEGIN
    IF (NEW.estado = 'Enviado' OR NEW.estado = 'Entregado') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'YA CUANDO EL PROCESO DE ESTADO ES ENVIADO Y ENTREGADO NO SE PUEDE CANCELAR';
    ELSEIF (NEW.estado = 'Pendiente' OR NEW.estado = 'Procesando') THEN
        SET @mensaje := 'Estado actualizado correctamente.';
    ELSEIF (NEW.estado = 'Cancelado') THEN
        INSERT INTO venta_eliminada (id_venta_fk, fecha_eliminacion, motivo)
        VALUES (OLD.id_venta, NOW(), 'CLIENTE CANCELO SU PEDIDO');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SU VENTA FUE CANCELADA';
    END IF;
END;
//
DELIMITER ;

UPDATE venta
SET estado = 'Procesando'
WHERE id_venta = 1;


-- 15. trg_validate_email_format_on_customer: Valida el formato del correo electrónico del cliente.

DROP TRIGGER IF EXISTS trg_validate_email_format_on_customer;

DELIMITER //
CREATE TRIGGER trg_validate_email_format_on_customer
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'EL CORREO QUE INGRESAS NO ES VALIDO';
    END IF;
END //
DELIMITER ;

INSERT INTO
    cliente (
        nombre,
        apellido,
        email,
        clave,
        fecha_registro,
        fecha_nacimiento
    )
VALUES ("maicoll", "mendez","","123456",NOW(),"2025-04-25");

-- 16. trg_update_last_order_date_customer: Actualiza la fecha del último pedido del cliente.

DROP TRIGGER IF EXISTS trg_update_last_order_date_customer;

DELIMITER //
CREATE TRIGGER trg_update_last_order_date_customer
AFTER INSERT ON venta
FOR EACH ROW
BEGIN
    UPDATE cliente
    SET ultima_compra = NEW.fecha_venta
    WHERE id_cliente = NEW.id_cliente_fk;
END;
//

DELIMITER ;

INSERT INTO `e_commerce_db`.`venta` (`fecha_venta`, `estado`,`total`,`id_cliente_fk`,`id_tienda_fk`,`id_descuento_fk`,`id_tarifa_envio_fk`)
VALUES
(now(), 'Pendiente','0.00','15','1','1','2');

-- 17. trg_prevent_self_referral: Impide que un cliente se referencie a sí mismo.

DROP TRIGGER IF EXISTS trg_prevent_self_referral;

DELIMITER //
CREATE TRIGGER trg_prevent_self_referral
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    IF NEW.id_cliente = NEW.id_referido THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un cliente no puede referirse a sí mismo.';
    END IF;
DELIMITER ;


INSERT INTO
    cliente (
        nombre,
        apellido,
        email,
        clave,
        fecha_registro,
        fecha_nacimiento,
        id_referido
    )
VALUES ("carlos", "lopez","carloslopez@hotmail.com","1234567",NOW(),"2025-04-25",20);


-- 18. trg_log_permission_changes: Audita los cambios de permisos en los usuarios.

-- 18. trg_log_permission_changes: Audita los cambios de permisos en los usuarios.

DROP TRIGGER IF EXISTS trg_log_permission_changes;

DELIMITER //

CREATE TRIGGER trg_log_permission_changes
AFTER UPDATE ON permisos
FOR EACH ROW
BEGIN

    INSERT INTO log_cambios_permisos(usuario, permiso_anterior, permiso_nuevo, fecha)
    VALUES (
        NEW.usuario,
        OLD.permiso,
        NEW.permiso,
        NOW()
    );

END //

DELIMITER ;


-- 19. trg_assign_default_category_on_null: Asigna una categoría por defecto si no se especifica ninguna.

DROP TRIGGER IF EXISTS trg_assign_default_category_on_null;

ALTER TABLE categoria
MODIFY COLUMN nombre ENUM('Calzado', 'Ropa', 'Electronico', 'Hogar', 'Pendiente') NOT NULL;

DELIMITER //
CREATE TRIGGER trg_assign_default_category_on_null
AFTER INSERT ON producto
FOR EACH ROW
BEGIN
    DECLARE default_categoria_id INT;

    SELECT id_categoria INTO default_categoria_id
    FROM categoria
    WHERE nombre = 'Pendiente'
    LIMIT 1;

    IF default_categoria_id IS NOT NULL THEN
        INSERT INTO producto_categoria (id_producto_fk, id_categoria_fk)
        VALUES (NEW.id_producto, default_categoria_id);
    END IF;

END //
DELIMITER ;

INSERT INTO
    `e_commerce_db`.`producto` (
        nombre,
        descripcion,
        precio,
        precio_iva,
        activo,
        peso
    )
VALUES (
        'Zapatos adidas',
        'Zapatos cómodos para deportes y actividades al aire libre',
        180000.00,
        NULL,
        1,
        1
    );

-- 20. trg_update_producto_count_in_categoria: Mantiene un contador de productos por categoría.


DROP TRIGGER IF EXISTS trg_actualizar_categoria_stock;

DELIMITER //

CREATE TRIGGER trg_actualizar_categoria_stock
AFTER INSERT ON producto_venta
FOR EACH ROW
BEGIN
    UPDATE categoria c
    JOIN producto_categoria pc ON c.id_categoria = pc.id_categoria_fk
    JOIN inventario i ON pc.id_producto_fk = i.id_producto_fk
    SET c.cantidad = (
        SELECT SUM(i2.stock)
        FROM producto_categoria pc2
        JOIN inventario i2 ON pc2.id_producto_fk = i2.id_producto_fk
        WHERE pc2.id_categoria_fk = c.id_categoria
    )
    WHERE pc.id_producto_fk = NEW.id_producto_fk;
END //

DELIMITER ;

INSERT INTO `e_commerce_db`.`producto_venta` (`id_producto_fk`, `id_venta_fk`, `cantidad`, `precio_unitario`, `id_moneda_fk`)
VALUES
(11, 5, 2, 10000.00, 1),
(7, 5, 3, 15000.00, 1),
(44, 5, 3, 15000.00, 1),
(37, 5, 3, 15000.00, 1);



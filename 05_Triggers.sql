-- Active: 1761397960283@@127.0.0.1@3309@e_commerce_db
-- 1. trg_audit_precio_producto_after_update: Guarda un log de cambios de precios.
DELIMITER //

CREATE TRIGGER trg_audit_precio_producto_after_update
AFTER UPDATE ON producto
FOR EACH ROW
BEGIN
    -- Solo registramos si el precio realmente cambió
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precio (id_producto_fk, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES (OLD.id_producto, OLD.precio, NEW.precio, NOW());
    END IF;
END //

DELIMITER ;


--Prueba el trigger haciendo un UPDATE en producto:--
UPDATE producto
SET precio = 150
WHERE id_producto = 1;

-- Verifica que se haya registrado el cambio:--
SELECT * FROM auditoria_precio;

--//////////////////////////////////////////////////////////////////////////////////////////////////////////////--


-- 2. trg_check_stock_before_insert_venta: Verifica el stock antes de registrar una venta.

DROP TRIGGER IF EXISTS trg_check_stock_before_insert_venta;
DELIMITER //

CREATE TRIGGER trg_check_stock_before_insert_venta
BEFORE INSERT ON producto_venta
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;

    -- Obtenemos el stock actual del producto
    SELECT stock INTO stock_actual
    FROM inventario
    WHERE id_producto_fk = NEW.id_producto_fk;

    -- Si la cantidad solicitada es mayor al stock disponible, cancelamos la inserción
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay suficiente stock para este producto';
    END IF;
END //

DELIMITER ;

--//  crear una venta nueva///
INSERT INTO venta
(fecha_venta, estado, total, id_cliente_fk, id_tienda_fk, id_descuento_fk, id_tarifa_envio_fk)
VALUES
(NOW(), 'Pendiente', 0.00, 1, 1, 1, 2);

SET @id_venta_nueva = LAST_INSERT_ID();

--//2️⃣ Insertar productos en la venta//
INSERT INTO producto_venta
(id_producto_fk, id_venta_fk, cantidad, precio_unitario, id_moneda_fk)
VALUES
(1, @id_venta_nueva, 5, 10000.00, 1);

INSERT INTO producto_venta
(id_producto_fk, id_venta_fk, cantidad, precio_unitario, id_moneda_fk)
VALUES
(2, @id_venta_nueva, 3, 15000.00, 1);

--//3️⃣ Actualizar cantidad si el producto ya existe--//
UPDATE producto_venta
SET cantidad = cantidad + 2
WHERE id_producto_fk = 1
  AND id_venta_fk = @id_venta_nueva
  AND id_moneda_fk = 1;

--//Verificar los registros--//

SELECT *
FROM producto_venta
WHERE id_venta_fk = @id_venta_nueva;

SELECT *
FROM venta
WHERE id_venta = @id_venta_nueva;

--////////////////////////////////////////////////////////////////////////////////////////////--
-- 3. trg_update_stock_after_insert_venta: Decrementa el stock después de una venta.

-- Primero eliminamos el trigger si existe
DROP TRIGGER IF EXISTS trg_update_stock_after_insert_venta;

DELIMITER //

CREATE TRIGGER trg_update_stock_after_insert_venta
AFTER INSERT ON producto_venta
FOR EACH ROW
BEGIN
    -- Actualizamos el stock en inventario restando la cantidad vendida
    UPDATE inventario
    SET stock = stock - NEW.cantidad
    WHERE id_producto_fk = NEW.id_producto_fk;

    -- Opcional: prevenir que el stock sea negativo
    IF (SELECT stock FROM inventario WHERE id_producto_fk = NEW.id_producto_fk) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente después de la venta';
    END IF;
END //

DELIMITER ;


-- Creamos una nueva venta
INSERT INTO venta
(fecha_venta, estado, total, id_cliente_fk, id_tienda_fk, id_descuento_fk, id_tarifa_envio_fk)
VALUES
(NOW(), 'Pendiente', 0.00, 1, 1, 1, 2);

SET @id_venta_nueva = LAST_INSERT_ID();

-- Insertamos productos en la venta
INSERT INTO producto_venta
(id_producto_fk, id_venta_fk, cantidad, precio_unitario, id_moneda_fk)
VALUES
(1, @id_venta_nueva, 5, 10000.00, 1),
(2, @id_venta_nueva, 3, 15000.00, 1);

-- Ver stock actualizado
SELECT * FROM inventario WHERE id_producto_fk IN (1, 2);

-- Ver productos vendidos
SELECT * FROM producto_venta WHERE id_venta_fk = @id_venta_nueva;

---//////////////////////////////////////////////////////////////////////////////--

-- 4. trg_prevent_delete_categoria_with_products: Impide eliminar una categoría si tiene productos asociados.

-- Eliminamos el trigger si existe
DROP TRIGGER IF EXISTS trg_prevent_delete_categoria_with_products;

DELIMITER //

CREATE TRIGGER trg_prevent_delete_categoria_with_products
BEFORE DELETE ON categoria
FOR EACH ROW
BEGIN
    DECLARE productos_asociados INT;

    -- Contamos cuántos productos pertenecen a la categoría que se intenta eliminar
    SELECT COUNT(*) INTO productos_asociados
    FROM producto
    WHERE id_categoria_fk = OLD.id_categoria;

    -- Si hay productos asociados, bloqueamos la eliminación
    IF productos_asociados > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar la categoría porque tiene productos asociados';
    END IF;
END //

DELIMITER ;

-- Ejemplo de categorías
INSERT INTO categoria (id_categoria, nombre_categoria)
VALUES (1, 'Electrónica'), (2, 'Ropa');

-- Ejemplo de productos asociados
INSERT INTO producto (id_producto, nombre_producto, precio, stock, id_categoria_fk)
VALUES (1, 'Televisor', 50000, 10, 1),
       (2, 'Camiseta', 20000, 50, 2);

-- Esto fallará porque la categoría 1 tiene un producto asociado
DELETE FROM categoria WHERE id_categoria = 1;
--resultado esperado

ERROR 1644 (45000): No se puede eliminar la categoría porque tiene productos asociados

--eliminar una categoria sin productos

-- Primero creamos una categoría sin productos
INSERT INTO categoria (id_categoria, nombre_categoria) VALUES (3, 'Libros');

-- Ahora la eliminamos
DELETE FROM categoria WHERE id_categoria = 3;

-- Esto funcionará porque no tiene productos asociados


--//////////////////////////////////////////////////////////////////////////////////--

-- 5. trg_log_new_customer_after_insert: Registra cada vez que se crea un nuevo cliente.

DROP TRIGGER IF EXISTS trg_log_new_customer_after_insert;

DELIMITER //

CREATE TRIGGER trg_log_new_customer_after_insert
AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_cliente (id_cliente_fk, nombre, email, fecha_registro)
    VALUES (NEW.id_cliente, NEW.nombre, NEW.email, NOW());
END //

DELIMITER ;

--2️⃣ Insertar un nuevo cliente (para probar el trigger)--

INSERT INTO cliente
(nombre, apellido, email, clave, fecha_nacimiento, estado, membresia, puntos)
VALUES
('Juan', 'Perez', 'juan.perez@email.com', '12345', '1990-05-15', 'activo', 'oro', 0);

---3️⃣ Verificar que se registró en la auditoría---ç

SELECT *
FROM auditoria_cliente
WHERE id_cliente_fk = LAST_INSERT_ID();

--/////////////////////////////////////////////////////////////////////////////////////////////////////////--
-- 6. trg_update_total_gastado_cliente: Actualiza el total gastado por cliente después de una compra.

DROP TRIGGER IF EXISTS trg_update_total_gastado_cliente;

DELIMITER //

CREATE TRIGGER trg_update_total_gastado_cliente
AFTER INSERT ON venta
FOR EACH ROW
BEGIN
    -- Actualiza el total gastado por el cliente sumando el total de la nueva venta
    UPDATE cliente
    SET puntos = IFNULL(puntos, 0) + NEW.total
    WHERE id_cliente = NEW.id_cliente_fk;
END //

DELIMITER ;

-- 1. Insertar una nueva venta para el cliente 1
INSERT INTO venta (fecha_venta, estado, total, id_cliente_fk, id_tienda_fk, id_descuento_fk, id_tarifa_envio_fk)
VALUES (NOW(), 'Pendiente', 50000.00, 1, 1, 1, 2);

-- 2. Revisar el total gastado/puntos del cliente
SELECT id_cliente, nombre, puntos
FROM cliente
WHERE id_cliente = 1;


--/////////////////////////////////////////////////////////////////////////////////////////////---

-- 7. trg_set_fecha_modificacion_producto: Actualiza la fecha de última modificación de un producto.
DROP TRIGGER IF EXISTS trg_set_fecha_modificacion_producto;

DELIMITER //

CREATE TRIGGER trg_set_fecha_modificacion_producto
BEFORE UPDATE ON producto
FOR EACH ROW
BEGIN
    SET NEW.fecha_modificacion = NOW();
END //

DELIMITER ;
----/Insertar un nuevo producto---
INSERT INTO producto (nombre, descripcion, precio, precio_iva, activo, peso, fecha_modificacion)
VALUES ('Producto A', 'Descripción', 1000, 1210, 1, 1.5, NOW());

---Actualizar cualquier campo--
UPDATE producto
SET precio = 1200
WHERE id_producto = 1;
----Verificar que la fecha de modificación se haya actualizado--
SELECT nombre, precio, fecha_modificacion
FROM producto
WHERE id_producto = 1;

-- 8. trg_prevent_negative_stock: Impide que el stock de un producto sea negativo.

DELIMITER $$

CREATE TRIGGER check_stock_before_update
BEFORE UPDATE ON inventario
FOR EACH ROW
BEGIN
    -- Verificar si el nuevo valor de stock es negativo
    IF NEW.stock < 0 THEN
        -- Lanzar un error si el stock es negativo
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede actualizar el stock a un valor negativo';
    END IF;
END$$

DELIMITER ;
--- como probarlo:
UPDATE inventario
SET stock = -10
WHERE id_producto_fk = 1;

-- 9. trg_capitalize_nombre_cliente: Convierte la primera letra del nombre y apellido a mayúscula.

DELIMITER $$

-- Trigger para convertir la primera letra a mayúscula al insertar un cliente
CREATE TRIGGER convertir_mayusculas_nombre_insert
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    -- Convertir la primera letra del nombre y apellido a mayúscula y el resto a minúsculas
    SET NEW.nombre = CONCAT(UPPER(SUBSTRING(NEW.nombre, 1, 1)), LOWER(SUBSTRING(NEW.nombre, 2)));
    SET NEW.apellido = CONCAT(UPPER(SUBSTRING(NEW.apellido, 1, 1)), LOWER(SUBSTRING(NEW.apellido, 2)));
END$$

-- Trigger para convertir la primera letra a mayúscula al actualizar un cliente
CREATE TRIGGER convertir_mayusculas_nombre_update
BEFORE UPDATE ON cliente
FOR EACH ROW
BEGIN
    -- Convertir la primera letra del nombre y apellido a mayúscula y el resto a minúsculas
    SET NEW.nombre = CONCAT(UPPER(SUBSTRING(NEW.nombre, 1, 1)), LOWER(SUBSTRING(NEW.nombre, 2)));
    SET NEW.apellido = CONCAT(UPPER(SUBSTRING(NEW.apellido, 1, 1)), LOWER(SUBSTRING(NEW.apellido, 2)));
END$$

DELIMITER ;

--- como probarlo normal y si se actualiza:
INSERT INTO cliente (nombre, apellido, email, clave, fecha_registro, fecha_nacimiento)
VALUES ('juan', 'perez', 'juan.perez@example.com', 'password', '2025-10-01', '1990-05-12');

UPDATE cliente
SET nombre = 'maria', apellido = 'garcia'
WHERE email = 'juan.perez@example.com';

-- 10. trg_recalculate_total_venta_on_detalle_change: Recalcula el total de una venta al modificar detalles.

DELIMITER $$

CREATE FUNCTION recalcular_total_venta(id_venta INT)
RETURNS DECIMAL(12,2)
DELIMITER $$

CREATE TRIGGER trg_recalculate_total_venta_on_detalle_change
AFTER UPDATE ON producto_venta
FOR EACH ROW
BEGIN
    DECLARE nuevo_total DECIMAL(12,2);

    -- Calcular el nuevo total de la venta
    SELECT SUM(pv.cantidad * pv.precio_unitario) INTO nuevo_total
    FROM producto_venta pv
    WHERE pv.id_venta_fk = NEW.id_venta_fk;

    -- Actualizar el total de la venta en la tabla 'venta'
    UPDATE venta
    SET total = nuevo_total
    WHERE id_venta = NEW.id_venta_fk;
END$$

DELIMITER ;

-- como probar
SELECT *
FROM producto_venta
WHERE id_venta_fk = 1;

UPDATE producto_venta
SET cantidad = 5
WHERE id_venta_fk = 1 AND id_producto_fk = 1;

SELECT recalcular_total_venta(1) AS nuevo_total;

-- 11. trg_log_order_status_change: Audita cada cambio de estado de un pedido.

DELIMITER $$

CREATE TRIGGER trg_log_order_status_change
AFTER UPDATE ON `e_commerce_db`.`venta`
FOR EACH ROW
BEGIN
    -- Solo registrar si el estado cambió
    IF OLD.estado != NEW.estado THEN
        INSERT INTO `e_commerce_db`.`auditoria_estado_venta` (
            id_venta_fk,
            estado_anterior,
            estado_nuevo,
            id_cliente_fk,
            total_venta,
            fecha_cambio
        )
        VALUES (
            NEW.id_venta,
            OLD.estado,
            NEW.estado,
            NEW.id_cliente_fk,
            NEW.total,
            NOW()
        );
    END IF;
END$$

DELIMITER ;

--- como usarlo:
SELECT id_venta, estado, id_cliente_fk, total
FROM venta
LIMIT 5;

UPDATE venta
SET estado = 'Procesando'
WHERE id_venta = 1;

UPDATE venta
SET estado = 'Enviado'
WHERE id_venta = 1;

SELECT
    a.id_auditoria_estado_venta,
    a.id_venta_fk,
    a.estado_anterior,
    a.estado_nuevo,
    c.nombre AS cliente_nombre,
    c.apellido AS cliente_apellido,
    c.email AS cliente_email,
    a.total_venta,
    a.fecha_cambio
FROM auditoria_estado_venta a
INNER JOIN cliente c ON a.id_cliente_fk = c.id_cliente
ORDER BY a.fecha_cambio DESC;

-- 12. trg_prevent_price_zero_or_less: Impide que el precio de un producto sea cero o negativo.

DELIMITER $$

DROP TRIGGER IF EXISTS trg_prevent_price_zero_or_less_insert$$

CREATE TRIGGER trg_prevent_price_zero_or_less_insert
BEFORE INSERT ON `e_commerce_db`.`producto`
FOR EACH ROW
BEGIN
    -- Validar que el precio no sea cero o negativo
    IF NEW.precio IS NOT NULL AND NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El precio del producto no puede ser cero o negativo';
    END IF;

    -- Validar que el precio con IVA no sea cero o negativo
    IF NEW.precio_iva IS NOT NULL AND NEW.precio_iva <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El precio con IVA del producto no puede ser cero o negativo';
    END IF;
END$$

DELIMITER ;


DELIMITER $$

DROP TRIGGER IF EXISTS trg_prevent_price_zero_or_less_update$$

CREATE TRIGGER trg_prevent_price_zero_or_less_update
BEFORE UPDATE ON `e_commerce_db`.`producto`
FOR EACH ROW
BEGIN
    -- Validar que el precio no sea cero o negativo
    IF NEW.precio IS NOT NULL AND NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El precio del producto no puede ser cero o negativo';
    END IF;

    -- Validar que el precio con IVA no sea cero o negativo
    IF NEW.precio_iva IS NOT NULL AND NEW.precio_iva <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El precio con IVA del producto no puede ser cero o negativo';
    END IF;
END$$

DELIMITER ;

--- como usarlo:
INSERT INTO `e_commerce_db`.`producto`
    (nombre, descripcion, precio, activo, peso)
VALUES
    ('Producto de prueba', 'Descripción de prueba', 100.00, 1, 0.5);

INSERT INTO `e_commerce_db`.`producto`
    (nombre, descripcion, precio, activo, peso)
VALUES
    ('Producto de prueba 2', 'Descripción de prueba', 0.00, 1, 0.5);

UPDATE `e_commerce_db`.`producto`
SET precio = 0.00
WHERE id_producto = 1;

-- 13. trg_send_stock_alert_on_low_stock: Crea una alerta cuando el stock baja de un umbral.

DELIMITER $$

DROP TRIGGER IF EXISTS trg_send_stock_alert_on_low_stock$$

CREATE TRIGGER trg_send_stock_alert_on_low_stock
AFTER UPDATE ON `e_commerce_db`.`inventario`
FOR EACH ROW
BEGIN
    DECLARE umbral INT DEFAULT 10;

    -- Solo actuar si el stock disminuyó
    IF NEW.stock < OLD.stock AND NEW.stock <= umbral THEN

        -- Insertar alerta solo si no existe una alerta pendiente para este inventario
        IF NOT EXISTS (
            SELECT 1
            FROM alerta_stock
            WHERE id_inventario_fk = NEW.id_inventario
            7-13AND estado = 'pendiente'
        ) THEN
            INSERT INTO `e_commerce_db`.`alerta_stock` (
                id_inventario_fk,
                stock_actual,
                umbral_minimo,
                fecha_alerta,
                estado
            )
            VALUES (
                NEW.id_inventario,
                NEW.stock,
                umbral,
                NOW(),
                'pendiente'
            );
        END IF;
    END IF;
END$$

DELIMITER ;

SELECT
    i.id_inventario,
    i.id_producto_fk,
    p.nombre,
    i.sku,
    i.stock
FROM inventario i
INNER JOIN producto p ON i.id_producto_fk = p.id_producto
WHERE i.stock > 10
LIMIT 5;

--Como usar, reducir stock:
UPDATE inventario
SET stock = 5
WHERE id_inventario = 1;

-- Ver las alertas generadas
SELECT
    a.id_alerta_stock,
    p.nombre AS nombre_producto,
    i.sku,
    a.stock_actual,
    a.umbral_minimo,
    a.fecha_alerta,
    a.estado
FROM alerta_stock a
INNER JOIN inventario i ON a.id_inventario_fk = i.id_inventario
INNER JOIN producto p ON i.id_producto_fk = p.id_producto
ORDER BY a.fecha_alerta DESC;

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


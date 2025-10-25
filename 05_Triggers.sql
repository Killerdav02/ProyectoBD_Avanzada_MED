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
BEFORE DELETE ON venta
FOR EACH ROW
BEGIN
    -- Lógica para archivar la venta antes de eliminarla

END //
DELIMITER ;

-- 15. trg_validate_email_format_on_customer: Valida el formato del correo electrónico del cliente.

DROP TRIGGER IF EXISTS trg_validate_email_format_on_customer;

DELIMITER //
CREATE TRIGGER trg_validate_email_format_on_customer
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    -- Lógica para validar el formato del email

END //
DELIMITER ;

-- 16. trg_update_last_order_date_customer: Actualiza la fecha del último pedido del cliente.

DROP TRIGGER IF EXISTS trg_update_last_order_date_customer;

DELIMITER //
CREATE TRIGGER trg_update_last_order_date_customer
AFTER INSERT ON venta
FOR EACH ROW
BEGIN
    -- Lógica para actualizar última fecha de pedido

END //
DELIMITER ;

-- 17. trg_prevent_self_referral: Impide que un cliente se referencie a sí mismo.

DROP TRIGGER IF EXISTS trg_prevent_self_referral;

DELIMITER //
CREATE TRIGGER trg_prevent_self_referral
BEFORE INSERT ON referidos
FOR EACH ROW
BEGIN
    -- Lógica para evitar autoreferencia

END //
DELIMITER ;

-- 18. trg_log_permission_changes: Audita los cambios de permisos en los usuarios.

DROP TRIGGER IF EXISTS trg_log_permission_changes;

DELIMITER //
CREATE TRIGGER trg_log_permission_changes
AFTER UPDATE ON permisos
FOR EACH ROW
BEGIN
    -- Lógica para registrar cambios en permisos

END //
DELIMITER ;

-- 19. trg_assign_default_category_on_null: Asigna una categoría por defecto si no se especifica ninguna.

DROP TRIGGER IF EXISTS trg_assign_default_category_on_null;

DELIMITER //
CREATE TRIGGER trg_assign_default_category_on_null
BEFORE INSERT ON producto
FOR EACH ROW
BEGIN
    -- Lógica para asignar categoría “General” si está vacía

END //
DELIMITER ;

-- 20. trg_update_producto_count_in_categoria: Mantiene un contador de productos por categoría.

DROP TRIGGER IF EXISTS trg_update_producto_count_in_categoria;

DELIMITER //
CREATE TRIGGER trg_update_producto_count_in_categoria
AFTER INSERT ON producto_categoria
FOR EACH ROW
BEGIN
    -- Lógica para actualizar el contador de productos por categoría

END //
DELIMITER ;

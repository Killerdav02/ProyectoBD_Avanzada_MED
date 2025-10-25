-- 1. sp_RealizarNuevaVenta: Procesa una nueva venta de forma transaccional.

DELIMITER $$

CREATE PROCEDURE sp_RealizarNuevaVenta(
    IN p_cliente_id INT,
    IN p_productos JSON
)
BEGIN
    -- Declaración de variables al inicio
    DECLARE v_producto_id INT;
    DECLARE v_cantidad INT;
    DECLARE v_stock_actual INT;
    DECLARE v_index INT DEFAULT 0;
    DECLARE v_productos_count INT;
    DECLARE v_venta_id INT;

    -- Contar la cantidad de productos en el JSON
    SET v_productos_count = JSON_LENGTH(p_productos);

    -- Iniciar la transacción
    START TRANSACTION;

    venta_loop: WHILE v_index < v_productos_count DO
        -- Obtener id del producto y cantidad
        SET v_producto_id = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', v_index, '].id_produ')));
        SET v_cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', v_index, '].cantidad')));

        -- Obtener stock actual del producto
        SELECT stock INTO v_stock_actual
        FROM productos
        WHERE id_producto = v_producto_id
        FOR UPDATE;

        -- Verificar stock
        IF v_stock_actual < v_cantidad THEN
            -- Mensaje de error y rollback
            SELECT CONCAT('Error: No hay stock suficiente para el producto ', v_producto_id) AS mensaje_error;
            ROLLBACK;
            LEAVE venta_loop;
        END IF;

        -- Restar stock
        UPDATE productos
        SET stock = stock - v_cantidad
        WHERE id_producto = v_producto_id;

        -- Incrementar índice
        SET v_index = v_index + 1;
    END WHILE venta_loop;

    -- Si todo salió bien, registrar la venta
    IF v_index = v_productos_count THEN
        INSERT INTO ventas(cliente_id, fecha)
        VALUES (p_cliente_id, NOW());

        -- Obtener id de venta
        SET v_venta_id = LAST_INSERT_ID();

        -- Insertar detalles de venta
        SET v_index = 0;
        WHILE v_index < v_productos_count DO
            SET v_producto_id = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', v_index, '].id_produ')));
            SET v_cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_productos, CONCAT('$[', v_index, '].cantidad')));

            INSERT INTO ventas_detalle(venta_id, producto_id, cantidad)
            VALUES (v_venta_id, v_producto_id, v_cantidad);

            SET v_index = v_index + 1;
        END WHILE;

        -- Confirmar transacción
        COMMIT;
        SELECT 'Venta realizada correctamente' AS mensaje;
    END IF;

END$$

DELIMITER ;

CALL sp_RealizarNuevaVenta(10, @productos_json);

SELECT 'Venta realizada correctamente' AS mensaje;

-- 2. sp_AgregarNuevoProducto: Inserta un nuevo producto y sus atributos iniciales.

DROP PROCEDURE IF EXISTS sp_AgregarNuevoProducto;
DELIMITER //

CREATE PROCEDURE sp_AgregarNuevoProducto(
    IN p_nombre VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_peso DECIMAL(10,2),
    IN p_activo TINYINT
)
BEGIN
    DECLARE v_precio_iva DECIMAL(10,2);
    
    -- Calcular precio con IVA (supongamos 21%)
    SET v_precio_iva = p_precio * 1.21;
    
    -- Insertar el producto
    INSERT INTO producto (nombre, descripcion, precio, precio_iva, activo, peso)
    VALUES (p_nombre, p_descripcion, p_precio, v_precio_iva, p_activo, p_peso);
END //

DELIMITER ;


CALL sp_AgregarNuevoProducto('Camiseta', 'Camiseta de algodón', 199.99, 0.2, 1);

SELECT * FROM producto ORDER BY id_producto DESC LIMIT 5;



-- 3. sp_ActualizarDireccionCliente: Actualiza la dirección de un cliente en todas las tablas relevantes.

DELIMITER $$

CREATE PROCEDURE sp_ActualizarDireccionCliente(
    IN p_id_cliente INT,
    IN p_ciudad VARCHAR(45),
    IN p_barrio VARCHAR(45),
    IN p_calle VARCHAR(45),
    IN p_tipo ENUM('Apartamento','Casa','Oficina','Otro')
)
BEGIN
    DECLARE v_id_direccion INT;

    -- Obtener la dirección actual del cliente (si existe)
    SELECT id_direccion_envio INTO v_id_direccion
    FROM direccion_envio
    WHERE id_direccion_envio = (
        SELECT id_cliente FROM cliente WHERE id_cliente = p_id_cliente
    );

    -- Si existe, actualiza la dirección
    IF v_id_direccion IS NOT NULL THEN
        UPDATE direccion_envio
        SET ciudad = p_ciudad,
            barrio = p_barrio,
            calle = p_calle,
            tipo = p_tipo
        WHERE id_direccion_envio = v_id_direccion;
    ELSE
        -- Si no existe, inserta una nueva dirección
        INSERT INTO direccion_envio (ciudad, barrio, calle, tipo)
        VALUES (p_ciudad, p_barrio, p_calle, p_tipo);
        
        -- Opcional: asociar la nueva dirección al cliente
        SET v_id_direccion = LAST_INSERT_ID();
        -- UPDATE cliente SET id_direccion_envio = v_id_direccion WHERE id_cliente = p_id_cliente;
    END IF;
END$$

DELIMITER ;

CALL sp_ActualizarDireccionCliente(1, 'Ciudad Ejemplo', 'Barrio Central', 'Calle 123', 'Casa');

SELECT c.id_cliente, c.nombre, c.apellido, d.ciudad, d.barrio, d.calle, d.tipo
FROM cliente c
JOIN direccion_envio d ON c.id_cliente = d.id_direccion_envio
WHERE c.id_cliente = 1;

SELECT * FROM direccion_envio;


-- 4. sp_ProcesarDevolucion: Gestiona la devolución de un producto.

DROP PROCEDURE IF EXISTS sp_ProcesarDevolucion;

DELIMITER $$

CREATE PROCEDURE sp_ProcesarDevolucion(
    IN p_id_venta INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_motivo VARCHAR(255)
)
BEGIN
    DECLARE v_stock_actual INT;

    -- Verificar cantidad del producto en la venta
    SELECT SUM(cantidad) INTO v_stock_actual
    FROM producto_venta
    WHERE id_venta_fk = p_id_venta
      AND id_producto_fk = p_id_producto;

    IF v_stock_actual IS NULL OR v_stock_actual = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El producto no existe en la venta.';
    ELSEIF p_cantidad > v_stock_actual THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cantidad a devolver excede la cantidad comprada.';
    END IF;

    -- Registrar devolución (si tuvieras tabla devolucion)
    /*
    INSERT INTO devolucion(id_venta_fk, id_producto_fk, cantidad, fecha, motivo)
    VALUES(p_id_venta, p_id_producto, p_cantidad, NOW(), p_motivo);
    */

    -- Actualizar cantidad en producto_venta
    UPDATE producto_venta
    SET cantidad = cantidad - p_cantidad
    WHERE id_venta_fk = p_id_venta
      AND id_producto_fk = p_id_producto
      AND cantidad >= p_cantidad;

END$$

DELIMITER ;

CALL sp_ProcesarDevolucion(1, 1, 1, 'Producto defectuoso');
SELECT * FROM producto_venta WHERE id_venta_fk = 1;



-- 5. sp_ObtenerHistorialComprasCliente: Devuelve el historial completo de compras de un cliente.
DROP PROCEDURE IF EXISTS sp_ObtenerHistorialComprasCliente;

DELIMITER $$

CREATE PROCEDURE sp_ObtenerHistorialComprasCliente(
    IN p_id_cliente INT
)
BEGIN
    SELECT 
        v.id_venta,
        v.fecha_venta,
        v.estado,
        v.total,
        pv.id_producto_fk,
        p.nombre AS nombre_producto,
        pv.cantidad,
        pv.precio_unitario,
        pv.cantidad * pv.precio_unitario AS subtotal
    FROM venta v
    INNER JOIN producto_venta pv ON v.id_venta = pv.id_venta_fk
    INNER JOIN producto p ON pv.id_producto_fk = p.id_producto
    WHERE v.id_cliente_fk = p_id_cliente
    ORDER BY v.fecha_venta DESC;
END$$

DELIMITER ;

CALL sp_ObtenerHistorialComprasCliente(1);


-- 6. sp_AjustarNivelStock: Permite ajustar manualmente el stock de un producto.

DROP PROCEDURE IF EXISTS sp_AjustarNivelStock;

DELIMITER $$

CREATE PROCEDURE sp_AjustarNivelStock(
    IN p_id_producto INT,
    IN p_nuevo_stock INT
)
BEGIN
    DECLARE v_existe INT;

    -- Verificar que exista el registro de inventario para el producto
    SELECT COUNT(*) INTO v_existe
    FROM inventario
    WHERE id_producto_fk = p_id_producto;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe inventario para este producto.';
    ELSE
        -- Actualizar stock
        UPDATE inventario
        SET stock = p_nuevo_stock
        WHERE id_producto_fk = p_id_producto;
    END IF;
END$$

DELIMITER ;

CALL sp_AjustarNivelStock(1, 100);  -- Ajusta el stock a 100
SELECT * FROM inventario WHERE id_producto_fk = 1;  -- Verifica el cambio



-- 7. sp_EliminarClienteDeFormaSegura: Anonimiza los datos de un cliente en lugar de borrarlos.

DROP PROCEDURE IF EXISTS sp_EliminarClienteDeFormaSegura;

DELIMITER $$

CREATE PROCEDURE sp_EliminarClienteDeFormaSegura(
    IN p_id_cliente INT
)
BEGIN
    -- Actualizar el cliente con datos anónimos
    UPDATE cliente
    SET 
        nombre = CONCAT('Anonimo_', id_cliente),
        apellido = '',
        email = CONCAT('anonimo', id_cliente, '@example.com'),
        clave = 'ANONIMO123', -- clave ficticia
        fecha_nacimiento = '1900-01-01',
        estado = 'inactivo',
        membresia = NULL,
        puntos = 0
    WHERE id_cliente = p_id_cliente;
END$$

DELIMITER ;

-- Llamar al procedimiento para anonimizar al cliente con id 3
CALL sp_EliminarClienteDeFormaSegura(3);

-- Verificar los cambios en la tabla cliente
SELECT * 
FROM cliente
WHERE id_cliente = 3;


-- 8. sp_AplicarDescuentoPorCategoria: Aplica un descuento a todos los productos de una categoría.

DROP PROCEDURE IF EXISTS sp_AplicarDescuentoPorCategoria;

DELIMITER //

CREATE PROCEDURE sp_AplicarDescuentoPorCategoria()
BEGIN
    -- Lógica para aplicar descuento por categoría

END //

DELIMITER ;


-- 9. sp_GenerarReporteMensualVentas: Genera un reporte completo de ventas.

DROP PROCEDURE IF EXISTS sp_GenerarReporteMensualVentas;

DELIMITER //

CREATE PROCEDURE sp_GenerarReporteMensualVentas()
BEGIN
    -- Lógica para generar reporte de ventas mensual

END //

DELIMITER ;


-- 10. sp_CambiarEstadoPedido: Cambia el estado de un pedido y notifica a otros sistemas.

DROP PROCEDURE IF EXISTS sp_CambiarEstadoPedido;

DELIMITER //

CREATE PROCEDURE sp_CambiarEstadoPedido()
BEGIN
    -- Lógica para cambiar estado de pedido y notificar

END //

DELIMITER ;


-- 11. sp_RegistrarNuevoCliente: Registra un nuevo cliente validando que el email no exista.

DROP PROCEDURE IF EXISTS sp_RegistrarNuevoCliente;

DELIMITER //

CREATE PROCEDURE sp_RegistrarNuevoCliente()
BEGIN
    -- Lógica para registrar nuevo cliente y validar email

END //

DELIMITER ;


-- 12. sp_ObtenerDetallesProductoCompleto: Devuelve toda la información de un producto.

DROP PROCEDURE IF EXISTS sp_ObtenerDetallesProductoCompleto;

DELIMITER //

CREATE PROCEDURE sp_ObtenerDetallesProductoCompleto()
BEGIN
    -- Lógica para obtener detalles completos del producto

END //

DELIMITER ;


-- 13. sp_FusionarCuentasCliente: Fusiona dos cuentas de cliente duplicadas.

DROP PROCEDURE IF EXISTS sp_FusionarCuentasCliente;

DELIMITER //

CREATE PROCEDURE sp_FusionarCuentasCliente()
BEGIN
    -- Lógica para fusionar cuentas de cliente duplicadas

END //

DELIMITER ;


-- 14. sp_AsignarProductoAProveedor: Asigna o cambia el proveedor de un producto.

DROP PROCEDURE IF EXISTS sp_AsignarProductoAProveedor;

DELIMITER //

CREATE PROCEDURE sp_AsignarProductoAProveedor()
BEGIN
    -- Lógica para asignar o cambiar proveedor de un producto

END //

DELIMITER ;


-- 15. sp_BuscarProductos: Realiza búsqueda avanzada de productos con filtros.

DROP PROCEDURE IF EXISTS sp_BuscarProductos;

DELIMITER //

CREATE PROCEDURE sp_BuscarProductos()
BEGIN
    -- Lógica para buscar productos con filtros

END //

DELIMITER ;


-- 16. sp_ObtenerDashboardAdmin: Devuelve KPIs para panel de administración.

DROP PROCEDURE IF EXISTS sp_ObtenerDashboardAdmin;

DELIMITER //

CREATE PROCEDURE sp_ObtenerDashboardAdmin()
BEGIN
    -- Lógica para generar dashboard de administración

END //

DELIMITER ;


-- 17. sp_ProcesarPago: Simula el procesamiento de un pago para una venta.

DROP PROCEDURE IF EXISTS sp_ProcesarPago;

DELIMITER //

CREATE PROCEDURE sp_ProcesarPago()
BEGIN
    -- Lógica para procesar pago y actualizar estado de venta

END //

DELIMITER ;


-- 18. sp_AñadirReseñaProducto: Permite a un cliente añadir reseña y calificación a un producto.

DROP PROCEDURE IF EXISTS sp_AñadirReseñaProducto;

DELIMITER //

CREATE PROCEDURE sp_AñadirReseñaProducto()
BEGIN
    -- Lógica para añadir reseña y calificación de producto

END //

DELIMITER ;


-- 19. sp_ObtenerProductosRelacionados: Devuelve productos relacionados a uno dado.

DROP PROCEDURE IF EXISTS sp_ObtenerProductosRelacionados;

DELIMITER //

CREATE PROCEDURE sp_ObtenerProductosRelacionados()
BEGIN
    -- Lógica para obtener productos relacionados

END //

DELIMITER ;


-- 20. sp_MoverProductosEntreCategorias: Mueve productos de una categoría a otra de forma segura.

DROP PROCEDURE IF EXISTS sp_MoverProductosEntreCategorias;

DELIMITER //

CREATE PROCEDURE sp_MoverProductosEntreCategorias()
BEGIN
    -- Lógica para mover productos entre categorías

END //

DELIMITER ;

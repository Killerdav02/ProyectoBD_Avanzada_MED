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

CALL sp_AjustarNivelStock(1, 100);
SELECT * FROM inventario WHERE id_producto_fk = 1;



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

DELIMITER $$

CREATE PROCEDURE sp_AplicarDescuentoPorCategoria (
    IN p_id_categoria INT,
    IN p_descuento DECIMAL(5,2)
)
BEGIN

    UPDATE producto p
    INNER JOIN producto_categoria pc ON p.id_producto = pc.id_producto_fk
    SET p.precio = p.precio * (1 - p_descuento)
    WHERE pc.id_categoria_fk = p_id_categoria;

END$$

DELIMITER ;

--- como usarlo:
CALL sp_AplicarDescuentoPorCategoria(3, 0.15);

SELECT id_producto, nombre, precio 
FROM producto 
WHERE id_producto IN (
    SELECT id_producto_fk FROM producto_categoria WHERE id_categoria_fk = 3
);


-- 9. sp_GenerarReporteMensualVentas: Genera un reporte completo de ventas.

DELIMITER $$

CREATE PROCEDURE sp_GenerarReporteMensualVentas (
    IN p_mes INT,
    IN p_anio INT
)
BEGIN

    SELECT 
        v.id_venta,
        v.fecha_venta,
        CONCAT(c.nombre, ' ', c.apellido) AS cliente,
        v.estado,
        v.total AS total_venta,
        COUNT(pv.id_producto_fk) AS cantidad_productos,
        SUM(pv.cantidad * pv.precio_unitario) AS subtotal_productos
    FROM venta v
    INNER JOIN cliente c ON v.id_cliente_fk = c.id_cliente
    INNER JOIN producto_venta pv ON v.id_venta = pv.id_venta_fk
    WHERE MONTH(v.fecha_venta) = p_mes
        AND YEAR(v.fecha_venta) = p_anio
    GROUP BY v.id_venta, v.fecha_venta, cliente, v.estado, v.total
    ORDER BY v.fecha_venta ASC;

END$$

DELIMITER ;

--- como usarlo:
CALL sp_GenerarReporteMensualVentas(10, 2025);



-- 10. sp_CambiarEstadoPedido: Cambia el estado de un pedido y notifica a otros sistemas.

DELIMITER $$

CREATE PROCEDURE sp_CambiarEstadoPedido (
    IN p_id_venta INT,
    IN p_nuevo_estado ENUM('Pendiente','Procesando','Enviado','Entregado','Cancelado')
)
BEGIN
    DECLARE v_estado_anterior ENUM('Pendiente','Procesando','Enviado','Entregado','Cancelado');
    DECLARE v_id_cliente INT;
    DECLARE v_total DECIMAL(12,2);

    -- Obtener los datos actuales del pedido
    SELECT estado, id_cliente_fk, total
    INTO v_estado_anterior, v_id_cliente, v_total
    FROM venta
    WHERE id_venta = p_id_venta;

    IF v_estado_anterior = p_nuevo_estado THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El pedido ya tiene ese estado.';
    ELSE
        UPDATE venta
        SET estado = p_nuevo_estado
        WHERE id_venta = p_id_venta;

        INSERT INTO auditoria_estado_venta (
            id_venta_fk,
            estado_anterior,
            estado_nuevo,
            id_cliente_fk,
            total_venta,
            fecha_cambio
        )
        VALUES (
            p_id_venta,
            v_estado_anterior,
            p_nuevo_estado,
            v_id_cliente,
            v_total,
            NOW()
        );

    END IF;
END$$

DELIMITER ;

--- como usarlo:
CALL sp_CambiarEstadoPedido(5, 'Enviado');

select estado,id_venta from venta where estado = 'enviado';



-- 11. sp_RegistrarNuevoCliente: Registra un nuevo cliente validando que el email no exista.

DELIMITER $$

CREATE PROCEDURE sp_RegistrarNuevoCliente (
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_email VARCHAR(120),
    IN p_clave VARCHAR(25),
    IN p_fecha_nacimiento VARCHAR(45)
)
BEGIN

    DECLARE v_existe INT;

    SELECT COUNT(*) INTO v_existe
    FROM cliente
    WHERE email = p_email;

    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El correo electrónico ya está registrado.';
    ELSE
        INSERT INTO cliente (nombre, apellido, email, clave, fecha_nacimiento, fecha_registro, estado, puntos)
        VALUES (p_nombre, p_apellido, p_email, p_clave, p_fecha_nacimiento, NOW(), 'activo', 0);
    END IF;

END$$

DELIMITER ;

--- como usarlo:
CALL sp_RegistrarNuevoCliente('Ana', 'Martínez', 'ana.martinez@example.com', 'clave123', '1992-05-20');



-- 12. sp_ObtenerDetallesProductoCompleto: Devuelve toda la información de un producto.

DELIMITER $$

CREATE PROCEDURE sp_ObtenerDetallesProductoCompleto (
    IN p_id_producto INT
)
BEGIN
    SELECT 
        p.id_producto,
        p.nombre AS nombre_producto,
        p.descripcion,
        p.precio,
        p.precio_iva,
        p.activo,
        p.peso,
        c.nombre AS categoria,
        c.descripcion AS descripcion_categoria,
        i.stock,
        i.sku,
        pr.nombre AS proveedor,
        pr.email_contacto,
        t.nombre AS tienda,
        t.nit AS nit_tienda
    FROM producto p
    LEFT JOIN producto_categoria pc ON p.id_producto = pc.id_producto_fk
    LEFT JOIN categoria c ON pc.id_categoria_fk = c.id_categoria
    LEFT JOIN inventario i ON p.id_producto = i.id_producto_fk
    LEFT JOIN proveedor_tienda_producto ptp ON p.id_producto = ptp.id_producto_fk
    LEFT JOIN proveedor pr ON ptp.id_proveedor_fk = pr.id_proveedor
    LEFT JOIN tienda t ON ptp.id_tienda_fk = t.id_tienda
    WHERE p.id_producto = p_id_producto;
END$$

DELIMITER ;

--- como usarlo:
CALL sp_ObtenerDetallesProductoCompleto(5);




-- 13. sp_FusionarCuentasCliente: Fusiona dos cuentas de cliente duplicadas.

DELIMITER $$

CREATE PROCEDURE sp_FusionarCuentasCliente (
    IN p_cliente_principal INT,
    IN p_cliente_duplicado INT
)
BEGIN
    DECLARE puntos_duplicado INT DEFAULT 0;

    -- Validar existencia de los clientes
    IF (SELECT COUNT(*) FROM cliente WHERE id_cliente = p_cliente_principal) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente principal no existe.';
    END IF;

    IF (SELECT COUNT(*) FROM cliente WHERE id_cliente = p_cliente_duplicado) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente duplicado no existe.';
    END IF;

    -- Obtener los puntos del duplicado
    SELECT IFNULL(puntos, 0) INTO puntos_duplicado
    FROM cliente
    WHERE id_cliente = p_cliente_duplicado;

    -- Transferir ventas
    UPDATE venta
    SET id_cliente_fk = p_cliente_principal
    WHERE id_cliente_fk = p_cliente_duplicado;

    -- Transferir direcciones
    INSERT IGNORE INTO cliente_direccion_envio (id_cliente_fk, id_direccion_envio_fk)
    SELECT p_cliente_principal, id_direccion_envio_fk
    FROM cliente_direccion_envio
    WHERE id_cliente_fk = p_cliente_duplicado;

    -- Transferir teléfonos
    INSERT IGNORE INTO telefono (id_pais_fk, telefono, id_cliente_fk)
    SELECT id_pais_fk, telefono, p_cliente_principal
    FROM telefono
    WHERE id_cliente_fk = p_cliente_duplicado;

    -- Sumar puntos
    UPDATE cliente
    SET puntos = IFNULL(puntos, 0) + puntos_duplicado
    WHERE id_cliente = p_cliente_principal;

    -- Eliminar duplicado
    DELETE FROM cliente
    WHERE id_cliente = p_cliente_duplicado;
END$$

DELIMITER ;

--- como usarlo:

select * from cliente;

CALL sp_FusionarCuentasCliente(23, 24);

INSERT INTO cliente (nombre, apellido, email, clave, fecha_registro, fecha_nacimiento, estado, puntos)
VALUES ('Carlos', 'Gómez', 'carlos.duplicado1@example.com', 'clave1', NOW(), '1993-09-25', 'activo', 5);

INSERT INTO cliente (nombre, apellido, email, clave, fecha_registro, fecha_nacimiento, estado, puntos)
VALUES ('Carlos', 'Gómez', 'carlos.duplicado2@example.com', 'clave2', NOW(), '1993-09-25', 'activo', 8);


-- 14. sp_AsignarProductoAProveedor: Asigna o cambia el proveedor de un producto.

DELIMITER $$

CREATE PROCEDURE sp_AsignarProductoAProveedor (
    IN p_id_producto INT,
    IN p_id_proveedor INT,
    IN p_condiciones VARCHAR(255)
)
BEGIN
    DECLARE existe_relacion INT;

    -- Verificar si el producto y proveedor existen
    IF (SELECT COUNT(*) FROM producto WHERE id_producto = p_id_producto) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto no existe.';
    END IF;

    IF (SELECT COUNT(*) FROM proveedor WHERE id_proveedor = p_id_proveedor) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El proveedor no existe.';
    END IF;

    -- Verificar si ya existe la relación entre proveedor y producto
    SELECT COUNT(*) INTO existe_relacion
    FROM proveedor_tienda_producto
    WHERE id_producto_fk = p_id_producto
        AND id_proveedor_fk = p_id_proveedor;

    -- Si existe, actualiza las condiciones
    IF existe_relacion > 0 THEN
        UPDATE proveedor_tienda_producto
        SET condiciones = p_condiciones
        WHERE id_producto_fk = p_id_producto
            AND id_proveedor_fk = p_id_proveedor;
    ELSE
        -- Si no existe, crea una nueva relación
        INSERT INTO proveedor_tienda_producto (condiciones, id_tienda_fk, id_proveedor_fk, id_producto_fk)
        VALUES (p_condiciones, 1, p_id_proveedor, p_id_producto); -- Se asume tienda 1 por defecto
    END IF;
END$$

DELIMITER ;
--- como usarlo:

CALL sp_AsignarProductoAProveedor(5, 2, 'Contrato renovado 2025');

SELECT * FROM proveedor_tienda_producto WHERE id_producto_fk = 5;


-- 15. sp_BuscarProductos: Realiza búsqueda avanzada de productos con filtros.

DROP PROCEDURE IF EXISTS sp_BuscarProductos;
DELIMITER //
CREATE PROCEDURE sp_BuscarProductos(
    IN p_nombre VARCHAR(150),
    IN p_id_categoria INT,
    IN p_precio_min DECIMAL(10,2),
    IN p_precio_max DECIMAL(10,2)
)
BEGIN
    SELECT p.id_producto, p.nombre, p.descripcion, p.precio, p.precio_iva, c.nombre AS categoria
    FROM producto p
    JOIN producto_categoria pc ON p.id_producto = pc.id_producto_fk
    JOIN categoria c ON pc.id_categoria_fk = c.id_categoria
    WHERE (p.nombre LIKE CONCAT('%', p_nombre, '%') OR p_nombre IS NULL)
        AND (pc.id_categoria_fk = p_id_categoria OR p_id_categoria IS NULL)
        AND (p.precio BETWEEN p_precio_min AND p_precio_max OR p_precio_min IS NULL OR p_precio_max IS NULL);
END //
DELIMITER ;


-- 16. sp_ObtenerDashboardAdmin: Devuelve KPIs para panel de administración.

DROP PROCEDURE IF EXISTS sp_ObtenerDashboardAdmin;
DELIMITER //
CREATE PROCEDURE sp_ObtenerDashboardAdmin()
BEGIN
    SELECT
        (SELECT COUNT(*) FROM cliente) AS total_clientes,
        (SELECT COUNT(*) FROM producto) AS total_productos,
        (SELECT COUNT(*) FROM venta) AS total_ventas,
        (SELECT SUM(total) FROM venta) AS ingresos_totales,
        (SELECT COUNT(*) FROM venta WHERE estado='Pendiente') AS ventas_pendientes;
END //
DELIMITER ;


-- 17. sp_ProcesarPago: Simula el procesamiento de un pago para una venta.

DROP PROCEDURE IF EXISTS sp_ProcesarPago;
DELIMITER //
CREATE PROCEDURE sp_ProcesarPago(IN p_id_venta INT, IN p_monto DECIMAL(12,2))
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT total INTO v_total FROM venta WHERE id_venta = p_id_venta;

    IF p_monto >= v_total THEN
        UPDATE venta
        SET estado = 'Procesando'
        WHERE id_venta = p_id_venta;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Monto insuficiente para procesar el pago';
    END IF;
END //
DELIMITER ;DELIMITER ;


-- 18. sp_AñadirReseñaProducto: Permite a un cliente añadir reseña y calificación a un producto.

CREATE TABLE IF NOT EXISTS reseña_producto (
    id_reseña INT NOT NULL AUTO_INCREMENT,
    id_cliente_fk INT NOT NULL,
    id_producto_fk INT NOT NULL,
    calificacion INT NOT NULL,
    comentario TEXT NULL,
    fecha_reseña DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_reseña),
    INDEX idx_cliente (id_cliente_fk),
    INDEX idx_producto (id_producto_fk),
    CONSTRAINT fk_reseña_cliente
        FOREIGN KEY (id_cliente_fk)
        REFERENCES cliente(id_cliente)
        ON DELETE CASCADE,
    CONSTRAINT fk_reseña_producto
        FOREIGN KEY (id_producto_fk)
        REFERENCES producto(id_producto)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;


DROP PROCEDURE IF EXISTS sp_AñadirReseñaProducto;

DELIMITER //

CREATE PROCEDURE sp_AñadirReseñaProducto(
    IN p_id_cliente INT,
    IN p_id_producto INT,
    IN p_calificacion INT,
    IN p_comentario TEXT
)
BEGIN
    IF p_calificacion < 1 OR p_calificacion > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La calificación debe estar entre 1 y 5';
    ELSE
        INSERT INTO reseña_producto(id_cliente_fk, id_producto_fk, calificacion, comentario, fecha_reseña)
        VALUES (p_id_cliente, p_id_producto, p_calificacion, p_comentario, NOW());
    END IF;
END //

DELIMITER ;



-- 19. sp_ObtenerProductosRelacionados: Devuelve productos relacionados a uno dado.

DROP PROCEDURE IF EXISTS sp_ObtenerProductosRelacionados;
DELIMITER //
CREATE PROCEDURE sp_ObtenerProductosRelacionados(IN p_id_producto INT)
BEGIN
    SELECT DISTINCT p2.id_producto, p2.nombre, p2.precio, c.nombre AS categoria
    FROM producto_categoria pc1
    JOIN producto_categoria pc2 ON pc1.id_categoria_fk = pc2.id_categoria_fk
    JOIN producto p2 ON pc2.id_producto_fk = p2.id_producto
    JOIN categoria c ON pc2.id_categoria_fk = c.id_categoria
    WHERE pc1.id_producto_fk = p_id_producto
      AND p2.id_producto <> p_id_producto;
END //
DELIMITER ;


-- 20. sp_MoverProductosEntreCategorias: Mueve productos de una categoría a otra de forma segura.

DROP PROCEDURE IF EXISTS sp_MoverProductosEntreCategorias;
DELIMITER //
CREATE PROCEDURE sp_MoverProductosEntreCategorias(
    IN p_id_producto INT,
    IN p_id_categoria_origen INT,
    IN p_id_categoria_destino INT
)
BEGIN
    DELETE FROM producto_categoria
    WHERE id_producto_fk = p_id_producto
      AND id_categoria_fk = p_id_categoria_origen;

    INSERT INTO producto_categoria(id_producto_fk, id_categoria_fk)
    VALUES (p_id_producto, p_id_categoria_destino);
END //
DELIMITER ;

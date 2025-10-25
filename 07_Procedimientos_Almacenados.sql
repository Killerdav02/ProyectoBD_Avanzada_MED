-- 1. sp_RealizarNuevaVenta: Procesa una nueva venta de forma transaccional.

DROP PROCEDURE IF EXISTS sp_RealizarNuevaVenta;

DELIMITER //

CREATE PROCEDURE sp_RealizarNuevaVenta()
BEGIN
    -- Lógica para procesar una nueva venta

END //

DELIMITER ;


-- 2. sp_AgregarNuevoProducto: Inserta un nuevo producto y sus atributos iniciales.

DROP PROCEDURE IF EXISTS sp_AgregarNuevoProducto;

DELIMITER //

CREATE PROCEDURE sp_AgregarNuevoProducto()
BEGIN
    -- Lógica para insertar un nuevo producto

END //

DELIMITER ;


-- 3. sp_ActualizarDireccionCliente: Actualiza la dirección de un cliente en todas las tablas relevantes.

DROP PROCEDURE IF EXISTS sp_ActualizarDireccionCliente;

DELIMITER //

CREATE PROCEDURE sp_ActualizarDireccionCliente()
BEGIN
    -- Lógica para actualizar la dirección de un cliente

END //

DELIMITER ;


-- 4. sp_ProcesarDevolucion: Gestiona la devolución de un producto.

DROP PROCEDURE IF EXISTS sp_ProcesarDevolucion;

DELIMITER //

CREATE PROCEDURE sp_ProcesarDevolucion()
BEGIN
    -- Lógica para gestionar devolución y ajustar stock

END //

DELIMITER ;


-- 5. sp_ObtenerHistorialComprasCliente: Devuelve el historial completo de compras de un cliente.

DROP PROCEDURE IF EXISTS sp_ObtenerHistorialComprasCliente;

DELIMITER //

CREATE PROCEDURE sp_ObtenerHistorialComprasCliente()
BEGIN
    -- Lógica para obtener historial de compras de un cliente

END //

DELIMITER ;


-- 6. sp_AjustarNivelStock: Permite ajustar manualmente el stock de un producto.

DROP PROCEDURE IF EXISTS sp_AjustarNivelStock;

DELIMITER //

CREATE PROCEDURE sp_AjustarNivelStock()
BEGIN
    -- Lógica para ajustar stock y registrar motivo

END //

DELIMITER ;


-- 7. sp_EliminarClienteDeFormaSegura: Anonimiza los datos de un cliente en lugar de borrarlos.

DROP PROCEDURE IF EXISTS sp_EliminarClienteDeFormaSegura;

DELIMITER //

CREATE PROCEDURE sp_EliminarClienteDeFormaSegura()
BEGIN
    -- Lógica para anonimizar datos del cliente

END //

DELIMITER ;


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

-- 1. fn_CalcularTotalVenta: Calcula el monto total de una venta específica.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_CalcularTotalVenta()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    -- Lógica para calcular el total de una venta

    RETURN total;
END //

DELIMITER ;

-- 2. fn_VerificarDisponibilidadStock: Valida si hay stock suficiente para un producto.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_VerificarDisponibilidadStock()
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE disponible BOOLEAN;

    -- Lógica para verificar stock

    RETURN disponible;
END //

DELIMITER ;

-- 3. fn_ObtenerPrecioProducto: Devuelve el precio actual de un producto.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_ObtenerPrecioProducto()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE precio DECIMAL(10,2);

    -- Lógica para obtener el precio

    RETURN precio;
END //

DELIMITER ;

-- 4. fn_CalcularEdadCliente: Calcula la edad de un cliente a partir de su fecha de nacimiento.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_CalcularEdadCliente()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE edad INT;

    -- Lógica para calcular edad

    RETURN edad;
END //

DELIMITER ;

-- 5. fn_FormatearNombreCompleto: Devuelve el nombre y apellido de un cliente en formato estandarizado.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_FormatearNombreCompleto()
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(200);

    -- Lógica para concatenar y formatear nombre completo

    RETURN nombre_completo;
END //

DELIMITER ;

-- 6. fn_EsClienteNuevo: Devuelve TRUE si un cliente realizó su primera compra en los últimos 30 días.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_EsClienteNuevo()
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE es_nuevo BOOLEAN;

    -- Lógica para verificar si es cliente nuevo

    RETURN es_nuevo;
END //

DELIMITER ;

-- 7. fn_CalcularCostoEnvio: Calcula el costo de envío basado en el peso total.

DELIMITER $$

CREATE FUNCTION `calcular_costo_envio`(id_venta INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE peso_total DECIMAL(10,2);
    DECLARE tipo_envio ENUM('liviano', 'mediano', 'pesado');
    DECLARE costo_envio DECIMAL(10,2);

    SELECT SUM(p.peso * pv.cantidad) INTO peso_total
    FROM producto_venta pv
    JOIN producto p ON pv.id_producto_fk = p.id_producto
    WHERE pv.id_venta_fk = id_venta;

    IF peso_total <= 5 THEN
        SET tipo_envio = 'liviano';
    ELSEIF peso_total > 5 AND peso_total <= 20 THEN
        SET tipo_envio = 'mediano';
    ELSE
        SET tipo_envio = 'pesado';
    END IF;

    SELECT te.valor INTO costo_envio
    FROM tarifa_envio te
    WHERE te.tipo = tipo_envio;

    RETURN costo_envio;
END$$

DELIMITER ;
--- como invocarla:
DELIMITER $$

CREATE FUNCTION aplicar_descuento_venta(p_id_venta INT, p_id_descuento INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_venta DECIMAL(12,2);
    DECLARE descuento DECIMAL(10,2);
    DECLARE total_con_descuento DECIMAL(12,2);
    
    SELECT total INTO total_venta
    FROM venta
    WHERE id_venta = p_id_venta;
    
    SELECT valor INTO descuento
    FROM descuento
    WHERE id_descuento = p_id_descuento;
    
    -- Calcular el total con el descuento (asumiendo descuento como porcentaje)
    SET total_con_descuento = total_venta * (1 - (descuento / 100));
    
    -- Devolver el total con descuento
    RETURN total_con_descuento;
END$$

DELIMITER ;

--- como usarla:

-- hay que actualizar o si no no sirve para nada
SELECT aplicar_descuento_venta(2, 3) AS nuevo_total;

UPDATE venta
SET total = aplicar_descuento_venta(2, 3),
    id_descuento_fk = 3
WHERE id_venta = 2;

SELECT id_venta, total
FROM venta
WHERE id_venta = 2;

-- 9. fn_ObtenerUltimaFechaCompra: Devuelve la fecha de la última compra de un cliente.

DELIMITER $$

CREATE FUNCTION ObtenerUltimaFechaCompra(id_cliente INT)
RETURNS DATETIME
DETERMINISTIC
BEGIN
    DECLARE ultima_fecha DATETIME;

    SELECT MAX(fecha_venta) INTO ultima_fecha
    FROM venta
    WHERE id_cliente_fk = id_cliente;

    RETURN ultima_fecha;
END$$

DELIMITER ;
--- como usar:

SELECT ObtenerUltimaFechaCompra(6) AS ultima_fecha_compra;


-- 10. fn_ValidarFormatoEmail: Comprueba si el correo tiene formato válido.

DELIMITER $$

CREATE FUNCTION validar_email(p_email VARCHAR(120))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    DECLARE es_valido BOOLEAN DEFAULT FALSE;
    
    IF p_email IS NOT NULL 
        AND p_email != ''
        AND p_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
        AND LOCATE('@', p_email) > 0
        AND LOCATE('.', p_email) > LOCATE('@', p_email)
        AND LENGTH(p_email) >= 5
        AND LENGTH(p_email) <= 120
    THEN
        SET es_valido = TRUE;
    END IF;
    
    RETURN es_valido;
END$$

DELIMITER ;
--- como usar:
SELECT validar_email('quionezmix@gmail.com') AS resultado;

-- 11. fn_ObtenerNombreCategoria: Devuelve el nombre de la categoría de un producto.

DELIMITER $$

CREATE FUNCTION obtener_nombre_categoria(id_producto INT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE nombre_categoria VARCHAR(255);

    SELECT c.nombre INTO nombre_categoria
    FROM categoria c
    JOIN producto_categoria pc ON c.id_categoria = pc.id_categoria_fk
    WHERE pc.id_producto_fk = id_producto
    LIMIT 1;

    RETURN nombre_categoria;
END$$

DELIMITER ;
--- como usar:
SELECT obtener_nombre_categoria(60) AS nombre_categoria;

-- 12. fn_ContarVentasCliente: Cuenta el número total de compras realizadas por un cliente.

DELIMITER $$

CREATE FUNCTION contar_compras_cliente(id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE num_compras INT;

    SELECT COUNT(*) INTO num_compras
    FROM venta
    WHERE id_cliente_fk = id_cliente;

    RETURN num_compras;
END$$

DELIMITER ;
--- como usar:
SELECT contar_compras_cliente(1) AS total_compras;

-- 13. fn_CalcularDiasDesdeUltimaCompra: Devuelve los días desde la última compra.

CREATE FUNCTION dias_desde_ultima_compra(id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE ultima_compra DATETIME;
    DECLARE dias_transcurridos INT;

    SELECT MAX(fecha_venta) INTO ultima_compra
    FROM venta
    WHERE id_cliente_fk = id_cliente;

    IF ultima_compra IS NOT NULL THEN
        SET dias_transcurridos = DATEDIFF(NOW(), ultima_compra);
    ELSE
        SET dias_transcurridos = NULL;
    END IF;

    RETURN dias_transcurridos;
END$$

DELIMITER ;
--- como usar:
SELECT dias_desde_ultima_compra(2) AS dias_desde_ultima_compra;

-- 14. fn_DeterminarEstadoLealtad: Asigna un estado (Bronce, Plata, Oro) según el gasto total.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_DeterminarEstadoLealtad()
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE estado VARCHAR(20);

    -- Lógica para determinar estado de lealtad

    RETURN estado;
END //

DELIMITER ;

-- 15. fn_GenerarSKU: Genera un código único basado en nombre y categoría.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_GenerarSKU()
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE sku VARCHAR(50);

    -- Lógica para generar SKU

    RETURN sku;
END //

DELIMITER ;

-- 16. fn_CalcularIVA: Calcula el IVA sobre un monto total.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_CalcularIVA()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_iva DECIMAL(10,2);

    -- Lógica para calcular IVA

    RETURN total_iva;
END //

DELIMITER ;

-- 17. fn_ObtenerStockTotalPorCategoria: Suma el stock de todos los productos de una categoría.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_ObtenerStockTotalPorCategoria()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE stock_total INT;

    -- Lógica para obtener stock total

    RETURN stock_total;
END //

DELIMITER ;

-- 18. fn_EstimarFechaEntrega: Calcula la fecha estimada de entrega según ubicación.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_EstimarFechaEntrega()
RETURNS DATE
DETERMINISTIC
BEGIN
    DECLARE fecha_estimada DATE;

    -- Lógica para estimar fecha de entrega

    RETURN fecha_estimada;
END //

DELIMITER ;

-- 19. fn_ConvertirMoneda: Convierte un monto a otra moneda con una tasa fija.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_ConvertirMoneda()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE monto_convertido DECIMAL(10,2);

    -- Lógica para convertir moneda

    RETURN monto_convertido;
END //

DELIMITER ;

-- 20. fn_ValidarComplejidadContraseña: Verifica si la contraseña cumple con criterios de seguridad.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_ValidarComplejidadContraseña()
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE es_segura BOOLEAN;

    -- Lógica para validar complejidad de contraseña

    RETURN es_segura;
END //

DELIMITER ;

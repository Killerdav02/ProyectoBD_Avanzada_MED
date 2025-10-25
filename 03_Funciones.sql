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

DELIMITER //

CREATE OR REPLACE FUNCTION fn_CalcularCostoEnvio()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE costo_envio DECIMAL(10,2);

    -- Lógica para calcular costo de envío

    RETURN costo_envio;
END //

DELIMITER ;

-- 8. fn_AplicarDescuento: Aplica un porcentaje de descuento a un monto dado.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_AplicarDescuento()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_con_descuento DECIMAL(10,2);

    -- Lógica para aplicar descuento

    RETURN total_con_descuento;
END //

DELIMITER ;

-- 9. fn_ObtenerUltimaFechaCompra: Devuelve la fecha de la última compra de un cliente.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_ObtenerUltimaFechaCompra()
RETURNS DATE
DETERMINISTIC
BEGIN
    DECLARE ultima_fecha DATE;

    -- Lógica para obtener la última compra

    RETURN ultima_fecha;
END //

DELIMITER ;

-- 10. fn_ValidarFormatoEmail: Comprueba si el correo tiene formato válido.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_ValidarFormatoEmail()
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE es_valido BOOLEAN;

    -- Lógica para validar formato de correo

    RETURN es_valido;
END //

DELIMITER ;

-- 11. fn_ObtenerNombreCategoria: Devuelve el nombre de la categoría de un producto.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_ObtenerNombreCategoria()
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE nombre_categoria VARCHAR(100);

    -- Lógica para obtener nombre de categoría

    RETURN nombre_categoria;
END //

DELIMITER ;

-- 12. fn_ContarVentasCliente: Cuenta el número total de compras realizadas por un cliente.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_ContarVentasCliente()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_ventas INT;

    -- Lógica para contar ventas

    RETURN total_ventas;
END //

DELIMITER ;

-- 13. fn_CalcularDiasDesdeUltimaCompra: Devuelve los días desde la última compra.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_CalcularDiasDesdeUltimaCompra()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE dias INT;

    -- Lógica para calcular días desde última compra

    RETURN dias;
END //

DELIMITER ;

-- 14. fn_DeterminarEstadoLealtad: Asigna un estado (Bronce, Plata, Oro) según el gasto total.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_DeterminarEstadoLealtad(p_id_cliente INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE total_gasto_mes DECIMAL(10,2);
    DECLARE estado VARCHAR(20);

    -- Calcula el gasto total del cliente en el último mes
    SELECT IFNULL(SUM(total), 0)
    INTO total_gasto_mes
    FROM venta
    WHERE id_cliente_fk = p_id_cliente
      AND fecha_venta >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

    -- Asigna el estado según el gasto del último mes
    IF total_gasto_mes < 50000 THEN
        SET estado = 'Bronce';
    ELSEIF total_gasto_mes BETWEEN 50000 AND 200000 THEN
        SET estado = 'Plata';
    ELSE
        SET estado = 'Oro';
    END IF;

    RETURN estado;
END //

DELIMITER ;

DELIMITER //

CREATE OR REPLACE PROCEDURE sp_ActualizarMembresias()
BEGIN
    UPDATE cliente
    SET membresia = fn_DeterminarEstadoLealtad(id_cliente);
END //

DELIMITER ;


-- 15. fn_GenerarSKU: Genera un código único basado en nombre y categoría.

DROP FUNCTION IF EXISTS fn_GenerarSKU;

DELIMITER //

CREATE FUNCTION fn_GenerarSKU(
    p_nombre VARCHAR(100),
    p_id_categoria INT
)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE prefijo_cat VARCHAR(10) DEFAULT '';
    DECLARE prefijo_nom VARCHAR(10) DEFAULT '';
    DECLARE randnum VARCHAR(6);
    DECLARE sku VARCHAR(50);

    SELECT UPPER(LEFT(IFNULL(nombre, ''), 4))
    INTO prefijo_cat
    FROM categoria
    WHERE id_categoria = p_id_categoria
    LIMIT 1;

    SET prefijo_nom = UPPER(LEFT(IFNULL(p_nombre, ''), 4));

    IF prefijo_cat = '' THEN
        SET prefijo_cat = 'GEN';
    END IF;

    SET randnum = LPAD(FLOOR(RAND() * 99999), 5, '0');

    SET sku = CONCAT(prefijo_cat, '-', prefijo_nom, '-', randnum);

    RETURN sku;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_generar_sku_inventario
BEFORE INSERT ON inventario
FOR EACH ROW
BEGIN
    DECLARE v_nombre_producto VARCHAR(100);
    DECLARE v_id_categoria INT;

    -- Obtener nombre del producto
    SELECT nombre INTO v_nombre_producto
    FROM producto
    WHERE id_producto = NEW.id_producto_fk
    LIMIT 1;

    -- Obtener una categoría asociada (la primera si hay varias)
    SELECT id_categoria_fk INTO v_id_categoria
    FROM producto_categoria
    WHERE id_producto_fk = NEW.id_producto_fk
    LIMIT 1;

    -- Generar el SKU y asignarlo
    SET NEW.sku = fn_GenerarSKU(v_nombre_producto, v_id_categoria);
END //

DELIMITER ;

INSERT INTO
    `e_commerce_db`.`inventario` (stock, id_producto_fk)
VALUES (15, 95);

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
        'Laptop trabajo',
        'Laptop de alto rendimiento para desarrollador',
        3500000.00,
        NULL,
        1,
        2.5
    );


-- 16. fn_CalcularIVA: Calcula el IVA sobre un monto total.

DELIMITER //

CREATE OR REPLACE FUNCTION fn_CalcularIVA(p_id_producto INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_iva DECIMAL(5,2);
    DECLARE v_precio_final DECIMAL(10,2);

    SELECT p.precio, c.iva
    INTO v_precio, v_iva
    FROM producto p
    INNER JOIN categoria c ON p.id_categoria_fk = c.id_categoria
    WHERE p.id_producto = p_id_producto;

    SET v_precio_final = v_precio + (v_precio * (v_iva / 100));

    RETURN v_precio_final;
END //

DELIMITER ;

-- 17. fn_ObtenerStockTotalPorCategoria: Suma el stock de todos los productos de una categoría.

DROP FUNCTION IF EXISTS fn_ObtenerStockTotalPorCategoria;

DELIMITER //

CREATE FUNCTION fn_ObtenerStockTotalPorCategoria(p_id_categoria INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE stock_total INT DEFAULT 0;

    SELECT COALESCE(SUM(i.stock), 0) INTO stock_total
    FROM inventario i
    INNER JOIN producto_categoria pc ON i.id_producto_fk = pc.id_producto_fk
    WHERE pc.id_categoria_fk = p_id_categoria;

    RETURN stock_total;
END //

DELIMITER ;

SELECT c.id_categoria, c.nombre, fn_ObtenerStockTotalPorCategoria(c.id_categoria) AS stock_total
FROM categoria c;




-- 18. fn_EstimarFechaEntrega: Calcula la fecha estimada de entrega según ubicación.

DROP FUNCTION IF EXISTS fn_EstimarFechaEntrega;

DELIMITER //

CREATE FUNCTION fn_EstimarFechaEntrega(p_id_venta INT)
RETURNS DATE
DETERMINISTIC
BEGIN
    DECLARE fecha_estimada DATE;
    DECLARE dias_envio INT;

    SELECT
        CASE te.tipo
            WHEN 'liviano' THEN 4
            WHEN 'mediano' THEN 6
            WHEN 'pesado' THEN 8
            ELSE 5  -- valor por defecto si no coincide
        END
    INTO dias_envio
    FROM venta v
    JOIN tarifa_envio te ON v.id_tarifa_envio_fk = te.id_tarifa_envio
    WHERE v.id_venta = p_id_venta;

    SELECT DATE_ADD(v.fecha_venta, INTERVAL dias_envio DAY)
    INTO fecha_estimada
    FROM venta v
    WHERE v.id_venta = p_id_venta;

    RETURN fecha_estimada;
END //

DELIMITER ;


SELECT fn_EstimarFechaEntrega(1) AS fecha_estimada;


-- 19. fn_ConvertirMoneda: Convierte un monto a otra moneda con una tasa fija.

DROP FUNCTION IF EXISTS fn_ConvertirMoneda;

DELIMITER //

CREATE FUNCTION fn_ConvertirMoneda(
    p_monto DECIMAL(12,2),
    p_id_moneda INT
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE monto_convertido DECIMAL(12,2);
    DECLARE tasa DECIMAL(12,2);

    SELECT valor INTO tasa
    FROM moneda
    WHERE id_moneda = p_id_moneda;

    SET monto_convertido = p_monto * tasa;

    RETURN monto_convertido;
END //

DELIMITER ;

SELECT
    pv.id_producto_fk,
    pv.id_venta_fk,
    pv.precio_unitario,
    fn_ConvertirMoneda(pv.precio_unitario, pv.id_moneda_fk) AS precio_convertido
FROM producto_venta pv;

-- 20. fn_ValidarComplejidadContraseña: Verifica si la contraseña cumple con criterios de seguridad.

DELIMITER //

CREATE FUNCTION fn_ValidarComplejidadContraseña(p_clave VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN
        LENGTH(p_clave) >= 8
        AND p_clave REGEXP '[A-Z]'
        AND p_clave REGEXP '[a-z]'
        AND p_clave REGEXP '[0-9]'
        AND p_clave REGEXP '[!@#$%^&*(),.?":{}|<>]';
END //

DELIMITER ;

SELECT fn_ValidarComplejidadContraseña('MiClave123!');


-- 1. fn_CalcularTotalVenta: Calcula el monto total de una venta específica.
-- Eliminamos la función si ya existe
DROP FUNCTION IF EXISTS fn_total_venta;

DELIMITER //

CREATE FUNCTION fn_total_venta(p_id_venta INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(12,2);

    -- Calculamos la suma de cantidad * precio_unitario para la venta indicada
    SELECT SUM(cantidad * precio_unitario)
    INTO total
    FROM producto_venta
    WHERE id_venta_fk = p_id_venta;

    -- Si no hay registros, devolvemos 0
    IF total IS NULL THEN
        SET total = 0;
    END IF;

    RETURN total;
END //

DELIMITER ;

-- Calcular el total de la venta con id 2
SELECT fn_total_venta(2) AS total_venta;


-- 2. fn_VerificarDisponibilidadStock: Valida si hay stock suficiente para un producto.
-- Eliminamos la función si ya existe
DROP FUNCTION IF EXISTS fn_VerificarDisponibilidadStock;

DELIMITER //

CREATE FUNCTION fn_VerificarDisponibilidadStock(p_id_producto INT, p_cantidad INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE stock_actual INT;

    -- Obtenemos el stock actual del producto
    SELECT stock INTO stock_actual
    FROM inventario
    WHERE id_producto_fk = p_id_producto;

    -- Si no hay registro, asumimos 0
    IF stock_actual IS NULL THEN
        SET stock_actual = 0;
    END IF;

    -- Retornamos TRUE si hay suficiente stock, FALSE si no
    RETURN stock_actual >= p_cantidad;
END //

DELIMITER ;

-- Verificar si hay al menos 5 unidades del producto con id 1
SELECT fn_VerificarDisponibilidadStock(1, 5) AS stock_suficiente;

-- 3. fn_ObtenerPrecioProducto: Devuelve el precio actual de un producto.
-- Eliminamos la función si ya existe
DROP FUNCTION IF EXISTS fn_ObtenerPrecioProducto;

DELIMITER //

CREATE FUNCTION fn_ObtenerPrecioProducto(p_id_producto INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE precio_actual DECIMAL(10,2);

    SELECT precio INTO precio_actual
    FROM producto
    WHERE id_producto = p_id_producto;

    RETURN precio_actual;
END //

DELIMITER ;

-- Obtener el precio del producto con id 1
SELECT fn_ObtenerPrecioProducto(1) AS precio;

-- 4. fn_CalcularEdadCliente: Calcula la edad de un cliente a partir de su fecha de nacimiento.

-- Eliminamos la función si ya existe
DROP FUNCTION IF EXISTS fn_CalcularEdadCliente;

DELIMITER //

CREATE FUNCTION fn_CalcularEdadCliente(p_id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE edad INT;
    DECLARE fecha_nac DATE;

    -- Obtenemos la fecha de nacimiento del cliente
    SELECT STR_TO_DATE(fecha_nacimiento, '%Y-%m-%d') INTO fecha_nac
    FROM cliente
    WHERE id_cliente = p_id_cliente;

    -- Calculamos la edad
    SET edad = TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE());

    RETURN edad;
END //

DELIMITER ;

-- Calcular la edad del cliente con id 1
SELECT fn_CalcularEdadCliente(1) AS edad;


-- 5. fn_FormatearNombreCompleto: Devuelve el nombre y apellido de un cliente en formato estandarizado.
-- Eliminamos la función si ya existe
DROP FUNCTION IF EXISTS fn_FormatearNombreCompleto;

DELIMITER //

CREATE FUNCTION fn_FormatearNombreCompleto(p_id_cliente INT)
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(250);

    -- Concatenamos nombre y apellido y estandarizamos capitalización
    SELECT CONCAT(UCASE(LEFT(nombre, 1)), LCASE(SUBSTRING(nombre, 2)), ' ',
                  UCASE(LEFT(apellido, 1)), LCASE(SUBSTRING(apellido, 2)))
    INTO nombre_completo
    FROM cliente
    WHERE id_cliente = p_id_cliente;

    RETURN nombre_completo;
END //

DELIMITER ;


-- Obtener el nombre completo del cliente con id 1
SELECT fn_FormatearNombreCompleto(1) AS nombre_completo;

-- 6. fn_EsClienteNuevo: Devuelve TRUE si un cliente realizó su primera compra en los últimos 30 días.

DELIMITER //

CREATE OR FUNCTION fn_EsClienteNuevo()
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE es_nuevo BOOLEAN;

    -- Lógica para verificar si es cliente nuevo

    RETURN es_nuevo;
END //

DELIMITER ;

-- Verificar si el cliente con id 1 es nuevo
SELECT fn_EsClienteNuevo(1) AS es_cliente_nuevo;

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

CREATE FUNCTION fn_DeterminarEstadoLealtad(p_id_cliente INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE total_gasto_mes DECIMAL(10,2);
    DECLARE estado VARCHAR(20);

    SELECT IFNULL(SUM(total), 0)
    INTO total_gasto_mes
    FROM venta
    WHERE id_cliente_fk = p_id_cliente
      AND fecha_venta >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

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

CREATE PROCEDURE sp_ActualizarMembresias()
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

CREATE FUNCTION fn_CalcularIVA(p_id_producto INT)
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

DROP FUNCTION IF EXISTS fn_ValidarClave;

DELIMITER //

CREATE FUNCTION fn_ValidarClave(p_clave VARCHAR(255))
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

SELECT fn_ValidarClave('MiClave123!');


DROP FUNCTION IF EXISTS fn_CalcularPrecioIVA;

--- 21. fn_CalcularPrecioIVA: Calcula valor iva cuando ingrese un dato

DELIMITER //

CREATE FUNCTION fn_CalcularPrecioIVA(p_precio_base DECIMAL(10,2), p_id_categoria INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_iva DECIMAL(5,2);
    DECLARE v_precio_final DECIMAL(10,2);

    SELECT iva INTO v_iva
    FROM categoria
    WHERE id_categoria = p_id_categoria;

    SET v_precio_final = p_precio_base + (p_precio_base * (v_iva / 100));

    RETURN v_precio_final;
END //

DELIMITER ;



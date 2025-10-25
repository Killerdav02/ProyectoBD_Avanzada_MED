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

CREATE OR REPLACE FUNCTION fn_EsClienteNuevo()
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

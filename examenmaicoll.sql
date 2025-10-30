---El departamento de finanzas necesita una forma rápida y reutilizable de calcular la rentabilidad total de cualquier producto del catálogo. Esta función será crucial para tomar decisiones sobre qué productos promocionar y cuáles podrían necesitar un ajuste de precio o costo.



--- Tarea: Crea una función SQL llamada fn_CalcularRentabilidadProducto que reciba un id_producto como parámetro de entrada.

---- La función debe calcular el margen de beneficio de cada venta del producto (precio_unitario_congelado - costo del producto en ese momento).
--   Debe sumar el beneficio total generado por todas las ventas de ese producto a lo largo del tiempo.
--- La función debe devolver un único valor decimal que represente la rentabilidad total del producto.

DELIMITER //

CREATE FUNCTION fn_CalcularRentabilidadProducto(producto INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE rentabilidad_venta DECIMAL(12,2);
    DECLARE valor_venta DECIMAL(12,2);
    DECLARE total DECIMAL(12,2);

     -- Calculamos la suma de cantidad * precio_unitario para la venta indicada
    SELECT SUM(v.total) INTO rentabilidad_venta
    FROM producto_venta AS pv
    INNER JOIN venta AS v ON pv.id_venta_fk = v.id_venta
    WHERE id_producto_fk = producto;

    -- Calculamos la suma de cantidad * precio_unitario para la venta indicada
    SELECT SUM(pv.cantidad * .pv.precio_unitario) INTO total
    FROM producto_venta AS pv
    INNER JOIN producto AS p ON pv.id_producto_fk = p.id_producto
    WHERE id_producto_fk = producto;

    valor_venta = rentabilidad_venta - total

    RETURN valor_venta;
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION fn_CalcularRentabilidadProducto1(producto INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(12,2);

    -- Calculamos la suma de cantidad * precio_unitario para la venta indicada
    SELECT SUM(pv.cantidad * .pv.precio_unitario) INTO total
    FROM producto_venta AS pv
    INNER JOIN producto AS p ON pv.id_producto_fk = p.id_producto
    WHERE id_producto_fk = producto;

    RETURN total;
END //

DELIMITER ;


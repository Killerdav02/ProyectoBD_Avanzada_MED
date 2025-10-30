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
    DECLARE rentabilidad DECIMAL(12,2);
    DECLARE valor_venta DECIMAL(12,2);

    -- Calculamos la suma de cantidad * precio_unitario para la venta indicada
    SELECT SUM(pv.cantidad * .pv.precio_unitario) INTO total
    FROM producto_venta AS pv
    INNER JOIN producto AS p ON pv.id_producto_fk = p.id_producto
    WHERE producto = id_producto;

    RETURN total;
END //

DELIMITER ;


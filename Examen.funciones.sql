
--El departamento de finanzas necesita una forma rápida y reutilizable de calcular la rentabilidad total de cualquier producto del catálogo. Esta función será crucial para tomar decisiones sobre qué productos promocionar y cuáles podrían necesitar un ajuste de precio o costo.


--Tarea: Crea una función SQL llamada fn_CalcularRentabilidadProducto que reciba un id_producto como parámetro de entrada.

--La función debe calcular el margen de beneficio de cada venta del producto (precio_unitario_congelado - costo del producto en ese momento).
--Debe sumar el beneficio total generado por todas las ventas de ese producto a lo largo del tiempo.
--La función debe devolver un único valor decimal que represente la rentabilidad total del producto.


DROP FUNCTION IF EXISTS fn_CalcularRentabilidadProducto;

DELIMITER //

CREATE FUNCTION fn_CalcularRentabilidadProducto(p_id_producto INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(12,2);

    -- Calculamos la suma de cantidad * precio_unitario para la venta indicada
    SELECT SUM(cantidad * precio_unitario)
    INTO total
    FROM producto_venta
    WHERE id_producto_fk = p_id_producto;

    set =  (precio_iva - precio_costo);

    where id_producto_fk = 1
    
    RETURN total;
END //

DELIMITER ;


-- en esta seccion agregamos el precio costo para saber en cuanto me esta saliendo el producto
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`producto` (
  `id_producto` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(150) NOT NULL,
  `descripcion` TEXT NULL DEFAULT NULL,
  `precio` DECIMAL(10,2) NULL DEFAULT NULL,
  `precio_iva` DECIMAL(10,2) NULL DEFAULT NULL,
  `activo` TINYINT NULL DEFAULT NULL,
  `peso` DECIMAL(10,2) NULL DEFAULT NULL,
  `fecha_modificacion`  DATETIME NULL,
  PRIMARY KEY (`id_producto`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;
--agregado el precio costo para saber en cuanto me salio el producto
  ALTER TABLE producto
  ADD COLUMN precio_costo DECIMAL(10,2) NULL DEFAULT NULL;


--insertamos dato en la columna creada de precio costo

INSERT INTO
    `e_commerce_db`.`producto` (
        nombre,
        descripcion,
        precio,
        precio_iva,
        activo,
        peso,
        precio_costo
    )
VALUES (
        'Zapatos deportivos',
        'Zapatos cómodos para deportes y actividades al aire libre',
        150000.00,
        NULL,
        1,
        0.5,
        20000
    );
    
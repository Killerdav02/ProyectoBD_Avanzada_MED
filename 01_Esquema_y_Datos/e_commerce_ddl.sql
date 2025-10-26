-- MySQL Workbench Forward Engineering
SET time_zone = 'America/Bogota';

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema e_commerce_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema e_commerce_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `e_commerce_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `e_commerce_db` ;

-- -----------------------------------------------------
-- Table `e_commerce_db`.`cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`cliente` (
  `id_cliente` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `apellido` VARCHAR(100) NOT NULL,
  `email` VARCHAR(120) NOT NULL,
  `clave` VARCHAR(25) NOT NULL,
  `fecha_registro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_nacimiento` VARCHAR(45) NOT NULL,
  `estado` ENUM('activo', 'inactivo') NULL DEFAULT 'activo',
  `ultima_compra` DATETIME NULL DEFAULT NULL,
  `membresia` ENUM('oro', 'plata', 'bronce') NULL DEFAULT NULL,
  `puntos` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id_cliente`),
  UNIQUE INDEX `email` (`email` ASC) VISIBLE,
  UNIQUE INDEX `id_cliente_UNIQUE` (`id_cliente` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;
  ALTER TABLE cliente
  ADD COLUMN id_referido INT NULL,
  ADD CONSTRAINT fk_referido
  FOREIGN KEY (id_referido) REFERENCES cliente(id_cliente);


-- -----------------------------------------------------
-- Table `e_commerce_db`.`producto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`producto` (
  `id_producto` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(150) NOT NULL,
  `descripcion` TEXT NULL DEFAULT NULL,
  `precio` DECIMAL(10,2) NULL DEFAULT NULL,
  `precio_iva` DECIMAL(10,2) NULL DEFAULT NULL,
  `activo` TINYINT NULL DEFAULT NULL,
  `peso` DECIMAL(10,2) NULL DEFAULT NULL,
  PRIMARY KEY (`id_producto`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`carrito`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`carrito` (
  `id_carrito` INT NOT NULL,
  `id_producto_fk` INT NOT NULL,
  `id_cliente_fk` INT NOT NULL,
  `cantidad` INT NULL DEFAULT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `estado` ENUM('activo', 'abandonado', 'convertido') NOT NULL DEFAULT 'activo',
  PRIMARY KEY (`id_carrito`, `id_producto_fk`),
  INDEX `fk_carrito_producto_idx` (`id_producto_fk` ASC) VISIBLE,
  INDEX `fk_carrito_cliente_idx` (`id_cliente_fk` ASC) VISIBLE,
  CONSTRAINT `fk_carrito_cliente`
    FOREIGN KEY (`id_cliente_fk`)
    REFERENCES `e_commerce_db`.`cliente` (`id_cliente`),
  CONSTRAINT `fk_carrito_producto`
    FOREIGN KEY (`id_producto_fk`)
    REFERENCES `e_commerce_db`.`producto` (`id_producto`)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;



-- -----------------------------------------------------
-- Table `e_commerce_db`.`categoria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`categoria` (
  `id_categoria` INT NOT NULL AUTO_INCREMENT,
  `descripcion` TEXT NOT NULL,
  `nombre` ENUM('Calzado', 'Ropa', 'Electronico', 'Hogar') NOT NULL,
  `iva` DECIMAL(5,2) NULL DEFAULT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE INDEX `nombre_UNIQUE` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`direccion_envio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`direccion_envio` (
  `id_direccion_envio` INT NOT NULL AUTO_INCREMENT,
  `ciudad` VARCHAR(45) NOT NULL,
  `barrio` VARCHAR(45) NOT NULL,
  `calle` VARCHAR(45) NOT NULL,
  `tipo` ENUM('Apartamento', 'Casa', 'Oficina', 'Otro') NULL DEFAULT NULL,
  PRIMARY KEY (`id_direccion_envio`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`cliente_direccion_envio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`cliente_direccion_envio` (
  `id_cliente_fk` INT NOT NULL,
  `id_direccion_envio_fk` INT NOT NULL,
  PRIMARY KEY (`id_cliente_fk`, `id_direccion_envio_fk`),
  INDEX `fk_clientes_has_direccion_envio_direccion_envio1_idx` (`id_direccion_envio_fk` ASC) VISIBLE,
  INDEX `fk_clientes_has_direccion_envio_clientes1_idx` (`id_cliente_fk` ASC) VISIBLE,
  CONSTRAINT `fk_clientes_has_direccion_envio_clientes1`
    FOREIGN KEY (`id_cliente_fk`)
    REFERENCES `e_commerce_db`.`cliente` (`id_cliente`),
  CONSTRAINT `fk_clientes_has_direccion_envio_direccion_envio1`
    FOREIGN KEY (`id_direccion_envio_fk`)
    REFERENCES `e_commerce_db`.`direccion_envio` (`id_direccion_envio`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `descuento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`descuento` (
  `id_descuento` INT NOT NULL AUTO_INCREMENT,
  `tipo` ENUM('puntos', 'cumpleaños', 'categoria', 'producto') NULL DEFAULT NULL,
  `valor` DECIMAL(10,2) NULL DEFAULT NULL,
  `nombre` ENUM('porcentaje') NULL DEFAULT 'porcentaje',
  `fecha_inicio` DATETIME NULL DEFAULT NULL,
  `fecha_fin` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id_descuento`)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`inventario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`inventario` (
  `id_inventario` INT NOT NULL AUTO_INCREMENT,
  `sku` VARCHAR(150) NULL DEFAULT NULL,
  `stock` INT NOT NULL,
  `id_producto_fk` INT NOT NULL,
  PRIMARY KEY (`id_inventario`),
  UNIQUE INDEX `sku_UNIQUE` (`sku` ASC) VISIBLE,
  INDEX `fk_inventario_producto1_idx` (`id_producto_fk` ASC) VISIBLE,
  CONSTRAINT `fk_inventario_producto1`
    FOREIGN KEY (`id_producto_fk`)
    REFERENCES `e_commerce_db`.`producto` (`id_producto`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`moneda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`moneda` (
  `id_moneda` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `valor` DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (`id_moneda`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`pais`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`pais` (
  `id_pais` INT NOT NULL AUTO_INCREMENT,
  `indicativo` VARCHAR(10) NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_pais`),
  UNIQUE INDEX `indicativo_UNIQUE` (`indicativo` ASC) VISIBLE,
  UNIQUE INDEX `nombre_UNIQUE` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`producto_categoria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`producto_categoria` (
  `id_producto_fk` INT NOT NULL,
  `id_categoria_fk` INT NOT NULL,
  PRIMARY KEY (`id_categoria_fk`, `id_producto_fk`),
  INDEX `fk_categoria_producto_producto1_idx` (`id_producto_fk` ASC) VISIBLE,
  INDEX `fk_categoria_producto_categoria1_idx` (`id_categoria_fk` ASC) VISIBLE,
  CONSTRAINT `fk_categoria_producto_categoria1`
    FOREIGN KEY (`id_categoria_fk`)
    REFERENCES `e_commerce_db`.`categoria` (`id_categoria`),
  CONSTRAINT `fk_categoria_producto_producto1`
    FOREIGN KEY (`id_producto_fk`)
    REFERENCES `e_commerce_db`.`producto` (`id_producto`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`tarifa_envio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`tarifa_envio` (
  `id_tarifa_envio` INT NOT NULL AUTO_INCREMENT,
  `tipo` ENUM('liviano', 'mediano', 'pesado') NULL DEFAULT NULL,
  `valor` DECIMAL(10,2) NULL DEFAULT NULL,
  PRIMARY KEY (`id_tarifa_envio`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`tienda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`tienda` (
  `id_tienda` INT NOT NULL AUTO_INCREMENT,
  `nit` VARCHAR(45) NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_tienda`),
  UNIQUE INDEX `nit_UNIQUE` (`nit` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`venta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`venta` (
  `id_venta` INT NOT NULL AUTO_INCREMENT,
  `fecha_venta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` ENUM('Pendiente', 'Procesando', 'Enviado', 'Entregado', 'Cancelado') NOT NULL DEFAULT 'Pendiente',
  `total` DECIMAL(12,2) NULL DEFAULT '0.00',
  `id_cliente_fk` INT NOT NULL,
  `id_tienda_fk` INT NOT NULL,
  `id_descuento_fk` INT NOT NULL,
  `id_tarifa_envio_fk` INT NOT NULL,
  PRIMARY KEY (`id_venta`),
  INDEX `fk_venta_cliente1_idx` (`id_cliente_fk` ASC) VISIBLE,
  INDEX `fk_venta_tienda1_idx` (`id_tienda_fk` ASC) VISIBLE,
  INDEX `fk_venta_descuento1_idx` (`id_descuento_fk` ASC) VISIBLE,
  INDEX `fk_venta_tarifa_envio1_idx` (`id_tarifa_envio_fk` ASC) VISIBLE,
  CONSTRAINT `fk_venta_cliente1`
    FOREIGN KEY (`id_cliente_fk`)
    REFERENCES `e_commerce_db`.`cliente` (`id_cliente`),
  CONSTRAINT `fk_venta_descuento1`
    FOREIGN KEY (`id_descuento_fk`)
    REFERENCES `e_commerce_db`.`descuento` (`id_descuento`),
  CONSTRAINT `fk_venta_tarifa_envio1`
    FOREIGN KEY (`id_tarifa_envio_fk`)
    REFERENCES `e_commerce_db`.`tarifa_envio` (`id_tarifa_envio`),
  CONSTRAINT `fk_venta_tienda1`
    FOREIGN KEY (`id_tienda_fk`)
    REFERENCES `e_commerce_db`.`tienda` (`id_tienda`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;
ALTER TABLE descuento 
ADD COLUMN activo TINYINT DEFAULT 1 AFTER nombre;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`producto_venta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`producto_venta` (
  `id_producto_fk` INT NOT NULL,
  `id_venta_fk` INT NOT NULL,
  `cantidad` INT NOT NULL,
  `precio_unitario` DECIMAL(10,2) NULL DEFAULT NULL,
  `id_moneda_fk` INT NOT NULL,
  PRIMARY KEY (`id_producto_fk`, `id_venta_fk`, `id_moneda_fk`),
  INDEX `fk_producto_has_venta_venta1_idx` (`id_venta_fk` ASC) VISIBLE,
  INDEX `fk_producto_has_venta_producto1_idx` (`id_producto_fk` ASC) VISIBLE,
  INDEX `fk_producto_venta_moneda1_idx` (`id_moneda_fk` ASC) VISIBLE,
  CONSTRAINT `fk_producto_has_venta_producto1`
    FOREIGN KEY (`id_producto_fk`)
    REFERENCES `e_commerce_db`.`producto` (`id_producto`),
  CONSTRAINT `fk_producto_has_venta_venta1`
    FOREIGN KEY (`id_venta_fk`)
    REFERENCES `e_commerce_db`.`venta` (`id_venta`),
  CONSTRAINT `fk_producto_venta_moneda1`
    FOREIGN KEY (`id_moneda_fk`)
    REFERENCES `e_commerce_db`.`moneda` (`id_moneda`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`proveedor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`proveedor` (
  `id_proveedor` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(150) NOT NULL,
  `email_contacto` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`id_proveedor`),
  UNIQUE INDEX `email_contacto` (`email_contacto` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`proveedor_tienda_producto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`proveedor_tienda_producto` (
  `condiciones` TEXT NOT NULL,
  `estado` ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
  `id_tienda_fk` INT NOT NULL,
  `id_proveedor_fk` INT NOT NULL,
  `id_producto_fk` INT NOT NULL,
  `cantidad` INT NULL,
  PRIMARY KEY (`id_tienda_fk`, `id_proveedor_fk`, `id_producto_fk`),
  INDEX `fk_tienda_proveedor_tienda_idx` (`id_tienda_fk` ASC) VISIBLE,
  INDEX `fk_tienda_proveedor_proveedor1_idx` (`id_proveedor_fk` ASC) VISIBLE,
  INDEX `fk_tienda_proveedor_producto1_idx` (`id_producto_fk` ASC) VISIBLE,
  CONSTRAINT `fk_tienda_proveedor_producto1`
    FOREIGN KEY (`id_producto_fk`)
    REFERENCES `e_commerce_db`.`producto` (`id_producto`),
  CONSTRAINT `fk_tienda_proveedor_proveedor1`
    FOREIGN KEY (`id_proveedor_fk`)
    REFERENCES `e_commerce_db`.`proveedor` (`id_proveedor`),
  CONSTRAINT `fk_tienda_proveedor_tienda`
    FOREIGN KEY (`id_tienda_fk`)
    REFERENCES `e_commerce_db`.`tienda` (`id_tienda`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`telefono`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `e_commerce_db`.`telefono` (
  `id_telefono` INT NOT NULL AUTO_INCREMENT,
  `id_pais_fk` INT NOT NULL,
  `telefono` VARCHAR(15) NULL DEFAULT NULL,
  `id_cliente_fk` INT NOT NULL,
  PRIMARY KEY (`id_telefono`, `id_cliente_fk`),
  UNIQUE INDEX `telefono_UNIQUE` (`telefono` ASC) VISIBLE,
  INDEX `fk_telefono_pais1_idx` (`id_pais_fk` ASC) VISIBLE,
  INDEX `fk_telefono_cliente1_idx` (`id_cliente_fk` ASC) VISIBLE,
  CONSTRAINT `fk_telefono_pais1`
    FOREIGN KEY (`id_pais_fk`)
    REFERENCES `e_commerce_db`.`pais` (`id_pais`),
  CONSTRAINT `fk_telefono_cliente1`
    FOREIGN KEY (`id_cliente_fk`)
    REFERENCES `e_commerce_db`.`cliente` (`id_cliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `e_commerce_db`.`venta_eliminada`(
  `id_venta_fk` INT PRIMARY KEY,
  `fecha_eliminacion` DATETIME NOT NULL,
  `motivo` TEXT NOT NULL,
  CONSTRAINT `venta_elimina_fk`
  FOREIGN KEY ( `id_venta_fk` )
  REFERENCES `e_commerce_db`.`venta` (`id_venta`)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- -----------------------------------------------------
-- Table `e_commerce_db`.`auditoria_cliente`
-- -----------------------------------------------------
CREATE TABLE auditoria_cliente (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_fk INT NOT NULL,
    nombre VARCHAR(200),
    email VARCHAR(200),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente_fk) REFERENCES cliente(id_cliente)
);
-- -----------------------------------------------------
-- Table `e_commerce_db`.`auditoria_cliente`
-- -----------------------------------------------------
CREATE TABLE auditoria_precio (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_producto_fk INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto_fk) REFERENCES producto(id_producto)
);

--- ================================================
-- 1. Crear tabla para reporte de ventas semanal
-- ================================================
CREATE TABLE IF NOT EXISTS reporte_ventas_semanal (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    fecha_reporte DATETIME NOT NULL,
    total_ventas DECIMAL(12,2) NOT NULL,
    total_productos INT NOT NULL
);

CREATE TABLE IF NOT EXISTS lista_reabastecimiento (
    id_lista INT AUTO_INCREMENT PRIMARY KEY,
    id_producto_fk INT NOT NULL,
    nombre_producto VARCHAR(150) NOT NULL,
    stock_actual INT NOT NULL,
    stock_minimo INT NOT NULL,
    cantidad_sugerida INT NOT NULL,
    fecha_generacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('pendiente', 'procesado', 'cancelado') DEFAULT 'pendiente',
    FOREIGN KEY (id_producto_fk) REFERENCES producto(id_producto),
    INDEX idx_fecha_estado (fecha_generacion, estado)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


CREATE TABLE IF NOT EXISTS log_mantenimiento_indices (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabla_nombre VARCHAR(100) NOT NULL,
    accion VARCHAR(50) NOT NULL,
    fecha_ejecucion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('exitoso', 'fallido') DEFAULT 'exitoso',
    mensaje TEXT,
    INDEX idx_fecha (fecha_ejecucion)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `e_commerce_db`.`auditoria_estado_venta` (
    `id_auditoria_estado_venta` INT AUTO_INCREMENT PRIMARY KEY,
    `id_venta_fk` INT NOT NULL,
    `estado_anterior` ENUM('Pendiente', 'Procesando', 'Enviado', 'Entregado', 'Cancelado') NOT NULL,
    `estado_nuevo` ENUM('Pendiente', 'Procesando', 'Enviado', 'Entregado', 'Cancelado') NOT NULL,
    `id_cliente_fk` INT NOT NULL,
    `total_venta` DECIMAL(12,2) NULL,
    `fecha_cambio` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`id_venta_fk`) REFERENCES `e_commerce_db`.`venta` (`id_venta`),
    FOREIGN KEY (`id_cliente_fk`) REFERENCES `e_commerce_db`.`cliente` (`id_cliente`),
    INDEX idx_fecha_cambio (fecha_cambio),
    INDEX idx_venta (id_venta_fk)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS resumen_ventas_diarias (
    fecha DATE NOT NULL,
    total_ventas DECIMAL(12,2) NOT NULL,
    total_productos_vendidos INT NOT NULL,
    PRIMARY KEY (fecha)
);

CREATE TABLE IF NOT EXISTS auditoria_consistencia_datos (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    tabla VARCHAR(100) NOT NULL,
    error VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS cupones_cumpleanos (
    id_cupón INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_cliente_fk INT NOT NULL,                        -- Cliente que recibe el cupón
    codigo_cupon VARCHAR(50) NOT NULL,                  -- Código único del cupón
    fecha_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Fecha de envío del cupón
    estado ENUM('enviado', 'usado') DEFAULT 'enviado',  -- Estado del cupón (activo o usado)
    descuento DECIMAL(10,2) NOT NULL,                   -- Valor del descuento
    FOREIGN KEY (id_cliente_fk) REFERENCES cliente(id_cliente)
);

CREATE TABLE IF NOT EXISTS ranking_productos (
    id_producto_fk INT NOT NULL,
    total_vendido DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_cantidad INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_producto_fk),
    CONSTRAINT fk_ranking_producto FOREIGN KEY (id_producto_fk)
        REFERENCES producto (id_producto)
        ON DELETE CASCADE,
    INDEX idx_total_vendido (total_vendido DESC)
);

--- 1. Crear el rol Administrador_Sistema con todos los privilegios.

-- Crear rol Administrador_Sistema
DROP ROLE IF EXISTS 'Administrador_Sistema';
CREATE ROLE 'Administrador_Sistema';

-- Asignar todos los privilegios al rol
GRANT ALL PRIVILEGES ON *.* TO 'Administrador_Sistema' WITH GRANT OPTION;

-- Crear usuario admin y asignar rol
DROP USER IF EXISTS 'admin'@'localhost';
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'TuContraseñaSegura';
GRANT 'Administrador_Sistema' TO 'admin'@'localhost';

-- Activar el rol por defecto al conectarse
SET DEFAULT ROLE 'Administrador_Sistema' TO 'admin'@'localhost';

-- Verificar privilegios
SHOW GRANTS FOR 'admin'@'localhost';

--- 2. Crear el rol Gerente_Marketing con acceso de solo lectura a ventas y clientes.

-- Crear rol Gerente_Marketing
DROP ROLE IF EXISTS 'Gerente_Marketing';
CREATE ROLE 'Gerente_Marketing';

-- Asignar privilegios de solo lectura a las tablas venta y cliente
GRANT SELECT ON e_commerce_db.venta TO 'Gerente_Marketing';
GRANT SELECT ON e_commerce_db.cliente TO 'Gerente_Marketing';

-- Crear usuario gerente y asignar rol
DROP USER IF EXISTS 'gerente'@'localhost';
CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'TuContraseñaSegura';

GRANT 'Gerente_Marketing' TO 'gerente'@'localhost';

-- Activar el rol por defecto al conectarse
SET DEFAULT ROLE 'Gerente_Marketing' TO 'gerente'@'localhost';

-- Verificar privilegios
SHOW GRANTS FOR 'gerente'@'localhost';

--- 3. Crear el rol Analista_Datos con acceso de solo lectura a todas las tablas, excepto a las de auditoría.
-- Crear rol Analista_Datos
DROP ROLE IF EXISTS 'Analista_Datos';
CREATE ROLE 'Analista_Datos';

-- Otorgar privilegios de solo lectura a todas las tablas de la base de datos, excepto las de auditoría
-- Primero obtenemos las tablas que no son de auditoría
-- Ajusta "e_commerce_db" si tu base de datos tiene otro nombre

-- Ejemplo directo si las tablas son: producto, venta, cliente, producto_venta, inventario, tienda, descuento, tarifa_envio
GRANT SELECT ON e_commerce_db.producto TO 'Analista_Datos';
GRANT SELECT ON e_commerce_db.venta TO 'Analista_Datos';
GRANT SELECT ON e_commerce_db.cliente TO 'Analista_Datos';
GRANT SELECT ON e_commerce_db.producto_venta TO 'Analista_Datos';
GRANT SELECT ON e_commerce_db.inventario TO 'Analista_Datos';
GRANT SELECT ON e_commerce_db.tienda TO 'Analista_Datos';
GRANT SELECT ON e_commerce_db.descuento TO 'Analista_Datos';
GRANT SELECT ON e_commerce_db.tarifa_envio TO 'Analista_Datos';
-- No se otorgan privilegios sobre tablas de auditoría, por ejemplo: auditoria_cliente, auditoria_precio

-- Crear usuario analista y asignar rol
DROP USER IF EXISTS 'analista'@'localhost';
CREATE USER 'analista'@'localhost' IDENTIFIED BY 'TuContraseñaSegura';

GRANT 'Analista_Datos' TO 'analista'@'localhost';

-- Activar el rol por defecto al conectarse
SET DEFAULT ROLE 'Analista_Datos' TO 'analista'@'localhost';

-- Verificar privilegios
SHOW GRANTS FOR 'analista'@'localhost';


--- 4. Crear el rol Empleado_Inventario que solo pueda modificar la tabla productos (stock y ubicación).
-- Crear rol Empleado_Inventario
DROP ROLE IF EXISTS 'Empleado_Inventario';
CREATE ROLE 'Empleado_Inventario';

-- Otorgar permisos de solo actualización a columnas específicas de la tabla producto
-- Ajusta las columnas según tu base de datos, por ejemplo: stock, ubicacion
GRANT UPDATE (precio, peso, activo) ON e_commerce_db.producto TO 'Empleado_Inventario';
-- Si el stock está en la tabla inventario
GRANT UPDATE (stock, ubicacion) ON e_commerce_db.inventario TO 'Empleado_Inventario';

-- No otorgar permisos de INSERT, DELETE ni acceso a otras tablas

-- Crear usuario inventario y asignar rol
DROP USER IF EXISTS 'empleado_inventario'@'localhost';
CREATE USER 'empleado_inventario'@'localhost' IDENTIFIED BY 'TuContraseñaSegura';

GRANT 'Empleado_Inventario' TO 'empleado_inventario'@'localhost';

-- Activar el rol por defecto al conectarse
SET DEFAULT ROLE 'Empleado_Inventario' TO 'empleado_inventario'@'localhost';

-- Verificar privilegios
SHOW GRANTS FOR 'empleado_inventario'@'localhost';

--- 5. Crear el rol Atencion_Cliente que pueda ver clientes y ventas, pero no modificar precios.
-- Crear rol Atencion_Cliente
DROP ROLE IF EXISTS 'Atencion_Cliente';
CREATE ROLE 'Atencion_Cliente';

-- Otorgar permisos de solo lectura a las tablas cliente y venta
GRANT SELECT ON e_commerce_db.cliente TO 'Atencion_Cliente';
GRANT SELECT ON e_commerce_db.venta TO 'Atencion_Cliente';

-- No otorgar permisos de INSERT, UPDATE ni DELETE

-- Crear usuario atencion_cliente y asignar rol
DROP USER IF EXISTS 'atencion_cliente'@'localhost';
CREATE USER 'atencion_cliente'@'localhost' IDENTIFIED BY 'TuContraseñaSegura';

GRANT 'Atencion_Cliente' TO 'atencion_cliente'@'localhost';

-- Activar el rol por defecto al conectarse
SET DEFAULT ROLE 'Atencion_Cliente' TO 'atencion_cliente'@'localhost';

-- Verificar privilegios
SHOW GRANTS FOR 'atencion_cliente'@'localhost';

--- 6. Crear el rol Auditor_Financiero con acceso de solo lectura a ventas, productos y logs de precios.
-- Crear rol Auditor_Financiero
DROP ROLE IF EXISTS 'Auditor_Financiero';
CREATE ROLE 'Auditor_Financiero';

-- Otorgar permisos de solo lectura a ventas, productos y auditoría de precios
GRANT SELECT ON e_commerce_db.venta TO 'Auditor_Financiero';
GRANT SELECT ON e_commerce_db.producto TO 'Auditor_Financiero';
GRANT SELECT ON e_commerce_db.auditoria_precio TO 'Auditor_Financiero';

-- Crear usuario auditor_financiero y asignar rol
DROP USER IF EXISTS 'auditor_financiero'@'localhost';
CREATE USER 'auditor_financiero'@'localhost' IDENTIFIED BY 'TuContraseñaSegura';

GRANT 'Auditor_Financiero' TO 'auditor_financiero'@'localhost';

-- Activar el rol por defecto al conectarse
SET DEFAULT ROLE 'Auditor_Financiero' TO 'auditor_financiero'@'localhost';

-- Verificar privilegios
SHOW GRANTS FOR 'auditor_financiero'@'localhost';

--- 7. Crear un usuario admin_user y asignarle el rol de administrador.
-- Crear usuario admin_user
DROP USER IF EXISTS 'admin_user'@'localhost';
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'TuContraseñaSegura';

-- Asignar el rol Administrador_Sistema al usuario
GRANT 'Administrador_Sistema' TO 'admin_user'@'localhost';

-- Activar el rol por defecto al conectarse
SET DEFAULT ROLE 'Administrador_Sistema' TO 'admin_user'@'localhost';

-- Verificar privilegios
SHOW GRANTS FOR 'admin_user'@'localhost';

--- 8. Crear un usuario marketing_user y asignarle el rol de marketing.
--- 9. Crear un usuario inventory_user y asignarle el rol de inventario.
--- 10. Crear un usuario support_user y asignarle el rol de atención al cliente.
--- 11. Impedir que el rol Analista_Datos pueda ejecutar comandos DELETE o TRUNCATE.
--- 12. Otorgar al rol Gerente_Marketing permiso para ejecutar procedimientos almacenados de reportes de marketing.
--- 13. Crear una vista v_info_clientes_basica que oculte información sensible y dar acceso a ella al rol Atencion_Cliente.
-- 14. Revocar el permiso de UPDATE sobre la columna precio de la tabla productos al rol Empleado_Inventario.

REVOKE UPDATE (precio) ON producto FROM 'Empleado_Inventario';

-- 15. Implementar una política de contraseñas seguras para todos los usuarios.

INSTALL PLUGIN IF NOT EXISTS validate_password SONAME 'validate_password.so';
SET GLOBAL validate_password.policy = 'STRONG';
SET GLOBAL validate_password.length = 12;
SET GLOBAL validate_password.mixed_case_count = 1;
SET GLOBAL validate_password.number_count = 1;
SET GLOBAL validate_password.special_char_count = 1;

-- 16. Asegurar que el usuario root no pueda ser usado desde conexiones remotas.

DROP USER IF EXISTS 'root'@'%';
CREATE USER 'root'@'localhost' IDENTIFIED BY 'TuContraseñaSegura';

-- 17. Crear un rol Visitante que solo pueda ver la tabla productos.

CREATE ROLE IF NOT EXISTS 'Visitante';
GRANT SELECT ON producto TO 'Visitante';

-- 18. Limitar el número de consultas por hora para el rol Analista_Datos para evitar sobrecarga.

CREATE USER IF NOT EXISTS 'Analista_Datos'@'localhost' IDENTIFIED BY 'TuContraseñaSegura' WITH MAX_QUERIES_PER_HOUR 100;

-- 19. Asegurar que los usuarios solo puedan ver las ventas de la sucursal a la que pertenecen (requiere añadir id_sucursal).

ALTER TABLE venta ADD COLUMN IF NOT EXISTS id_sucursal INT;
CREATE VIEW vista_ventas_usuario AS
SELECT * FROM venta
WHERE id_sucursal = (SELECT id_sucursal FROM usuario_sucursal WHERE usuario = CURRENT_USER());

-- 20 Auditar todos los intentos de inicio de sesión fallidos en la base de datos.

CREATE TABLE IF NOT EXISTS log_intentos_fallidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50),
    host VARCHAR(50),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);


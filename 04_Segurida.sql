--- 1. Crear el rol Administrador_Sistema con todos los privilegios.
--- 2. Crear el rol Gerente_Marketing con acceso de solo lectura a ventas y clientes.
--- 3. Crear el rol Analista_Datos con acceso de solo lectura a todas las tablas, excepto a las de auditoría.
--- 4. Crear el rol Empleado_Inventario que solo pueda modificar la tabla productos (stock y ubicación).
--- 5. Crear el rol Atencion_Cliente que pueda ver clientes y ventas, pero no modificar precios.
--- 6. Crear el rol Auditor_Financiero con acceso de solo lectura a ventas, productos y logs de precios.
--- 7. Crear un usuario admin_user y asignarle el rol de administrador.
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


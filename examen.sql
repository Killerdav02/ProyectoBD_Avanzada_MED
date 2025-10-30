-- Active: 1761843830446@@127.0.0.1@3309@e_commerce_db
select * from venta;

select * from producto_venta;

select precio_unitario, cantidad from producto_venta where id_venta_fk = 5;


    ALTER TABLE venta 
    MODIFY COLUMN `estado` enum('Pendiente','Procesando','Enviado','Entregado','Cancelado','devuelta parcialmente','Devuleta totalmente');

DELIMITER $$

CREATE PROCEDURE sp_CambiarEstadoPedido (
    IN p_id_venta INT,
    IN p_nuevo_estado ENUM('Pendiente','Procesando','Enviado','Entregado','Cancelado','devuelta parcialmente','Devuleta totalmente')
)
BEGIN
    DECLARE v_estado_anterior ENUM('Pendiente','Procesando','Enviado','Entregado','Cancelado','devuelta parcialmente','Devuleta totalmente');
    DECLARE v_id_cliente INT;
    DECLARE v_total DECIMAL(12,2);

    -- Obtener los datos actuales del pedido
    SELECT estado, id_cliente_fk, total
    INTO v_estado_anterior, v_id_cliente, v_total
    FROM venta
    WHERE id_venta = p_id_venta;

    IF v_estado_anterior = p_nuevo_estado THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El pedido ya tiene ese estado.';
    ELSE
        UPDATE venta
        SET estado = p_nuevo_estado
        WHERE id_venta = p_id_venta;

        INSERT INTO auditoria_estado_venta (
            id_venta_fk,
            estado_anterior,
            estado_nuevo,
            id_cliente_fk,
            total_venta,
            fecha_cambio
        )
        VALUES (
            p_id_venta,
            v_estado_anterior,
            p_nuevo_estado,
            v_id_cliente,
            v_total,
            NOW()
        );

    END IF;
END$$

DELIMITER ;

--- como usarlo:
CALL sp_CambiarEstadoPedido(6, 'devuelta parcialmente');

select estado,total,id_venta from venta where estado = 'devuelta parcialmente';

--- pensaba crear una funcion dentro del prcedimiento pero no fui capaz, hasta el momento solo actualiza el estado pèro no devuelve el dinero o el dato a las demas tablas :()

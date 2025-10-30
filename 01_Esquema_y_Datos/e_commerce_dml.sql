--- insercion de categorias
INSERT INTO
    categoria (descripcion, nombre, iva)
VALUES (
        'Calzado deportivo y casual para hombres, mujeres y niños',
        'Calzado',
        0.00
    );

INSERT INTO
    categoria (descripcion, nombre, iva)
VALUES (
        'Prendas de vestir como camisetas, pantalones y chaquetas',
        'Ropa',
        19.00
    );

INSERT INTO
    categoria (descripcion, nombre, iva)
VALUES (
        'Dispositivos electrónicos como celulares, tablets y accesorios',
        'Electronico',
        19.00
    );

INSERT INTO
    categoria (descripcion, nombre, iva)
VALUES (
        'Artículos para el hogar, cocina y decoración',
        'Hogar',
        5.00
    );

INSERT INTO
    categoria (descripcion, iva)
VALUES (
        'Artículos para el hogar, cocina y decoración',
        8.00
    );

ALTER TABLE categoria
MODIFY COLUMN `nombre` enum('Calzado','Ropa','Electronico','Hogar','Pendiente');
--- insercion de cliente
INSERT INTO
    cliente (
        nombre,
        apellido,
        email,
        clave,
        fecha_registro,
        fecha_nacimiento
    )
VALUES (
        'Sofía',
        'Torres',
        'sofiatorres@example.com',
        'password1.',
        '2024-05-12',
        '1981-02-23'
    ),
    (
        'Raquel',
        'Mendoza',
        'raquelmendoza@example.com',
        'password2.',
        '2023-06-05',
        '1982-10-13'
    ),
    (
        'Daniel',
        'Martínez',
        'danielmartinez@example.com',
        'password3.',
        '2023-01-18',
        '2000-02-20'
    ),
    (
        'María',
        'Fernández',
        'mariafernandez@example.com',
        'password4.',
        '2024-08-09',
        '1986-02-19'
    ),
    (
        'Javier',
        'Jiménez',
        'javierjimenez@example.com',
        'password5.',
        '2023-12-04',
        '1983-08-24'
    ),
    (
        'Tomás',
        'Ramírez',
        'tomasramirez@example.com',
        'password6.',
        '2025-08-19',
        '1984-04-10'
    ),
    (
        'Fernando',
        'Pérez',
        'fernandoperez@example.com',
        'password7.',
        '2024-12-13',
        '1995-10-15'
    ),
    (
        'Elena',
        'Calle',
        'elenacalle@example.com',
        'password8.',
        '2024-11-14',
        '1987-10-19'
    ),
    (
        'Lucía',
        'Sánchez',
        'luciasanchez@example.com',
        'password9.',
        '2025-10-05',
        '1988-10-19'
    ),
    (
        'Raul',
        'Morales',
        'raulmorales@example.com',
        'password10.',
        '2023-12-07',
        '1998-01-25'
    ),
    (
        'Miguel',
        'Cordero',
        'miguelcordero@example.com',
        'password11.',
        '2025-05-07',
        '1993-02-27'
    ),
    (
        'Paula',
        'Fernández',
        'paulafernandez@example.com',
        'password12.',
        '2024-02-05',
        '1997-12-19'
    ),
    (
        'Alberto',
        'Ruiz',
        'albertoruiz@example.com',
        'password13.',
        '2024-07-10',
        '1991-09-20'
    ),
    (
        'Pedro',
        'Sánchez',
        'pedrosanchez@example.com',
        'password14.',
        '2025-01-06',
        '1989-04-21'
    ),
    (
        'Marta',
        'Sánchez',
        'martasanchez@example.com',
        'password15.',
        '2025-02-21',
        '1992-02-03'
    ),
    (
        'Carlos',
        'Vázquez',
        'carlosvazquez@example.com',
        'password16.',
        '2024-09-25',
        '1983-08-19'
    ),
    (
        'Javier',
        'Cordero',
        'javiercordero@example.com',
        'password17.',
        '2025-04-15',
        '1985-06-27'
    ),
    (
        'Laura',
        'Jiménez',
        'laurajimenez@example.com',
        'password18.',
        '2025-03-04',
        '1981-03-04'
    ),
    (
        'Carlos',
        'Gómez',
        'carlosgomez@example.com',
        'password19.',
        '2025-04-16',
        '1993-09-25'
    ),
    (
        'David',
        'Sánchez',
        'davidsanchez@example.com',
        'password20.',
        '2024-04-02',
        '1986-12-01'
    );

INSERT INTO
    cliente (
        nombre,
        apellido,
        email,
        clave,
        fecha_registro,
        fecha_nacimiento
    )
VALUES (
        'maicoll',
        'mendez',
        'maicollmendez@example.com',
        'password1.',
        '2024-09-12',
        '1981-02-23'
    );
--- insercion de direcciones
INSERT INTO
    `e_commerce_db`.`direccion_envio` (ciudad, barrio, calle, tipo)
VALUES (
        'Bucaramanga',
        'Centro',
        'Carrera 19 # 34-45',
        'Apartamento'
    ),
    (
        'Bucaramanga',
        'Cabecera',
        'Calle 36 # 14-23',
        'Casa'
    ),
    (
        'Bucaramanga',
        'Cañaveral',
        'Avenida Las Vegas # 26-40',
        'Oficina'
    ),
    (
        'Bucaramanga',
        'El Prado',
        'Calle 45 # 17-8',
        'Otro'
    ),
    (
        'Floridablanca',
        'La Cumbre',
        'Carrera 32 # 18-22',
        'Apartamento'
    ),
    (
        'Floridablanca',
        'San Javier',
        'Calle 21 # 12-9',
        'Casa'
    ),
    (
        'Bucaramanga',
        'Barrio La Concordia',
        'Carrera 14 # 36-13',
        'Oficina'
    ),
    (
        'Bucaramanga',
        'La Libertad',
        'Calle 48 # 18-7',
        'Otro'
    ),
    (
        'Bucaramanga',
        'Alcalá',
        'Calle 32 # 15-5',
        'Apartamento'
    ),
    (
        'Bucaramanga',
        'La Rosita',
        'Carrera 23 # 30-16',
        'Casa'
    ),
    (
        'Girón',
        'Centro',
        'Calle 19 # 10-12',
        'Oficina'
    ),
    (
        'Girón',
        'El Trapiche',
        'Carrera 14 # 5-20',
        'Otro'
    ),
    (
        'Bucaramanga',
        'Callejón del Agua',
        'Carrera 16 # 10-5',
        'Apartamento'
    ),
    (
        'Floridablanca',
        'Prado',
        'Calle 5 # 4-18',
        'Casa'
    ),
    (
        'Bucaramanga',
        'Bello Horizonte',
        'Carrera 24 # 45-6',
        'Oficina'
    );

select * from direccion_envio;

--- insercion cliente_direccion_envio

INSERT INTO
    `e_commerce_db`.`cliente_direccion_envio` (
        id_cliente_fk,
        id_direccion_envio_fk
    )
VALUES (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 7),
    (8, 8),
    (9, 9),
    (10, 10),
    (11, 11),
    (12, 12),
    (13, 13),
    (14, 14),
    (15, 15),
    (16, 1),
    (17, 2),
    (18, 3),
    (19, 4),
    (20, 5);

--- insercion producto

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
    ),
    (
        'Botas de lluvia',
        'Botas impermeables para días de lluvia',
        120000.00,
        NULL,
        1,
        0.8,
        20000
    ),
    (
        'Sandalias de playa',
        'Sandalias ligeras para la playa',
        60000.00,
        NULL,
        1,
        0.3
        20000
    ),
    (
        'Zapatillas de correr',
        'Zapatillas diseñadas para correr largas distancias',
        180000.00,
        NULL,
        1,
        0.6
        20000
    ),
    (
        'Bermudas deportivas',
        'Bermudas ligeras para actividades deportivas',
        45000.00,
        NULL,
        1,
        0.4
        20000
    ),
    (
        'Camiseta deportiva',
        'Camiseta transpirable para deportes',
        35000.00,
        NULL,
        1,
        0.2
        20000
    ),
    (
        'Pantalones deportivos',
        'Pantalones cómodos para hacer ejercicio',
        75000.00,
        NULL,
        1,
        0.5
        20000
    ),
    (
        'Chaqueta impermeable',
        'Chaqueta ligera y resistente al agua',
        135000.00,
        NULL,
        1,
        0.7
        20000
    ),
    (
        'Gorra deportiva',
        'Gorra para protegerse del sol mientras haces deporte',
        25000.00,
        NULL,
        1,
        0.1
        20000
    ),
    (
        'Socks de running',
        'Socks cómodos para corredores',
        20000.00,
        NULL,
        1,
        0.1
        20000
    ),
    (
        'Camiseta básica',
        'Camiseta cómoda y básica para uso diario',
        40000.00,
        NULL,
        1,
        0.2
        20000
    ),
    (
        'Sudadera con capucha',
        'Sudadera de felpa con capucha',
        115000.00,
        NULL,
        1,
        0.6
        20000
    ),
    (
        'Jeans rasgados',
        'Jeans de mezclilla con detalles rasgados',
        120000.00,
        NULL,
        1,
        0.7
        20000
    ),
    (
        'Pantalones cortos',
        'Pantalones cortos cómodos para el verano',
        50000.00,
        NULL,
        1,
        0.3
        20000
    ),
    (
        'Bufanda de lana',
        'Bufanda suave de lana para el invierno',
        45000.00,
        NULL,
        1,
        0.2
        20000
    ),
    (
        'Botines de invierno',
        'Botines de cuero para el frío',
        200000.00,
        NULL,
        1,
        1.0
        20000
    ),
    (
        'Zapatos formales',
        'Zapatos de vestir para ocasiones formales',
        180000.00,
        NULL,
        1,
        0.6
        20000
    ),
    (
        'Botas de montaña',
        'Botas resistentes para caminatas de montaña',
        220000.00,
        NULL,
        1,
        1.2
        20000
    ),
    (
        'Mocasines de cuero',
        'Mocasines de cuero para uso diario',
        160000.00,
        NULL,
        1,
        0.5
        20000
    ),
    (
        'Tacones de fiesta',
        'Tacones altos para ocasiones especiales',
        250000.00,
        NULL,
        1,
        0.4
        20000
    ),
    (
        'Zapatos de charol',
        'Zapatos de charol elegantes para fiestas',
        210000.00,
        NULL,
        1,
        0.5
        20000
    ),
    (
        'Botas de combate',
        'Botas resistentes de combate para exteriores',
        180000.00,
        NULL,
        1,
        1.5
        20000
    ),
    (
        'Alpargatas',
        'Alpargatas cómodas para el verano',
        70000.00,
        NULL,
        1,
        0.3
        20000
    ),
    (
        'Zapatos de ballet',
        'Zapatos de ballet elegantes para ocasiones formales',
        120000.00,
        NULL,
        1,
        0.2
        20000
    ),
    (
        'Zapatillas de skate',
        'Zapatillas de skate para deportes urbanos',
        150000.00,
        NULL,
        1,
        0.7
        20000
    ),
    (
        'Zapatillas deportivas de lujo',
        'Zapatillas de alta gama para actividades deportivas',
        350000.00,
        NULL,
        1,
        0.6
        20000
    );

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
        'Camisa de manga corta',
        'Camisa ligera de manga corta para climas cálidos',
        70000.00,
        NULL,
        1,
        0.3
        20000
    ),
    (
        'Pantalón chino',
        'Pantalón chino cómodo y moderno para el día a día',
        120000.00,
        NULL,
        1,
        0.6
        20000
    ),
    (
        'Chaqueta de punto',
        'Chaqueta de punto suave para clima templado',
        95000.00,
        NULL,
        1,
        0.5
        20000
    ),
    (
        'Falda corta',
        'Falda corta de algodón para días calurosos',
        85000.00,
        NULL,
        1,
        0.4
        20000
    ),
    (
        'Polo de manga larga',
        'Polo elegante de manga larga para ocasiones casuales',
        80000.00,
        NULL,
        1,
        0.3
        20000
    ),
    (
        'Camiseta de tirantes',
        'Camiseta de tirantes cómoda para el verano',
        30000.00,
        NULL,
        1,
        0.2
        20000
    ),
    (
        'Abrigo de paño',
        'Abrigo de paño grueso para el invierno',
        250000.00,
        NULL,
        1,
        1.0
        20000
    ),
    (
        'Pantalones de vestir',
        'Pantalones de vestir de corte recto para oficina',
        140000.00,
        NULL,
        1,
        0.7
        20000
    ),
    (
        'Camisa a rayas',
        'Camisa de manga larga con rayas finas para estilo formal',
        105000.00,
        NULL,
        1,
        0.4
        20000
    ),
    (
        'Sudadera con logo',
        'Sudadera de algodón con logo estampado',
        120000.00,
        NULL,
        1,
        0.6
        20000
    );

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
        'Laptop gaming',
        'Laptop de alto rendimiento para juegos y diseño gráfico',
        3500000.00,
        NULL,
        1,
        2.5
        20000
    ),
    (
        'Auriculares con cancelación de ruido',
        'Auriculares bluetooth con cancelación de ruido activa',
        450000.00,
        NULL,
        1,
        0.3
        20000
    ),
    (
        'Smartphone de gama media',
        'Teléfono móvil con pantalla de 6.5 pulgadas y cámara dual',
        1000000.00,
        NULL,
        1,
        0.2
        20000
    ),
    (
        'Teclado mecánico RGB',
        'Teclado mecánico con retroiluminación RGB para gaming',
        250000.00,
        NULL,
        1,
        1.0
        20000
    ),
    (
        'Monitor ultrawide 34"',
        'Monitor ultrawide de 34 pulgadas para productividad y entretenimiento',
        1800000.00,
        NULL,
        1,
        7.0
        20000
    ),
    (
        'Cámara deportiva',
        'Cámara de acción resistente al agua y con grabación en 4K',
        700000.00,
        NULL,
        1,
        0.3
        20000
    ),
    (
        'Proyector portátil',
        'Proyector mini portátil con resolución HD para presentaciones',
        550000.00,
        NULL,
        1,
        0.8
        20000
    ),
    (
        'Smart TV 55" 4K',
        'Televisor inteligente de 55 pulgadas con resolución 4K y acceso a streaming',
        2500000.00,
        NULL,
        1,
        10.0
        20000
    ),
    (
        'Estación de carga inalámbrica',
        'Estación de carga inalámbrica para varios dispositivos',
        180000.00,
        NULL,
        1,
        0.5
        20000
    ),
    (
        'Laptop ultradelgada',
        'Laptop ultradelgada con pantalla de 13 pulgadas',
        2200000.00,
        NULL,
        1,
        1.2
        20000
    ),
    (
        'Cámara web HD',
        'Cámara web HD ideal para videollamadas y streaming',
        150000.00,
        NULL,
        1,
        0.1
        20000
    ),
    (
        'Altavoz inteligente',
        'Altavoz inteligente con control por voz y compatibilidad con Alexa',
        350000.00,
        NULL,
        1,
        1.0
        20000
    ),
    (
        'Disco duro externo 2TB',
        'Disco duro externo de 2TB para almacenamiento de archivos grandes',
        450000.00,
        NULL,
        1,
        0.7
        20000
    ),
    (
        'Tablet 8 pulgadas',
        'Tablet compacta de 8 pulgadas con sistema Android',
        600000.00,
        NULL,
        1,
        0.4
        20000
    ),
    (
        'Microfono USB para PC',
        'Micrófono USB para grabación y streaming en alta calidad',
        200000.00,
        NULL,
        1,
        0.2
        20000
    );

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
        'Aspiradora robot',
        'Aspiradora automática que limpia los pisos sin intervención',
        900000.00,
        NULL,
        1,
        2.5
        20000
    ),
    (
        'Ventilador de torre',
        'Ventilador de torre con varias velocidades y control remoto',
        250000.00,
        NULL,
        1,
        1.5
        20000
    ),
    (
        'Cafetera de cápsulas',
        'Cafetera automática para preparar café con cápsulas',
        350000.00,
        NULL,
        1,
        2.0
        20000
    ),
    (
        'Horno eléctrico',
        'Horno eléctrico pequeño para panadería y pasteles',
        500000.00,
        NULL,
        1,
        10.0
        20000
    ),
    (
        'Licuadora de vaso',
        'Licuadora potente para batidos y jugos',
        150000.00,
        NULL,
        1,
        1.2
        20000
    ),
    (
        'Refrigerador de 2 puertas',
        'Refrigerador con capacidad de 300 litros, eficiente y práctico',
        1800000.00,
        NULL,
        1,
        40.0
        20000
    ),
    (
        'Estufa de 4 quemadores',
        'Estufa de cocina con 4 quemadores y horno integrado',
        700000.00,
        NULL,
        1,
        10.0
        20000
    ),
    (
        'Microondas',
        'Microondas con tecnología de descongelación rápida y grill',
        450000.00,
        NULL,
        1,
        8.0
        20000
    ),
    (
        'Plancha a vapor',
        'Plancha de vapor con temperatura ajustable para todo tipo de telas',
        120000.00,
        NULL,
        1,
        1.0
        20000
    ),
    (
        'Secadora de ropa',
        'Secadora de ropa de carga frontal, rápida y eficiente',
        900000.00,
        NULL,
        1,
        15.0
        20000
    ),
    (
        'Cesta organizadora',
        'Cesta para organizar ropa o juguetes, de plástico resistente',
        60000.00,
        NULL,
        1,
        2.0
        20000
    ),
    (
        'Mesa de comedor',
        'Mesa de comedor de madera, para 6 personas',
        1200000.00,
        NULL,
        1,
        20.0
        20000
    ),
    (
        'Silla ergonómica de oficina',
        'Silla ergonómica con respaldo alto y ajuste de altura',
        350000.00,
        NULL,
        1,
        7.0
        20000
    ),
    (
        'Cesta de picnic',
        'Cesta para picnic con aislamiento térmico y compartimentos',
        150000.00,
        NULL,
        1,
        3.0
        20000
    ),
    (
        'Espejo de cuerpo entero',
        'Espejo de cuerpo entero con marco elegante',
        200000.00,
        NULL,
        1,
        7.0
        20000
    );

--- insert carrito

INSERT INTO `e_commerce_db`.`carrito` (`id_carrito`, `id_producto_fk`, `id_cliente_fk`, `cantidad`) VALUES
(2, 5, 2, 1),
(2, 6, 2, 1),
(2, 7, 2, 1),

(3, 5, 3, 1),
(3, 6, 3, 2),
(3, 7, 3, 1),

(4, 5, 4, 1),
(4, 6, 4, 1),
(4, 7, 4, 1),
(4, 20, 4, 2),

(5, 5, 5, 1),
(5, 6, 5, 1),
(5, 7, 5, 2),

(6, 15, 6, 1),
(6, 16, 6, 1),
(6, 17, 6, 2),

(7, 15, 7, 1),
(7, 16, 7, 2),
(7, 17, 7, 1),

(8, 15, 8, 1),
(8, 16, 8, 1),
(8, 17, 8, 1),
(8, 33, 8, 3),

(9, 15, 9, 1),
(9, 16, 9, 1),
(9, 17, 9, 2),

(10, 25, 10, 2),
(10, 26, 10, 1),

(11, 25, 11, 1),
(11, 26, 11, 2),
(11, 40, 11, 1),

(12, 25, 12, 3),
(12, 26, 12, 1),

(13, 30, 13, 1),
(13, 31, 13, 4),

(14, 30, 14, 1),
(14, 31, 14, 3),
(14, 45, 14, 1),

(15, 30, 15, 1),
(15, 31, 15, 2);


--- insercion de inventario

INSERT INTO
    `e_commerce_db`.`inventario` (stock, id_producto_fk)
VALUES (15, 1),
    (42, 2),
    (73, 3),
    (58, 4),
    (10, 5),
    (21, 6),
    (8, 7),
    (62, 8),
    (55, 9),
    (33, 10),
    (3, 11),
    (48, 12),
    (81, 13),
    (24, 14),
    (39, 15),
    (71, 16),
    (5, 17),
    (14, 18),
    (29, 19),
    (46, 20),
    (85, 21),
    (66, 22),
    (11, 23),
    (4, 24),
    (63, 25),
    (78, 26),
    (9, 27),
    (6, 28),
    (31, 29),
    (6, 30),
    (19, 31),
    (72, 32),
    (80, 33),
    (37, 34),
    (76, 35),
    (64, 36),
    (83, 37),
    (30, 38),
    (54, 39),
    (47, 40),
    (56, 41),
    (89, 42),
    (25, 43),
    (60, 44),
    (40, 45),
    (22, 46),
    (51, 47),
    (16, 48),
    (34, 49),
    (68, 50),
    (59, 51),
    (49, 52),
    (53, 53),
    (32, 54),
    (79, 55),
    (23, 56),
    (77, 57),
    (1, 58),
    (18, 59),
    (38, 60),
    (28, 61),
    (70, 62),
    (41, 63),
    (44, 64),
    (65, 65),
    (74, 66);

--- insercion de moneda

INSERT INTO
    `e_commerce_db`.`moneda` (`nombre`, `valor`)
VALUES (
        'Dólar estadounidense',
        3880.30
    ),
    ('Euro', 4516.51),
    ('Peso mexicano', 211.89),
    ('Libra esterlina', 5172.05);

--- insercion de pais

INSERT INTO
    `e_commerce_db`.`pais` (`indicativo`, `nombre`)
VALUES ('57', 'Colombia'),
    ('34', 'España'),
    ('1', 'Estados Unidos'),
    ('44', 'Reino Unido'),
    ('52', 'México'),
    ('54', 'Argentina'),
    ('56', 'Chile'),
    ('55', 'Brasil'),
    ('49', 'Alemania'),
    (
        '971',
        'Emiratos Árabes Unidos'
    );

--- insercion producto_categoria

INSERT INTO
    producto_categoria (
        id_producto_fk,
        id_categoria_fk
    )
VALUES (1, 1),
    (2, 1),
    (3, 1),
    (4, 1),
    (5, 2),
    (6, 2),
    (7, 2),
    (8, 2),
    (9, 2),
    (10, 1),
    (11, 2),
    (12, 2),
    (13, 2),
    (14, 2),
    (15, 2),
    (16, 1),
    (17, 1),
    (18, 1),
    (19, 1),
    (20, 1),
    (21, 1),
    (22, 1),
    (23, 1),
    (24, 1),
    (25, 1),
    (26, 1);

INSERT INTO
    producto_categoria (
        id_producto_fk,
        id_categoria_fk
    )
VALUES (27, 2),
    (28, 2),
    (29, 2),
    (30, 2),
    (31, 2),
    (32, 2),
    (33, 2),
    (34, 2),
    (35, 2),
    (36, 2);

INSERT INTO
    producto_categoria (
        id_producto_fk,
        id_categoria_fk
    )
VALUES (37, 3),
    (38, 3),
    (39, 3),
    (40, 3),
    (41, 3),
    (42, 3),
    (43, 3),
    (44, 3),
    (45, 3),
    (46, 3),
    (47, 3),
    (48, 3),
    (49, 3),
    (50, 3),
    (51, 3);

INSERT INTO
    producto_categoria (
        id_producto_fk,
        id_categoria_fk
    )
VALUES (52, 4),
    (53, 4),
    (54, 4),
    (55, 4),
    (56, 4),
    (57, 4),
    (58, 4),
    (59, 4),
    (60, 4),
    (61, 4),
    (62, 4),
    (63, 4),
    (64, 4),
    (65, 4),
    (66, 4);


--- insercion de tienda

INSERT INTO `e_commerce_db`.`tienda` (`nit`, `nombre`)
VALUES
('900123456-7', 'Tienda El Parchadito');

--- insercion tarifa_envio

INSERT INTO `e_commerce_db`.`tarifa_envio` (`tipo`, `valor`)
VALUES
('liviano', 10000.00),
('mediano', 15000.00),
('pesado', 25000.00);

--- insert descuento

INSERT INTO descuento (id_descuento, tipo, valor, nombre)
VALUES
(1, 'puntos', 0.10, 'porcentaje'),
(2, 'cumpleanos', 0.10, 'porcentaje'),
(3, 'categoria', 0.10, 'porcentaje'),
(4, 'producto', 0.10, 'porcentaje');

--- insert venta

INSERT INTO `e_commerce_db`.`venta` (`fecha_venta`, `estado`, `total`, `id_cliente_fk`, `id_tienda_fk`, `id_descuento_fk`, `id_tarifa_envio_fk`)
VALUES
(NOW(), 'Pendiente', 0.00, 1, 1, 1, 2),
(NOW(), 'Entregado', 85000.00, 2, 1, 1, 1),
(NOW(), 'Entregado', 90000.00, 3, 1, 1, 1),
(NOW(), 'Enviado', 95000.00, 4, 1, 1, 1),
(NOW(), 'Entregado', 88000.00, 5, 1, 1, 1),
(NOW(), 'Entregado', 65000.00, 6, 1, 1, 1),
(NOW(), 'Entregado', 70000.00, 7, 1, 1, 1),
(NOW(), 'Procesando', 68000.00, 8, 1, 1, 1),
(NOW(), 'Entregado', 72000.00, 9, 1, 1, 1),
(NOW(), 'Entregado', 45000.00, 10, 1, 1, 1),
(NOW(), 'Entregado', 50000.00, 11, 1, 1, 1),
(NOW(), 'Enviado', 48000.00, 12, 1, 1, 1),
(NOW(), 'Entregado', 35000.00, 13, 1, 1, 1),
(NOW(), 'Procesando', 40000.00, 14, 1, 1, 1),
(NOW(), 'Pendiente', 38000.00, 15, 1, 1, 1);

ALTER TABLE venta AUTO_INCREMENT = 1;

--- insert producto_venta

INSERT INTO `e_commerce_db`.`producto_venta` (`id_producto_fk`, `id_venta_fk`, `cantidad`, `precio_unitario`, `id_moneda_fk`)
VALUES
(1, 1, 2, 10000.00, 1),
(2, 1, 3, 15000.00, 1),

(5, 2, 1, 50000.00, 1),
(6, 2, 1, 20000.00, 1),
(7, 2, 1, 15000.00, 1),

(5, 3, 1, 50000.00, 1),
(6, 3, 2, 20000.00, 1),
(7, 3, 1, 15000.00, 1),

(5, 4, 1, 50000.00, 1),
(6, 4, 1, 20000.00, 1),
(7, 4, 1, 15000.00, 1),
(20, 4, 2, 5000.00, 1),

(5, 5, 1, 50000.00, 1),
(6, 5, 1, 20000.00, 1),
(7, 5, 2, 9000.00, 1),

(15, 6, 1, 30000.00, 1),
(16, 6, 1, 18000.00, 1),

(15, 7, 1, 30000.00, 1),
(16, 7, 2, 18000.00, 1),

(15, 8, 1, 30000.00, 1),
(16, 8, 1, 18000.00, 1),
(33, 8, 3, 3833.33, 1),

(15, 9, 1, 30000.00, 1),
(16, 9, 1, 18000.00, 1),
(17, 9, 2, 12000.00, 1),

(25, 10, 2, 15000.00, 1),
(26, 10, 1, 15000.00, 1),

(25, 11, 1, 15000.00, 1),
(26, 11, 2, 15000.00, 1),
(40, 11, 1, 5000.00, 1),

(25, 12, 3, 12000.00, 1),
(26, 12, 1, 12000.00, 1),

(30, 13, 1, 25000.00, 1),
(31, 13, 4, 2500.00, 1),

(30, 14, 1, 25000.00, 1),
(31, 14, 3, 3000.00, 1),
(45, 14, 1, 5000.00, 1),

(30, 15, 1, 25000.00, 1),
(31, 15, 2, 6500.00, 1);

--- insert proveedor

INSERT INTO `e_commerce_db`.`proveedor` (`nombre`, `email_contacto`)
VALUES
('Proveedor Calzado', 'contacto@proveedorcalzado.com'),
('Proveedor Hogar', 'contacto@proveedordhogar.com'),
('Proveedor Ropa', 'contacto@proveedorropa.com'),
('Proveedor Electronicos', 'contacto@proveedorelectronicos.com');

--- proveedor_tienda_producto

INSERT INTO `e_commerce_db`.`proveedor_tienda_producto` (`condiciones`, `id_tienda_fk`, `id_proveedor_fk`, `id_producto_fk`)
VALUES
('Condición A', 1, 1, 1),
('Condición B', 1, 1, 2),
('Condición C', 1, 1, 3),
('Condición A', 1, 1, 4),
('Condición B', 1, 1, 5),
('Condición C', 1, 1, 6),
('Condición A', 1, 1, 7),
('Condición B', 1, 1, 8),
('Condición C', 1, 1, 9),
('Condición A', 1, 1, 10),
('Condición B', 1, 1, 11),
('Condición C', 1, 1, 12),


('Condición A', 1, 2, 13),
('Condición B', 1, 2, 14),
('Condición C', 1, 2, 15),
('Condición A', 1, 2, 16),
('Condición B', 1, 2, 17),
('Condición C', 1, 2, 18),
('Condición A', 1, 2, 19),
('Condición B', 1, 2, 20),
('Condición C', 1, 2, 21),
('Condición A', 1, 2, 22),
('Condición B', 1, 2, 23),
('Condición C', 1, 2, 24),


('Condición A', 1, 3, 25),
('Condición B', 1, 3, 26),
('Condición C', 1, 3, 27),
('Condición A', 1, 3, 28),
('Condición B', 1, 3, 29),
('Condición C', 1, 3, 30),
('Condición A', 1, 3, 31),
('Condición B', 1, 3, 32),
('Condición C', 1, 3, 33),
('Condición A', 1, 3, 34),
('Condición B', 1, 3, 35),
('Condición C', 1, 3, 36),


('Condición A', 1, 4, 37),
('Condición B', 1, 4, 38),
('Condición C', 1, 4, 39),
('Condición A', 1, 4, 40),
('Condición B', 1, 4, 41),
('Condición C', 1, 4, 42),
('Condición A', 1, 4, 43),
('Condición B', 1, 4, 44),
('Condición C', 1, 4, 45),
('Condición A', 1, 4, 46),
('Condición B', 1, 4, 47),
('Condición C', 1, 4, 48);



--- insert telefono

INSERT INTO `e_commerce_db`.`telefono` (`id_pais_fk`, `telefono`, `id_cliente_fk`)
VALUES
(1, '3001234567', 1),
(1, '3001234568', 2),
(1, '3001234569', 3),
(1, '3001234570', 4),
(1, '3001234571', 5),
(1, '3001234572', 6),
(1, '3001234573', 7),
(1, '3001234574', 8),
(1, '3001234575', 9),
(1, '3001234576', 10),
(1, '3001234577', 11),
(1, '3001234578', 12),
(1, '3001234579', 13),
(1, '3001234580', 14),
(1, '3001234581', 15),
(1, '3001234582', 16),
(1, '3001234583', 17),
(1, '3001234584', 18),
(1, '3001234585', 19),
(1, '3001234586', 20);

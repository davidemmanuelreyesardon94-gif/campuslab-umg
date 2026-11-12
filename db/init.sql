CREATE DATABASE IF NOT EXISTS campuslab CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campuslab;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    rol VARCHAR(30) DEFAULT 'ADMIN',
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE solicitante (
    id_solicitante INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre_completo VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo'
);

CREATE TABLE equipo (
    id_equipo INT AUTO_INCREMENT PRIMARY KEY,
    codigo_inventario VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NOT NULL,
    tipo ENUM('computadora', 'proyector', 'otro') NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    ram_gb INT NULL,
    ubicacion VARCHAR(100) NOT NULL,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo'
);

CREATE TABLE mantenimiento (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    motivo VARCHAR(200) NOT NULL,
    observaciones TEXT,
    estado ENUM('programado', 'finalizado', 'anulado') DEFAULT 'programado',
    FOREIGN KEY (id_equipo) REFERENCES equipo(id_equipo)
);

CREATE TABLE reserva (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitante INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    tipo_equipo ENUM('computadora', 'proyector', 'otro') NOT NULL,
    cantidad INT NOT NULL,
    ram_minima INT NULL,
    motivo_uso VARCHAR(200) NOT NULL,
    estrategia ENUM('menor_uso', 'ajuste_capacidad') DEFAULT 'menor_uso',
    estado ENUM('pendiente', 'confirmada', 'cancelada', 'finalizada') DEFAULT 'pendiente',
    FOREIGN KEY (id_solicitante) REFERENCES solicitante(id_solicitante)
);

CREATE TABLE reserva_equipo (
    id_reserva_equipo INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_equipo INT NOT NULL,
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
    FOREIGN KEY (id_equipo) REFERENCES equipo(id_equipo)
);

CREATE TABLE prestamo (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    fecha_entrega DATETIME NOT NULL,
    recibido_por VARCHAR(100) NOT NULL,
    fecha_devolucion_prevista DATETIME NOT NULL,
    observaciones TEXT,
    estado ENUM('abierto', 'devuelto', 'anulado') DEFAULT 'abierto',
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
);

CREATE TABLE prestamo_equipo (
    id_prestamo_equipo INT AUTO_INCREMENT PRIMARY KEY,
    id_prestamo INT NOT NULL,
    id_equipo INT NOT NULL,
    fecha_devolucion_real DATETIME NULL,
    condicion_devolucion VARCHAR(150) NULL,
    FOREIGN KEY (id_prestamo) REFERENCES prestamo(id_prestamo),
    FOREIGN KEY (id_equipo) REFERENCES equipo(id_equipo)
);

CREATE TABLE incidencia (
    id_incidencia INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo INT NOT NULL,
    id_prestamo INT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT NOT NULL,
    prioridad ENUM('baja', 'media', 'alta') DEFAULT 'media',
    responsable VARCHAR(100) NOT NULL,
    estado ENUM('abierta', 'en_atencion', 'resuelta', 'anulada') DEFAULT 'abierta',
    solucion TEXT NULL,
    fecha_resolucion DATETIME NULL,
    id_mantenimiento INT NULL,
    FOREIGN KEY (id_equipo) REFERENCES equipo(id_equipo),
    FOREIGN KEY (id_prestamo) REFERENCES prestamo(id_prestamo),
    FOREIGN KEY (id_mantenimiento) REFERENCES mantenimiento(id_mantenimiento)
);

CREATE TABLE configuracion_reporte (
    id_config INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_reporte ENUM('inventario', 'reservas', 'uso_equipos', 'mantenimientos', 'prestamos', 'incidencias') NOT NULL,
    filtros_json VARCHAR(255) NULL
);

INSERT INTO usuario (username, password_hash, nombre_completo, rol) VALUES 
('admin', 'admin123', 'Administrador Laboratorio UMG', 'ADMIN');

INSERT INTO solicitante (codigo, nombre_completo, correo, departamento, estado) VALUES
('DOC-001', 'Ing. David Reyes', 'dreyes@miumg.edu.gt', 'Ingeniería en Sistemas', 'activo'),
('DOC-002', 'Licda. Lucrecia Morales', 'lmorales@miumg.edu.gt', 'Ciencias de la Administración', 'activo'),
('DOC-003', 'Ing. Francisco Hernandez', 'fhernandez@miumg.edu.gt', 'Arquitectura', 'activo'),
('DOC-004', 'MSc. Patricia Castillo', 'pcastillo@miumg.edu.gt', 'Ingeniería Industrial', 'inactivo');

INSERT INTO equipo (codigo_inventario, descripcion, tipo, marca, modelo, ram_gb, ubicacion, estado) VALUES
('PC-LAB1-01', 'Laptop Desarrollo i7', 'computadora', 'Dell', 'Latitude 5420', 16, 'Estante A1', 'activo'),
('PC-LAB1-02', 'Laptop Desarrollo i7', 'computadora', 'Dell', 'Latitude 5420', 16, 'Estante A1', 'activo'),
('PC-LAB1-03', 'Laptop Diseño 32GB', 'computadora', 'Lenovo', 'ThinkPad P15', 32, 'Estante A2', 'activo'),
('PC-LAB1-04', 'Laptop Ofimática i5', 'computadora', 'HP', 'ProBook 450', 8, 'Estante B1', 'activo'),
('PC-LAB1-05', 'Laptop Ofimática i5', 'computadora', 'HP', 'ProBook 450', 8, 'Estante B1', 'activo'),
('PRJ-LAB1-01', 'Proyector Full HD Aula', 'proyector', 'Epson', 'PowerLite X49', NULL, 'Gabinete Multimedia', 'activo'),
('PRJ-LAB1-02', 'Proyector Portátil', 'proyector', 'BenQ', 'MS550', NULL, 'Gabinete Multimedia', 'activo');

INSERT INTO mantenimiento (id_equipo, fecha_inicio, fecha_fin, motivo, observaciones, estado) VALUES
(5, '2026-11-12 08:00:00', '2026-11-12 14:00:00', 'Cambio de pasta térmica y limpieza', 'Preventivo semestral', 'programado');

INSERT INTO reserva (id_solicitante, fecha_inicio, fecha_fin, tipo_equipo, cantidad, ram_minima, motivo_uso, estrategia, estado) VALUES
(1, '2026-11-13 19:00:00', '2026-11-13 21:30:00', 'computadora', 2, 16, 'Clase Programación 2', 'ajuste_capacidad', 'confirmada');

INSERT INTO reserva_equipo (id_reserva, id_equipo) VALUES (1, 1), (1, 2);

INSERT INTO incidencia (id_equipo, descripcion, prioridad, responsable, estado) VALUES
(4, 'Tecla Enter trabada y batería dura poco', 'media', 'Soporte Técnico Lab', 'abierta');

INSERT INTO configuracion_reporte (nombre, tipo_reporte, filtros_json) VALUES
('Inventario General Activo', 'inventario', 'estado=activo'),
('Reservas Confirmadas', 'reservas', 'estado=confirmada'),
('Equipos en Mantenimiento', 'mantenimientos', 'estado=programado');

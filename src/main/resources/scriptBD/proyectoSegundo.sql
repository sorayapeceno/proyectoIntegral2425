-- -----------------------------------------------------
-- SCHEMA guzpasen
-- ----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS guzpasen;

CREATE DATABASE IF NOT EXISTS guzpasen;
USE guzpasen;
ALTER DATABASE guzpasen CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SET default_storage_engine = InnoDB;

CREATE USER IF NOT EXISTS 'alumno'@'localhost' IDENTIFIED BY 'alumnodam#1234';
GRANT ALL PRIVILEGES ON *.* TO 'alumno'@'localhost';
FLUSH PRIVILEGES;

CREATE USER IF NOT EXISTS 'roberto'@'localhost' IDENTIFIED BY 'dam1';
GRANT ALL PRIVILEGES ON *.* TO 'roberto'@'localhost';
FLUSH PRIVILEGES;

-- Tabla Usuario
CREATE TABLE usuario (
    id_usuario BIGINT AUTO_INCREMENT PRIMARY KEY,
    nick VARCHAR(30) NOT NULL,
    nombre VARCHAR(30),
    apellidos VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL,
    clave VARCHAR(200) NOT NULL,
    rol ENUM('ADMIN', 'PROFESOR', 'GESTOR_INCIDENCIAS'),
    usuario_movil BOOLEAN
);

-- Tabla Alumno
CREATE TABLE alumno (
    dni VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(50),
    apellidos VARCHAR(100),
    nombre_tutor_legal VARCHAR(30),
    apellidos_tutor_legal VARCHAR(50),
    email_tutor_legal VARCHAR(50)
);

-- Crear tabla zona
CREATE TABLE zona (
    id_zona BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    tipo ENUM('AULA', 'PASILLO', 'ASEO', 'PATIO', 'GIMNASIO', 'DEPARTAMENTO', 'BIBLIOTECA', 'OTROS') NOT NULL,
    planta ENUM('P0', 'P1', 'P2') NOT NULL
);

-- Crear tabla item
CREATE TABLE item (
    id_item BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    tipo ENUM('DISPOSITIVO', 'MOBILIARIO', 'OTROS') NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    estado ENUM('ASIGNADO', 'MANTENIMIENTO', 'RESERVABLE', 'RETIRADO') NOT NULL,
    fecha_compra DATE,
    origen VARCHAR(50),
    zona_id BIGINT NOT NULL,
    CONSTRAINT fk_item_zona FOREIGN KEY (zona_id) REFERENCES zona(id_zona)
);

-- -----------------------------------------------------
-- Tabla reserva
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS reserva (
   id BIGINT AUTO_INCREMENT PRIMARY KEY,
   fecha DATE NOT NULL,
   estado ENUM('ACTIVA', 'CANCELADA', 'COMPLETADA') NOT NULL DEFAULT 'ACTIVA',
   observaciones VARCHAR(500),
   id_zona BIGINT NOT NULL,
   id_usuario BIGINT NOT NULL,
   FOREIGN KEY (id_zona) REFERENCES zona(id_zona),
   FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);
CREATE TABLE IF NOT EXISTS reserva_horario (
   reserva_id BIGINT NOT NULL,
   horario ENUM('H1', 'H2', 'H3', 'H4', 'H5', 'H6') NOT NULL,
   PRIMARY KEY (reserva_id, horario),
   FOREIGN KEY (reserva_id) REFERENCES reserva(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- TABLA GUARDIA - JUAN CARLOS
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS guardia (
	id_guardia BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora_inicio ENUM ('PRIMERA','SEGUNDA','TERCERA','CUARTA','QUINTA','SEXTA') NOT NULL,
    hora_fin ENUM ('PRIMERA','SEGUNDA','TERCERA','CUARTA','QUINTA','SEXTA') NOT NULL,
    id_profesor BIGINT NOT NULL,
    id_aula BIGINT NOT NULL,
	CONSTRAINT fk_guardia_usuario FOREIGN KEY (id_profesor) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_guardia_zona FOREIGN KEY (id_aula) REFERENCES zona(id_zona)
);

-- -----------------------------------------------------
-- TABLA AUSENCIA - JUAN CARLOS
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ausencia (
	id_ausencia BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora_inicio ENUM ('PRIMERA','SEGUNDA','TERCERA','CUARTA','QUINTA','SEXTA') NOT NULL,
    hora_fin ENUM ('PRIMERA','SEGUNDA','TERCERA','CUARTA','QUINTA','SEXTA') NOT NULL,
    motivo VARCHAR (255) NOT NULL,
    estado ENUM ('PENDIENTE DE GUARDIA', 'GUARDIA ASIGNADA') NOT NULL,
    tarea_alumnado VARCHAR (255),
    id_guardia BIGINT NOT NULL,
    id_profesor BIGINT NOT NULL,
    id_zona BIGINT NOT NULL,
    CONSTRAINT fk_ausencia_guardia FOREIGN KEY (id_guardia) REFERENCES guardia(id_guardia),
    CONSTRAINT fk_ausencia_usuario FOREIGN KEY (id_profesor) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_ausencia_zona FOREIGN KEY (id_zona) REFERENCES zona(id_zona)
);



-- Inserts de prueba
INSERT INTO zona (nombre, tipo, planta) VALUES 
('Aula 2B', 'AULA', 'P1'),
('Biblioteca', 'BIBLIOTECA', 'P0'),
('Departamento de Música', 'DEPARTAMENTO', 'P2'),
('Pasillo Norte', 'PASILLO', 'P1'),
('Gimnasio Principal', 'GIMNASIO', 'P0');

INSERT INTO item (nombre, tipo, descripcion, estado, fecha_compra, origen, zona_id) VALUES 
('Proyector Epson X1', 'DISPOSITIVO', 'Proyector FHD', 'RESERVABLE', '2022-09-10', 'Compra centralizada', 1),
('Silla ergonómica', 'MOBILIARIO', 'Silla con respaldo ajustable', 'ASIGNADO', '2021-05-22', 'Donación', 1),
('Portátil HP EliteBook', 'DISPOSITIVO', 'Portátil con Windows 11', 'ASIGNADO', '2023-01-15', 'Programa TIC Andalucía', 3),
('Altavoz Bluetooth JBL', 'DISPOSITIVO', 'Altavoz portátil', 'RESERVABLE', '2022-03-12', 'Adquisición local', 5),
('Banco de ejercicios', 'MOBILIARIO', 'Banco acolchado', 'MANTENIMIENTO', '2021-11-30', 'Reutilización interna', 5);


CREATE TABLE incidencia (
    incidencia_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(255),
    fecha DATE,
   hora ENUM('PRIMERA', 'SEGUNDA', 'TERCERA', 'CUARTA', 'QUINTA', 'SEXTA', 'RECREO', 'OTROS'),
    id_item BIGINT,
    id_usuario BIGINT,
	CONSTRAINT fk_incidencia_item FOREIGN KEY (id_item) REFERENCES item(id_item),
    CONSTRAINT fk_incidencia_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE historico (
    id_historico BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
     hora ENUM('PRIMERA', 'SEGUNDA', 'TERCERA', 'CUARTA', 'QUINTA', 'SEXTA', 'RECREO', 'OTROS'),
    tipo ENUM( 'ALTAINCIDENCIA', 'BAJAINCIDENCIA', 'MODIFICACIONINCIDENCIA'),
    usuario_id BIGINT,
    CONSTRAINT fk_historico_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id_usuario)
);


-- Tabla Alumno
CREATE TABLE IF NOT EXISTS alumno (
    dni VARCHAR(255) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellidos VARCHAR(255) NOT NULL,
    nombre_tutor_legal VARCHAR(255),
    apellidos_tutor_legal VARCHAR(255),
    email_tutor_legal VARCHAR(255)
);

-- Tabla Parte
CREATE TABLE IF NOT EXISTS parte (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    motivo VARCHAR(255) NOT NULL,
    fecha DATE,
    hora TIME,
    descripcion TEXT,
    lugar VARCHAR(255)
);

-- Tabla Sancion
CREATE TABLE IF NOT EXISTS sancion (
    id BIGINT PRIMARY KEY,
    fecha DATE,
    tipo_sancion ENUM('CON_EXPULSION_DENTRO', 'CON_EXPULSION_FUERA', 'SIN_EXPULSION'),
    duracion VARCHAR(255),
    alumno VARCHAR(255),
    CONSTRAINT fk_sancion_alumno FOREIGN KEY (alumno) REFERENCES alumno(dni)
);

-- Tabla Acta
CREATE TABLE acta (
    id_acta BIGINT PRIMARY KEY AUTO_INCREMENT,
    puntos_tratados VARCHAR(100),
    observaciones VARCHAR(50),
    fecha DATE
);
-- Tabla Tutoria
CREATE TABLE tutoria (
    id_tutoria BIGINT PRIMARY KEY AUTO_INCREMENT,
    motivo VARCHAR(100),
    urgencia VARCHAR(20),
    asignatura VARCHAR(50),
    fecha DATE,
    estado ENUM('PENDIENTE', 'REALIZADA'),
    observaciones VARCHAR(100),
    id_usuario BIGINT,
    dni_alumno VARCHAR(20),
    id_acta BIGINT,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (dni_alumno) REFERENCES alumno(dni),
    FOREIGN KEY (id_acta) REFERENCES acta(id_acta)
);

-- Tabla Tarea
CREATE TABLE IF NOT EXISTS tarea (
    id_tarea BIGINT PRIMARY KEY AUTO_INCREMENT,
    asignatura VARCHAR(50),
    descripcion VARCHAR(100),
    titulo VARCHAR(255) NOT NULL,
    estado ENUM('COMPLETADA', 'EN_PROGRESO', 'PENDIENTE'),
    fecha_tarea DATE,
    fecha_creacion DATE,
    fecha_limite DATE,
    sancion BIGINT,
    id_tutoria BIGINT, 
    CONSTRAINT fk_tarea_sancion FOREIGN KEY (sancion) REFERENCES sancion(id),    
    FOREIGN KEY (id_tutoria) REFERENCES tutoria(id_tutoria)
);









/* BASE DE DATOS: gestion_academica_universidad
   AUTOR: Analista de Datos - Institución Académica
   FECHA: 2026
*/

-- ==========================================
-- TASK 1: DISEÑO Y CREACIÓN (DDL)
-- ==========================================

DROP DATABASE IF EXISTS gestion_academica_universidad;
CREATE DATABASE gestion_academica_universidad;
USE gestion_academica_universidad;

-- Tabla: Estudiantes
CREATE TABLE estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) UNIQUE NOT NULL,
    genero CHAR(1) CHECK (genero IN ('M', 'F', 'O')),
    identificacion VARCHAR(20) UNIQUE NOT NULL,
    carrera VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    fecha_ingreso DATE DEFAULT (CURRENT_DATE)
);

-- Tabla: Docentes
CREATE TABLE docentes (
    id_docente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    correo_institucional VARCHAR(100) UNIQUE NOT NULL,
    departamento_academico VARCHAR(50),
    anios_experiencia INT CHECK (anios_experiencia >= 0)
);

-- Tabla: Cursos
-- Se aplica ON DELETE SET NULL para no borrar el curso si el docente se retira.
CREATE TABLE cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    creditos INT CHECK (creditos > 0),
    semestre INT CHECK (semestre BETWEEN 1 AND 12),
    id_docente INT,
    FOREIGN KEY (id_docente) REFERENCES docentes(id_docente) ON DELETE SET NULL
);

-- Tabla: Inscripciones
CREATE TABLE inscripciones (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_curso INT NOT NULL,
    fecha_inscripcion DATE DEFAULT (CURRENT_DATE),
    calificacion_final DECIMAL(4,2) CHECK (calificacion_final BETWEEN 0 AND 10),
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso) ON DELETE CASCADE
);

-- ==========================================
-- TASK 2: INSERCIÓN DE DATOS (DML)
-- ==========================================

-- 3 Docentes
INSERT INTO docentes (nombre_completo, correo_institucional, departamento_academico, anios_experiencia) VALUES
('Dr. Julian Sanchez', 'jsanchez@uni.edu', 'Matemáticas', 10),
('Dra. Elena Rivas', 'erivas@uni.edu', 'Sistemas', 4),
('Ing. Roberto Gomez', 'rgomez@uni.edu', 'Física', 7);

-- 5 Estudiantes
INSERT INTO estudiantes (nombre_completo, correo_electronico, genero, identificacion, carrera, fecha_nacimiento) VALUES
('Ana Lopez', 'ana.l@mail.com', 'F', '102030', 'Ingeniería', '2002-05-15'),
('Luis Perez', 'luis.p@mail.com', 'M', '405060', 'Ingeniería', '2001-11-20'),
('Carla Ruiz', 'carla.r@mail.com', 'F', '708090', 'Matemáticas', '2003-01-10'),
('Diego Sosa', 'diego.s@mail.com', 'M', '112233', 'Física', '2000-08-25'),
('Marta Diaz', 'marta.d@mail.com', 'F', '445566', 'Sistemas', '2002-03-12');

-- 4 Cursos
INSERT INTO cursos (nombre, codigo, creditos, semestre, id_docente) VALUES
('Cálculo I', 'MAT101', 4, 1, 1),
('Programación I', 'SIS101', 3, 2, 2),
('Física Mecánica', 'FIS101', 4, 2, 3),
('Bases de Datos', 'SIS202', 3, 4, 2);

-- 8 Inscripciones
INSERT INTO inscripciones (id_estudiante, id_curso, calificacion_final) VALUES
(1, 1, 8.5), (1, 2, 9.0), (2, 1, 7.0), (3, 1, 9.5),
(4, 3, 6.5), (5, 2, 8.0), (5, 4, 10.0), (1, 3, 7.5);

-- ==========================================
-- TASK 3: CONSULTAS Y MANIPULACIÓN (DQL/DDL)
-- ==========================================

-- Listar estudiantes, inscripciones y cursos
SELECT e.nombre_completo, c.nombre AS curso, i.fecha_inscripcion 
FROM estudiantes e 
JOIN inscripciones i ON e.id_estudiante = i.id_estudiante 
JOIN cursos c ON i.id_curso = c.id_curso;

-- Cursos con docentes > 5 años de experiencia
SELECT c.nombre, d.nombre_completo, d.anios_experiencia 
FROM cursos c 
JOIN docentes d ON c.id_docente = d.id_docente 
WHERE d.anios_experiencia > 5;

-- Promedio de calificaciones por curso
SELECT c.nombre, AVG(i.calificacion_final) AS promedio_curso 
FROM cursos c 
JOIN inscripciones i ON c.id_curso = i.id_curso 
GROUP BY c.nombre;

-- Estudiantes inscritos en más de un curso
SELECT e.nombre_completo, COUNT(*) AS total_cursos 
FROM estudiantes e 
JOIN inscripciones i ON e.id_estudiante = i.id_estudiante 
GROUP BY e.id_estudiante 
HAVING COUNT(*) > 1;

-- Agregar columna estado_academico
ALTER TABLE estudiantes ADD COLUMN estado_academico VARCHAR(20) DEFAULT 'Activo';

-- Eliminar un docente (Efecto ON DELETE SET NULL en cursos)
DELETE FROM docentes WHERE id_docente = 1;

-- Cursos con más de 2 estudiantes inscritos
SELECT c.nombre, COUNT(i.id_estudiante) AS total_alumnos 
FROM cursos c 
JOIN inscripciones i ON c.id_curso = i.id_curso 
GROUP BY c.id_curso 
HAVING COUNT(i.id_estudiante) > 2;

-- ==========================================
-- TASK 4: SUB-CONSULTAS Y FUNCIONES
-- ==========================================

-- Estudiantes con calificación promedio > promedio general
SELECT nombre_completo 
FROM estudiantes 
WHERE id_estudiante IN (
    SELECT id_estudiante 
    FROM inscripciones 
    GROUP BY id_estudiante 
    HAVING AVG(calificacion_final) > (SELECT AVG(calificacion_final) FROM inscripciones)
);

-- Carreras con estudiantes en cursos de semestre >= 2
SELECT DISTINCT carrera 
FROM estudiantes e 
WHERE EXISTS (
    SELECT 1 FROM inscripciones i 
    JOIN cursos c ON i.id_curso = c.id_curso 
    WHERE i.id_estudiante = e.id_estudiante AND c.semestre >= 2
);

-- Indicadores estadísticos
SELECT 
    ROUND(SUM(calificacion_final), 1) as suma_total_notas,
    MAX(calificacion_final) as nota_mas_alta,
    MIN(calificacion_final) as nota_mas_baja,
    COUNT(*) as total_inscripciones
FROM inscripciones;

-- ==========================================
-- TASK 5: CREACIÓN DE VISTA
-- ==========================================

CREATE OR REPLACE VIEW vista_historial_academico AS
SELECT 
    e.nombre_completo AS estudiante,
    c.nombre AS curso,
    d.nombre_completo AS docente,
    c.semestre,
    i.calificacion_final
FROM inscripciones i
JOIN estudiantes e ON i.id_estudiante = e.id_estudiante
JOIN cursos c ON i.id_curso = c.id_curso
LEFT JOIN docentes d ON c.id_docente = d.id_docente;

-- ==========================================
-- TASK 6: CONTROL DE ACCESO Y TRANSACCIONES
-- ==========================================

-- Permisos (Ejecutar solo si tienes privilegios de Superusuario/Root)
-- CREATE ROLE IF NOT EXISTS 'revisor_academico'; -- Nota: Algunos DBs requieren sintaxis específica
-- GRANT SELECT ON vista_historial_academico TO 'revisor_academico';
-- REVOKE UPDATE, INSERT, DELETE ON inscripciones FROM 'revisor_academico';

-- Transacción: Simulación de actualización de nota
START TRANSACTION;

SAVEPOINT inicio_proceso;

-- Intento de actualización
UPDATE inscripciones 
SET calificacion_final = 9.5 
WHERE id_estudiante = 1 AND id_curso = 2;

-- Si verificamos que el ID es incorrecto o hubo error, haríamos:
-- ROLLBACK TO SAVEPOINT inicio_proceso;

-- Si todo está correcto, confirmamos:
COMMIT;

-- Consultar resultado final
SELECT * FROM vista_historial_academico;
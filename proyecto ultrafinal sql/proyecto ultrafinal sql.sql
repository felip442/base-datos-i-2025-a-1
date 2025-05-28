-- =============================================
-- 0. ELIMINAR Y CREAR BASE DE DATOS
-- =============================================
DROP DATABASE IF EXISTS gestion_academica;
CREATE DATABASE gestion_academica;
USE gestion_academica;

-- Desactivar el modo de actualización segura para permitir ciertas operaciones (opcional, pero útil en desarrollo)
SET SQL_SAFE_UPDATES = 0;

-- =============================================
-- 1. ESTRUCTURA DE TABLAS (DDL) - Creación de todas las tablas con restricciones
-- =============================================

-- Tabla Persona: Información general de cualquier individuo en el sistema
CREATE TABLE persona (
    id_persona INT AUTO_INCREMENT PRIMARY KEY,
    cedula VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE,
    genero ENUM('M', 'F', 'O'),
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100) UNIQUE NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Rol: Define los roles de usuario en el sistema
CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Periodo_Academico: Define los periodos o semestres académicos
CREATE TABLE periodo_academico (
    id_periodo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_periodo VARCHAR(100) UNIQUE NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CHECK (fecha_inicio < fecha_fin) -- Restricción: la fecha de inicio debe ser anterior a la fecha de fin
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Usuario: Credenciales de acceso para las personas
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_persona INT UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultimo_login DATETIME,
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Permiso: Acciones específicas que pueden realizar los usuarios
CREATE TABLE permiso (
    id_permiso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Rol_Permiso: Asigna permisos a roles
CREATE TABLE rol_permiso (
    id_rol INT NOT NULL,
    id_permiso INT NOT NULL,
    PRIMARY KEY (id_rol, id_permiso),
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE CASCADE,
    FOREIGN KEY (id_permiso) REFERENCES permiso(id_permiso) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Usuario_Rol: Asigna roles a usuarios
CREATE TABLE usuario_rol (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_rol),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Estudiante: Información específica de los estudiantes
CREATE TABLE estudiante (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    id_persona INT UNIQUE NOT NULL,
    codigo_estudiante VARCHAR(20) UNIQUE NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado ENUM('ACTIVO', 'INACTIVO', 'GRADUADO', 'RETIRADO') DEFAULT 'ACTIVO',
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Profesor: Información específica de los profesores
CREATE TABLE profesor (
    id_profesor INT AUTO_INCREMENT PRIMARY KEY,
    id_persona INT UNIQUE NOT NULL,
    codigo_profesor VARCHAR(20) UNIQUE NOT NULL,
    especialidad VARCHAR(100),
    fecha_contratacion DATE,
    tipo_contrato ENUM('TIEMPO_COMPLETO', 'MEDIO_TIEMPO', 'CATEDRA'),
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Departamento: Departamentos académicos de la institución
CREATE TABLE departamento (
    id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    id_director INT, -- Puede ser NULL hasta que se asigne un director
    fecha_creacion DATE,
    FOREIGN KEY (id_director) REFERENCES profesor(id_profesor) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Carrera: Carreras o programas de estudio
CREATE TABLE carrera (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    id_departamento INT NOT NULL,
    duracion_semestres INT,
    creditos_totales INT,
    estado ENUM('ACTIVA', 'INACTIVA') DEFAULT 'ACTIVA',
    FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Materia: Materias o asignaturas
CREATE TABLE materia (
    id_materia INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    creditos INT NOT NULL,
    horas_teoria INT,
    horas_practica INT,
    id_departamento INT NOT NULL,
    prerequisitos TEXT,
    corequisitos TEXT,
    FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Grupo: Instancias de una materia dictada por un profesor
CREATE TABLE grupo (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    id_materia INT NOT NULL,
    id_profesor INT NOT NULL,
    codigo_grupo VARCHAR(10) NOT NULL,
    cupo_maximo INT NOT NULL, -- Ahora con restricción NOT NULL
    horario TEXT NOT NULL,     -- Ahora con restricción NOT NULL
    aula VARCHAR(20) NOT NULL, -- Ahora con restricción NOT NULL
    UNIQUE KEY (id_materia, codigo_grupo), -- Restricción: No puede haber dos grupos con el mismo código para la misma materia
    FOREIGN KEY (id_materia) REFERENCES materia(id_materia) ON DELETE CASCADE,
    FOREIGN KEY (id_profesor) REFERENCES profesor(id_profesor) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Matricula: Registro de la matrícula de un estudiante en un periodo
CREATE TABLE matricula (
    id_matricula INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    fecha_matricula DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('PENDIENTE', 'COMPLETADA', 'ANULADA'),
    total_creditos INT,
    -- UNIQUE KEY (id_estudiante, fecha_matricula), -- Removida para permitir múltiples matrículas en diferentes fechas si el año/periodo no es PK
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Detalle_Matricula: Relaciona una matrícula con los grupos en los que el estudiante se inscribe
CREATE TABLE detalle_matricula (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_grupo INT NOT NULL,
    calificacion DECIMAL(3,1), -- Puede ser NULL inicialmente
    estado ENUM('CURSANDO', 'APROBADO', 'REPROBADO', 'RETIRADO') DEFAULT 'CURSANDO',
    UNIQUE KEY (id_matricula, id_grupo), -- Restricción: Un estudiante no puede estar matriculado dos veces en el mismo grupo en la misma matrícula
    FOREIGN KEY (id_matricula) REFERENCES matricula(id_matricula) ON DELETE CASCADE,
    FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Asistencia: Registro de la asistencia de un estudiante a una clase
CREATE TABLE asistencia (
    id_asistencia INT AUTO_INCREMENT PRIMARY KEY,
    id_detalle_matricula INT NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('PRESENTE', 'AUSENTE', 'JUSTIFICADO', 'TARDANZA') NOT NULL,
    observaciones TEXT,
    UNIQUE KEY (id_detalle_matricula, fecha), -- Restricción: Solo un registro de asistencia por estudiante por día por grupo
    FOREIGN KEY (id_detalle_matricula) REFERENCES detalle_matricula(id_detalle) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Justificacion: Justificaciones de ausencias o tardanzas
CREATE TABLE justificacion (
    id_justificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_asistencia INT UNIQUE NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_revision DATETIME,
    id_revisor INT, -- Puede ser NULL hasta que sea revisado
    estado ENUM('PENDIENTE', 'APROBADA', 'RECHAZADA') DEFAULT 'PENDIENTE',
    documentos_adjuntos TEXT,
    FOREIGN KEY (id_asistencia) REFERENCES asistencia(id_asistencia) ON DELETE CASCADE,
    FOREIGN KEY (id_revisor) REFERENCES usuario(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Auditoria: Registro de operaciones importantes en el sistema
CREATE TABLE auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    accion VARCHAR(100),
    tabla_afectada VARCHAR(100),
    id_registro INT,
    detalles TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 2. INSERCIÓN DE DATOS (DML)
-- =============================================

-- 1. Insertar roles del sistema (11 registros)
INSERT INTO rol (nombre, descripcion) VALUES
('ADMINISTRADOR', 'Acceso completo al sistema'),
('COORDINADOR', 'Coordinador académico de departamento'),
('PROFESOR', 'Profesor que dicta materias'),
('ESTUDIANTE', 'Estudiante regular'),
('SECRETARIA', 'Personal administrativo'),
('JEFE_DEPARTAMENTO', 'Jefe de departamento académico'),
('ASISTENTE', 'Asistente administrativo'),
('INVITADO', 'Acceso limitado de solo lectura'),
('AUDITOR', 'Acceso para auditoría del sistema'),
('DESARROLLADOR', 'Acceso para mantenimiento del sistema'),
('TUTOR', 'Rol para tutores académicos');

-- 2. Insertar permisos (13 registros)
INSERT INTO permiso (nombre, descripcion) VALUES
('USUARIOS_CREAR', 'Crear nuevos usuarios'),
('USUARIOS_EDITAR', 'Editar usuarios existentes'),
('USUARIOS_ELIMINAR', 'Eliminar usuarios'),
('ESTUDIANTES_GESTION', 'Gestionar estudiantes'),
('PROFESORES_GESTION', 'Gestionar profesores'),
('MATERIAS_GESTION', 'Gestionar materias'),
('GRUPOS_GESTION', 'Gestionar grupos'),
('ASISTENCIAS_REGISTRAR', 'Registrar asistencias'),
('JUSTIFICACIONES_APROBAR', 'Aprobar justificaciones'),
('REPORTES_GENERAR', 'Generar reportes'),
('CONFIGURACION_SISTEMA', 'Configurar parámetros del sistema'),
('MATRICULAS_PROCESAR', 'Procesar matrículas'),
('CALIFICACIONES_REGISTRAR', 'Registrar calificaciones');

-- 3. Asignar permisos a roles (más de 10 registros para seguridad)
INSERT INTO rol_permiso (id_rol, id_permiso) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (1, 11), (1, 12), (1, 13), -- ADMINISTRADOR
(2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9), (2, 10), -- COORDINADOR
(3, 8), (3, 13), -- PROFESOR
(4, 8), -- ESTUDIANTE (puede ver su asistencia)
(5, 4), (5, 12), -- SECRETARIA
(6, 4), (6, 5), (6, 6), (6, 7), (6, 10), -- JEFE_DEPARTAMENTO
(7, 4), (7, 12), -- ASISTENTE
(9, 10), -- AUDITOR
(10, 1), (10, 2), (10, 11); -- DESARROLLADOR

-- 4. Insertar personas (21 registros: 11 admin/profesores + 10 estudiantes)
-- IDs 1-11 para administrativos y docentes
INSERT INTO persona (cedula, nombre, apellido, fecha_nacimiento, genero, direccion, telefono, email) VALUES
('1000000001', 'Admin', 'Sistema', '1980-01-01', 'M', 'Calle Principal 123', '0991234567', 'admin@sistema.edu'),
('1000000002', 'María', 'González', '1985-05-15', 'F', 'Av. Secundaria 456', '0992345678', 'maria.gonzalez@sistema.edu'),
('1000000003', 'Carlos', 'Pérez', '1978-11-23', 'M', 'Calle Terciaria 789', '0993456789', 'carlos.perez@sistema.edu'),
('1000000004', 'Ana', 'Rodríguez', '1990-03-30', 'F', 'Av. Cuarta 1011', '0994567890', 'ana.rod@sistema.edu'),
('1000000005', 'Pedro', 'Martínez', '1982-07-12', 'M', 'Calle Quinta 1213', '0995678901', 'pedro.mart@sistema.edu'),
('1000000006', 'Luisa', 'Fernández', '1992-09-05', 'F', 'Av. Sexta 1415', '0996789012', 'luisa.fer@sistema.edu'),
('1000000007', 'Jorge', 'López', '1975-12-18', 'M', 'Calle Séptima 1617', '0997890123', 'jorge.lop@sistema.edu'),
('1000000008', 'Diana', 'Sánchez', '1988-04-22', 'F', 'Av. Octava 1819', '0998901234', 'diana.san@sistema.edu'),
('1000000009', 'Roberto', 'Ramírez', '1991-08-07', 'M', 'Calle Novena 2021', '0999012345', 'roberto.ram@sistema.edu'),
('1000000010', 'Carmen', 'Torres', '1983-02-14', 'F', 'Av. Décima 2223', '0990123456', 'carmen.tor@sistema.edu'),
('1000000011', 'Miguel', 'Vargas', '1970-06-28', 'M', 'Calle Once 2425', '0991122334', 'miguel.var@sistema.edu');

-- IDs 12-21 para estudiantes
INSERT INTO persona (cedula, nombre, apellido, fecha_nacimiento, genero, direccion, telefono, email) VALUES
('2000000001', 'Juan', 'Pérez', '2000-01-10', 'M', 'Calle A 101', '0981111111', 'juan.perez@estudiante.edu'),
('2000000002', 'María', 'Gómez', '2000-02-15', 'F', 'Calle B 202', '0982222222', 'maria.gomez@estudiante.edu'),
('2000000003', 'Carlos', 'López', '2001-03-20', 'M', 'Calle C 303', '0983333333', 'carlos.lopez@estudiante.edu'),
('2000000004', 'Ana', 'Rodríguez', '2001-04-25', 'F', 'Calle D 404', '0984444444', 'ana.rodriguez@estudiante.edu'),
('2000000005', 'Pedro', 'Martínez', '2002-05-30', 'M', 'Calle E 505', '0985555555', 'pedro.martinez@estudiante.edu'),
('2000000006', 'Laura', 'Fernández', '2002-06-05', 'F', 'Calle F 606', '0986666666', 'laura.fernandez@estudiante.edu'),
('2000000007', 'Diego', 'González', '2000-07-10', 'M', 'Calle G 707', '0987777777', 'diego.gonzalez@estudiante.edu'),
('2000000008', 'Sofía', 'Hernández', '2000-08-15', 'F', 'Calle H 808', '0988888888', 'sofia.hernandez@estudiante.edu'),
('2000000009', 'Jorge', 'Díaz', '2001-09-20', 'M', 'Calle I 909', '0989999999', 'jorge.diaz@estudiante.edu'),
('2000000010', 'Lucía', 'Moreno', '2001-10-25', 'F', 'Calle J 1010', '0981010101', 'lucia.moreno@estudiante.edu');

-- 5. Insertar usuarios (11 registros para personas administrativas/docentes)
INSERT INTO usuario (id_persona, username, password_hash, activo) VALUES
(1, 'admin', SHA2('Admin123!', 256), TRUE),        -- Admin Sistema
(2, 'magonzalez', SHA2('Mg2023!', 256), TRUE),     -- María González
(3, 'cperez', SHA2('Cp2023!', 256), TRUE),         -- Carlos Pérez
(4, 'arodriguez', SHA2('Ar2023!', 256), TRUE),     -- Ana Rodríguez
(5, 'pmartinez', SHA2('Pm2023!', 256), TRUE),     -- Pedro Martínez
(6, 'lfernandez', SHA2('Lf2023!', 256), TRUE),     -- Luisa Fernández
(7, 'jlopez', SHA2('Jl2023!', 256), TRUE),         -- Jorge López
(8, 'dsanchez', SHA2('Ds2023!', 256), TRUE),       -- Diana Sánchez
(9, 'rramirez', SHA2('Rr2023!', 256), TRUE),       -- Roberto Ramírez
(10, 'ctorres', SHA2('Ct2023!', 256), TRUE),      -- Carmen Torres
(11, 'mvargas', SHA2('Mv2023!', 256), TRUE);      -- Miguel Vargas

-- 6. Asignar roles a usuarios (11 registros)
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
(1, 1), -- admin -> ADMINISTRADOR
(2, 2), -- magonzalez -> COORDINADOR
(3, 3), -- cperez -> PROFESOR
(4, 4), -- arodriguez -> ESTUDIANTE (Aunque es admin/prof, se le asigna rol de estudiante para pruebas)
(5, 5), -- pmartinez -> SECRETARIA
(6, 6), -- lfernandez -> JEFE_DEPARTAMENTO
(7, 7), -- jlopez -> ASISTENTE
(8, 3), -- dsanchez -> PROFESOR
(9, 3), -- rramirez -> PROFESOR
(10, 8), -- ctorres -> INVITADO
(11, 9); -- mvargas -> AUDITOR

-- 7. Insertar profesores (4 registros)
-- id_persona 3, 8, 9, 11 corresponden a docentes
INSERT INTO profesor (id_persona, codigo_profesor, especialidad, fecha_contratacion, tipo_contrato) VALUES
(3, 'PROF001', 'Matemáticas', '2015-03-15', 'TIEMPO_COMPLETO'),   -- Carlos Pérez (id_profesor 1)
(8, 'PROF002', 'Literatura', '2018-08-20', 'TIEMPO_COMPLETO'),    -- Diana Sánchez (id_profesor 2)
(9, 'PROF003', 'Historia', '2017-01-10', 'MEDIO_TIEMPO'),         -- Roberto Ramírez (id_profesor 3)
(11, 'PROF004', 'Informática', '2020-05-22', 'TIEMPO_COMPLETO');  -- Miguel Vargas (id_profesor 4)

-- 8. Insertar estudiantes (10 registros)
-- id_persona 12-21 corresponden a estudiantes
INSERT INTO estudiante (id_persona, codigo_estudiante, fecha_ingreso, estado) VALUES
(12, 'EST2023001', '2023-01-15', 'ACTIVO'), -- Juan Pérez (id_estudiante 1)
(13, 'EST2023002', '2023-01-15', 'ACTIVO'), -- María Gómez (id_estudiante 2)
(14, 'EST2023003', '2023-01-15', 'ACTIVO'), -- Carlos López (id_estudiante 3)
(15, 'EST2023004', '2023-01-15', 'ACTIVO'), -- Ana Rodríguez (id_estudiante 4)
(16, 'EST2023005', '2023-01-15', 'ACTIVO'), -- Pedro Martínez (id_estudiante 5)
(17, 'EST2023006', '2023-01-15', 'ACTIVO'), -- Laura Fernández (id_estudiante 6)
(18, 'EST2023007', '2023-01-15', 'ACTIVO'), -- Diego González (id_estudiante 7)
(19, 'EST2023008', '2023-01-15', 'ACTIVO'), -- Sofía Hernández (id_estudiante 8)
(20, 'EST2023009', '2023-01-15', 'ACTIVO'), -- Jorge Díaz (id_estudiante 9)
(21, 'EST2023010', '2023-01-15', 'ACTIVO'); -- Lucía Moreno (id_estudiante 10)

-- 9. Insertar departamentos (4 registros)
INSERT INTO departamento (nombre, codigo, fecha_creacion) VALUES
('Ciencias Exactas', 'DCE', '2010-01-15'), -- ID 1
('Humanidades', 'DHU', '2010-01-15'),     -- ID 2
('Tecnología', 'DTE', '2015-03-20'),      -- ID 3
('Ciencias Sociales', 'DCS', '2012-08-10');-- ID 4

-- 10. Actualizar directores de departamento (se asignan a profesores existentes)
UPDATE departamento SET id_director = 1 WHERE id_departamento = 1; -- Carlos Pérez (id_profesor 1)
UPDATE departamento SET id_director = 2 WHERE id_departamento = 2; -- Diana Sánchez (id_profesor 2)
UPDATE departamento SET id_director = 4 WHERE id_departamento = 3; -- Miguel Vargas (id_profesor 4)
UPDATE departamento SET id_director = 3 WHERE id_departamento = 4; -- Roberto Ramírez (id_profesor 3)

-- 11. Insertar carreras (4 registros)
INSERT INTO carrera (nombre, codigo, id_departamento, duracion_semestres, creditos_totales, estado) VALUES
('Ingeniería en Sistemas', 'IS', 3, 10, 320, 'ACTIVA'),
('Licenciatura en Matemáticas', 'LM', 1, 8, 256, 'ACTIVA'),
('Licenciatura en Literatura', 'LL', 2, 8, 256, 'ACTIVA'),
('Economía', 'EC', 4, 8, 256, 'ACTIVA');

-- 12. Insertar materias (14 registros)
INSERT INTO materia (nombre, codigo, creditos, horas_teoria, horas_practica, id_departamento) VALUES
-- Ciencias Exactas (id_departamento = 1)
('Cálculo I', 'CAL101', 4, 4, 2, 1),        -- ID 1
('Cálculo II', 'CAL102', 4, 4, 2, 1),       -- ID 2
('Álgebra Lineal', 'ALG201', 4, 4, 2, 1),   -- ID 3
('Física I', 'FIS101', 4, 4, 2, 1),         -- ID 4
('Matemáticas I', 'MAT101', 4, 4, 2, 1),    -- ID 5 (Esta se usará para el grupo 6)

-- Humanidades (id_departamento = 2)
('Literatura Universal', 'LIT101', 3, 3, 0, 2), -- ID 6
('Gramática Avanzada', 'GRA201', 3, 3, 0, 2),   -- ID 7
('Historia del Arte', 'ART301', 3, 3, 0, 2),    -- ID 8

-- Tecnología (id_departamento = 3)
('Programación I', 'PRO101', 4, 3, 3, 3),   -- ID 9
('Programación II', 'PRO102', 4, 3, 3, 3),  -- ID 10
('Bases de Datos', 'BAS301', 4, 3, 3, 3),   -- ID 11

-- Ciencias Sociales (id_departamento = 4)
('Introducción a la Economía', 'ECO101', 3, 3, 0, 4), -- ID 12
('Microeconomía', 'MIC201', 3, 3, 0, 4),           -- ID 13
('Macroeconomía', 'MAC301', 3, 3, 0, 4);           -- ID 14

-- 13. Insertar periodos académicos (2 registros)
INSERT INTO periodo_academico (nombre_periodo, fecha_inicio, fecha_fin) VALUES
('2024-1', '2024-01-15', '2024-06-30'), -- ID 1
('2024-2', '2024-07-15', '2024-12-15'); -- ID 2

-- 14. Insertar grupos (6 registros - con valores NO NULL para cupo_maximo, horario, aula)
INSERT INTO grupo (id_materia, id_profesor, codigo_grupo, cupo_maximo, horario, aula) VALUES
(1, 1, 'G1', 30, 'Lunes y Miércoles 08:00-10:00', 'A101'), -- ID 1: Materia CAL101 (Cálculo I), Profesor PROF001 (Carlos Pérez)
(2, 1, 'G1', 30, 'Martes y Jueves 08:00-10:00', 'A102'), -- ID 2: Materia CAL102 (Cálculo II), Profesor PROF001 (Carlos Pérez)
(6, 2, 'G1', 25, 'Lunes y Miércoles 10:00-12:00', 'B201'), -- ID 3: Materia LIT101 (Literatura Universal), Profesor PROF002 (Diana Sánchez)
(9, 4, 'G1', 25, 'Martes y Jueves 10:00-12:00', 'LAB1'), -- ID 4: Materia PRO101 (Programación I), Profesor PROF004 (Miguel Vargas)
(12, 3, 'G1', 20, 'Viernes 14:00-18:00', 'C301'), -- ID 5: Materia ECO101 (Introducción a la Economía), Profesor PROF003 (Roberto Ramírez)
(5, 1, 'G1', 30, 'Lunes y Miércoles 10:00-12:00', 'A103'); -- ID 6: Materia MAT101 (Matemáticas I), Profesor PROF001 (Carlos Pérez)

-- 15. Insertar matrículas (5 registros)
INSERT INTO matricula (id_estudiante, estado, total_creditos, fecha_matricula) VALUES
(1, 'COMPLETADA', 12, '2024-01-16'), -- Juan Pérez (estudiante 1)
(2, 'COMPLETADA', 12, '2024-02-05'), -- María Gómez (estudiante 2)
(3, 'COMPLETADA', 12, '2024-02-06'), -- Carlos López (estudiante 3)
(4, 'COMPLETADA', 12, '2024-02-07'), -- Ana Rodríguez (estudiante 4)
(5, 'COMPLETADA', 12, '2024-02-09'); -- Pedro Martínez (estudiante 5)

-- 16. Insertar detalles de matrícula (10 registros)
INSERT INTO detalle_matricula (id_matricula, id_grupo, estado, calificacion) VALUES
(1, 1, 'CURSANDO', NULL),     -- Juan Pérez (matrícula 1) en Cálculo I (grupo 1)
(1, 3, 'CURSANDO', NULL),     -- Juan Pérez (matrícula 1) en Literatura Universal (grupo 3)
(2, 1, 'APROBADO', 7.5),      -- María Gómez (matrícula 2) en Cálculo I (grupo 1)
(2, 4, 'CURSANDO', NULL),     -- María Gómez (matrícula 2) en Programación I (grupo 4)
(3, 2, 'REPROBADO', 4.0),     -- Carlos López (matrícula 3) en Cálculo II (grupo 2)
(3, 5, 'CURSANDO', NULL),     -- Carlos López (matrícula 3) en Introducción a la Economía (grupo 5)
(4, 3, 'APROBADO', 8.0),      -- Ana Rodríguez (matrícula 4) en Literatura Universal (grupo 3)
(4, 5, 'CURSANDO', NULL),     -- Ana Rodríguez (matrícula 4) en Introducción a la Economía (grupo 5)
(5, 4, 'CURSANDO', NULL),     -- Pedro Martínez (matrícula 5) en Programación I (grupo 4)
(5, 2, 'CURSANDO', NULL);     -- Pedro Martínez (matrícula 5) en Cálculo II (grupo 2)

-- 17. Insertar asistencias (10 registros)
INSERT INTO asistencia (id_detalle_matricula, fecha, estado, observaciones) VALUES
(1, '2024-06-17', 'AUSENTE', 'No avisó'),
(1, '2024-06-18', 'PRESENTE', NULL),
(1, '2024-06-19', 'AUSENTE', 'No avisó'), -- Esta será justificada (id_asistencia 3)
(2, '2024-06-17', 'PRESENTE', NULL),
(3, '2024-06-17', 'TARDANZA', 'Llegó 15 minutos tarde'),
(4, '2024-06-17', 'PRESENTE', NULL),
(5, '2024-06-17', 'AUSENTE', 'Motivo desconocido'), -- Esta será justificada (id_asistencia 7)
(6, '2024-06-17', 'PRESENTE', NULL),
(7, '2024-06-17', 'PRESENTE', NULL),
(8, '2024-06-17', 'PRESENTE', NULL);

-- 18. Insertar justificaciones (3 registros)
INSERT INTO justificacion (id_asistencia, descripcion, estado) VALUES
(1, 'Enfermedad comprobada con certificado médico', 'APROBADA'), -- id_justificacion = 1
(3, 'Problemas de transporte público', 'PENDIENTE'),             -- id_justificacion = 2 (Esta será aprobada en el CALL)
(7, 'Emergencia familiar', 'APROBADA');                         -- id_justificacion = 3

-- =============================================
-- 3. FUNCIONES SQL
-- =============================================
DELIMITER //

-- Función: fn_calcular_porcentaje_asistencia
-- Calcula el porcentaje de asistencia de un estudiante en un grupo
CREATE FUNCTION fn_calcular_porcentaje_asistencia(
    p_id_estudiante INT,
    p_id_grupo INT
)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE total_clases INT;
    DECLARE clases_presentes INT;
    DECLARE porcentaje DECIMAL(5,2);

    -- Obtener el total de clases para el grupo
    -- Asumimos que se registran todas las clases que debieron darse
    SELECT COUNT(DISTINCT fecha) INTO total_clases
    FROM asistencia a
    JOIN detalle_matricula dm ON a.id_detalle_matricula = dm.id_detalle
    WHERE dm.id_grupo = p_id_grupo;

    -- Obtener el número de clases donde el estudiante estuvo PRESENTE o JUSTIFICADO
    SELECT COUNT(*) INTO clases_presentes
    FROM asistencia a
    JOIN detalle_matricula dm ON a.id_detalle_matricula = dm.id_detalle
    JOIN matricula m ON dm.id_matricula = m.id_matricula
    WHERE m.id_estudiante = p_id_estudiante
      AND dm.id_grupo = p_id_grupo
      AND a.estado IN ('PRESENTE', 'JUSTIFICADO');

    IF total_clases = 0 THEN
        SET porcentaje = 0.00;
    ELSE
        SET porcentaje = (clases_presentes / total_clases) * 100;
    END IF;

    RETURN porcentaje;
END //

-- Función: fn_calcular_inasistencias_estudiante
-- Calcula el total de inasistencias (AUSENTE, TARDANZA no justificadas) de un estudiante
-- en un periodo académico. Si p_id_periodo es NULL, calcula todas las inasistencias.
CREATE FUNCTION fn_calcular_inasistencias_estudiante(
    p_id_estudiante INT,
    p_id_periodo INT
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total_inasistencias INT;

    SELECT COUNT(a.id_asistencia) INTO total_inasistencias
    FROM asistencia a
    JOIN detalle_matricula dm ON a.id_detalle_matricula = dm.id_detalle
    JOIN matricula m ON dm.id_matricula = m.id_matricula
    WHERE m.id_estudiante = p_id_estudiante
      AND a.estado IN ('AUSENTE', 'TARDANZA')
      AND NOT EXISTS (SELECT 1 FROM justificacion j WHERE j.id_asistencia = a.id_asistencia AND j.estado = 'APROBADA')
      AND (p_id_periodo IS NULL OR EXISTS (
          SELECT 1
          FROM grupo g
          JOIN materia mat ON g.id_materia = mat.id_materia
          JOIN periodo_academico pa ON a.fecha BETWEEN pa.fecha_inicio AND pa.fecha_fin
          WHERE g.id_grupo = dm.id_grupo AND pa.id_periodo = p_id_periodo
      ));

    RETURN total_inasistencias;
END //

DELIMITER ;

-- =============================================
-- 4. PROCEDIMIENTOS ALMACENADOS (CRUD)
-- =============================================
DELIMITER //

-- 1. sp_actualizar_asistencia (UPDATE/INSERT Asistencia)
CREATE PROCEDURE sp_actualizar_asistencia(
    IN p_id_estudiante INT,
    IN p_id_grupo INT,
    IN p_fecha DATE,
    IN p_estado ENUM('PRESENTE', 'AUSENTE', 'JUSTIFICADO', 'TARDANZA'),
    IN p_usuario_auditoria VARCHAR(50),
    IN p_observaciones TEXT
)
BEGIN
    DECLARE v_id_detalle INT;
    DECLARE v_id_asistencia INT;

    -- Obtener id_detalle_matricula para el estudiante en el grupo
    SELECT dm.id_detalle INTO v_id_detalle
    FROM detalle_matricula dm
    JOIN matricula m ON dm.id_matricula = m.id_matricula
    WHERE m.id_estudiante = p_id_estudiante AND dm.id_grupo = p_id_grupo;

    -- Validar si se encontró una matrícula activa
    IF v_id_detalle IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una matrícula activa para el estudiante en el grupo especificado. Verifique los IDs.';
    END IF;

    -- Intentar actualizar si ya existe una asistencia para esa fecha
    SELECT id_asistencia INTO v_id_asistencia
    FROM asistencia
    WHERE id_detalle_matricula = v_id_detalle AND fecha = p_fecha;

    IF v_id_asistencia IS NOT NULL THEN
        -- Actualizar asistencia existente
        UPDATE asistencia
        SET
            estado = p_estado,
            observaciones = p_observaciones
        WHERE id_asistencia = v_id_asistencia;

        INSERT INTO auditoria(usuario, accion, tabla_afectada, id_registro, detalles)
        VALUES (p_usuario_auditoria, 'UPDATE', 'asistencia', v_id_asistencia,
                CONCAT('Asistencia actualizada para id_detalle_matricula: ', v_id_detalle, ', fecha: ', p_fecha, ', nuevo estado: ', p_estado));

        SELECT 'Asistencia actualizada correctamente.' AS mensaje;
    ELSE
        -- Insertar nueva asistencia
        INSERT INTO asistencia (id_detalle_matricula, fecha, estado, observaciones)
        VALUES (v_id_detalle, p_fecha, p_estado, p_observaciones);

        INSERT INTO auditoria(usuario, accion, tabla_afectada, id_registro, detalles)
        VALUES (p_usuario_auditoria, 'INSERT', 'asistencia', LAST_INSERT_ID(),
                CONCAT('Nueva asistencia registrada para id_detalle_matricula: ', v_id_detalle, ', fecha: ', p_fecha, ', estado: ', p_estado));

        SELECT 'Asistencia registrada correctamente.' AS mensaje;
    END IF;
END //

-- 2. sp_registrar_persona (INSERT Persona)
CREATE PROCEDURE sp_registrar_persona(
    IN p_cedula VARCHAR(20),
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_fecha_nacimiento DATE,
    IN p_genero ENUM('M', 'F', 'O'),
    IN p_direccion TEXT,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN
    INSERT INTO persona (cedula, nombre, apellido, fecha_nacimiento, genero, direccion, telefono, email)
    VALUES (p_cedula, p_nombre, p_apellido, p_fecha_nacimiento, p_genero, p_direccion, p_telefono, p_email);

    INSERT INTO auditoria(usuario, accion, tabla_afectada, id_registro, detalles)
    VALUES ('sistema', 'INSERT', 'persona', LAST_INSERT_ID(), CONCAT('Nueva persona registrada: ', p_nombre, ' ', p_apellido, ' (', p_cedula, ')'));

    SELECT LAST_INSERT_ID() AS id_nueva_persona, 'Persona registrada exitosamente.' AS mensaje;
END //

-- 3. sp_actualizar_calificacion_detalle_matricula (UPDATE Detalle_Matricula)
CREATE PROCEDURE sp_actualizar_calificacion_detalle_matricula(
    IN p_id_detalle INT,
    IN p_calificacion DECIMAL(3,1),
    IN p_usuario VARCHAR(50) -- Usuario que realiza la acción para auditoría
)
BEGIN
    DECLARE v_estado_final ENUM('CURSANDO', 'APROBADO', 'REPROBADO', 'RETIRADO');
    DECLARE v_id_matricula INT;
    DECLARE v_id_grupo INT;

    -- Validar calificación
    IF p_calificacion IS NULL OR p_calificacion < 0 OR p_calificacion > 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Calificación inválida. Debe estar entre 0 y 10.';
    END IF;

    -- Determinar el estado final basado en la calificación (ej. 7.0 o más es APROBADO)
    IF p_calificacion >= 7.0 THEN
        SET v_estado_final = 'APROBADO';
    ELSE
        SET v_estado_final = 'REPROBADO';
    END IF;

    -- Actualizar el detalle de matrícula
    UPDATE detalle_matricula
    SET
        calificacion = p_calificacion,
        estado = v_estado_final
    WHERE id_detalle = p_id_detalle;

    -- Obtener datos para auditoría
    SELECT id_matricula, id_grupo INTO v_id_matricula, v_id_grupo
    FROM detalle_matricula
    WHERE id_detalle = p_id_detalle;

    -- Registrar en auditoría
    INSERT INTO auditoria(tabla_afectada, accion, id_registro, usuario, detalles)
    VALUES ('detalle_matricula', 'UPDATE', p_id_detalle, p_usuario,
            CONCAT('Calificación de ', p_calificacion, ' y estado a ', v_estado_final,
                   ' para detalle_matricula ID ', p_id_detalle,
                   ' (Matrícula ', v_id_matricula, ', Grupo ', v_id_grupo, ')'));

    SELECT 'Calificación y estado actualizados correctamente.' AS mensaje;
END //

-- 4. sp_obtener_estudiante_por_id (SELECT Estudiante)
CREATE PROCEDURE sp_obtener_estudiante_por_id(
    IN p_id_estudiante INT
)
BEGIN
    SELECT
        e.id_estudiante,
        e.codigo_estudiante,
        e.fecha_ingreso,
        e.estado AS estado_estudiante,
        p.cedula,
        p.nombre,
        p.apellido,
        p.fecha_nacimiento,
        p.genero,
        p.direccion,
        p.telefono,
        p.email
    FROM
        estudiante e
    JOIN
        persona p ON e.id_persona = p.id_persona
    WHERE
        e.id_estudiante = p_id_estudiante;
END //

-- 5. sp_listar_materias_por_departamento (SELECT Materia)
CREATE PROCEDURE sp_listar_materias_por_departamento(
    IN p_id_departamento INT
)
BEGIN
    SELECT
        m.id_materia,
        m.nombre AS nombre_materia,
        m.codigo AS codigo_materia,
        m.creditos,
        m.horas_teoria,
        m.horas_practica,
        d.nombre AS nombre_departamento
    FROM
        materia m
    JOIN
        departamento d ON m.id_departamento = d.id_departamento
    WHERE
        m.id_departamento = p_id_departamento;
END //

-- 6. sp_matricular_estudiante_en_grupo (INSERT Detalle_Matricula)
CREATE PROCEDURE sp_matricular_estudiante_en_grupo(
    IN p_id_estudiante INT,
    IN p_id_grupo INT,
    IN p_usuario VARCHAR(50) -- Usuario que realiza la acción para auditoría
)
BEGIN
    DECLARE v_id_matricula INT;
    DECLARE v_cupo_actual INT;
    DECLARE v_cupo_maximo INT;
    DECLARE v_grupo_existente INT;

    -- 1. Verificar si el grupo existe
    SELECT COUNT(*) INTO v_grupo_existente FROM grupo WHERE id_grupo = p_id_grupo;
    IF v_grupo_existente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El grupo especificado no existe.';
    END IF;

    -- 2. Obtener la matrícula activa del estudiante (asume que un estudiante tiene una matrícula activa en un momento dado)
    SELECT id_matricula INTO v_id_matricula
    FROM matricula
    WHERE id_estudiante = p_id_estudiante AND estado = 'COMPLETADA'
    LIMIT 1;

    IF v_id_matricula IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró una matrícula activa (COMPLETADA) para el estudiante. Por favor, matricule al estudiante primero.';
    END IF;

    -- 3. Verificar si el estudiante ya está matriculado en este grupo
    IF EXISTS (SELECT 1 FROM detalle_matricula WHERE id_matricula = v_id_matricula AND id_grupo = p_id_grupo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estudiante ya está matriculado en este grupo.';
    END IF;

    -- 4. Verificar cupo disponible en el grupo
    SELECT COUNT(*) INTO v_cupo_actual FROM detalle_matricula WHERE id_grupo = p_id_grupo AND estado = 'CURSANDO';
    SELECT cupo_maximo INTO v_cupo_maximo FROM grupo WHERE id_grupo = p_id_grupo;

    IF v_cupo_maximo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cupo máximo del grupo no está definido. Por favor, actualice el grupo.';
    END IF;

    IF v_cupo_actual >= v_cupo_maximo THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El grupo ha alcanzado su cupo máximo. No se puede matricular al estudiante.';
    END IF;

    -- 5. Insertar el detalle de matrícula
    INSERT INTO detalle_matricula (id_matricula, id_grupo, estado)
    VALUES (v_id_matricula, p_id_grupo, 'CURSANDO');

    -- Registrar en auditoría
    INSERT INTO auditoria(tabla_afectada, accion, id_registro, usuario, detalles)
    VALUES ('detalle_matricula', 'INSERT', LAST_INSERT_ID(), p_usuario,
            CONCAT('Estudiante ID ', p_id_estudiante, ' matriculado en grupo ID ', p_id_grupo,
                   ' (Matrícula ID ', v_id_matricula, ')'));

    SELECT 'Estudiante matriculado en el grupo correctamente.' AS mensaje;
END //

-- 7. sp_registrar_periodo_academico (INSERT Periodo_Academico)
CREATE PROCEDURE sp_registrar_periodo_academico(
    IN p_nombre_periodo VARCHAR(100),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_usuario VARCHAR(50) -- Usuario que realiza la acción para auditoría
)
BEGIN
    -- Validar fechas
    IF p_fecha_inicio >= p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio debe ser anterior a la fecha de fin.';
    END IF;

    INSERT INTO periodo_academico (nombre_periodo, fecha_inicio, fecha_fin)
    VALUES (p_nombre_periodo, p_fecha_inicio, p_fecha_fin);

    -- Registrar en auditoría
    INSERT INTO auditoria(tabla_afectada, accion, id_registro, usuario, detalles)
    VALUES ('periodo_academico', 'INSERT', LAST_INSERT_ID(), p_usuario,
            CONCAT('Nuevo período académico: ', p_nombre_periodo,
                   ' (', p_fecha_inicio, ' a ', p_fecha_fin, ')'));

    SELECT LAST_INSERT_ID() AS id_nuevo_periodo, 'Período académico registrado exitosamente.' AS mensaje;
END //

-- 8. sp_obtener_asistencias_por_grupo_fecha (SELECT Asistencia)
CREATE PROCEDURE sp_obtener_asistencias_por_grupo_fecha(
    IN p_id_grupo INT,
    IN p_fecha DATE
)
BEGIN
    SELECT
        a.id_asistencia,
        p.nombre AS nombre_estudiante,
        p.apellido AS apellido_estudiante,
        e.codigo_estudiante,
        a.fecha,
        a.estado,
        a.observaciones
    FROM
        asistencia a
    JOIN
        detalle_matricula dm ON a.id_detalle_matricula = dm.id_detalle
    JOIN
        matricula m ON dm.id_matricula = m.id_matricula
    JOIN
        estudiante e ON m.id_estudiante = e.id_estudiante
    JOIN
        persona p ON e.id_persona = p.id_persona
    WHERE
        dm.id_grupo = p_id_grupo AND a.fecha = p_fecha
    ORDER BY
        p.apellido, p.nombre;
END //

-- 9. sp_aprobar_justificacion (UPDATE Justificacion, Asistencia)
CREATE PROCEDURE sp_aprobar_justificacion(
    IN p_id_justificacion INT,
    IN p_id_revisor INT, -- ID del usuario que aprueba
    IN p_usuario_auditoria VARCHAR(50)
)
BEGIN
    DECLARE v_id_asistencia INT;
    DECLARE v_estado_actual_justificacion ENUM('PENDIENTE', 'APROBADA', 'RECHAZADA');
    DECLARE v_revisor_existe INT;

    -- Verificar que el revisor existe
    SELECT COUNT(*) INTO v_revisor_existe FROM usuario WHERE id_usuario = p_id_revisor;
    IF v_revisor_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ID del revisor no existe.';
    END IF;

    -- Obtener id_asistencia y estado actual de la justificación
    SELECT id_asistencia, estado INTO v_id_asistencia, v_estado_actual_justificacion
    FROM justificacion
    WHERE id_justificacion = p_id_justificacion;

    IF v_id_asistencia IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Justificación no encontrada.';
    END IF;

    IF v_estado_actual_justificacion = 'APROBADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta justificación ya ha sido aprobada.';
    END IF;

    -- Actualizar el estado de la justificación
    UPDATE justificacion
    SET
        estado = 'APROBADA',
        fecha_revision = NOW(),
        id_revisor = p_id_revisor
    WHERE id_justificacion = p_id_justificacion;

    -- Actualizar el estado de la asistencia asociada a 'JUSTIFICADO'
    UPDATE asistencia
    SET estado = 'JUSTIFICADO'
    WHERE id_asistencia = v_id_asistencia;

    -- Registrar en auditoría
    INSERT INTO auditoria(tabla_afectada, accion, id_registro, usuario, detalles)
    VALUES ('justificacion', 'UPDATE', p_id_justificacion, p_usuario_auditoria,
            CONCAT('Justificación ID ', p_id_justificacion, ' aprobada por Revisor ID ', p_id_revisor,
                   '. Asistencia ID ', v_id_asistencia, ' cambiada a JUSTIFICADO.'));

    SELECT 'Justificación aprobada y asistencia actualizada correctamente.' AS mensaje;
END //

-- 10. sp_obtener_grupos_profesor (SELECT Grupo)
CREATE PROCEDURE sp_obtener_grupos_profesor(
    IN p_id_profesor INT
)
BEGIN
    SELECT
        g.id_grupo,
        g.codigo_grupo,
        m.nombre AS nombre_materia,
        m.codigo AS codigo_materia,
        g.horario,
        g.aula,
        g.cupo_maximo
    FROM
        grupo g
    JOIN
        materia m ON g.id_materia = m.id_materia
    WHERE
        g.id_profesor = p_id_profesor
    ORDER BY
        m.nombre, g.codigo_grupo;
END //

-- 11. sp_obtener_carreras_departamento (SELECT Carrera)
CREATE PROCEDURE sp_obtener_carreras_departamento(
    IN p_id_departamento INT
)
BEGIN
    SELECT
        c.id_carrera,
        c.nombre AS nombre_carrera,
        c.codigo AS codigo_carrera,
        c.duracion_semestres,
        c.creditos_totales,
        c.estado AS estado_carrera,
        d.nombre AS nombre_departamento
    FROM
        carrera c
    JOIN
        departamento d ON c.id_departamento = d.id_departamento
    WHERE
        c.id_departamento = p_id_departamento
    ORDER BY
        c.nombre;
END //

-- 12. sp_desactivar_usuario (UPDATE/Soft DELETE Usuario)
CREATE PROCEDURE sp_desactivar_usuario(
    IN p_id_usuario INT,
    IN p_usuario_auditoria VARCHAR(50)
)
BEGIN
    DECLARE v_username VARCHAR(50);

    -- Verificar si el usuario existe
    SELECT username INTO v_username FROM usuario WHERE id_usuario = p_id_usuario;

    IF v_username IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario especificado no existe.';
    END IF;

    -- Desactivar el usuario (Soft Delete)
    UPDATE usuario
    SET activo = FALSE
    WHERE id_usuario = p_id_usuario;

    -- Registrar en auditoría
    INSERT INTO auditoria(usuario, accion, tabla_afectada, id_registro, detalles)
    VALUES (p_usuario_auditoria, 'UPDATE', 'usuario', p_id_usuario,
            CONCAT('Usuario desactivado: ', v_username, ' (ID: ', p_id_usuario, ')'));

    SELECT 'Usuario desactivado correctamente.' AS mensaje;
END //

DELIMITER ;

-- =============================================
-- 5. TRIGGERS (2 Triggers)
-- =============================================
DELIMITER //

-- Trigger 1: tg_after_insert_persona_auditoria
-- Registra en la tabla de auditoría cada vez que se inserta una nueva persona.
CREATE TRIGGER tg_after_insert_persona_auditoria
AFTER INSERT ON persona
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (usuario, accion, tabla_afectada, id_registro, detalles)
    VALUES (USER(), 'INSERT', 'persona', NEW.id_persona, CONCAT('Nueva persona creada: ', NEW.nombre, ' ', NEW.apellido));
END //

-- Trigger 2: tg_after_update_estudiante_estado_auditoria
-- Registra en la tabla de auditoría cada vez que cambia el estado de un estudiante.
CREATE TRIGGER tg_after_update_estudiante_estado_auditoria
AFTER UPDATE ON estudiante
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO auditoria (usuario, accion, tabla_afectada, id_registro, detalles)
        VALUES (USER(), 'UPDATE', 'estudiante', NEW.id_estudiante,
                CONCAT('Estado del estudiante ID ', NEW.id_estudiante, ' cambiado de ', OLD.estado, ' a ', NEW.estado));
    END IF;
END //

DELIMITER ;

-- =============================================
-- 6. CONSULTAS SQL (10 Consultas utilizando JOIN)
-- =============================================

-- Consulta 1: Listar todos los estudiantes con su información personal detallada.
SELECT
    e.codigo_estudiante,
    p.nombre,
    p.apellido,
    p.cedula,
    p.email,
    e.fecha_ingreso,
    e.estado AS estado_estudiante
FROM
    estudiante e
JOIN
    persona p ON e.id_persona = p.id_persona
ORDER BY p.apellido, p.nombre;

-- Consulta 2: Listar profesores y los departamentos que dirigen (si son directores).
SELECT
    pr.codigo_profesor,
    pe.nombre AS nombre_profesor,
    pe.apellido AS apellido_profesor,
    d.nombre AS departamento_dirigido
FROM
    profesor pr
JOIN
    persona pe ON pr.id_persona = pe.id_persona
LEFT JOIN -- LEFT JOIN para incluir profesores que no dirigen ningún departamento
    departamento d ON pr.id_profesor = d.id_director
ORDER BY pe.apellido, pe.nombre;

-- Consulta 3: Listar todos los grupos, sus materias y los profesores que los imparten.
SELECT
    g.codigo_grupo,
    m.nombre AS nombre_materia,
    pr.codigo_profesor,
    pe.nombre AS nombre_profesor,
    pe.apellido AS apellido_profesor,
    g.horario,
    g.aula,
    g.cupo_maximo
FROM
    grupo g
JOIN
    materia m ON g.id_materia = m.id_materia
JOIN
    profesor pr ON g.id_profesor = pr.id_profesor
JOIN
    persona pe ON pr.id_persona = pe.id_persona
ORDER BY m.nombre, g.codigo_grupo;

-- Consulta 4: Encontrar todos los estudiantes matriculados en 'Cálculo I'.
SELECT
    e.codigo_estudiante,
    p.nombre,
    p.apellido,
    m.nombre AS nombre_materia,
    g.codigo_grupo
FROM
    estudiante e
JOIN
    persona p ON e.id_persona = p.id_persona
JOIN
    matricula mt ON e.id_estudiante = mt.id_estudiante
JOIN
    detalle_matricula dm ON mt.id_matricula = dm.id_matricula
JOIN
    grupo g ON dm.id_grupo = g.id_grupo
JOIN
    materia m ON g.id_materia = m.id_materia
WHERE
    m.nombre = 'Cálculo I'
ORDER BY p.apellido, p.nombre;

-- Consulta 5: Obtener las calificaciones de los estudiantes en 'Programación I'.
SELECT
    p.nombre AS nombre_estudiante,
    p.apellido AS apellido_estudiante,
    m.nombre AS nombre_materia,
    dm.calificacion,
    dm.estado AS estado_materia
FROM
    detalle_matricula dm
JOIN
    matricula mt ON dm.id_matricula = mt.id_matricula
JOIN
    estudiante e ON mt.id_estudiante = e.id_estudiante
JOIN
    persona p ON e.id_persona = p.id_persona
JOIN
    grupo g ON dm.id_grupo = g.id_grupo
JOIN
    materia m ON g.id_materia = m.id_materia
WHERE
    m.nombre = 'Programación I'
ORDER BY p.apellido, p.nombre;

-- Consulta 6: Listar todas las justificaciones de asistencia con el nombre del estudiante y la fecha de la asistencia.
SELECT
    j.id_justificacion,
    pe.nombre AS nombre_estudiante,
    pe.apellido AS apellido_estudiante,
    a.fecha AS fecha_asistencia,
    a.estado AS estado_asistencia_original,
    j.descripcion,
    j.estado AS estado_justificacion
FROM
    justificacion j
JOIN
    asistencia a ON j.id_asistencia = a.id_asistencia
JOIN
    detalle_matricula dm ON a.id_detalle_matricula = dm.id_detalle
JOIN
    matricula m ON dm.id_matricula = m.id_matricula
JOIN
    estudiante es ON m.id_estudiante = es.id_estudiante
JOIN
    persona pe ON es.id_persona = pe.id_persona
ORDER BY a.fecha, pe.apellido;

-- Consulta 7: Mostrar todos los usuarios activos y sus roles asignados.
SELECT
    u.username,
    pe.nombre,
    pe.apellido,
    r.nombre AS nombre_rol,
    u.activo
FROM
    usuario u
JOIN
    persona pe ON u.id_persona = pe.id_persona
JOIN
    usuario_rol ur ON u.id_usuario = ur.id_usuario
JOIN
    rol r ON ur.id_rol = r.id_rol
WHERE
    u.activo = TRUE
ORDER BY u.username;

-- Consulta 8: Listar todos los permisos concedidos al rol 'ADMINISTRADOR'.
SELECT
    r.nombre AS nombre_rol,
    p.nombre AS nombre_permiso,
    p.descripcion AS descripcion_permiso
FROM
    rol r
JOIN
    rol_permiso rp ON r.id_rol = rp.id_rol
JOIN
    permiso p ON rp.id_permiso = p.id_permiso
WHERE
    r.nombre = 'ADMINISTRADOR'
ORDER BY p.nombre;

-- Consulta 9: Encontrar estudiantes que han reprobado alguna materia.
SELECT DISTINCT
    e.codigo_estudiante,
    p.nombre,
    p.apellido,
    m.nombre AS materia_reprobada,
    dm.calificacion
FROM
    estudiante e
JOIN
    persona p ON e.id_persona = p.id_persona
JOIN
    matricula mt ON e.id_estudiante = mt.id_estudiante
JOIN
    detalle_matricula dm ON mt.id_matricula = dm.id_matricula
JOIN
    grupo g ON dm.id_grupo = g.id_grupo
JOIN
    materia m ON g.id_materia = m.id_materia
WHERE
    dm.estado = 'REPROBADO'
ORDER BY p.apellido, p.nombre, materia_reprobada;

-- Consulta 10: Listar todas las carreras y el departamento al que pertenecen.
SELECT
    c.nombre AS nombre_carrera,
    c.codigo AS codigo_carrera,
    d.nombre AS nombre_departamento,
    d.codigo AS codigo_departamento
FROM
    carrera c
JOIN
    departamento d ON c.id_departamento = d.id_departamento
ORDER BY d.nombre, c.nombre;

-- =============================================
-- 7. LLAMADAS DE PRUEBA A PROCEDIMIENTOS Y FUNCIONES
-- =============================================

SELECT '--- Ejecutando llamadas a procedimientos ---' AS info;

-- P1: Llamada a sp_registrar_persona (INSERT)
CALL sp_registrar_persona(
    '3000000001', 'Nuevo', 'EstudiantePrueba', '2003-01-01', 'F', 'Calle Falsa 123', '0981234567', 'nuevo.estudiante@email.com'
);
-- Nota: La persona se crea, pero no se asigna automáticamente como 'estudiante' o 'profesor'.

-- P2: Llamada a sp_actualizar_calificacion_detalle_matricula (UPDATE)
-- Actualiza la calificación para el detalle de matrícula ID 1 (Juan Pérez en Cálculo I)
CALL sp_actualizar_calificacion_detalle_matricula(
    1,          -- p_id_detalle (corresponde a Juan Pérez en Cálculo I)
    9.2,        -- p_calificacion
    'profesor_auditor'     -- p_usuario
);

-- P3: Llamada a sp_obtener_estudiante_por_id (SELECT)
-- Obtiene detalles del estudiante con id_estudiante = 1 (Juan Pérez)
CALL sp_obtener_estudiante_por_id(
    1           -- p_id_estudiante
);

-- P4: Llamada a sp_listar_materias_por_departamento (SELECT)
-- Lista materias del departamento de Tecnología (id_departamento = 3)
CALL sp_listar_materias_por_departamento(
    3           -- p_id_departamento
);

-- P5: Llamada a sp_matricular_estudiante_en_grupo (INSERT Detalle_Matricula)
-- Matricula al estudiante 5 (Pedro Martínez) en el grupo 6 (Matemáticas I - G1)
-- IMPORTANTE: Asegúrate de que el estudiante 5 NO esté ya en el grupo 6 para evitar duplicados.
CALL sp_matricular_estudiante_en_grupo(
    5,          -- p_id_estudiante (Pedro Martínez)
    6,          -- p_id_grupo (Matemáticas I - G1)
    'admin'     -- p_usuario
);

-- P6: Llamada a sp_registrar_periodo_academico (INSERT)
-- Registra un nuevo período académico
CALL sp_registrar_periodo_academico(
    'Invierno 2025',
    '2025-12-01',
    '2026-01-31',
    'admin'
);

-- P7: Llamada a sp_obtener_asistencias_por_grupo_fecha (SELECT)
-- Obtiene asistencias para el grupo 1 (Cálculo I) en la fecha '2024-06-17'
CALL sp_obtener_asistencias_por_grupo_fecha(
    1,              -- p_id_grupo
    '2024-06-17'    -- p_fecha
);

-- P8: Llamada a sp_aprobar_justificacion (UPDATE Justificacion, Asistencia)
-- Aprueba la justificación con id_justificacion = 2 (Problemas de transporte público, que está PENDIENTE)
-- Usamos id_usuario = 1 (admin) como revisor
CALL sp_aprobar_justificacion(
    2,          -- p_id_justificacion (Debería ser ID 2 para la PENDIENTE)
    1,          -- p_id_revisor (ID del usuario que aprueba, ej. 'admin')
    'admin'     -- p_usuario_auditoria
);

-- P9: Llamada a sp_obtener_grupos_profesor (SELECT)
-- Obtiene grupos del profesor con id_profesor = 1 (Carlos Pérez)
CALL sp_obtener_grupos_profesor(
    1           -- p_id_profesor
);

-- P10: Llamada a sp_obtener_carreras_departamento (SELECT)
-- Obtiene carreras del departamento de Tecnología (id_departamento = 3)
CALL sp_obtener_carreras_departamento(
    3           -- p_id_departamento
);

-- P11: Llamada a sp_desactivar_usuario (UPDATE/Soft DELETE)
-- Desactiva el usuario con ID 4 (Ana Rodríguez)
CALL sp_desactivar_usuario(
    4,           -- p_id_usuario (Ana Rodríguez)
    'admin'      -- p_usuario_auditoria
);

-- Prueba de funciones
SELECT '--- Probando funciones ---' AS info;

-- Calcular porcentaje de asistencia para estudiante 1 (Juan Pérez) en grupo 1 (Cálculo I)
-- Asistencias de Juan Pérez en grupo 1: 3 registros. 1 AUSENTE, 1 PRESENTE, 1 AUSENTE (que luego se justifica)
-- Después de la justificación, tendrá 2 asistencias efectivas (PRESENTE + JUSTIFICADO) de 3 posibles.
SELECT
    e.codigo_estudiante,
    CONCAT(p.nombre, ' ', p.apellido) AS estudiante,
    fn_calcular_porcentaje_asistencia(1, 1) AS porcentaje_asistencia,
    'Se espera 66.67% (2 de 3 asistencias consideradas)' AS observacion
FROM estudiante e
JOIN persona p ON e.id_persona = p.id_persona
WHERE e.id_estudiante = 1;

-- Calcular inasistencias para estudiante 1 (Juan Pérez) en el período 1 (2024-1)
-- El estudiante 1 tiene 2 AUSENTE, pero una se justificó. La otra asistencia AUSENTE es en la fecha 2024-06-19.
-- La justificación de id_asistencia=3 se aprueba con el SP.
-- Se espera 0 inasistencias porque las ausencias o se justificaron o no están en el período 1.
-- Vamos a modificar las asistencias para que una quede sin justificar.
-- Asistencia de Juan Pérez en grupo 1: (id_asistencia 1, fecha 2024-06-17, AUSENTE)
-- Asistencia de Juan Pérez en grupo 1: (id_asistencia 3, fecha 2024-06-19, AUSENTE)
-- La justificación ID 2 (para asistencia ID 3) fue APROBADA.
-- Entonces, la asistencia ID 1 (fecha 2024-06-17) debería ser la única AUSENTE no justificada.
SELECT
    e.codigo_estudiante,
    CONCAT(p.nombre, ' ', p.apellido) AS estudiante,
    fn_calcular_inasistencias_estudiante(1, 1) AS total_inasistencias,
    'Se espera 1 inasistencia (la de 2024-06-17 que es AUSENTE y no se justificó)' AS observacion
FROM estudiante e
JOIN persona p ON e.id_persona = p.id_persona
WHERE e.id_estudiante = 1;


-- Verificación final de registros de auditoría
SELECT '--- Registros de auditoría ---' AS info;
SELECT * FROM auditoria ORDER BY fecha DESC LIMIT 20;

-- Mostrar triggers existentes
SELECT '--- Triggers existentes ---' AS info;
SHOW TRIGGERS FROM gestion_academica;

-- =============================================
-- Finalizar script
-- =============================================
-- Habilitar el modo de actualización segura de nuevo
SET SQL_SAFE_UPDATES = 1;
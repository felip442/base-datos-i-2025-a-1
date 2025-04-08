-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS sistema_facturacion;
USE sistema_facturacion;

-- Tabla: persona
CREATE TABLE persona (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_nacimiento DATE,
    correo VARCHAR(100),
    direccion VARCHAR(100),
    telefono VARCHAR(20)
);

-- Tabla: cliente
CREATE TABLE cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20),
    fecha_vinculacion DATE,
    persona_id INT,
    FOREIGN KEY (persona_id) REFERENCES persona(id)
);

-- Tabla: empleado
CREATE TABLE empleado (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20),
    fecha_vinculacion DATE,
    salario DECIMAL(10, 2),
    tipo_contrato VARCHAR(50),
    persona_id INT,
    FOREIGN KEY (persona_id) REFERENCES persona(id)
);

-- Tabla: categoria
CREATE TABLE categoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion TEXT
);

-- Tabla: metodo_pago
CREATE TABLE metodo_pago (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion TEXT
);

-- Tabla: producto
CREATE TABLE producto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20),
    nombre VARCHAR(100),
    descripcion TEXT,
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES categoria(id)
);

-- Tabla: inventario
CREATE TABLE inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    fecha DATE,
    precio DECIMAL(10,2),
    stock INT,
    fecha_lote DATE,
    fecha_vencimiento DATE,
    producto_id INT,
    FOREIGN KEY (producto_id) REFERENCES producto(id)
);

-- Tabla: factura
CREATE TABLE factura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20),
    fecha DATE,
    valor_bruto DECIMAL(10,2),
    valor_descuento DECIMAL(10,2),
    valor_incremento DECIMAL(10,2),
    valor_neto DECIMAL(10,2),
    cliente_id INT,
    medio_pago_id INT,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id),
    FOREIGN KEY (medio_pago_id) REFERENCES metodo_pago(id)
);

-- Tabla: detalle_factura
CREATE TABLE detalle_factura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cantidad INT,
    porcentaje_descuento DECIMAL(5,2),
    porcentaje_incremento DECIMAL(5,2),
    subtotal DECIMAL(10,2),
    producto_id INT,
    factura_id INT,
    FOREIGN KEY (producto_id) REFERENCES producto(id),
    FOREIGN KEY (factura_id) REFERENCES factura(id)
);

-- -----------------------------
-- Insertar datos de ejemplo
-- -----------------------------

-- Personas
INSERT INTO persona (nombre, apellido, fecha_nacimiento, correo, direccion, telefono) VALUES
('Laura', 'Gómez', '1990-05-12', 'laura@gmail.com', 'Calle 123', '3216549870'),
('Carlos', 'Ramírez', '1985-08-20', 'carlos@gmail.com', 'Carrera 45', '3124567890');

-- Clientes
INSERT INTO cliente (codigo, fecha_vinculacion, persona_id) VALUES
('CL001', '2024-01-15', 1);

-- Empleados
INSERT INTO empleado (codigo, fecha_vinculacion, salario, tipo_contrato, persona_id) VALUES
('EMP001', '2023-12-01', 2500000.00, 'Término indefinido', 2);

-- Categorías
INSERT INTO categoria (nombre, descripcion) VALUES
('Electrónica', 'Productos electrónicos'),
('Ropa', 'Prendas de vestir');

-- Métodos de pago
INSERT INTO metodo_pago (nombre, descripcion) VALUES
('Efectivo', 'Pago en efectivo'),
('Tarjeta', 'Pago con tarjeta bancaria');

-- Productos
INSERT INTO producto (codigo, nombre, descripcion, categoria_id) VALUES
('PRD001', 'Celular XYZ', 'Teléfono inteligente gama media', 1),
('PRD002', 'Camiseta Blanca', 'Camiseta de algodón', 2);

-- Inventario
INSERT INTO inventario (nombre, fecha, precio, stock, fecha_lote, fecha_vencimiento, producto_id) VALUES
('Lote 001', '2024-03-01', 1200000.00, 10, '2024-03-01', '2025-03-01', 1),
('Lote 002', '2024-03-01', 25000.00, 50, '2024-03-01', '2024-09-01', 2);

-- Facturas
INSERT INTO factura (codigo, fecha, valor_bruto, valor_descuento, valor_incremento, valor_neto, cliente_id, medio_pago_id) VALUES
('F001', '2024-04-01', 1220000.00, 20000.00, 0.00, 1200000.00, 1, 1);

-- Detalles de factura
INSERT INTO detalle_factura (cantidad, porcentaje_descuento, porcentaje_incremento, subtotal, producto_id, factura_id) VALUES
(1, 1.00, 0.00, 1200000.00, 1, 1);
select * from 
-- Ver personas registradas
SELECT * FROM persona;

-- Ver clientes
SELECT * FROM cliente;

-- Ver empleados
SELECT * FROM empleado;

-- Ver categorías de productos
SELECT * FROM categoria;

-- Ver métodos de pago
SELECT * FROM metodo_pago;

-- Ver productos
SELECT * FROM producto;

-- Ver inventario
SELECT * FROM inventario;

-- Ver facturas
SELECT * FROM factura;

-- Ver detalles de factura
SELECT * FROM detalle_factura;
CREATE TABLE IF NOT EXISTS persona (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_nacimiento DATE,
    correo VARCHAR(100),
    direccion VARCHAR(100),
    telefono VARCHAR(20)
);
INSERT INTO empleado (codigo, fecha_vinculacion, salario, tipo_contrato, persona_id) VALUES
('EMP001', '2023-01-10', 3500000.00, 'Indefinido', 2),
('EMP002', '2022-07-05', 2800000.00, 'Fijo', 3);



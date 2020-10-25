USE GD2C2020

--			MOTORES			--	
SELECT
   TIPO_MOTOR_CODIGO as tipo_motor,
   MODELO_POTENCIA as pot_motor,
   AUTO_NRO_MOTOR as nro_motor
INTO 
    Motores    
FROM    
    gd_esquema.Maestra

select * from Motores

ALTER TABLE Motores
ADD cod_motor bigint identity(1,1) PRIMARY KEY;

drop table Motores

create table Motores (
	--cod_motor bigint identity(1,1) PRIMARY KEY,
	nro_motor nvarchar(50) PRIMARY KEY,
	tipo_motor int,
	pot_motor int
);


--			AUTOS			--	

SELECT
   AUTO_NRO_CHASIS as num_chasis,
   TIPO_AUTO_CODIGO as cod_auto,
   TIPO_AUTO_DESC as desc_auto,
   AUTO_FECHA_ALTA as fecha_alta_auto,
   AUTO_CANT_KMS as kms_auto,
   AUTO_PATENTE as pat_auto,
   MODELO_CODIGO as cod_modelo
INTO 
    Autos
FROM    
    gd_esquema.Maestra
where
	AUTO_NRO_CHASIS is not null;

ALTER TABLE Autos
ADD PRIMARY KEY (num_chasis);

ALTER TABLE autos ADD CONSTRAINT fk_modelo FOREIGN KEY (cod_modelo) REFERENCES Modelos(cod_modelo);

ALTER TABLE Autos
ALTER COLUMN num_chasis nvarchar(50) not null;

drop table autos

select * from autos

ALTER TABLE autos
ADD id_auto bigint identity(1,1) PRIMARY KEY;

ALTER TABLE Modelos
DROP CONSTRAINT fk_auto;

select AUTO_NRO_CHASIS from gd_esquema.Maestra

create table Autos (
	num_chasis nvarchar(50) PRIMARY KEY not null,
	cod_auto decimal(18,0),
	desc_auto nvarchar(255),
	fecha_alta_auto datetime2(3),
	kms_auto decimal(18,0),
	pat_auto nvarchar(50),
	cod_modelo decimal(18,0) FOREIGN KEY REFERENCES Modelos(cod_modelo)
);

CREATE PROCEDURE CargarTablaAutos
AS
BEGIN
SET	NOCOUNT ON;
	INSERT INTO Autos(num_chasis, cod_auto, desc_auto, fecha_alta_auto,kms_auto,pat_auto)
	VALUES( 
	(SELECT AUTO_NRO_CHASIS 
		FROM gd_esquema.Maestra),
	(SELECT TIPO_AUTO_CODIGO
		FROM gd_esquema.Maestra),
	(SELECT TIPO_AUTO_DESC
		FROM gd_esquema.Maestra),
	(SELECT AUTO_FECHA_ALTA 
		FROM gd_esquema.Maestra),
	(SELECT AUTO_CANT_KMS
		FROM gd_esquema.Maestra),
	(SELECT AUTO_PATENTE
		FROM gd_esquema.Maestra)
	)
END

select * from autos

EXEC CargarTablaAutos

--			MODELOS			--	

SELECT
   MODELO_NOMBRE as nom_modelo,
   FABRICANTE_NOMBRE as fabr_modelo,
    as 

INTO 
    Modelos
FROM    
    gd_esquema.Maestra

select * from modelos

drop table modelos

ALTER TABLE modelos ADD id_auto bigint;
ALTER TABLE modelos ADD CONSTRAINT fk_auto FOREIGN KEY (id_auto) REFERENCES Autos(id_auto);

ALTER TABLE modelos
ADD id_motor bigint;


create table Modelos (
	cod_modelo decimal(18,0) PRIMARY KEY,
	nom_modelo nvarchar(255),
	fabricante_modelo nvarchar(255),
	cod_caja decimal(18,0),
	cod_motor bigint FOREIGN KEY REFERENCES Motores(cod_motor) 
);
--FALTA AGREGAR FOREIGN KEY EN cod_caja--

--			AUTOPARTES			--	
select AUTO_PARTE_CODIGO from gd_esquema.Maestra

create table Autopartes (
	cod_autoparte decimal(18,0) PRIMARY KEY,
	desc_autoparte nvarchar(255),
	precio_autoparte decimal,
	cod_modelo decimal FOREIGN KEY REFERENCES Modelos(cod_modelo) 
);


--			CAJAS DE CAMBIO			--	

create table Cajas_de_cambio(
	cod_caja decimal(18,0) PRIMARY KEY,
	cod_transmision decimal(18,0),
	desc_transmision nvarchar(255),
	desc_caja nvarchar(255),
	cant_cambios bigint
);

-- DE DONDE SALIO CANT CAMBIOS? cod_caja not null? --


--			COMPRAS			--

CREATE TABLE Compras(
	nro_compra decimal(18,0) PRIMARY KEY NOT NULL,
	cod_suc bigint FOREIGN KEY REFERENCES Sucursales(cod_suc)
)

/*
INSERT INTO Compras
SELECT COMPRA_NRO AS nro_compra
FROM gd_esquema.Maestra
*/

CREATE TABLE Compras_Auto(
	fecha_compra_auto datetime2(3),
	precio_compra_auto decimal(18,2),
	num_chasis nvarchar(50) FOREIGN KEY REFERENCES Autos(num_chasis)
)

CREATE TABLE Compras_Autoparte(
	cant_compra_parte decimal(18,0),
	cod_autoparte decimal(18,0) FOREIGN KEY REFERENCES Autopartes(cod_autoparte) 
)


--			SUCURSALES			--

CREATE TABLE Sucursales(
	cod_suc bigint identity(1,1) PRIMARY KEY NOT NULL,
	mail_suc nvarchar(255),
	tel_suc decimal(18,0),
	ciu_suc nvarchar(255),
	dir_suc nvarchar(255)
)

DROP TABLE Sucursales

ALTER PROCEDURE CargarTablaSucursales
AS
BEGIN
	INSERT INTO Sucursales(mail_suc, tel_suc, ciu_suc, dir_suc)
	VALUES( 
	(SELECT SUCURSAL_MAIL 
		FROM gd_esquema.Maestra 
		WHERE SUCURSAL_MAIL = 'Sucursal N°8@gmail.com'
		AND SUCURSAL_TELEFONO = 84061310
		AND SUCURSAL_CIUDAD = 'Los Polvorines'
		AND SUCURSAL_DIRECCION = 'Lavalle9510'
		AND CLIENTE_DNI = 62177881),
	(SELECT SUCURSAL_TELEFONO 
		FROM gd_esquema.Maestra 
		WHERE SUCURSAL_MAIL = 'Sucursal N°8@gmail.com'
		AND SUCURSAL_TELEFONO = 84061310
		AND SUCURSAL_CIUDAD = 'Los Polvorines'
		AND SUCURSAL_DIRECCION = 'Lavalle9510'
		AND CLIENTE_DNI = 62177881),
	(SELECT SUCURSAL_CIUDAD 
		FROM gd_esquema.Maestra 
		WHERE SUCURSAL_MAIL = 'Sucursal N°8@gmail.com'
		AND SUCURSAL_TELEFONO = 84061310
		AND SUCURSAL_CIUDAD = 'Los Polvorines'
		AND SUCURSAL_DIRECCION = 'Lavalle9510'
		AND CLIENTE_DNI = 62177881),
	(SELECT SUCURSAL_DIRECCION 
		FROM gd_esquema.Maestra 
		WHERE SUCURSAL_MAIL = 'Sucursal N°8@gmail.com'
		AND SUCURSAL_TELEFONO = 84061310
		AND SUCURSAL_CIUDAD = 'Los Polvorines'
		AND SUCURSAL_DIRECCION = 'Lavalle9510'
		AND CLIENTE_DNI = 62177881)
	)
END

EXEC CargarTablaSucursales

SELECT * FROM Sucursales

SELECT * 
FROM gd_esquema.Maestra
WHERE SUCURSAL_MAIL = 'Sucursal N°8@gmail.com'
		AND SUCURSAL_TELEFONO = 84061310
		AND SUCURSAL_CIUDAD = 'Los Polvorines'
		AND SUCURSAL_DIRECCION = 'Lavalle9510'
		AND CLIENTE_DNI = 62177881














---------------------------





--		SUCURSAL		--

CREATE PROCEDURE CrearSucursales
AS
BEGIN
SET	NOCOUNT ON;
CREATE TABLE Sucursales(
	cod_suc bigint identity(1,1) PRIMARY KEY NOT NULL,
	mail_suc nvarchar(255),
	tel_suc decimal(18,0),
	ciu_suc nvarchar(255),
	dir_suc nvarchar(255)
)
END

CREATE PROCEDURE CargarSucursales
AS
BEGIN
INSERT INTO Sucursales (mail_suc, tel_suc, ciu_suc, dir_suc)
SELECT SUCURSAL_MAIL, SUCURSAL_TELEFONO, SUCURSAL_CIUDAD, SUCURSAL_DIRECCION
FROM gd_esquema.Maestra
WHERE SUCURSAL_MAIL is not null
GROUP BY SUCURSAL_MAIL, SUCURSAL_TELEFONO, SUCURSAL_CIUDAD, SUCURSAL_DIRECCION
END

CREATE PROCEDURE ProcedimientoSucursales
AS
BEGIN
EXEC CrearSucursales
EXEC CargarSucursales
END

EXEC ProcedimientoSucursales

select * from sucursales

drop table sucursales




--		CLIENTES		--

CREATE TABLE Clientes(
	cod_clie bigint identity(1,1) PRIMARY KEY NOT NULL,
	nom_clie nvarchar(255),
	ape_clie nvarchar(255),
	dir_clie nvarchar(255),
	nac_clie datetime2(3),
	mail_clie nvarchar(255),
	dni_clie decimal(18,0),
)


INSERT INTO Clientes (nom_clie, ape_clie, dir_clie, nac_clie, mail_clie, dni_clie)
SELECT CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_DNI
FROM gd_esquema.Maestra
WHERE CLIENTE_DNI is not null and
FAC_CLIENTE_DNI is not null
GROUP BY CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_DNI

select * from clientes

drop table clientes

CREATE PROCEDURE CrearClientes
AS
BEGIN
SET	NOCOUNT ON;
CREATE TABLE Clientes(
	cod_clie bigint identity(1,1) PRIMARY KEY NOT NULL,
	nom_clie nvarchar(255),
	ape_clie nvarchar(255),
	dir_clie nvarchar(255),
	nac_clie datetime2(3),
	mail_clie nvarchar(255),
	dni_clie decimal(18,0),
)
END

drop procedure CargarClientes

CREATE PROCEDURE CargarClientes
AS
BEGIN
INSERT INTO Clientes (nom_clie, ape_clie, dir_clie, nac_clie, mail_clie, dni_clie)
SELECT CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_DNI
FROM gd_esquema.Maestra
WHERE CLIENTE_DNI is not null and
FAC_CLIENTE_DNI is not null
GROUP BY CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_DNI
END

CREATE PROCEDURE ProcedimientoClientes
AS
BEGIN
EXEC CrearClientes
EXEC CargarClientes
END

EXEC ProcedimientoClientes


select * from clientes


--		FACTURAS		--

CREATE PROCEDURE CrearFacturas
AS
BEGIN
SET	NOCOUNT ON;
CREATE TABLE Facturas(
	cod_fac bigint identity(1,1) PRIMARY KEY NOT NULL,
	nro_fac decimal(18,0),
	precio_fac decimal(18,2),
	fecha_fac datetime2(3),
	fecha_clie_fac datetime2(3),
	cod_clie bigint,
	cod_suc bigint
)
END

CREATE PROCEDURE CargarFacturas
AS
BEGIN
SET	NOCOUNT ON;
INSERT INTO Facturas (nro_fac, precio_fac, fecha_fac, fecha_clie_fac, cod_clie, cod_suc)
SELECT M.FACTURA_NRO, M.PRECIO_FACTURADO, M.FACTURA_FECHA, M.FAC_CLIENTE_FECHA_NAC, C.cod_clie, S.cod_suc
FROM gd_esquema.Maestra M
LEFT JOIN Clientes C on 
C.nom_clie = M.CLIENTE_NOMBRE and
C.ape_clie = M.CLIENTE_APELLIDO
LEFT JOIN Sucursales S on S.mail_suc = M.FAC_SUCURSAL_MAIL
WHERE M.FACTURA_NRO is not null and 
M.PRECIO_FACTURADO is not null and
M.FACTURA_FECHA is not null and
M.CLIENTE_NOMBRE is not null and
M.FAC_CLIENTE_FECHA_NAC is not null
GROUP BY M.FACTURA_NRO, M.PRECIO_FACTURADO, M.FACTURA_FECHA, M.FAC_CLIENTE_FECHA_NAC, C.cod_clie, S.cod_suc
END

CREATE PROCEDURE ProcedimientoFactura
AS
BEGIN
SET NOCOUNT ON;
EXEC CrearFacturas
EXEC CargarFacturas
END

exec ProcedimientoFactura

select * from facturas

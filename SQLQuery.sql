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
	cod_motor bigint identity(1,1) PRIMARY KEY,
	tipo_motor int,
	pot_motor int,
	nro_motor nvarchar(50)
);


--			AUTOS			--	

SELECT
   AUTO_NRO_CHASIS as num_chasis,
   TIPO_AUTO_CODIGO as cod_auto,
   TIPO_AUTO_DESC as desc_auto,
   AUTO_FECHA_ALTA as fecha_alta_auto,
   AUTO_CANT_KMS as kms_auto,
   AUTO_PATENTE as pat_auto
INTO 
    Autos
FROM    
    gd_esquema.Maestra
where
	AUTO_NRO_CHASIS is not null;

ALTER TABLE Autos
ADD PRIMARY KEY (num_chasis);

ALTER TABLE Autos
ALTER COLUMN num_chasis nvarchar(50) not null;

drop table autos

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

--			MODELOS			--	

SELECT
   MODELO_NOMBRE as nom_modelo,
   FABRICANTE_NOMBRE as fabr_modelo,
   AUTO_NRO_CHASIS as prueba
INTO 
    Modelos
FROM    
    gd_esquema.Maestra

select * from motores

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
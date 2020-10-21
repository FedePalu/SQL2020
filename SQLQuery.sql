use GD2C2020

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

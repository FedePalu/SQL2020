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


--			MODELOS			--	

SELECT
   MODELO_NOMBRE as nom_modelo,
   FABRICANTE_NOMBRE as fabr_modelo,
   AUTO_NRO_CHASIS as prueba
INTO 
    Modelos
FROM    
    gd_esquema.Maestra

select * from autos

drop table modelos

ALTER TABLE modelos ADD id_auto bigint;
ALTER TABLE modelos ADD CONSTRAINT fk_auto FOREIGN KEY (id_auto) REFERENCES Autos(id_auto);

ALTER TABLE modelos
ADD id_motor bigint;
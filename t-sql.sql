USE [GD2C2020]
GO

/**
## INTEGRANTES ##
	
	- Federico Palumbo			1674640		K3671

	- Ignacio Garay				1680900		K3572		
	
	- Walter Barreiro			1674456		K3521		

**/


--------------------------------------
--			DIMENSION AUTOS			--
--------------------------------------


CREATE PROCEDURE [ESECUELE].CrearAutosBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_AUTO(
		cod_auto bigint PRIMARY KEY,
		tipo_auto decimal(18,0),
		tipo_caja decimal(18,0),
		cant_cambios bigint,
		tipo_motor decimal(18,0),
		cod_transmision decimal(18,0),
		cod_modelo decimal(18,0),
		pot_motor nvarchar(255) --VER
	)

END

ALTER PROCEDURE [ESECUELE].AgregarKeyDimAuto
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_AUTO ADD FOREIGN KEY (cod_auto) REFERENCES [ESECUELE].Autos(cod_auto)
END

GO


ALTER PROCEDURE [ESECUELE].CargarCajasBI --CAMBIAR NOMBRE
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_AUTO(tipo_auto, tipo_caja, cant_cambios, tipo_motor, cod_transmision, cod_modelo)
	SELECT A.tipo_auto, C.tipo_caja, C.cant_cambios, MOT.tipo_motor, C.cod_transmision, A.cod_modelo
	FROM [ESECUELE].Autos A
	INNER JOIN [ESECUELE].Modelos M ON
	A.cod_modelo = M.cod_modelo
	INNER JOIN [ESECUELE].Cajas_de_cambio C ON
	M.cod_caja = C.cod_caja
	INNER JOIN [ESECUELE].Motores MOT ON
	m.cod_motor = mot.cod_motor
	GROUP BY A.tipo_auto, C.tipo_caja, C.cant_cambios, MOT.tipo_motor, C.cod_transmision, A.cod_modelo
END
GO

DROP PROCEDURE [ESECUELE].CargarCajasBI
GO


ALTER PROCEDURE [ESECUELE].AtualizarPotenciaBI
AS
BEGIN
	DECLARE @potencia decimal(18,0)
	DECLARE @cod_auto bigint
	DECLARE cursor_autos CURSOR FOR (SELECT MOT.pot_motor, A.cod_auto FROM [ESECUELE].BI_DIM_AUTO A
									INNER JOIN [ESECUELE].Modelos MO ON
									A.cod_modelo = MO.cod_modelo
									INNER JOIN [ESECUELE].Motores MOT ON
									MO.cod_motor = MOT.cod_motor
									)

	OPEN cursor_autos
	FETCH NEXT FROM cursor_autos INTO @potencia ,@cod_auto
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF(@potencia >= 50 AND @potencia <= 150)
		BEGIN
			UPDATE [ESECUELE].BI_DIM_AUTO SET pot_motor = '50-150' WHERE cod_auto = @cod_auto
		END
		ELSE 
		IF (@potencia > 150 AND @potencia <= 300)
		BEGIN
			UPDATE [ESECUELE].BI_DIM_AUTO SET pot_motor = '151-300' WHERE cod_auto = @cod_auto
		END
		ELSE IF (@potencia > 300) 
		BEGIN
			UPDATE [ESECUELE].BI_DIM_AUTO SET pot_motor = '>300' WHERE cod_auto = @cod_auto
		END
		ELSE 
		BEGIN
			DELETE FROM [ESECUELE].BI_DIM_AUTO WHERE pot_motor = @potencia	
		END
		FETCH NEXT FROM cursor_autos INTO @potencia, @cod_auto
	END

	CLOSE cursor_autos
	DEALLOCATE cursor_autos
	
	--ALTER TABLE [ESECUELE].BI_DIM_AUTO group by *

END
GO

DROP TABLE [ESECUELE].BI_DIM_AUTO

EXEC [ESECUELE].CrearAutosBI

EXEC [ESECUELE].AgregarKeyDimAuto

EXEC [ESECUELE].CargarCajasBI

select * from [ESECUELE].BI_DIM_AUTO 

EXEC [ESECUELE].AtualizarPotenciaBI


--------------------------------------
--	   DIMENSION CLIENTES AUTO		--
--------------------------------------


ALTER PROCEDURE [ESECUELE].CrearClientesAutoBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_CLIE_AUTO(
		cod_clie  BIGINT PRIMARY KEY,
		clie_edad nvarchar(255),
		clie_sexo nvarchar(255)
	)

END


ALTER PROCEDURE [ESECUELE].AgregarKeyDimClieAuto
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_CLIE_AUTO ADD FOREIGN KEY (cod_clie) REFERENCES [ESECUELE].Clientes(cod_clie)
END

GO

ALTER PROCEDURE [ESECUELE].CargarClientesAutoBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE_AUTO(cod_clie)
	SELECT C.cod_clie 
	FROM [ESECUELE].FacturasAuto FA
	INNER JOIN Facturas F ON
	FA.cod_fac_auto = F.cod_fac
	JOIN Clientes C ON
	F.cod_clie = C.cod_clie
	GROUP BY C.cod_clie
END
GO


DROP TABLE [ESECUELE].BI_DIM_CLIE_AUTO

EXEC [ESECUELE].CrearClientesAutoBI

EXEC [ESECUELE].AgregarKeyDimClieAuto

EXEC [ESECUELE].CargarClientesAutoBI

select * from [ESECUELE].BI_DIM_CLIE_AUTO 

EXEC [ESECUELE].AtualizarClientesAutoBI



ALTER PROCEDURE [ESECUELE].AtualizarClientesAutoBI
AS
BEGIN
	DECLARE @cod_clie bigint
	DECLARE @edad BIGINT
	DECLARE cursor_clientes CURSOR FOR (SELECT A.cod_clie, YEAR(GETDATE()) - YEAR(C.nac_clie)  FROM [ESECUELE].BI_DIM_CLIE_AUTO A
									INNER JOIN [ESECUELE].Clientes C ON
									A.cod_clie = C.cod_clie
									)

	

	OPEN cursor_clientes
	FETCH NEXT FROM cursor_clientes INTO @cod_clie ,@edad
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF(@edad >= 18 AND @edad <= 30)
		BEGIN
			UPDATE [ESECUELE].BI_DIM_CLIE_AUTO SET clie_edad = '18-30' WHERE cod_clie = @cod_clie
		END
		ELSE 
		IF (@edad > 30 AND @edad <= 50)
		BEGIN
			UPDATE [ESECUELE].BI_DIM_CLIE_AUTO SET clie_edad = '31-50' WHERE cod_clie = @cod_clie
		END
		ELSE IF (@edad > 50) 
		BEGIN
			UPDATE [ESECUELE].BI_DIM_CLIE_AUTO SET clie_edad = '>50' WHERE cod_clie = @cod_clie
		END
		--ELSE 
		--BEGIN
			--DELETE FROM [ESECUELE].BI_DIM_CLIE WHERE cod_clie = @cod_clie	
		--END

		FETCH NEXT FROM cursor_clientes INTO @cod_clie, @edad
	END

	CLOSE cursor_clientes
	DEALLOCATE cursor_clientes
	
END
GO




----------------------------------
--	   DIMENSION MODELOS		--
----------------------------------

select * from [ESECUELE].Modelos

ALTER PROCEDURE [ESECUELE].CrearModeloBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_MODELO(
		cod_mod  decimal(18,0) PRIMARY KEY,
		fabricante_mod nvarchar(255),
		nom_modelo nvarchar(255)
	)

END


ALTER PROCEDURE [ESECUELE].AgregarKeyDimModelo
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_MODELO ADD FOREIGN KEY (cod_mod) REFERENCES [ESECUELE].Modelos(cod_modelo)
END

GO

alter PROCEDURE [ESECUELE].CargarModeloBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_MODELO(cod_mod, fabricante_mod, nom_modelo)
	SELECT M.cod_modelo, M.fabricante_modelo, m.nom_modelo
	FROM [ESECUELE].Modelos M
	GROUP BY M.cod_modelo, M.fabricante_modelo, m.nom_modelo
END
GO

DROP TABLE [ESECUELE].BI_DIM_MODELO

EXEC [ESECUELE].CrearModeloBI

EXEC [ESECUELE].AgregarKeyDimModelo

EXEC [ESECUELE].CargarModeloBI

select * from [ESECUELE].BI_DIM_MODELO 


----------------------------------
--	   DIMENSION SUCURSALES		--
----------------------------------


ALTER PROCEDURE [ESECUELE].CrearSucursalBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_SUCRUSAL(
		cod_suc bigint identity(1,1),
		mail_suc nvarchar(255),
		tel_suc decimal(18,0),
		ciu_suc nvarchar(255),
		dir_suc nvarchar(255)
	)

END

ALTER PROCEDURE [ESECUELE].AgregarKeyDimSucursal
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_SUCURSAL ADD FOREIGN KEY (cod_suc) REFERENCES [ESECUELE].Sucursales(cod_suc)
END

GO

CREATE PROCEDURE [ESECUELE].CargarSucursalBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_SUCURSAL(cod_suc, mail_suc, tel_suc, ciu_suc, dir_suc)
	SELECT S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc
	FROM [ESECUELE].Sucursales S
	GROUP BY S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc
END

DROP TABLE [ESECUELE].BI_DIM_SUCURSAL

EXEC [ESECUELE].CrearSucursalBI

EXEC [ESECUELE].AgregarKeyDimSucursal

EXEC [ESECUELE].CargarSucursalBI

select * from [ESECUELE].BI_DIM_SUCURSAL 
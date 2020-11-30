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
		id_clie_auto bigint identity(1,1) PRIMARY KEY,
		cod_clie  BIGINT,
		clie_edad nvarchar(255),
		clie_sexo nvarchar(255),
		cod_auto bigint
	)

END


ALTER PROCEDURE [ESECUELE].AgregarKeyDimClieAuto
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_CLIE_AUTO ADD FOREIGN KEY (cod_clie) REFERENCES [ESECUELE].Clientes(cod_clie)
	ALTER TABLE [ESECUELE].BI_DIM_CLIE_AUTO ADD FOREIGN KEY (cod_auto) REFERENCES [ESECUELE].Autos(cod_auto)
END

GO


CREATE PROCEDURE [ESECUELE].CargarClientesAutoJovenesBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE_AUTO(cod_clie, clie_edad, cod_auto)
	SELECT C.cod_clie, '18-30', A.cod_auto 
	FROM [ESECUELE].FacturasAuto FA
	INNER JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_auto = F.cod_fac
	JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	JOIN [ESECUELE].Autos A ON
	A.cod_auto = FA.cod_auto
	WHERE YEAR(GETDATE()) - YEAR(C.nac_clie)
	BETWEEN 18 AND 30
	GROUP BY C.cod_clie, A.cod_auto
END
GO

CREATE PROCEDURE [ESECUELE].CargarClientesAutoMedianosBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE_AUTO(cod_clie, clie_edad, cod_auto)
	SELECT C.cod_clie, '31-50', A.cod_auto 
	FROM [ESECUELE].FacturasAuto FA
	INNER JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_auto = F.cod_fac
	JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	JOIN [ESECUELE].Autos A ON
	A.cod_auto = FA.cod_auto
	WHERE YEAR(GETDATE()) - YEAR(C.nac_clie)
	BETWEEN 31 AND 50
	GROUP BY C.cod_clie, A.cod_auto
END
GO


CREATE PROCEDURE [ESECUELE].CargarClientesAutoViejosBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE_AUTO(cod_clie, clie_edad, cod_auto)
	SELECT C.cod_clie, '>50', A.cod_auto 
	FROM [ESECUELE].FacturasAuto FA
	INNER JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_auto = F.cod_fac
	JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	JOIN [ESECUELE].Autos A ON
	A.cod_auto = FA.cod_auto
	WHERE YEAR(GETDATE()) - YEAR(C.nac_clie) > 50
	GROUP BY C.cod_clie, A.cod_auto
END
GO


DROP TABLE [ESECUELE].BI_DIM_CLIE_AUTO

EXEC [ESECUELE].CrearClientesAutoBI

EXEC [ESECUELE].AgregarKeyDimClieAuto

EXEC [ESECUELE].CargarClientesAutoJovenesBI
go
EXEC [ESECUELE].CargarClientesAutoMedianosBI
go
EXEC [ESECUELE].CargarClientesAutoViejosBI
go

select * from [ESECUELE].BI_DIM_CLIE_AUTO 


--------------------------------------
--	 DIMENSION CLIENTES AUTOPARTE	--
--------------------------------------


alter PROCEDURE [ESECUELE].CrearClientesAutoparteBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_CLIE_AUTOPARTE(
		id_clie_autoparte bigint identity(1,1) PRIMARY KEY,
		cod_clie  BIGINT,
		clie_edad nvarchar(255),
		clie_sexo nvarchar(255),
		cod_autoparte decimal(18,0)
	)

END


alter PROCEDURE [ESECUELE].AgregarKeyDimClieAutoparte
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_CLIE_AUTOPARTE ADD FOREIGN KEY (cod_clie) REFERENCES [ESECUELE].Clientes(cod_clie)
	ALTER TABLE [ESECUELE].BI_DIM_CLIE_AUTOPARTE ADD FOREIGN KEY (cod_autoparte) REFERENCES [ESECUELE].Autopartes(cod_autoparte)
END

GO


CREATE PROCEDURE [ESECUELE].CargarClientesAutoparteJovenesBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE_AUTOPARTE(cod_clie, clie_edad, cod_autoparte)
	SELECT C.cod_clie, '18-30', FA.cod_autoparte
	FROM [ESECUELE].FacturasAutoparte FA
	INNER JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_autoparte = F.cod_fac
	inner JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	WHERE YEAR(GETDATE()) - YEAR(C.nac_clie)
	BETWEEN 18 AND 30
	GROUP BY C.cod_clie, FA.cod_autoparte
END
GO

CREATE PROCEDURE [ESECUELE].CargarClientesAutoparteMedianosBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE_AUTOPARTE(cod_clie, clie_edad, cod_autoparte)
	SELECT C.cod_clie, '31-50', FA.cod_autoparte
	FROM [ESECUELE].FacturasAutoparte FA
	INNER JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_autoparte = F.cod_fac
	inner JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	WHERE YEAR(GETDATE()) - YEAR(C.nac_clie)
	BETWEEN 31 AND 50
	GROUP BY C.cod_clie, FA.cod_autoparte
END
GO


CREATE PROCEDURE [ESECUELE].CargarClientesAutoparteViejosBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE_AUTOPARTE(cod_clie, clie_edad, cod_autoparte)
	SELECT C.cod_clie, '>50', FA.cod_autoparte
	FROM [ESECUELE].FacturasAutoparte FA
	INNER JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_autoparte = F.cod_fac
	inner JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	WHERE YEAR(GETDATE()) - YEAR(C.nac_clie) > 50
	GROUP BY C.cod_clie, FA.cod_autoparte
END
GO




DROP TABLE [ESECUELE].BI_DIM_CLIE_AUTOPARTE

EXEC [ESECUELE].CrearClientesAutoparteBI

EXEC [ESECUELE].AgregarKeyDimClieAutoparte

exec [ESECUELE].CargarClientesAutoparteJovenesBI
go
exec [ESECUELE].CargarClientesAutoparteMedianosBI
go
exec [ESECUELE].CargarClientesAutoparteViejosBI
go

select * from [ESECUELE].BI_DIM_CLIE_AUTOPARTE





----------------------------------
--	   DIMENSION MODELOSX		--
----------------------------------


ALTER PROCEDURE [ESECUELE].CrearModeloBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_MODELO(
		id_modelo bigint identity(1,1) PRIMARY KEY,
		cod_mod  decimal(18,0),
		fabricante_mod nvarchar(255),
		nom_modelo nvarchar(255),
		cod_autoparte decimal(18,0),
		cod_auto bigint
	)

END


ALTER PROCEDURE [ESECUELE].AgregarKeyDimModelo
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_MODELO ADD FOREIGN KEY (cod_mod) REFERENCES [ESECUELE].Modelos(cod_modelo)
	ALTER TABLE [ESECUELE].BI_DIM_MODELO ADD FOREIGN KEY (cod_auto) REFERENCES [ESECUELE].Autos(cod_auto)
	ALTER TABLE [ESECUELE].BI_DIM_MODELO ADD FOREIGN KEY (cod_autoparte) REFERENCES [ESECUELE].Autopartes(cod_autoparte)
END

GO


ALTER PROCEDURE [ESECUELE].CargarModeloAutoparteBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_MODELO(cod_mod, fabricante_mod, nom_modelo, cod_autoparte)
	SELECT M.cod_modelo, M.fabricante_modelo, m.nom_modelo, A.cod_autoparte
	FROM [ESECUELE].Modelos M
	JOIN [ESECUELE].Autopartes A ON
	A.cod_modelo = M.cod_modelo
	GROUP BY M.cod_modelo, M.fabricante_modelo, m.nom_modelo, A.cod_autoparte
END
GO

CREATE PROCEDURE [ESECUELE].CargarModeloAutoBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_MODELO(cod_mod, fabricante_mod, nom_modelo, cod_auto)
	SELECT M.cod_modelo, M.fabricante_modelo, m.nom_modelo, A.cod_auto
	FROM [ESECUELE].Modelos M
	JOIN [ESECUELE].Autos A ON
	A.cod_modelo = M.cod_modelo
	GROUP BY M.cod_modelo, M.fabricante_modelo, m.nom_modelo, A.cod_auto
END
GO


DROP TABLE [ESECUELE].BI_DIM_MODELO

EXEC [ESECUELE].CrearModeloBI

EXEC [ESECUELE].AgregarKeyDimModelo

EXEC [ESECUELE].CargarModeloAutoparteBI

EXEC [ESECUELE].CargarModeloAutoBI

select * from [ESECUELE].BI_DIM_MODELO 


----------------------------------
--	DIMENSION SUCURSALX AUTOS	--
----------------------------------


ALTER PROCEDURE [ESECUELE].CrearSucursalAutoBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_SUCURSAL_AUTO(
		id_suc BIGINT IDENTITY(1,1) PRIMARY KEY,
		cod_suc bigint,
		mail_suc nvarchar(255),
		tel_suc decimal(18,0),
		ciu_suc nvarchar(255),
		dir_suc nvarchar(255),
		cod_auto bigint
	)
END
GO

CREATE PROCEDURE [ESECUELE].CargarSucursalAutoVentaBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_SUCURSAL_AUTO(cod_suc, mail_suc, tel_suc, ciu_suc, dir_suc, cod_auto)
	SELECT S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc, FA.cod_auto
	FROM [ESECUELE].Sucursales S
	JOIN [ESECUELE].Facturas F ON
	F.cod_suc = S.cod_suc
	JOIN [ESECUELE].FacturasAuto FA ON
	FA.cod_fac_auto = F.cod_fac
	GROUP BY S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc, FA.cod_auto
END
GO

CREATE PROCEDURE [ESECUELE].CargarSucursalAutoCompraBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_SUCURSAL_AUTO(cod_suc, mail_suc, tel_suc, ciu_suc, dir_suc, cod_auto)
	SELECT S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc, CA.cod_auto
	FROM [ESECUELE].Sucursales S
	JOIN [ESECUELE].Compras C ON
	C.cod_suc = S.cod_suc
	JOIN [ESECUELE].ComprasAuto CA ON
	CA.cod_compra_auto = C.cod_compra
	GROUP BY S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc, CA.cod_auto
END
GO

CREATE PROCEDURE [ESECUELE].AgregarKeyDimSucursalAuto
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_SUCURSAL_AUTO ADD FOREIGN KEY (cod_suc) REFERENCES [ESECUELE].Sucursales(cod_suc)
	ALTER TABLE [ESECUELE].BI_DIM_SUCURSAL_AUTO ADD FOREIGN KEY (cod_auto) REFERENCES [ESECUELE].Autos(cod_auto)
END

GO



DROP TABLE [ESECUELE].BI_DIM_SUCURSAL_AUTO

EXEC [ESECUELE].CrearSucursalAutoBI

EXEC [ESECUELE].AgregarKeyDimSucursalAuto

EXEC [ESECUELE].CargarSucursalAutoVentaBI
go
EXEC [ESECUELE].CargarSucursalAutoCompraBI
go

select * from [ESECUELE].BI_DIM_SUCURSAL_AUTO 



----------------------------------
--DIMENSION SUCURSALX AUTOPARTE	--
----------------------------------


CREATE PROCEDURE [ESECUELE].CrearSucursalAutoparteBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE(
		id_suc BIGINT IDENTITY(1,1) PRIMARY KEY,
		cod_suc bigint,
		mail_suc nvarchar(255),
		tel_suc decimal(18,0),
		ciu_suc nvarchar(255),
		dir_suc nvarchar(255),
		cod_autoparte decimal(18,0)
	)
END
GO

CREATE PROCEDURE [ESECUELE].CargarSucursalAutoparteVentaBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE(cod_suc, mail_suc, tel_suc, ciu_suc, dir_suc, cod_autoparte)
	SELECT S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc, FA.cod_autoparte
	FROM [ESECUELE].Sucursales S
	JOIN [ESECUELE].Facturas F ON
	F.cod_suc = S.cod_suc
	JOIN [ESECUELE].FacturasAutoparte FA ON
	FA.cod_fac_autoparte = F.cod_fac
	GROUP BY S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc, FA.cod_autoparte
END
GO

CREATE PROCEDURE [ESECUELE].CargarSucursalAutoparteCompraBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE(cod_suc, mail_suc, tel_suc, ciu_suc, dir_suc, cod_autoparte)
	SELECT S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc, CA.cod_autoparte
	FROM [ESECUELE].Sucursales S
	JOIN [ESECUELE].Compras C ON
	C.cod_suc = S.cod_suc
	JOIN [ESECUELE].ComprasAutoparte CA ON
	CA.cod_compra_autoparte = C.cod_compra
	GROUP BY S.cod_suc, S.mail_suc, S.tel_suc, S.ciu_suc, S.dir_suc, CA.cod_autoparte
END
GO

ALTER PROCEDURE [ESECUELE].AgregarKeyDimSucursalAutoparte
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE ADD FOREIGN KEY (cod_suc) REFERENCES [ESECUELE].Sucursales(cod_suc)
	ALTER TABLE [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE ADD FOREIGN KEY (cod_autoparte) REFERENCES [ESECUELE].Autopartes(cod_autoparte)
END

GO



DROP TABLE [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE

EXEC [ESECUELE].CrearSucursalAutoparteBI

EXEC [ESECUELE].AgregarKeyDimSucursalAutoparte

EXEC [ESECUELE].CargarSucursalAutoparteVentaBI
go
EXEC [ESECUELE].CargarSucursalAutoparteCompraBI
go

select * from [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE 



----------------------------------
--			TIEMPO AUTO			--
----------------------------------


ALTER PROCEDURE [ESECUELE].CrearTiempoAutoBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_TIEMPO_AUTO(
		id_tiempo bigint identity(1,1) PRIMARY KEY,
		discriminador nvarchar(255),
		anio bigint,
		mes bigint,
		cod_auto bigint
	)

END
GO

ALTER PROCEDURE [ESECUELE].CargarTiempoAutoBI1
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_TIEMPO_AUTO(discriminador, anio , mes, cod_auto)
	SELECT 'C', YEAR(CA.fecha_compra_auto), MONTH(ca.fecha_compra_auto), CA.cod_auto
	FROM [ESECUELE].ComprasAuto CA
	GROUP BY YEAR(CA.fecha_compra_auto), MONTH(ca.fecha_compra_auto), CA.cod_auto
END
GO

ALTER PROCEDURE [ESECUELE].CargarTiempoAutoBI2
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_TIEMPO_AUTO(discriminador, anio , mes, cod_auto)
	SELECT 'V', YEAR(F.fecha_fac), MONTH(F.fecha_fac), FA.cod_auto
	FROM [ESECUELE].FacturasAuto FA 
	JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_auto = F.cod_fac
	GROUP BY YEAR(F.fecha_fac), MONTH(F.fecha_fac), FA.cod_auto
END
GO

DROP TABLE [ESECUELE].BI_DIM_TIEMPO_AUTO

EXEC [ESECUELE].CrearTiempoAutoBI

EXEC [ESECUELE].CargarTiempoAutoBI1

EXEC [ESECUELE].CargarTiempoAutoBI2

SELECT * FROM [ESECUELE].BI_DIM_TIEMPO_AUTO


----------------------------------
--		TIEMPO AUTOPARTEX		--
----------------------------------

ALTER PROCEDURE [ESECUELE].CrearTiempoAutoparteBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_TIEMPO_AUTOPARTE(
		id_tiempo bigint identity(1,1) PRIMARY KEY,
		discriminador nvarchar(255),
		anio bigint,
		mes bigint,
		cod_autoparte decimal(18,0)
	)

END
GO

ALTER PROCEDURE [ESECUELE].CargarTiempoAutoparteBI1
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_TIEMPO_AUTOPARTE(discriminador, anio , mes, cod_autoparte)
	SELECT 'C', YEAR(CA.fecha_compra), MONTH(CA.fecha_compra), CA.cod_autoparte
	FROM [ESECUELE].ComprasAutoparte CA
	GROUP BY YEAR(CA.fecha_compra), MONTH(ca.fecha_compra), CA.cod_autoparte
END
GO

ALTER PROCEDURE [ESECUELE].CargarTiempoAutoparteBI2
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_TIEMPO_AUTOPARTE(discriminador, anio , mes, cod_autoparte)
	SELECT 'V', YEAR(F.fecha_fac), MONTH(F.fecha_fac), FA.cod_autoparte
	FROM [ESECUELE].FacturasAutoparte FA 
	JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_autoparte = F.cod_fac
	GROUP BY YEAR(F.fecha_fac), MONTH(F.fecha_fac), FA.cod_autoparte
END
GO

DROP TABLE [ESECUELE].BI_DIM_TIEMPO_AUTOPARTE

EXEC [ESECUELE].CrearTiempoAutoparteBI

EXEC [ESECUELE].CargarTiempoAutoparteBI1

EXEC [ESECUELE].CargarTiempoAutoparteBI2

SELECT * FROM [ESECUELE].BI_DIM_TIEMPO_AUTOPARTE


----------------------------------
--			AUTOPARTEX			--
----------------------------------


CREATE PROCEDURE [ESECUELE].CrearAutoparteBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_AUTOPARTE(
		id_autoparte bigint identity(1,1) PRIMARY KEY,
		cod_autoparte decimal(18,0),
		desc_autoparte nvarchar(255),
		precio_venta_autoparte decimal(18,2)
	)

END
GO

CREATE PROCEDURE [ESECUELE].AgregarKeyDimAutoparte
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_AUTOPARTE ADD FOREIGN KEY (cod_autoparte) REFERENCES [ESECUELE].Autopartes(cod_autoparte)
END

GO


CREATE PROCEDURE [ESECUELE].CargarAutoparteBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_AUTOPARTE(cod_autoparte, desc_autoparte, precio_venta_autoparte)
	SELECT A.cod_autoparte, A.desc_autoparte, FA.PRECIO_UNITARIO
	FROM [ESECUELE].Autopartes A
	INNER JOIN [ESECUELE].FacturasAutoparte FA ON
	FA.cod_autoparte = A.cod_autoparte
	GROUP BY A.cod_autoparte, A.desc_autoparte, FA.PRECIO_UNITARIO
END
GO

EXEC [ESECUELE].CrearAutoparteBI

EXEC [ESECUELE].AgregarKeyDimAutoparte

EXEC [ESECUELE].CargarAutoparteBI

drop table [ESECUELE].BI_DIM_AUTOPARTE

SELECT * FROM [ESECUELE].BI_DIM_AUTOPARTE


----------------------------------
--			HECHOS AUTOX			--
----------------------------------

CREATE PROCEDURE [ESECUELE].CrearHechosAutoBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_AUTOPARTE(
		id_autoparte bigint identity(1,1) PRIMARY KEY,
		
	)

END
GO

CREATE PROCEDURE [ESECUELE].AgregarKeyHechosAuto
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_AUTOPARTE ADD FOREIGN KEY (cod_autoparte) REFERENCES [ESECUELE].Autopartes(cod_autoparte)
END

GO



----------------------------------
--		HECHOS AUTOPARTEX		--
----------------------------------

CREATE PROCEDURE [ESECUELE].CrearHechosAutoparteBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_HECHO_AUTOPARTE(
		id_autoparte bigint identity(1,1) PRIMARY KEY,
		cod_autoparte bigint,
		cod_clie_autoparte bigint,
		cod_modelo decimal(18,0),
		cod_suc bigint,
		cod_tiempo_autoparte bigint
		
	)

END
GO

CREATE PROCEDURE [ESECUELE].AgregarKeyHechosAutoparte
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_autoparte) REFERENCES [ESECUELE].BI_DIM_AUTOPARTE(id_autoparte)
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_clie_autoparte) REFERENCES [ESECUELE].BI_DIM_CLIE_AUTOPARTE(cod_clie) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_modelo) REFERENCES [ESECUELE].BI_DIM_MODELO_AUTOPARTE(id_modelo) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_suc) REFERENCES [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE(id_suc) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_tiempo_autoparte) REFERENCES [ESECUELE].DIM_TIEMPO_AUTOPARTE(id_tiempo) --
END

GO


CREATE PROCEDURE [ESECUELE].CargarHechoAutoparteBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_HECHO_AUTOPARTE(cod_autoparte, cod_clie_autoparte, cod_modelo, cod_suc, cod_tiempo_autoparte)
	SELECT A.cod_autoparte, CA.cod_clie, M.cod_mod, S.cod_suc, TA.id_tiempo
	FROM [ESECUELE].BI_DIM_AUTOPARTE A
	JOIN [ESECUELE].BI_DIM_CLIE_AUTOPARTE CA ON
	CA.cod_autoparte = A.cod_autoparte
	JOIN [ESECUELE].BI_DIM_MODELO M ON
	M.cod_autoparte = A.cod_autoparte
	JOIN [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE S ON
	S.cod_autoparte = A.cod_autoparte
	JOIN [ESECUELE].BI_DIM_TIEMPO_AUTOPARTE TA ON
	TA.cod_autoparte = A.cod_autoparte
	GROUP BY A.cod_autoparte, CA.cod_clie, M.cod_mod, S.cod_suc, TA.id_tiempo
END
GO

select * from [ESECUELE].BI_DIM_SUCURSAL_AUTOPARTE
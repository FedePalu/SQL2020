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

ALTER PROCEDURE [ESECUELE].CrearAutosBI
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
		pot_motor nvarchar(255) 
	)

END

/*
CRAETE PROCEDURE [ESECUELE].AgregarKeyDimAuto
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_AUTO ADD FOREIGN KEY (cod_auto) REFERENCES [ESECUELE].Autos(cod_auto)
END
GO
*/

select * from [ESECUELE].motores

ALTER PROCEDURE [ESECUELE].CargarAutosBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_AUTO(cod_auto ,tipo_auto, tipo_caja, cant_cambios, tipo_motor, cod_transmision, cod_modelo)
	SELECT A.cod_auto, A.tipo_auto, C.tipo_caja, C.cant_cambios, MOT.tipo_motor, C.cod_transmision, A.cod_modelo
	FROM [ESECUELE].Autos A
	INNER JOIN [ESECUELE].Modelos M ON
	A.cod_modelo = M.cod_modelo
	INNER JOIN [ESECUELE].Cajas_de_cambio C ON
	M.cod_caja = C.cod_caja
	INNER JOIN [ESECUELE].Motores MOT ON
	m.cod_motor = mot.cod_motor
	GROUP BY A.cod_auto, A.tipo_auto, C.tipo_caja, C.cant_cambios, MOT.tipo_motor, C.cod_transmision, A.cod_modelo
END
GO


CREATE PROCEDURE [ESECUELE].ActualizarPotenciaBI
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

END
GO

DROP TABLE [ESECUELE].BI_DIM_AUTO

EXEC [ESECUELE].CrearAutosBI

-- EXEC [ESECUELE].AgregarKeyDimAuto

EXEC [ESECUELE].CargarAutosBI

select * from [ESECUELE].BI_DIM_AUTO 

EXEC [ESECUELE].ActualizarPotenciaBI

--------------------------------------
--		DIMENSION CLIENTES			--
--------------------------------------


CREATE PROCEDURE [ESECUELE].CrearClientesBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_CLIE(
		cod_clie  BIGINT PRIMARY KEY,
		clie_edad nvarchar(255),
		clie_sexo nvarchar(255),
	)

END

/*
CREATE PROCEDURE [ESECUELE].AgregarKeyDimClieAuto
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_CLIE_AUTO ADD FOREIGN KEY (cod_clie) REFERENCES [ESECUELE].Clientes(cod_clie)
END
GO
*/

CREATE PROCEDURE [ESECUELE].CargarClientesJovenesBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE(cod_clie, clie_edad)
	SELECT C.cod_clie, '18-30'
	FROM [ESECUELE].Facturas F
	JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	WHERE YEAR(GETDATE()) - YEAR(C.nac_clie)
	BETWEEN 18 AND 30
	GROUP BY C.cod_clie
END
GO

CREATE PROCEDURE [ESECUELE].CargarClientesMedianosBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE(cod_clie, clie_edad)
	SELECT C.cod_clie, '31-50'
	FROM [ESECUELE].Facturas F
	JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	WHERE YEAR(GETDATE()) - YEAR(C.nac_clie)
	BETWEEN 31 AND 50
	GROUP BY C.cod_clie
END
GO


ALTER PROCEDURE [ESECUELE].CargarClientesViejosBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_CLIE(cod_clie, clie_edad)
	SELECT C.cod_clie, '>50'
	FROM [ESECUELE].Facturas F
	JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	WHERE YEAR(GETDATE()) - YEAR(C.nac_clie) > 50
	GROUP BY C.cod_clie
END
GO


DROP TABLE [ESECUELE].BI_DIM_CLIE

EXEC [ESECUELE].CrearClientesBI

-- EXEC [ESECUELE].AgregarKeyDimClieAuto

EXEC [ESECUELE].CargarClientesJovenesBI
go
EXEC [ESECUELE].CargarClientesMedianosBI
go
EXEC [ESECUELE].CargarClientesViejosBI
go

select * from [ESECUELE].BI_DIM_CLIE 


----------------------------------
--	   DIMENSION MODELOSX		--
----------------------------------


ALTER PROCEDURE [ESECUELE].CrearModeloBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_MODELO(
		cod_mod  decimal(18,0) PRIMARY KEY,
		fabricante_mod nvarchar(255),
		nom_modelo nvarchar(255)
	)

END

/*
ALTER PROCEDURE [ESECUELE].AgregarKeyDimModelo
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_MODELO ADD FOREIGN KEY (cod_mod) REFERENCES [ESECUELE].Modelos(cod_modelo)
END

GO
*/

CREATE PROCEDURE [ESECUELE].CargarModeloBI
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

--EXEC [ESECUELE].AgregarKeyDimModelo

EXEC [ESECUELE].CargarModeloBI

select * from [ESECUELE].BI_DIM_MODELO 


----------------------------------
--		DIMENSION SUCURSALX 	--
----------------------------------


CREATE PROCEDURE [ESECUELE].CrearSucursalBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_SUCURSAL(
		cod_suc bigint PRIMARY KEY,
		mail_suc nvarchar(255),
		tel_suc decimal(18,0),
		ciu_suc nvarchar(255),
		dir_suc nvarchar(255),
	)
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
GO

/*
DROP PROCEDURE [ESECUELE].AgregarKeyDimSucursalAuto
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_DIM_SUCURSAL_AUTO ADD FOREIGN KEY (cod_suc) REFERENCES [ESECUELE].Sucursales(cod_suc)
END

GO
*/


DROP TABLE [ESECUELE].BI_DIM_SUCURSAL

EXEC [ESECUELE].CrearSucursalBI

-- EXEC [ESECUELE].AgregarKeyDimSucursal

EXEC [ESECUELE].CargarSucursalBI

select * from [ESECUELE].BI_DIM_SUCURSAL 


----------------------------------
--		DIMENSION TIEMPOX		--
----------------------------------


CREATE PROCEDURE [ESECUELE].CrearTiempoBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_TIEMPO(
		id_tiempo bigint identity(1,1) PRIMARY KEY,
		discriminador nvarchar(255),
		anio bigint,
		mes bigint
	)

END
GO

ALTER PROCEDURE [ESECUELE].CargarTiempoCompraBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_TIEMPO(discriminador, anio , mes)
	SELECT 'C',YEAR(CA.fecha_compra), MONTH(ca.fecha_compra)
	FROM [ESECUELE].ComprasAutoparte CA
	GROUP BY YEAR(CA.fecha_compra), MONTH(ca.fecha_compra)
	INTERSECT
	SELECT 'C' ,YEAR(CA.fecha_compra_auto), MONTH(ca.fecha_compra_auto)
	FROM [ESECUELE].ComprasAuto CA
	GROUP BY YEAR(CA.fecha_compra_auto), MONTH(ca.fecha_compra_auto)
END
GO

ALTER PROCEDURE [ESECUELE].CargarTiempoVentaBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_TIEMPO(discriminador, anio , mes)
	SELECT 'V', YEAR(F.fecha_fac), MONTH(F.fecha_fac)
	FROM [ESECUELE].Facturas F
	GROUP BY YEAR(F.fecha_fac), MONTH(F.fecha_fac)
END
GO

DROP TABLE [ESECUELE].BI_DIM_TIEMPO

EXEC [ESECUELE].CrearTiempoBI

EXEC [ESECUELE].CargarTiempoCompraBI

EXEC [ESECUELE].CargarTiempoVentaBI

SELECT * FROM [ESECUELE].BI_DIM_TIEMPO


----------------------------------
--			AUTOPARTEX			--
----------------------------------


ALTER PROCEDURE [ESECUELE].CrearAutoparteBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_AUTOPARTE(
		cod_autoparte decimal(18,0) PRIMARY KEY,
		desc_autoparte nvarchar(255) 
	)

END
GO

SELECT * FROM [ESECUELE].FacturasAutoparte

SELECT * FROM gd_esquema.Maestra

ALTER PROCEDURE [ESECUELE].CargarAutoparteBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_AUTOPARTE(cod_autoparte, desc_autoparte)
	SELECT A.cod_autoparte, A.desc_autoparte
	FROM [ESECUELE].Autopartes A
	GROUP BY A.cod_autoparte, A.desc_autoparte
END
GO


EXEC [ESECUELE].CrearAutoparteBI

EXEC [ESECUELE].CargarAutoparteBI

SELECT * FROM [ESECUELE].BI_DIM_AUTOPARTE

drop table [ESECUELE].BI_DIM_AUTOPARTE

----------------------------------
--		PRECIO VENTA AUTO		--
----------------------------------


CREATE PROCEDURE [ESECUELE].CrearPrecioVentaAutoBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_PRECIO_VENTA_AUTO(
		cod_auto bigint PRIMARY KEY,
		precio_venta_auto decimal(18,2),
		fecha_venta_auto datetime2(3)
	)

END
GO

ALTER PROCEDURE [ESECUELE].CargarPrecioVentaAutoBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_PRECIO_VENTA_AUTO(cod_auto, precio_venta_auto, fecha_venta_auto)
	SELECT A.cod_auto, F.precio_fac, F.fecha_fac
	FROM [ESECUELE].Autos A
	INNER JOIN [ESECUELE].FacturasAuto FA ON
	FA.cod_auto = A.cod_auto
	INNER JOIN [ESECUELE].Facturas F ON
	F.cod_fac = FA.cod_fac_auto
	GROUP BY A.cod_auto, F.precio_fac, F.fecha_fac
END
GO

EXEC [ESECUELE].CrearPrecioVentaAutoBI

EXEC [ESECUELE].CargarPrecioVentaAutoBI

SELECT * FROM [ESECUELE].BI_DIM_PRECIO_VENTA_AUTO

----------------------------------
--		PRECIO COMPRA AUTO		--
----------------------------------


CREATE PROCEDURE [ESECUELE].CrearPrecioCompraAutoBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTO(
		cod_auto bigint PRIMARY KEY,
		precio_compra_auto decimal(18,2),
		fecha_compra_auto datetime2(3)
	)

END
GO

CREATE PROCEDURE [ESECUELE].CargarPrecioCompraAutoBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTO(cod_auto, precio_compra_auto, fecha_compra_auto)
	SELECT A.cod_auto, CA.precio_compra_auto, CA.fecha_compra_auto
	FROM [ESECUELE].Autos A
	INNER JOIN [ESECUELE].ComprasAuto CA ON
	CA.cod_auto = A.cod_auto
	GROUP BY A.cod_auto, CA.precio_compra_auto, CA.fecha_compra_auto
END
GO

EXEC [ESECUELE].CrearPrecioCompraAutoBI

EXEC [ESECUELE].CargarPrecioCompraAutoBI

SELECT * FROM [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTO


----------------------------------
--	PRECIO VENTA AUTOPARTE		--
----------------------------------

ALTER PROCEDURE [ESECUELE].CrearPrecioVentaAutoparteBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE(
		id_venta_autoparte bigint identity(1,1) PRIMARY KEY,
		cod_autoparte bigint,
		precio_venta_autoparte decimal(18,2),
		fecha_venta_autoparte datetime2(3),
		cant_venta_autoparte bigint
	)

END
GO

CREATE PROCEDURE [ESECUELE].CargarPrecioVentaAutoparteBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE(cod_autoparte, precio_venta_autoparte, fecha_venta_autoparte, cant_venta_autoparte)
	SELECT A.cod_autoparte, FA.precio_unitario, F.fecha_fac, FA.cant_autopartes
	FROM [ESECUELE].Autopartes A
	INNER JOIN [ESECUELE].FacturasAutoparte FA ON
	FA.cod_autoparte = A.cod_autoparte
	INNER JOIN [ESECUELE].Facturas F ON
	F.cod_fac = FA.cod_fac_autoparte
	GROUP BY A.cod_autoparte, FA.precio_unitario, F.fecha_fac, FA.cant_autopartes
	ORDER BY 1 ASC
END
GO

EXEC [ESECUELE].CrearPrecioVentaAutoparteBI

EXEC [ESECUELE].CargarPrecioVentaAutoparteBI

SELECT * FROM [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE

drop table [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE

SELECT * FROM [ESECUELE].Autopartes



----------------------------------
--	PRECIO COMPRA AUTOPARTE		--
----------------------------------


ALTER PROCEDURE [ESECUELE].CrearPrecioCompraAutoparteBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE(
		id_compra_autoparte bigint identity(1,1) PRIMARY KEY,
		cod_autoparte bigint,
		precio_compra_autoparte decimal(18,2),
		fecha_compra_autoparte datetime2(3),
		cant_compra_autoparte bigint
	)

END
GO

ALTER PROCEDURE [ESECUELE].CargarPrecioCompraAutoparteBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE(cod_autoparte, precio_compra_autoparte, fecha_compra_autoparte, cant_compra_autoparte)
	SELECT A.cod_autoparte, CA.precio_unitario, CA.fecha_compra, CA.cant_compra_autoparte
	FROM [ESECUELE].Autopartes A
	INNER JOIN [ESECUELE].ComprasAutoparte CA ON
	CA.cod_autoparte = A.cod_autoparte
	GROUP BY A.cod_autoparte, CA.precio_unitario, CA.fecha_compra, CA.cant_compra_autoparte
END
GO

DROP TABLE [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE

EXEC [ESECUELE].CrearPrecioCompraAutoparteBI

EXEC [ESECUELE].CargarPrecioCompraAutoparteBI

SELECT * FROM [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE 



----------------------------------
--		HECHOS AUTOPARTEX		--
----------------------------------

alter PROCEDURE [ESECUELE].CrearHechosAutoparteBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_HECHO_AUTOPARTE(
		id_autoparte bigint identity(1,1) PRIMARY KEY,
		cod_autoparte decimal(18,0),
		cod_clie_autoparte bigint,
		cod_modelo decimal(18,0),
		cod_suc bigint,
		cod_tiempo_autoparte bigint,
		cod_precio_venta_autoparte bigint,
		cod_precio_compra_autoparte bigint,
	)

END
GO

ALTER PROCEDURE [ESECUELE].AgregarKeyHechosAutoparte
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_autoparte) REFERENCES [ESECUELE].BI_DIM_AUTOPARTE(cod_autoparte)
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_clie_autoparte) REFERENCES [ESECUELE].BI_DIM_CLIE(cod_clie) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_modelo) REFERENCES [ESECUELE].BI_DIM_MODELO(cod_mod) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_suc) REFERENCES [ESECUELE].BI_DIM_SUCURSAL(cod_suc) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_tiempo_autoparte) REFERENCES [ESECUELE].BI_DIM_TIEMPO(id_tiempo) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_precio_venta_autoparte) REFERENCES [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE(id_venta_autoparte) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTOPARTE ADD FOREIGN KEY (cod_precio_compra_autoparte) REFERENCES [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE(id_compra_autoparte) --
END

GO

SELECT * FROM [ESECUELE].BI_DIM_TIEMPO

alter PROCEDURE [ESECUELE].CargarHechoComprasAutoparteBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_HECHO_AUTOPARTE(cod_autoparte, cod_modelo, cod_suc, cod_tiempo_autoparte, cod_precio_compra_autoparte)
	SELECT A.cod_autoparte, M.cod_modelo, S.cod_suc, T.id_tiempo, PCA.id_compra_autoparte
	FROM [ESECUELE].ComprasAutoparte CA
	JOIN [ESECUELE].Autopartes A ON
	CA.cod_autoparte = A.cod_autoparte
	JOIN [ESECUELE].Modelos M ON
	A.cod_modelo = M.cod_modelo
	JOIN [ESECUELE].Compras C ON
	C.cod_compra = CA.cod_compra_autoparte
	JOIN [ESECUELE].Sucursales S ON
	C.cod_suc = S.cod_suc
	JOIN [ESECUELE].BI_DIM_TIEMPO T ON
	YEAR(CA.fecha_compra) = T.anio AND
	MONTH(CA.fecha_compra) = T.mes
	JOIN [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE PCA ON
	PCA.cod_autoparte = A.cod_autoparte AND
	CA.precio_unitario = PCA.precio_compra_autoparte
	WHERE T.discriminador = 'C'
	GROUP BY A.cod_autoparte, M.cod_modelo, S.cod_suc, T.id_tiempo, PCA.id_compra_autoparte
END
GO

ALTER PROCEDURE [ESECUELE].CargarHechoVentasAutoparteBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_HECHO_AUTOPARTE(cod_autoparte, cod_clie_autoparte, cod_modelo, cod_suc, cod_tiempo_autoparte, cod_precio_venta_autoparte)
	SELECT A.cod_autoparte, C.cod_clie, M.cod_modelo, S.cod_suc, T.id_tiempo, PVA.id_venta_autoparte
	FROM [ESECUELE].Autopartes A
	JOIN [ESECUELE].FacturasAutoparte FA ON
	FA.cod_autoparte = A.cod_autoparte
	JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_autoparte = F.cod_fac
	JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	JOIN [ESECUELE].Sucursales S ON
	F.cod_suc = S.cod_suc
	JOIN [ESECUELE].Modelos M ON
	A.cod_modelo = M.cod_modelo
	JOIN [ESECUELE].BI_DIM_TIEMPO T ON
	YEAR(F.fecha_fac) = T.anio AND
	MONTH(F.fecha_fac) = T.mes
	JOIN [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE PVA ON
	PVA.cod_autoparte = A.cod_autoparte AND
	FA.precio_unitario = PVA.precio_venta_autoparte
	WHERE T.discriminador = 'V'
	GROUP BY A.cod_autoparte, C.cod_clie, M.cod_modelo, S.cod_suc, T.id_tiempo, PVA.id_venta_autoparte
END
GO

EXEC [ESECUELE].CrearHechosAutoparteBI

EXEC [ESECUELE].AgregarKeyHechosAutoparte

EXEC [ESECUELE].CargarHechoComprasAutoparteBI
GO
EXEC [ESECUELE].CargarHechoVentasAutoparteBI
GO

SELECT * FROM [ESECUELE].BI_HECHO_AUTOPARTE

DROP TABLE [ESECUELE].BI_HECHO_AUTOPARTE


----------------------------------
--			HECHOS AUTOX		--
----------------------------------

ALTER PROCEDURE [ESECUELE].CrearHechosAutoBI
AS
BEGIN
	CREATE TABLE [ESECUELE].BI_HECHO_AUTO(
		id_auto bigint identity(1,1) PRIMARY KEY,
		cod_auto decimal(18,0),
		cod_clie_auto bigint,
		cod_modelo decimal(18,0),
		cod_suc bigint,
		cod_tiempo_auto bigint,
		
	)

END
GO

ALTER PROCEDURE [ESECUELE].AgregarKeyHechosAuto
AS 
BEGIN
	ALTER TABLE [ESECUELE].BI_HECHO_AUTO ADD FOREIGN KEY (cod_auto) REFERENCES [ESECUELE].BI_DIM_AUTO(cod_auto)
	ALTER TABLE [ESECUELE].BI_HECHO_AUTO ADD FOREIGN KEY (cod_clie_auto) REFERENCES [ESECUELE].BI_DIM_CLIE(cod_clie) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTO ADD FOREIGN KEY (cod_modelo) REFERENCES [ESECUELE].BI_DIM_MODELO(cod_mod) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTO ADD FOREIGN KEY (cod_suc) REFERENCES [ESECUELE].BI_DIM_SUCURSAL(cod_suc) --
	ALTER TABLE [ESECUELE].BI_HECHO_AUTO ADD FOREIGN KEY (cod_tiempo_auto) REFERENCES [ESECUELE].BI_DIM_TIEMPO(id_tiempo) --
END

GO


ALTER PROCEDURE [ESECUELE].CargarHechoComprasAutoBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_HECHO_AUTO(cod_auto, cod_modelo, cod_suc, cod_tiempo_auto)
	SELECT A.cod_auto, M.cod_modelo, S.cod_suc, T.id_tiempo
	FROM [ESECUELE].ComprasAuto CA
	JOIN [ESECUELE].Autos A ON
	CA.cod_auto = A.cod_auto
	JOIN [ESECUELE].Modelos M ON
	A.cod_modelo = M.cod_modelo
	JOIN [ESECUELE].Compras C ON
	C.cod_compra = CA.cod_compra_auto
	JOIN [ESECUELE].Sucursales S ON
	C.cod_suc = S.cod_suc
	JOIN [ESECUELE].BI_DIM_TIEMPO T ON
	YEAR(CA.fecha_compra_auto) = T.anio AND
	MONTH(CA.fecha_compra_auto) = T.mes
	WHERE T.discriminador = 'C'
	GROUP BY A.cod_auto, M.cod_modelo, S.cod_suc, T.id_tiempo
END
GO

CREATE PROCEDURE [ESECUELE].CargarHechoVentasAutoBI
AS
BEGIN
	INSERT INTO [ESECUELE].BI_HECHO_AUTO(cod_auto, cod_clie_auto, cod_modelo, cod_suc, cod_tiempo_auto)
	SELECT A.cod_auto, C.cod_clie, M.cod_modelo, S.cod_suc, T.id_tiempo
	FROM [ESECUELE].Autos A
	JOIN [ESECUELE].FacturasAuto FA ON
	FA.cod_auto = A.cod_auto
	JOIN [ESECUELE].Facturas F ON
	FA.cod_fac_auto = F.cod_fac
	JOIN [ESECUELE].Clientes C ON
	F.cod_clie = C.cod_clie
	JOIN [ESECUELE].Sucursales S ON
	F.cod_suc = S.cod_suc
	JOIN [ESECUELE].Modelos M ON
	A.cod_modelo = M.cod_modelo
	JOIN [ESECUELE].BI_DIM_TIEMPO T ON
	YEAR(F.fecha_fac) = T.anio AND
	MONTH(F.fecha_fac) = T.mes
	WHERE T.discriminador = 'V'
	GROUP BY A.cod_auto, C.cod_clie, M.cod_modelo, S.cod_suc, T.id_tiempo
END
GO

EXEC [ESECUELE].CrearHechosAutoBI

EXEC [ESECUELE].AgregarKeyHechosAuto

EXEC [ESECUELE].CargarHechoComprasAutoBI

EXEC [ESECUELE].CargarHechoVentasAutoBI

SELECT * FROM [ESECUELE].BI_HECHO_AUTO

drop table [ESECUELE].BI_HECHO_AUTO



----------------------------------
--			VISTAS				--
----------------------------------

--  Cantidad de automóviles, vendidos y comprados x sucursal y mes  --

CREATE VIEW [AUTOS_VENDIDOS_Y_COMPRADOS_POR_SUC_Y_MES]
AS
SELECT T.mes as [Mes], HA.cod_suc as [Sucursal],
(
Select Count(Distinct(HA1.cod_auto)) 
FROM [ESECUELE].BI_HECHO_AUTO HA1
INNER JOIN [ESECUELE].BI_DIM_TIEMPO T1 ON
HA1.cod_tiempo_auto = T1.id_tiempo
WHERE T.mes = T1.mes  AND HA1.cod_suc = HA.cod_suc
) AS [Cantidad de autos vendidos y comprados por mes y sucursal]
FROM [ESECUELE].BI_HECHO_AUTO HA
INNER JOIN [ESECUELE].BI_DIM_TIEMPO T ON
HA.cod_tiempo_auto = T.id_tiempo
GROUP BY T.mes, HA.cod_suc
GO



-- Precio promedio de automóviles, vendidos y comprados.  --

CREATE VIEW [PRECIO_PROMEDIO_AUTOS_VENDIDOS_Y_COMPRADOS]
AS
SELECT AVG(PCA.precio_compra_auto + PVA.precio_venta_auto) AS [PRECIO PROMEDIO DE AUTOS VENDIDOS Y COMPRADOS]
FROM [ESECUELE].BI_HECHO_AUTO HA
JOIN [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTO PCA ON
PCA.cod_auto = HA.cod_auto
JOIN [ESECUELE].BI_DIM_PRECIO_VENTA_AUTO PVA ON
PVA.cod_auto = HA.cod_auto
GO

--  Ganancias (precio de venta – precio de compra) x Sucursal x mes  --

CREATE VIEW [GANANCIAS_POR_SUC_POR_MES_AUTOS]
AS
SELECT T.mes as [Mes], HA.cod_suc as [Sucursal], sum(PVA.precio_venta_auto - PCA.precio_compra_auto)  AS [Ganancias]
FROM [ESECUELE].BI_HECHO_AUTO HA  
INNER JOIN [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTO PCA ON 
PCA.cod_auto = HA.cod_auto
INNER JOIN [ESECUELE].BI_DIM_PRECIO_VENTA_AUTO PVA ON
PVA.cod_auto = HA.cod_auto
INNER JOIN [ESECUELE].BI_DIM_TIEMPO T ON
HA.cod_tiempo_auto = T.id_tiempo
WHERE MONTH(PCA.fecha_compra_auto) = T.mes AND
MONTH(PVA.fecha_venta_auto) = T.mes
GROUP BY T.mes, HA.cod_suc
GO


--  Promedio de tiempo en stock de cada modelo de automóvil.  --

CREATE VIEW [PROMEDIO_STOCK_MODELO_POR_AUTO]
AS
SELECT HA.cod_modelo AS [MODELO], AVG(DATEDIFF(month,PCA.fecha_compra_auto, PVA.fecha_venta_auto))  AS [PROMEDIO_TIEMPO_STOCK_MODELO_EN_MESES]
FROM [ESECUELE].BI_HECHO_AUTO HA 
INNER JOIN [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTO PCA ON 
PCA.cod_auto = HA.cod_auto
INNER JOIN [ESECUELE].BI_DIM_PRECIO_VENTA_AUTO PVA ON
PVA.cod_auto = HA.cod_auto
GROUP BY HA.cod_modelo
GO


--  Precio promedio de cada autoparte, vendida y comprada.   --

CREATE VIEW [PRECIO_PROMEDIO_AUTOPARTE_VENDIDA_Y_COMPRADA]
AS
SELECT HA.cod_autoparte, AVG(PCA.precio_compra_autoparte + PVA.precio_venta_autoparte) AS [PRECIO PROMEDIO DE AUTOPARTE VENDIDAS Y COMPRADAS]
FROM [ESECUELE].BI_HECHO_AUTOPARTE HA
JOIN [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE PCA ON
PCA.cod_autoparte = HA.cod_autoparte
JOIN [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE PVA ON
PVA.cod_autoparte = HA.cod_autoparte
GROUP BY HA.cod_autoparte
GO


--  Ganancias (precio de venta – precio de compra) x Sucursal x mes  --
CREATE VIEW [GANANCIAS_POR_SUC_POR_MES_AUTOPARTES]
AS
SELECT T.mes as [Mes], HA.cod_suc as [Sucursal], sum(PVA.precio_venta_autoparte - PCA.precio_compra_autoparte)  AS [Ganancias]
FROM [ESECUELE].BI_HECHO_AUTOPARTE HA  
INNER JOIN [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE PCA ON 
PCA.cod_autoparte = HA.cod_autoparte
INNER JOIN [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE PVA ON
PVA.cod_autoparte = HA.cod_autoparte
INNER JOIN [ESECUELE].BI_DIM_TIEMPO T ON
HA.cod_tiempo_autoparte = T.id_tiempo
WHERE MONTH(PCA.fecha_compra_autoparte) = T.mes AND
MONTH(PVA.fecha_venta_autoparte) = T.mes
GROUP BY T.mes, HA.cod_suc
GO


--  Promedio de tiempo en stock de cada autoparte  --

CREATE VIEW [PROMEDIO_STOCK_AUTOPARTE]
AS
SELECT HA.cod_autoparte AS [AUTOPARTE], AVG(DATEDIFF(month,PCA.fecha_compra_autoparte, PVA.fecha_venta_autoparte))  AS [PROMEDIO_TIEMPO_STOCK_AUTOPARTE_EN_MESES]
FROM [ESECUELE].BI_HECHO_AUTOPARTE HA 
INNER JOIN [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE PCA ON 
PCA.cod_autoparte = HA.cod_autoparte
INNER JOIN [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE PVA ON
PVA.cod_autoparte = HA.cod_autoparte
GROUP BY HA.cod_autoparte
GO


--  Máxima cantidad de stock por cada sucursal (anual)  --

CREATE VIEW [MAXIMA_CANTIDAD_STOCK_POR_SUCURSAL]
AS
SELECT HA.cod_suc as [SUCURSAL], T.anio AS [AÑO], MAX(PCA.cant_compra_autoparte - PVA.cant_venta_autoparte) as [MAXIMA_CANTIDAD_STOCK]
FROM [ESECUELE].BI_HECHO_AUTOPARTE HA 
INNER JOIN [ESECUELE].BI_DIM_PRECIO_COMPRA_AUTOPARTE PCA ON
PCA.cod_autoparte = HA.cod_autoparte
INNER JOIN [ESECUELE].BI_DIM_PRECIO_VENTA_AUTOPARTE PVA ON
PVA.cod_autoparte = HA.cod_autoparte
INNER JOIN [ESECUELE].BI_DIM_TIEMPO T ON
HA.cod_tiempo_autoparte = T.id_tiempo
WHERE T.anio = YEAR(PCA.fecha_compra_autoparte) AND
T.anio = YEAR(PVA.fecha_venta_autoparte) AND
YEAR(PCA.fecha_compra_autoparte) = YEAR(PVA.fecha_venta_autoparte) 
GROUP BY HA.cod_suc, T.anio
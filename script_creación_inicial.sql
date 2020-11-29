USE [GD2C2020]
GO

/**
## INTEGRANTES ##
	
	- Federico Palumbo			1674640		K3671

	- Ignacio Garay				1680900		K3572		
	
	- Walter Barreiro			1674456		K3521		


## PROCEDURES ##

	1. CrearX: crea tabla con sus atributos

	2. AsignarKeyX: asigna constraints tales como FK a los atributos de la tabla

	3. CargarX: emigra los registros de la tabla maestra, cargándolos en la tabla indicada

	4. ProcedimientoX: crea y carga una tabla de datos

	5. MigracionDeDatos: ejecuta las creaciones y cargas de todas las tablas

	6. EliminarTablas: dropea todas las tablas


**/


--------------------------------------
--			CREACIÓN SCHEMA			--
--------------------------------------

GO
	CREATE SCHEMA [ESECUELE]
GO

--------------------------
--		SUCURSAL		--
--------------------------

CREATE PROCEDURE [ESECUELE].CrearSucursales
AS
BEGIN
	SET	NOCOUNT ON;
	CREATE TABLE [ESECUELE].Sucursales(
		cod_suc bigint identity(1,1) PRIMARY KEY NOT NULL,
		mail_suc nvarchar(255),
		tel_suc decimal(18,0),
		ciu_suc nvarchar(255),
		dir_suc nvarchar(255)
	)
END

GO

CREATE PROCEDURE [ESECUELE].CargarSucursales
AS
BEGIN
	INSERT INTO [ESECUELE].Sucursales (mail_suc, tel_suc, ciu_suc, dir_suc)
	SELECT SUCURSAL_MAIL, SUCURSAL_TELEFONO, SUCURSAL_CIUDAD, SUCURSAL_DIRECCION
	FROM gd_esquema.Maestra
	WHERE SUCURSAL_MAIL IS NOT NULL
	GROUP BY SUCURSAL_MAIL, SUCURSAL_TELEFONO, SUCURSAL_CIUDAD, SUCURSAL_DIRECCION
END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoSucursales
AS
BEGIN
	EXEC [ESECUELE].CrearSucursales
	EXEC [ESECUELE].CargarSucursales
END

GO

CREATE PROCEDURE [ESECUELE].EliminarSucursales
AS
BEGIN
	DROP TABLE [ESECUELE].Sucursales
	DROP PROCEDURE [ESECUELE].CrearSucursales
	DROP PROCEDURE [ESECUELE].CargarSucursales
	DROP PROCEDURE [ESECUELE].ProcedimientoSucursales
END

GO

--------------------------
--		CLIENTES		--
--------------------------

CREATE PROCEDURE [ESECUELE].CrearClientes
AS
BEGIN
	SET	NOCOUNT ON;
	CREATE TABLE [ESECUELE].Clientes(
		cod_clie bigint identity(1,1) PRIMARY KEY NOT NULL,
		nom_clie nvarchar(255),
		ape_clie nvarchar(255),
		dir_clie nvarchar(255),
		nac_clie datetime2(3),
		mail_clie nvarchar(255),
		dni_clie decimal(18,0),
	)
END

GO

CREATE PROCEDURE [ESECUELE].CargarClientes1
AS
BEGIN
	INSERT INTO [ESECUELE].Clientes (nom_clie, ape_clie, dir_clie, nac_clie, mail_clie, dni_clie)
	SELECT CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_DNI
	FROM gd_esquema.Maestra
	WHERE CLIENTE_DNI IS NOT NULL
	GROUP BY CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_DNI
END

GO

CREATE PROCEDURE [ESECUELE].CargarClientes2
AS
BEGIN
INSERT INTO [ESECUELE].Clientes (nom_clie, ape_clie, dir_clie, nac_clie, mail_clie, dni_clie)
	SELECT FAC_CLIENTE_NOMBRE, FAC_CLIENTE_APELLIDO, FAC_CLIENTE_DIRECCION, FAC_CLIENTE_FECHA_NAC, FAC_CLIENTE_MAIL, FAC_CLIENTE_DNI
	FROM gd_esquema.Maestra
	WHERE FAC_CLIENTE_DNI IS NOT NULL
	GROUP BY FAC_CLIENTE_NOMBRE, FAC_CLIENTE_APELLIDO, FAC_CLIENTE_DIRECCION, FAC_CLIENTE_FECHA_NAC, FAC_CLIENTE_MAIL, FAC_CLIENTE_DNI
END

GO


CREATE PROCEDURE [ESECUELE].ProcedimientoClientes
AS
BEGIN
	EXEC [ESECUELE].CrearClientes
	EXEC [ESECUELE].CargarClientes1
	EXEC [ESECUELE].CargarClientes2
END

GO

CREATE PROCEDURE [ESECUELE].EliminarClientes 
AS
BEGIN
	DROP TABLE [ESECUELE].Clientes
	DROP PROCEDURE [ESECUELE].CrearClientes
	DROP PROCEDURE [ESECUELE].CargarClientes1
	DROP PROCEDURE [ESECUELE].CargarClientes2
	DROP PROCEDURE [ESECUELE].ProcedimientoClientes
END

GO

--------------------------
--		FACTURAS		--
--------------------------

CREATE PROCEDURE [ESECUELE].CrearFacturas
AS
BEGIN
	SET	NOCOUNT ON;
	CREATE TABLE [ESECUELE].Facturas(
		cod_fac bigint identity(1,1) PRIMARY KEY NOT NULL,
		nro_fac decimal(18,0),
		precio_fac decimal(18,2),
		fecha_fac datetime2(3),
		fecha_clie_fac datetime2(3),
		cod_clie bigint,
		cod_suc bigint
	)
END

GO

CREATE PROCEDURE [ESECUELE].AgregarKeysFacturas
AS
BEGIN
	ALTER TABLE [ESECUELE].Facturas add FOREIGN KEY (cod_suc) REFERENCES [ESECUELE].Sucursales(cod_suc)
	ALTER TABLE [ESECUELE].Facturas add FOREIGN KEY (cod_clie) REFERENCES [ESECUELE].Clientes(cod_clie)
END

GO

CREATE PROCEDURE [ESECUELE].CargarFacturas1
AS
BEGIN
	SET	NOCOUNT ON;
	INSERT INTO [ESECUELE].Facturas (nro_fac, precio_fac, fecha_fac, fecha_clie_fac, cod_clie, cod_suc)
	SELECT M.FACTURA_NRO, M.PRECIO_FACTURADO, M.FACTURA_FECHA, M.FAC_CLIENTE_FECHA_NAC, C.cod_clie, S.cod_suc
	FROM gd_esquema.Maestra M
	LEFT JOIN [ESECUELE].Clientes C on 
	C.dni_clie = M.CLIENTE_DNI 
	LEFT JOIN [ESECUELE].Sucursales S on S.mail_suc = M.FAC_SUCURSAL_MAIL
	WHERE M.FACTURA_NRO IS NOT NULL AND
	M.PRECIO_FACTURADO IS NOT NULL AND
	M.FACTURA_FECHA IS NOT NULL AND
	M.CLIENTE_NOMBRE IS NOT NULL AND
	M.FAC_CLIENTE_FECHA_NAC IS NOT NULL
	GROUP BY M.FACTURA_NRO, M.PRECIO_FACTURADO, M.FACTURA_FECHA, M.FAC_CLIENTE_FECHA_NAC, C.cod_clie, S.cod_suc
END

GO


CREATE PROCEDURE [ESECUELE].CargarFacturas2
AS
BEGIN
	SET	NOCOUNT ON;
	INSERT INTO [ESECUELE].Facturas (nro_fac, precio_fac, fecha_fac, fecha_clie_fac, cod_clie, cod_suc)
	SELECT M.FACTURA_NRO, M.PRECIO_FACTURADO, M.FACTURA_FECHA, M.FAC_CLIENTE_FECHA_NAC, C.cod_clie, S.cod_suc
	FROM gd_esquema.Maestra M
	LEFT JOIN [ESECUELE].Clientes C on 
	C.dni_clie = M.FAC_CLIENTE_DNI
	LEFT JOIN [ESECUELE].Sucursales S on S.mail_suc = M.FAC_SUCURSAL_MAIL
	WHERE M.FACTURA_NRO IS NOT NULL AND
	M.PRECIO_FACTURADO IS NOT NULL AND
	M.FACTURA_FECHA IS NOT NULL AND
	M.CLIENTE_NOMBRE IS NOT NULL AND
	M.FAC_CLIENTE_FECHA_NAC IS NOT NULL
	GROUP BY M.FACTURA_NRO, M.PRECIO_FACTURADO, M.FACTURA_FECHA, M.FAC_CLIENTE_FECHA_NAC, C.cod_clie, S.cod_suc
END

GO


CREATE PROCEDURE [ESECUELE].ProcedimientoFactura
AS
BEGIN
	SET NOCOUNT ON;
	EXEC [ESECUELE].CrearFacturas
	EXEC [ESECUELE].AgregarKeysFacturas
	EXEC [ESECUELE].CargarFacturas1
	EXEC [ESECUELE].CargarFacturas2
END

GO

CREATE PROCEDURE [ESECUELE].EliminarFacturas
AS
BEGIN
	DROP TABLE [ESECUELE].Facturas
	DROP PROCEDURE [ESECUELE].CrearFacturas
	DROP PROCEDURE [ESECUELE].AgregarKeysFacturas
	DROP PROCEDURE [ESECUELE].CargarFacturas1
	DROP PROCEDURE [ESECUELE].CargarFacturas2
	DROP PROCEDURE [ESECUELE].ProcedimientoFactura
END

GO

----------------------
--		Motores		--
----------------------

CREATE PROCEDURE [ESECUELE].CrearMotores
AS
BEGIN
	SET	NOCOUNT ON;
	CREATE TABLE [ESECUELE].Motores(
		cod_motor bigint identity(1,1) PRIMARY KEY NOT NULL,
		tipo_motor decimal(18,0),
		pot_motor decimal(18,0)
	)
END

GO

CREATE PROCEDURE [ESECUELE].CargarMotores
AS
BEGIN
	INSERT INTO [ESECUELE].Motores (tipo_motor, pot_motor)
	SELECT TIPO_MOTOR_CODIGO, MODELO_POTENCIA
	FROM gd_esquema.Maestra
	WHERE TIPO_MOTOR_CODIGO is not null
	GROUP BY TIPO_MOTOR_CODIGO, MODELO_POTENCIA
END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoMotores
AS
BEGIN
	EXEC [ESECUELE].CrearMotores
	EXEC [ESECUELE].CargarMotores
END

GO

CREATE PROCEDURE [ESECUELE].EliminarMotores
AS
BEGIN
	DROP TABLE [ESECUELE].Motores
	DROP PROCEDURE [ESECUELE].CrearMotores
	DROP PROCEDURE [ESECUELE].CargarMotores
	DROP PROCEDURE [ESECUELE].ProcedimientoMotores
END 

GO

------------------------------
--		Cajas de cambio		--
------------------------------

CREATE PROCEDURE [ESECUELE].CrearCajas
AS
BEGIN
	SET	NOCOUNT ON;
	CREATE TABLE [ESECUELE].Cajas_de_cambio(
		cod_caja bigint identity(1,1) PRIMARY KEY NOT NULL,
		cod_transmision decimal(18,0),
		desc_transmision nvarchar(255),
		desc_caja nvarchar(255),
		tipo_caja decimal(18,0),
		cant_cambios bigint
	)
END

GO

CREATE PROCEDURE [ESECUELE].CargarCajas
AS
BEGIN
	INSERT INTO [ESECUELE].Cajas_de_cambio (cod_transmision, desc_transmision, desc_caja, tipo_caja)
	SELECT TIPO_TRANSMISION_CODIGO, TIPO_TRANSMISION_DESC, TIPO_CAJA_DESC, TIPO_CAJA_CODIGO
	FROM gd_esquema.Maestra
	WHERE TIPO_CAJA_CODIGO IS NOT NULL
	GROUP BY TIPO_TRANSMISION_CODIGO, TIPO_TRANSMISION_DESC, TIPO_CAJA_DESC, TIPO_CAJA_CODIGO
END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoCajas
AS
BEGIN
	EXEC [ESECUELE].CrearCajas
	EXEC [ESECUELE].CargarCajas
END

GO

CREATE PROCEDURE [ESECUELE].EliminarCajas
AS
BEGIN
	DROP TABLE [ESECUELE].Cajas_de_cambio
	DROP PROCEDURE [ESECUELE].CrearCajas
	DROP PROCEDURE [ESECUELE].CargarCajas
	DROP PROCEDURE [ESECUELE].ProcedimientoCajas
END

GO

----------------------
--		MODELOS		--	 
----------------------

CREATE PROCEDURE [ESECUELE].CrearModelos
AS
BEGIN
	SET	NOCOUNT ON;
	create table [ESECUELE].Modelos (
		cod_modelo decimal(18,0) PRIMARY KEY,
		nom_modelo nvarchar(255),
		fabricante_modelo nvarchar(255),
		cod_caja bigint,
		cod_motor bigint 
	)
END

GO

CREATE PROCEDURE [ESECUELE].AgregarKeysModelos
AS
BEGIN
	ALTER TABLE [ESECUELE].Modelos add FOREIGN KEY (cod_caja) REFERENCES [ESECUELE].Cajas_de_cambio(cod_caja)
	ALTER TABLE [ESECUELE].Modelos add FOREIGN KEY (cod_motor) REFERENCES [ESECUELE].Motores(cod_motor)
END

GO

CREATE PROCEDURE [ESECUELE].CargarModelos
AS
BEGIN
	SET	NOCOUNT ON;
	INSERT INTO [ESECUELE].Modelos (cod_modelo, nom_modelo, fabricante_modelo, cod_caja, cod_motor)
	SELECT A.MODELO_CODIGO, A.MODELO_NOMBRE, A.FABRICANTE_NOMBRE, C.cod_caja, M.cod_motor
	FROM gd_esquema.Maestra A
	LEFT JOIN [ESECUELE].Motores M ON
	M.tipo_motor = A.TIPO_MOTOR_CODIGO AND
	M.pot_motor = A.MODELO_POTENCIA
	LEFT JOIN [ESECUELE].Cajas_de_cambio C ON
	C.cod_transmision = A.TIPO_TRANSMISION_CODIGO AND
	C.desc_transmision = A.TIPO_TRANSMISION_DESC AND
	C.desc_caja = A.TIPO_CAJA_DESC AND
	C.tipo_caja = A.TIPO_CAJA_CODIGO
	WHERE A.TIPO_MOTOR_CODIGO IS NOT NULL AND
	A.TIPO_CAJA_CODIGO is not null AND
	A.FABRICANTE_NOMBRE is not null AND
	A.MODELO_CODIGO IS NOT NULL
	GROUP BY A.MODELO_CODIGO, A.MODELO_NOMBRE, A.FABRICANTE_NOMBRE, C.cod_caja, M.cod_motor
END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoModelos
AS
BEGIN
	EXEC [ESECUELE].CrearModelos
	EXEC [ESECUELE].AgregarKeysModelos
	EXEC [ESECUELE].CargarModelos
END

GO

CREATE PROCEDURE [ESECUELE].EliminarModelos
AS
BEGIN
	DROP TABLE [ESECUELE].Modelos
	DROP PROCEDURE [ESECUELE].CrearModelos
	DROP PROCEDURE [ESECUELE].AgregarKeysModelos
	DROP PROCEDURE [ESECUELE].CargarModelos
	DROP PROCEDURE [ESECUELE].ProcedimientoModelos
END

GO

------------------------------
--			COMPRAS			--
------------------------------

CREATE PROCEDURE [ESECUELE].CrearCompras
AS
BEGIN
	SET	NOCOUNT ON;
	CREATE TABLE [ESECUELE].Compras(
		cod_compra bigint identity(1,1) PRIMARY KEY NOT NULL,
		nro_compra decimal(18,0),
		cod_suc bigint
	)
END

GO

CREATE PROCEDURE [ESECUELE].AgregarKeyCompras
AS
BEGIN
	ALTER TABLE [ESECUELE].Compras add FOREIGN KEY (cod_suc) REFERENCES [ESECUELE].Sucursales(cod_suc)
END

GO

CREATE PROCEDURE [ESECUELE].CargarCompras
AS
BEGIN
	SET	NOCOUNT ON;
	INSERT INTO [ESECUELE].Compras (nro_compra, cod_suc)
	SELECT M.COMPRA_NRO, S.cod_suc
	FROM gd_esquema.Maestra M
	LEFT JOIN [ESECUELE].Sucursales S on S.mail_suc = M.SUCURSAL_MAIL
	WHERE M.COMPRA_NRO is not null 
	GROUP BY M.COMPRA_NRO, S.cod_suc
END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoCompra
AS
BEGIN
	EXEC [ESECUELE].CrearCompras
	EXEC [ESECUELE].AgregarKeyCompras
	EXEC [ESECUELE].CargarCompras
END

GO

CREATE PROCEDURE [ESECUELE].EliminarCompras
AS
BEGIN
	DROP TABLE [ESECUELE].Compras
	DROP PROCEDURE [ESECUELE].CrearCompras
	DROP PROCEDURE [ESECUELE].AgregarKeyCompras
	DROP PROCEDURE [ESECUELE].CargarCompras
	DROP PROCEDURE [ESECUELE].ProcedimientoCompra
END

GO

------------------------------
--			AUTOS			--
------------------------------

CREATE PROCEDURE [ESECUELE].CrearAutos
AS
BEGIN
	SET NOCOUNT ON
	CREATE TABLE [ESECUELE].Autos(
		cod_auto bigint identity(1,1) PRIMARY KEY,
		nro_chasis nvarchar(50),
		tipo_auto decimal(18,0),
		desc_auto nvarchar(255),
		fecha_alta_auto datetime2(3),
		kms_auto decimal(18,0),
		pat_auto nvarchar(50),
		nro_motor nvarchar(50),
		cod_modelo decimal(18,0)
	)
END

GO

CREATE PROCEDURE [ESECUELE].AgregarKeyAutos
AS 
BEGIN
	ALTER TABLE [ESECUELE].Autos ADD FOREIGN KEY (cod_modelo) REFERENCES [ESECUELE].Modelos(cod_modelo)
END

GO

CREATE PROCEDURE [ESECUELE].CargarAutos	
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO [ESECUELE].Autos(nro_chasis, tipo_auto, desc_auto, fecha_alta_auto, kms_auto, pat_auto, nro_motor, cod_modelo)	
	SELECT Ma.AUTO_NRO_CHASIS, Ma.TIPO_AUTO_CODIGO, Ma.TIPO_AUTO_DESC, Ma.AUTO_FECHA_ALTA, Ma.AUTO_CANT_KMS, Ma.AUTO_PATENTE, Ma.AUTO_NRO_MOTOR, Mo.cod_modelo
	FROM gd_esquema.Maestra Ma
	LEFT JOIN [ESECUELE].Modelos Mo ON 
	Mo.cod_modelo = Ma.MODELO_CODIGO AND 
	Mo.nom_modelo = Ma.MODELO_NOMBRE AND 
	Mo.fabricante_modelo = Ma.FABRICANTE_NOMBRE 
	WHERE Ma.AUTO_NRO_CHASIS is not null and
	Ma.AUTO_FECHA_ALTA is not null and
	Ma.TIPO_AUTO_DESC is not null and
	Ma.AUTO_FECHA_ALTA is not null and
	Ma.AUTO_CANT_KMS is not null and
	Ma.AUTO_PATENTE is not null and
	Ma.AUTO_NRO_MOTOR is not null
	GROUP BY Ma.AUTO_NRO_CHASIS, Ma.TIPO_AUTO_CODIGO, Ma.TIPO_AUTO_DESC, Ma.AUTO_FECHA_ALTA, Ma.AUTO_CANT_KMS, Ma.AUTO_PATENTE, Ma.AUTO_NRO_MOTOR, Mo.cod_modelo
END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoAutos
AS 
BEGIN
	EXEC [ESECUELE].CrearAutos
	EXEC [ESECUELE].AgregarKeyAutos
	EXEC [ESECUELE].CargarAutos
END

GO

CREATE PROCEDURE [ESECUELE].EliminarAutos
AS
BEGIN
	DROP TABLE [ESECUELE].Autos	
	DROP PROCEDURE [ESECUELE].CrearAutos	
	DROP PROCEDURE [ESECUELE].AgregarKeyAutos
	DROP PROCEDURE [ESECUELE].CargarAutos
	DROP PROCEDURE [ESECUELE].ProcedimientoAutos
END

GO

----------------------------------
--			Autoparte			--
----------------------------------

CREATE PROCEDURE [ESECUELE].CrearAutopartes
AS
BEGIN
	SET NOCOUNT ON
	CREATE TABLE [ESECUELE].Autopartes(
		cod_autoparte decimal(18,0) PRIMARY KEY,
		desc_autoparte nvarchar(255),
		precio_autoparte decimal(18,2), -- Pedido en el enunciado
		cod_modelo decimal(18,0)
	)
END

GO

CREATE PROCEDURE [ESECUELE].AgregarKeyAutopartes
AS
BEGIN
	ALTER TABLE [ESECUELE].Autopartes ADD FOREIGN KEY (cod_modelo) REFERENCES [ESECUELE].Modelos(cod_modelo)
END

GO

CREATE PROCEDURE [ESECUELE].CargarAutopartes
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO [ESECUELE].Autopartes(cod_autoparte, desc_autoparte, cod_modelo)
	SELECT Ma.AUTO_PARTE_CODIGO, Ma.AUTO_PARTE_DESCRIPCION, Mo.cod_modelo
	FROM gd_esquema.Maestra Ma
	LEFT JOIN [ESECUELE].Modelos Mo ON 
	Ma.MODELO_CODIGO = Mo.cod_modelo AND 
	Ma.MODELO_NOMBRE = Mo.nom_modelo AND 
	Ma.FABRICANTE_NOMBRE = Mo.fabricante_modelo
	WHERE Ma.AUTO_PARTE_CODIGO IS NOT NULL
	GROUP BY Ma.AUTO_PARTE_CODIGO, Ma.AUTO_PARTE_DESCRIPCION, Mo.cod_modelo
END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoAutopartes
AS 
BEGIN
	EXEC [ESECUELE].CrearAutopartes
	EXEC [ESECUELE].AgregarKeyAutopartes
	EXEC [ESECUELE].CargarAutopartes
END

GO

CREATE PROCEDURE [ESECUELE].EliminarAutopartes
AS
BEGIN
	DROP TABLE [ESECUELE].Autopartes
	DROP PROCEDURE [ESECUELE].CrearAutopartes
	DROP PROCEDURE [ESECUELE].AgregarKeyAutopartes
	DROP PROCEDURE [ESECUELE].CargarAutopartes
	DROP PROCEDURE [ESECUELE].ProcedimientoAutopartes
END

GO

--------------------------------------
--          FACTURA AUTO            --
--------------------------------------

CREATE PROCEDURE [ESECUELE].CrearFacturaAuto
AS
SET NOCOUNT ON 
BEGIN
    CREATE TABLE [ESECUELE].FacturasAuto(
        cod_fac_auto bigint,
        cod_auto bigint
    )
END

GO

CREATE PROCEDURE [ESECUELE].AgregarKeyFacturasAuto
AS
BEGIN
    ALTER TABLE [ESECUELE].FacturasAuto ADD FOREIGN KEY (cod_fac_auto) REFERENCES [ESECUELE].Facturas(cod_fac)
    ALTER TABLE [ESECUELE].FacturasAuto ADD FOREIGN KEY (cod_auto) REFERENCES [ESECUELE].Autos(cod_auto)
END

GO


CREATE PROCEDURE [ESECUELE].CargarFacturasAuto
AS
SET NOCOUNT ON
BEGIN
    INSERT INTO [ESECUELE].FacturasAuto(cod_fac_auto, cod_auto)
    SELECT F.cod_fac, A.cod_auto
    FROM gd_esquema.Maestra M
    LEFT JOIN [ESECUELE].Facturas F ON 
	F.nro_fac = M.FACTURA_NRO AND 
	F.precio_fac = M.PRECIO_FACTURADO AND 
	F.fecha_fac = M.FACTURA_FECHA AND 
	F.fecha_clie_fac = M.FAC_CLIENTE_FECHA_NAC
    LEFT JOIN [ESECUELE].Autos A ON 
	A.nro_chasis = M.AUTO_NRO_CHASIS AND 
	A.tipo_auto = M.TIPO_AUTO_CODIGO AND 
	A.desc_auto = M.TIPO_AUTO_DESC AND 
	A.fecha_alta_auto = M.AUTO_FECHA_ALTA AND 
	A.kms_auto = M.AUTO_CANT_KMS AND 
	A.nro_motor = M.AUTO_NRO_MOTOR AND
	A.pat_auto = M.AUTO_PATENTE 
    WHERE M.TIPO_AUTO_CODIGO IS NOT NULL AND 
	M.FACTURA_NRO IS NOT NULL
    GROUP BY F.cod_fac, A.cod_auto
	ORDER BY cod_auto

END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoFacturasAuto
AS
BEGIN
    EXEC [ESECUELE].CrearFacturaAuto
    EXEC [ESECUELE].AgregarKeyFacturasAuto
    EXEC [ESECUELE].CargarFacturasAuto
END

GO

CREATE PROCEDURE [ESECUELE].EliminarFacturasAuto
AS
BEGIN
	DROP TABLE [ESECUELE].FacturasAuto
	DROP PROCEDURE [ESECUELE].CrearFacturaAuto
	DROP PROCEDURE [ESECUELE].AgregarKeyFacturasAuto
	DROP PROCEDURE [ESECUELE].CargarFacturasAuto
	DROP PROCEDURE [ESECUELE].ProcedimientoFacturasAuto
END

GO

--------------------------------------
--		  FACTURA AUTOPARTE         --
--------------------------------------

CREATE PROCEDURE [ESECUELE].CrearFacturaAutoparte
AS
SET NOCOUNT ON 
BEGIN
    CREATE TABLE [ESECUELE].FacturasAutoparte(
        id_fac_autoparte bigint identity(1,1) PRIMARY KEY,
		cod_fac_autoparte bigint,
        cod_autoparte decimal(18,0),
		cant_autopartes bigint, -- Pedida en el enunciado
		ciudad_origen nvarchar(255) -- Pedida en el enunciado
    )
END

GO
SELECT * FROM FacturasAutoparte

CREATE PROCEDURE [ESECUELE].AgregarKeyFacturasAutoparte
AS
BEGIN
    ALTER TABLE [ESECUELE].FacturasAutoparte ADD FOREIGN KEY (cod_fac_autoparte) REFERENCES [ESECUELE].Facturas(cod_fac)
    ALTER TABLE [ESECUELE].FacturasAutoparte ADD FOREIGN KEY (cod_autoparte) REFERENCES [ESECUELE].Autopartes(cod_autoparte)
END

GO

SELECT * FROM gd_esquema.Maestra

CREATE PROCEDURE [ESECUELE].CargarFacturasAutoparte
AS
SET NOCOUNT ON
BEGIN
    INSERT INTO [ESECUELE].FacturasAutoparte(cod_fac_autoparte, cod_autoparte)
    SELECT F.cod_fac, A.cod_autoparte
    FROM gd_esquema.Maestra M
    LEFT JOIN [ESECUELE].Facturas F ON 
	F.nro_fac = M.FACTURA_NRO AND 
	F.precio_fac = M.PRECIO_FACTURADO AND 
	F.fecha_fac = M.FACTURA_FECHA AND 
	F.fecha_clie_fac = M.FAC_CLIENTE_FECHA_NAC
    LEFT JOIN [ESECUELE].Autopartes A ON 
	A.cod_autoparte = M.AUTO_PARTE_CODIGO AND 
	A.desc_autoparte = M.AUTO_PARTE_DESCRIPCION
	WHERE M.AUTO_PARTE_CODIGO IS NOT NULL AND 
	M.FACTURA_NRO IS NOT NULL
    GROUP BY F.cod_fac, A.cod_autoparte
END

GO



CREATE PROCEDURE [ESECUELE].ProcedimientoFacturasAutoparte
AS
BEGIN
    EXEC [ESECUELE].CrearFacturaAutoparte
    EXEC [ESECUELE].AgregarKeyFacturasAutoparte
    EXEC [ESECUELE].CargarFacturasAutoparte
END

GO

CREATE PROCEDURE [ESECUELE].EliminarFacturasAutoparte
AS
BEGIN	
	DROP TABLE [ESECUELE].FacturasAutoparte
	DROP PROCEDURE [ESECUELE].CrearFacturaAutoparte
	DROP PROCEDURE [ESECUELE].AgregarKeyFacturasAutoparte
	DROP PROCEDURE [ESECUELE].CargarFacturasAutoparte
	DROP PROCEDURE [ESECUELE].ProcedimientoFacturasAutoparte
END

GO

--------------------------------------
--			COMPRAS AUTO		    --
--------------------------------------

CREATE PROCEDURE [ESECUELE].CrearComprasAuto
AS
SET NOCOUNT ON 
BEGIN
    CREATE TABLE [ESECUELE].ComprasAuto(
        id_compra_auto bigint identity(1,1) PRIMARY KEY,
		cod_compra_auto bigint,
        cod_auto bigint,
		fecha_compra_auto datetime2(3),
		precio_compra_auto decimal(18,2)
    )
END

GO

CREATE PROCEDURE [ESECUELE].AgregarKeyComprasAuto
AS
BEGIN
    ALTER TABLE [ESECUELE].ComprasAuto ADD FOREIGN KEY (cod_compra_auto) REFERENCES [ESECUELE].Compras(cod_compra)
    ALTER TABLE [ESECUELE].ComprasAuto ADD FOREIGN KEY (cod_auto) REFERENCES [ESECUELE].Autos(cod_auto)
END

GO

CREATE PROCEDURE [ESECUELE].CargarComprasAuto
AS
SET NOCOUNT ON
BEGIN
    INSERT INTO [ESECUELE].ComprasAuto(cod_compra_auto, cod_auto, fecha_compra_auto, precio_compra_auto)
    SELECT C.cod_compra, A.cod_auto, M.COMPRA_FECHA, M.COMPRA_PRECIO
    FROM gd_esquema.Maestra M
    LEFT JOIN [ESECUELE].Compras C ON 
	C.nro_compra = M.COMPRA_NRO
    LEFT JOIN [ESECUELE].Autos A ON 
	A.nro_chasis = M.AUTO_NRO_CHASIS AND 
	A.tipo_auto = M.TIPO_AUTO_CODIGO AND 
	A.desc_auto = M.TIPO_AUTO_DESC AND 
	A.fecha_alta_auto = M.AUTO_FECHA_ALTA AND 
	A.kms_auto = M.AUTO_CANT_KMS AND 
	A.nro_motor = M.AUTO_NRO_MOTOR AND
	A.pat_auto = M.AUTO_PATENTE 
	WHERE M.TIPO_AUTO_CODIGO IS NOT NULL AND 
	M.COMPRA_NRO IS NOT NULL
    GROUP BY C.cod_compra, A.cod_auto, M.COMPRA_FECHA, M.COMPRA_PRECIO
END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoComprasAuto
AS
BEGIN
    EXEC [ESECUELE].CrearComprasAuto
    EXEC [ESECUELE].AgregarKeyComprasAuto
    EXEC [ESECUELE].CargarComprasAuto
END

GO

CREATE PROCEDURE [ESECUELE].EliminarComprasAuto
AS
BEGIN
	DROP TABLE [ESECUELE].ComprasAuto
	DROP PROCEDURE [ESECUELE].CrearComprasAuto
	DROP PROCEDURE [ESECUELE].AgregarKeyComprasAuto
	DROP PROCEDURE [ESECUELE].CargarComprasAuto
	DROP PROCEDURE [ESECUELE].ProcedimientoComprasAuto
END 

GO

--------------------------------------
--		  COMPRAS AUTOPARTE		    --
--------------------------------------

CREATE PROCEDURE [ESECUELE].CrearComprasAutoparte
AS
SET NOCOUNT ON 
BEGIN
    CREATE TABLE [ESECUELE].ComprasAutoparte(
        id_compra_autoparte bigint identity(1,1) PRIMARY KEY,
		cod_compra_autoparte bigint,
        cod_autoparte decimal(18,0),
		cant_compra_autoparte bigint
    )
END

GO

CREATE PROCEDURE [ESECUELE].AgregarKeyComprasAutoparte
AS
BEGIN
    ALTER TABLE [ESECUELE].ComprasAutoparte ADD FOREIGN KEY (cod_compra_autoparte) REFERENCES [ESECUELE].Compras(cod_compra)
    ALTER TABLE [ESECUELE].ComprasAutoparte ADD FOREIGN KEY (cod_autoparte) REFERENCES [ESECUELE].Autopartes(cod_autoparte)
END

GO

CREATE PROCEDURE [ESECUELE].CargarComprasAutoparte
AS
SET NOCOUNT ON
BEGIN
    INSERT INTO [ESECUELE].ComprasAutoparte(cod_compra_autoparte, cod_autoparte)
    SELECT C.cod_compra, A.cod_autoparte
    FROM gd_esquema.Maestra M
    LEFT JOIN [ESECUELE].Compras C ON 
	C.nro_compra = M.COMPRA_NRO
    LEFT JOIN [ESECUELE].Autopartes A ON 
	A.cod_autoparte = M.AUTO_PARTE_CODIGO AND 
	A.desc_autoparte = M.AUTO_PARTE_DESCRIPCION
	WHERE M.AUTO_PARTE_CODIGO IS NOT NULL AND 
	M.COMPRA_NRO IS NOT NULL
    GROUP BY C.cod_compra, A.cod_autoparte
END

GO

CREATE PROCEDURE [ESECUELE].ProcedimientoComprasAutoparte
AS
BEGIN
    EXEC [ESECUELE].CrearComprasAutoparte
    EXEC [ESECUELE].AgregarKeyComprasAutoparte
    EXEC [ESECUELE].CargarComprasAutoparte
END

GO

CREATE PROCEDURE [ESECUELE].EliminarComprasAutoparte
AS
BEGIN
	DROP TABLE [ESECUELE].ComprasAutoparte
	DROP PROCEDURE [ESECUELE].CrearComprasAutoparte
	DROP PROCEDURE [ESECUELE].AgregarKeyComprasAutoparte
	DROP PROCEDURE [ESECUELE].CargarComprasAutoparte
	DROP PROCEDURE [ESECUELE].ProcedimientoComprasAutoparte
END
 
GO

----------------------------------
--			MIGRACION			--
----------------------------------

CREATE PROCEDURE [ESECUELE].MigracionDeDatos
AS
BEGIN
	EXEC [ESECUELE].ProcedimientoSucursales
	EXEC [ESECUELE].ProcedimientoClientes
	EXEC [ESECUELE].ProcedimientoMotores
	EXEC [ESECUELE].ProcedimientoCajas
	EXEC [ESECUELE].ProcedimientoModelos
	EXEC [ESECUELE].ProcedimientoAutos
	EXEC [ESECUELE].ProcedimientoAutopartes
	EXEC [ESECUELE].ProcedimientoCompra
	EXEC [ESECUELE].ProcedimientoComprasAuto
	EXEC [ESECUELE].ProcedimientoComprasAutoparte
	EXEC [ESECUELE].ProcedimientoFactura
	EXEC [ESECUELE].ProcedimientoFacturasAuto
	EXEC [ESECUELE].ProcedimientoFacturasAutoparte
END

GO

EXEC [ESECUELE].MigracionDeDatos

GO

DROP PROCEDURE [ESECUELE].MigracionDeDatos

GO




----------------------------------------------
--			ELIMINAR PROCEDIMIENTOS			--
----------------------------------------------


/*
CREATE PROCEDURE [ESECUELE].EliminarTodo
AS
BEGIN
	EXEC [ESECUELE].EliminarComprasAutoparte
	EXEC [ESECUELE].EliminarComprasAuto
	EXEC [ESECUELE].EliminarFacturasAutoparte
	EXEC [ESECUELE].EliminarFacturasAuto
	EXEC [ESECUELE].EliminarAutopartes
	EXEC [ESECUELE].EliminarAutos
	EXEC [ESECUELE].EliminarCompras
	EXEC [ESECUELE].EliminarModelos
	EXEC [ESECUELE].EliminarCajas
	EXEC [ESECUELE].EliminarMotores
	EXEC [ESECUELE].EliminarFacturas
	EXEC [ESECUELE].EliminarClientes
	EXEC [ESECUELE].EliminarSucursales	
END

GO 

EXEC [ESECUELE].EliminarTodo

GO

DROP PROCEDURE [ESECUELE].EliminarTodo

GO


CREATE PROCEDURE [ESECUELE].EliminarProcedimientosRestantes
AS
BEGIN
	DROP PROCEDURE [ESECUELE].EliminarComprasAutoparte
	DROP PROCEDURE [ESECUELE].EliminarComprasAuto
	DROP PROCEDURE [ESECUELE].EliminarFacturasAutoparte
	DROP PROCEDURE [ESECUELE].EliminarFacturasAuto
	DROP PROCEDURE [ESECUELE].EliminarAutopartes
	DROP PROCEDURE [ESECUELE].EliminarAutos
	DROP PROCEDURE [ESECUELE].EliminarCompras
	DROP PROCEDURE [ESECUELE].EliminarModelos
	DROP PROCEDURE [ESECUELE].EliminarCajas
	DROP PROCEDURE [ESECUELE].EliminarMotores
	DROP PROCEDURE [ESECUELE].EliminarFacturas
	DROP PROCEDURE [ESECUELE].EliminarClientes
	DROP PROCEDURE [ESECUELE].EliminarSucursales
END

GO

EXEC [ESECUELE].EliminarProcedimientosRestantes

GO

DROP PROCEDURE [ESECUELE].EliminarProcedimientosRestantes

*/

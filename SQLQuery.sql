USE GD2C2020

--------------------------
--		SUCURSAL		--
--------------------------

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
	WHERE SUCURSAL_MAIL IS NOT NULL
	GROUP BY SUCURSAL_MAIL, SUCURSAL_TELEFONO, SUCURSAL_CIUDAD, SUCURSAL_DIRECCION
END

CREATE PROCEDURE ProcedimientoSucursales
AS
BEGIN
	EXEC CrearSucursales
	EXEC CargarSucursales
END

EXEC ProcedimientoSucursales

SELECT * FROM sucursales

DROP TABLE Sucursales
DROP PROCEDURE CrearSucursales
DROP PROCEDURE CargarSucursales
DROP PROCEDURE ProcedimientoSucursales



--------------------------
--		CLIENTES		--
--------------------------

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

CREATE PROCEDURE CargarClientes
AS
BEGIN
	INSERT INTO Clientes (nom_clie, ape_clie, dir_clie, nac_clie, mail_clie, dni_clie)
	SELECT CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_DNI
	FROM gd_esquema.Maestra
	WHERE CLIENTE_DNI IS NOT NULL AND
	FAC_CLIENTE_DNI IS NOT NULL
	GROUP BY CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DIRECCION, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_DNI
END

CREATE PROCEDURE ProcedimientoClientes
AS
BEGIN
	EXEC CrearClientes
	EXEC CargarClientes
END

EXEC ProcedimientoClientes

SELECT * FROM Clientes

DROP TABLE Clientes
DROP PROCEDURE CrearClientes
DROP PROCEDURE CargarClientes
DROP PROCEDURE ProcedimientoClientes



--------------------------
--		FACTURAS		--
--------------------------

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

CREATE PROCEDURE AgregarKeysFacturas
AS
BEGIN
	ALTER TABLE Facturas add FOREIGN KEY (cod_suc) REFERENCES Sucursales(cod_suc)
	ALTER TABLE Facturas add FOREIGN KEY (cod_clie) REFERENCES Clientes(cod_clie)
END

CREATE PROCEDURE CargarFacturas
AS
BEGIN
	SET	NOCOUNT ON;
	INSERT INTO Facturas (nro_fac, precio_fac, fecha_fac, fecha_clie_fac, cod_clie, cod_suc)
	SELECT M.FACTURA_NRO, M.PRECIO_FACTURADO, M.FACTURA_FECHA, M.FAC_CLIENTE_FECHA_NAC, C.cod_clie, S.cod_suc
	FROM gd_esquema.Maestra M
	LEFT JOIN Clientes C on 
	C.nom_clie = M.CLIENTE_NOMBRE AND
	C.ape_clie = M.CLIENTE_APELLIDO
	LEFT JOIN Sucursales S on S.mail_suc = M.FAC_SUCURSAL_MAIL
	WHERE M.FACTURA_NRO IS NOT NULL AND
	M.PRECIO_FACTURADO IS NOT NULL AND
	M.FACTURA_FECHA IS NOT NULL AND
	M.CLIENTE_NOMBRE IS NOT NULL AND
	M.FAC_CLIENTE_FECHA_NAC IS NOT NULL
	GROUP BY M.FACTURA_NRO, M.PRECIO_FACTURADO, M.FACTURA_FECHA, M.FAC_CLIENTE_FECHA_NAC, C.cod_clie, S.cod_suc
END

CREATE PROCEDURE ProcedimientoFactura
AS
BEGIN
	SET NOCOUNT ON;
	EXEC CrearFacturas
	EXEC AgregarKeysFacturas
	EXEC CargarFacturas
END

EXEC ProcedimientoFactura

SELECT * FROM Facturas

DROP TABLE Facturas
DROP PROCEDURE CrearFacturas
DROP PROCEDURE AgregarKeysFacturas
DROP PROCEDURE CargarFacturas
DROP PROCEDURE ProcedimientoFactura



----------------------
--		Motores		--
----------------------

CREATE PROCEDURE CrearMotores
AS
BEGIN
	SET	NOCOUNT ON;
	CREATE TABLE Motores(
		cod_motor bigint identity(1,1) PRIMARY KEY NOT NULL,
		tipo_motor decimal(18,0),
		pot_motor decimal(18,0),
		nro_motor nvarchar(50)
	)
END

CREATE PROCEDURE CargarMotores
AS
BEGIN
	INSERT INTO Motores (tipo_motor, pot_motor, nro_motor)
	SELECT TIPO_MOTOR_CODIGO, MODELO_POTENCIA, AUTO_NRO_MOTOR
	FROM gd_esquema.Maestra
	GROUP BY TIPO_MOTOR_CODIGO, MODELO_POTENCIA, AUTO_NRO_MOTOR
END

CREATE PROCEDURE ProcedimientoMotores
AS
BEGIN
	EXEC CrearMotores
	EXEC CargarMotores
END

EXEC ProcedimientoMotores

SELECT * FROM Motores

DROP TABLE Motores
DROP PROCEDURE CrearMotores
DROP PROCEDURE CargarMotores
DROP PROCEDURE ProcedimientoMotores



------------------------------
--		Cajas de cambio		--
------------------------------

CREATE PROCEDURE CrearCajas
AS
BEGIN
	SET	NOCOUNT ON;
	CREATE TABLE Cajas_de_cambio(
		cod_caja bigint identity(1,1) PRIMARY KEY NOT NULL,
		cod_transmision decimal(18,0),
		desc_transmision nvarchar(255),
		desc_caja nvarchar(255),
		tipo_caja decimal(18,0)
		--cant_cambios? 
	)
END

CREATE PROCEDURE CargarCajas
AS
BEGIN
	INSERT INTO Cajas_de_cambio (cod_transmision, desc_transmision, desc_caja, tipo_caja)
	SELECT TIPO_TRANSMISION_CODIGO, TIPO_TRANSMISION_DESC, TIPO_CAJA_DESC, TIPO_CAJA_CODIGO
	FROM gd_esquema.Maestra
	WHERE TIPO_CAJA_CODIGO IS NOT NULL
	GROUP BY TIPO_TRANSMISION_CODIGO, TIPO_TRANSMISION_DESC, TIPO_CAJA_DESC, TIPO_CAJA_CODIGO
END

CREATE PROCEDURE ProcedimientoCajas
AS
BEGIN
	EXEC CrearCajas
	EXEC CargarCajas
END

EXEC ProcedimientoCajas

SELECT * FROM Cajas_de_cambio

DROP TABLE Cajas_de_cambio
DROP PROCEDURE CrearCajas
DROP PROCEDURE CargarCajas
DROP PROCEDURE ProcedimientoCajas



----------------------
--		MODELOS		--	 VER XQ HAY MUCHOS REGISTROS IGUALES SOLO POR UN CAMPO DISTINTO
----------------------

CREATE PROCEDURE CrearModelos
AS
BEGIN
	SET	NOCOUNT ON;
	create table Modelos (
		cod_modelo bigint identity(1,1) PRIMARY KEY,
		tipo_modelo decimal(18,0),
		nom_modelo nvarchar(255),
		fabricante_modelo nvarchar(255),
		cod_caja bigint,
		cod_motor bigint 
	)
END

CREATE PROCEDURE AgregarKeysModelos
AS
BEGIN
	ALTER TABLE Modelos add FOREIGN KEY (cod_caja) REFERENCES Cajas_de_cambio(cod_caja)
	ALTER TABLE Modelos add FOREIGN KEY (cod_motor) REFERENCES Motores(cod_motor)
END

CREATE PROCEDURE CargarModelos
AS
BEGIN
	SET	NOCOUNT ON;
	INSERT INTO Modelos (tipo_modelo, nom_modelo, fabricante_modelo, cod_caja, cod_motor)
	SELECT A.MODELO_CODIGO, A.MODELO_NOMBRE, A.FABRICANTE_NOMBRE, C.cod_caja, M.cod_motor
	FROM gd_esquema.Maestra A
	LEFT JOIN Motores M ON
	M.nro_motor= A.AUTO_NRO_MOTOR AND
	M.pot_motor= A.MODELO_POTENCIA AND
	M.tipo_motor = A.TIPO_MOTOR_CODIGO
	LEFT JOIN Cajas_de_cambio C ON
	C.cod_transmision = A.TIPO_TRANSMISION_CODIGO AND
	C.desc_transmision = A.TIPO_TRANSMISION_DESC AND
	C.desc_caja = A.TIPO_CAJA_DESC AND
	C.tipo_caja = A.TIPO_CAJA_CODIGO
	--WHERE M.FACTURA_NRO IS NOT NULL AND 
	GROUP BY A.MODELO_CODIGO, A.MODELO_NOMBRE, A.FABRICANTE_NOMBRE, C.cod_caja, M.cod_motor
END

CREATE PROCEDURE ProcedimientoModelos
AS
BEGIN
	EXEC CrearModelos
	EXEC AgregarKeysModelos
	EXEC CargarModelos
END

EXEC ProcedimientoModelos

SELECT * FROM Modelos

DROP TABLE Modelos
DROP PROCEDURE CrearModelos
DROP PROCEDURE AgregarKeysModelos
DROP PROCEDURE CargarModelos
DROP PROCEDURE ProcedimientoModelos



------------------------------
--			COMPRAS			--
------------------------------

CREATE PROCEDURE CrearCompras
AS
BEGIN
	SET	NOCOUNT ON;
	CREATE TABLE Compras(
		cod_compra bigint identity(1,1) PRIMARY KEY NOT NULL,
		nro_compra decimal(18,0),
		cod_suc bigint
	)
END

CREATE PROCEDURE AgregarKeyCompras
AS
BEGIN
	ALTER TABLE Compras add FOREIGN KEY (cod_suc) REFERENCES Sucursales(cod_suc)
END

CREATE PROCEDURE CargarCompras
AS
BEGIN
	SET	NOCOUNT ON;
	INSERT INTO Compras (nro_compra, cod_suc)
	SELECT M.COMPRA_NRO, S.cod_suc
	FROM gd_esquema.Maestra M
	LEFT JOIN Sucursales S on S.mail_suc = M.SUCURSAL_MAIL
	WHERE M.COMPRA_NRO is not null 
	GROUP BY M.COMPRA_NRO, S.cod_suc
END

CREATE PROCEDURE ProcedimientoCompra
AS
BEGIN
	EXEC CrearCompras
	EXEC AgregarKeyCompras
	EXEC CargarCompras
END

EXEC ProcedimientoCompra

SELECT* FROM Compras

DROP TABLE Compras
DROP PROCEDURE CrearCompras
DROP PROCEDURE AgregarKeyCompras
DROP PROCEDURE CargarCompras
DROP PROCEDURE ProcedimientoCompra



------------------------------
--			AUTOS			--
------------------------------

CREATE PROCEDURE CrearAutos
AS
BEGIN
	SET NOCOUNT ON
	CREATE TABLE Autos(
		nro_chasis nvarchar(50) PRIMARY KEY NOT NULL,
		cod_auto decimal(18,0),
		desc_auto nvarchar(255),
		fecha_alta_auto datetime2(3),
		kms_auto decimal(18,0),
		pat_auto nvarchar(50),
		cod_modelo bigint
	)
END

CREATE PROCEDURE AgregarKeyAutos
AS 
BEGIN
	ALTER TABLE Autos ADD FOREIGN KEY (cod_modelo) REFERENCES Modelos(cod_modelo)
END

CREATE PROCEDURE CargarAutos	
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO Autos(nro_chasis, cod_auto, desc_auto, fecha_alta_auto, kms_auto, pat_auto, cod_modelo)	
	SELECT Ma.AUTO_NRO_CHASIS, Ma.TIPO_AUTO_CODIGO, Ma.TIPO_AUTO_DESC, Ma.AUTO_FECHA_ALTA, Ma.AUTO_CANT_KMS, Ma.AUTO_PATENTE, Mo.cod_modelo
	FROM gd_esquema.Maestra Ma
	LEFT JOIN Modelos Mo ON Ma.MODELO_CODIGO =  Mo.tipo_modelo
	AND Ma.MODELO_NOMBRE = Mo.nom_modelo
	AND Ma.FABRICANTE_NOMBRE = Mo.fabricante_modelo
	GROUP BY Ma.AUTO_NRO_CHASIS, Ma.TIPO_AUTO_CODIGO, Ma.TIPO_AUTO_DESC, Ma.AUTO_FECHA_ALTA, Ma.AUTO_CANT_KMS, Ma.AUTO_PATENTE, Mo.cod_modelo
END

CREATE PROCEDURE ProcedimientoAutos
AS 
BEGIN
	EXEC CrearAutos
	EXEC AgregarKeyAutos
	EXEC CargarAutos
END

EXEC ProcedimientoAutos

SELECT* FROM Autos

DROP TABLE Autos
DROP PROCEDURE CrearAutos
DROP PROCEDURE AgregarKeyAutos
DROP PROCEDURE CargarAutos
DROP PROCEDURE ProcedimientoAutos



----------------------------------
--			Autoparte			--
----------------------------------

CREATE PROCEDURE CrearAutopartes
AS
BEGIN
	SET NOCOUNT ON
	CREATE TABLE Autopartes(
		id_autoparte bigint identity(1,1) PRIMARY KEY,
		cod_autoparte decimal(18,0),
		desc_autoparte nvarchar(255),
		precio_autoparte decimal(18,2),
		cod_modelo bigint
	)
END

CREATE PROCEDURE AgregarKeyAutopartes
AS
BEGIN
	ALTER TABLE Autopartes ADD FOREIGN KEY (cod_modelo) REFERENCES Modelos(cod_modelo)
END

CREATE PROCEDURE CargarAutopartes
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO Autopartes(cod_autoparte, desc_autoparte, precio_autoparte, cod_modelo)
	SELECT Ma.AUTO_PARTE_CODIGO, Ma.AUTO_PARTE_DESCRIPCION, Ma.COMPRA_PRECIO, Mo.cod_modelo
	FROM gd_esquema.Maestra Ma
	LEFT JOIN Modelos Mo ON Ma.MODELO_CODIGO = Mo.tipo_modelo
	AND Ma.MODELO_NOMBRE = Mo.nom_modelo
	AND Ma.FABRICANTE_NOMBRE = Mo.fabricante_modelo
	WHERE Ma.AUTO_PARTE_CODIGO IS NOT NULL
	GROUP BY Ma.AUTO_PARTE_CODIGO, Ma.AUTO_PARTE_DESCRIPCION, Ma.COMPRA_PRECIO, Mo.cod_modelo
END

CREATE PROCEDURE ProcedimientoAutopartes
AS 
BEGIN
	EXEC CrearAutopartes
	EXEC AgregarKeyAutopartes
	EXEC CargarAutopartes
END

EXEC ProcedimientoAutopartes

SELECT* FROM Autopartes

DROP TABLE Autopartes
DROP PROCEDURE CrearAutopartes
DROP PROCEDURE AgregarKeyAutopartes
DROP PROCEDURE CargarAutopartes
DROP PROCEDURE ProcedimientoAutopartes



--
--			
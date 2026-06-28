/* 
    Universidad Nacional de La Matanza
    Materia: Bases de Datos Aplicada (3641)
    Fecha: 19/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures ABM del esquema Gestion.
*/

USE GestionParquesNacionales;
GO

/*=========================================================
ALTA TIPO PARQUE
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.tipoParque_Alta
    @nombre VARCHAR(50),
    @descripcion VARCHAR(200) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errorMsg = @errorMsg + '- El nombre del tipo de parque es obligatorio.' + @saltoLinea;

    IF @nombre IS NOT NULL AND EXISTS (SELECT 1 FROM Gestion.tipoParque WHERE nombre = @nombre)
        SET @errorMsg = @errorMsg + '- Ya existe un tipo de parque con el nombre: ' + @nombre + '.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50101, @errorMsg, 1;
    END

    INSERT INTO Gestion.tipoParque (nombre, descripcion)
    VALUES (@nombre, @descripcion);
END
GO

/*=========================================================
MODIFICAR TIPO PARQUE
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.tipoParque_Modificar
    @idTipoParque INT,
    @nombre VARCHAR(50) = NULL,
    @descripcion VARCHAR(200) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Gestion.tipoParque WHERE idTipoParque = @idTipoParque)
        SET @errorMsg = @errorMsg + '- No existe un tipo de parque con id: ' + CAST(@idTipoParque AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
        SET @errorMsg = @errorMsg + '- El nombre no puede estar vacio.' + @saltoLinea;

    IF @nombre IS NOT NULL AND EXISTS (
        SELECT 1 FROM Gestion.tipoParque 
        WHERE nombre = @nombre AND idTipoParque <> @idTipoParque
    )
        SET @errorMsg = @errorMsg + '- Ya existe otro tipo de parque con el nombre: ' + @nombre + '.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50102, @errorMsg, 1;
    END

    UPDATE Gestion.tipoParque
    SET nombre = ISNULL(@nombre, nombre),
        descripcion = ISNULL(@descripcion, descripcion)
    WHERE idTipoParque = @idTipoParque;
END
GO

/*=========================================================
BAJA TIPO PARQUE
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.tipoParque_Baja
    @idTipoParque INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Gestion.tipoParque WHERE idTipoParque = @idTipoParque)
        SET @errorMsg = @errorMsg + '- No existe un tipo de parque con id: ' + CAST(@idTipoParque AS VARCHAR(10)) + '.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM Gestion.parque WHERE idTipoParque = @idTipoParque)
        SET @errorMsg = @errorMsg + '- No se puede eliminar: existen parques asociados a este tipo.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50103, @errorMsg, 1;
    END

    DELETE FROM Gestion.tipoParque
    WHERE idTipoParque = @idTipoParque;
END
GO

/*=========================================================
ALTA PARQUE
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.parque_Alta
    @nombre VARCHAR(100),
    @superficie DECIMAL(12, 2),
    @idTipoParque INT,
    @provincia VARCHAR(50),
    @codigoPostal VARCHAR(10) = NULL,
    @calle VARCHAR(100) = NULL,
    @nro VARCHAR(10) = NULL,
    @latitud DECIMAL(9, 6) = NULL,
    @longitud DECIMAL(9, 6) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errorMsg = @errorMsg + '- El nombre del parque es obligatorio.' + @saltoLinea;

    IF @provincia IS NULL OR LTRIM(RTRIM(@provincia)) = ''
        SET @errorMsg = @errorMsg + '- La provincia es obligatoria.' + @saltoLinea;

    IF @superficie IS NULL OR @superficie <= 0
        SET @errorMsg = @errorMsg + '- La superficie debe ser mayor a 0.' + @saltoLinea;

    IF @nombre IS NOT NULL AND EXISTS (SELECT 1 FROM Gestion.parque WHERE nombre = @nombre)
        SET @errorMsg = @errorMsg + '- Ya existe un parque con el nombre: ' + @nombre + '.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Gestion.tipoParque WHERE idTipoParque = @idTipoParque)
        SET @errorMsg = @errorMsg + '- No existe un tipo de parque con id: ' + CAST(@idTipoParque AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @latitud IS NOT NULL AND (@latitud < -90 OR @latitud > 90)
        SET @errorMsg = @errorMsg + '- La latitud debe estar entre -90 y 90.' + @saltoLinea;

    IF @longitud IS NOT NULL AND (@longitud < -180 OR @longitud > 180)
        SET @errorMsg = @errorMsg + '- La longitud debe estar entre -180 y 180.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50104, @errorMsg, 1;
    END

    INSERT INTO Gestion.parque (nombre, superficie, idTipoParque, provincia, codigoPostal, calle, nro, latitud, longitud)
    VALUES (@nombre, @superficie, @idTipoParque, @provincia, @codigoPostal, @calle, @nro, @latitud, @longitud);
END
GO

/*=========================================================
MODIFICAR PARQUE
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.parque_Modificar
    @idParque INT,
    @nombre VARCHAR(100) = NULL,
    @superficie DECIMAL(12, 2) = NULL,
    @idTipoParque INT = NULL,
    @provincia VARCHAR(50) = NULL,
    @codigoPostal VARCHAR(10) = NULL,
    @calle VARCHAR(100) = NULL,
    @nro VARCHAR(10) = NULL,
    @latitud DECIMAL(9, 6) = NULL,
    @longitud DECIMAL(9, 6) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
        SET @errorMsg = @errorMsg + '- El nombre no puede estar vacio.' + @saltoLinea;

    IF @nombre IS NOT NULL AND EXISTS (
        SELECT 1 FROM Gestion.parque 
        WHERE nombre = @nombre AND idParque <> @idParque
    )
        SET @errorMsg = @errorMsg + '- Ya existe otro parque con el nombre: ' + @nombre + '.' + @saltoLinea;

    IF @superficie IS NOT NULL AND @superficie <= 0
        SET @errorMsg = @errorMsg + '- La superficie debe ser mayor a 0.' + @saltoLinea;

    IF @idTipoParque IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Gestion.tipoParque WHERE idTipoParque = @idTipoParque)
        SET @errorMsg = @errorMsg + '- No existe un tipo de parque con id: ' + CAST(@idTipoParque AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @latitud IS NOT NULL AND (@latitud < -90 OR @latitud > 90)
        SET @errorMsg = @errorMsg + '- La latitud debe estar entre -90 y 90.' + @saltoLinea;

    IF @longitud IS NOT NULL AND (@longitud < -180 OR @longitud > 180)
        SET @errorMsg = @errorMsg + '- La longitud debe estar entre -180 y 180.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50105, @errorMsg, 1;
    END

    UPDATE Gestion.parque
    SET nombre = ISNULL(@nombre, nombre),
        superficie = ISNULL(@superficie, superficie),
        idTipoParque = ISNULL(@idTipoParque, idTipoParque),
        provincia = ISNULL(@provincia, provincia),
        codigoPostal = ISNULL(@codigoPostal, codigoPostal),
        calle = ISNULL(@calle, calle),
        nro = ISNULL(@nro, nro),
        latitud = ISNULL(@latitud, latitud),
        longitud = ISNULL(@longitud, longitud)
    WHERE idParque = @idParque;
END
GO

/*=========================================================
BAJA PARQUE
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.parque_Baja
    @idParque INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10)) + '.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- No se puede eliminar: el parque tiene concesiones asociadas.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50106, @errorMsg, 1;
    END

    DELETE FROM Gestion.parque
    WHERE idParque = @idParque;
END
GO
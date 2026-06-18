/* 
    Universidad Nacional de La Matanza
    Materia: Bases de Datos Aplicada (3641)
    Fecha: 18/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures ABM del esquema Gestion (TipoParque y Parque).
*/

USE GestionParquesNacionales;
GO

-- ALTA TIPO PARQUE

CREATE OR ALTER PROCEDURE Gestion.TipoParque_Alta
    @nombre VARCHAR(50),
    @descripcion VARCHAR(200) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('El nombre del tipo de parque es obligatorio.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Gestion.TipoParque WHERE nombre = @nombre)
    BEGIN
        SET @errorMsg = 'Ya existe un tipo de parque con el nombre: ' + @nombre;
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    INSERT INTO Gestion.TipoParque (nombre, descripcion)
    VALUES (@nombre, @descripcion);
END
GO


--  MODIFICAR TIPO PARQUE

CREATE OR ALTER PROCEDURE Gestion.TipoParque_Modificar
    @idTipoParque INT,
    @nombre VARCHAR(50) = NULL,
    @descripcion VARCHAR(200) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Gestion.TipoParque WHERE idTipoParque = @idTipoParque)
    BEGIN
        SET @errorMsg = 'No existe un tipo de parque con id: ' + CAST(@idTipoParque AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('El nombre no puede estar vacio.', 16, 1);
        RETURN;
    END

    IF @nombre IS NOT NULL 
       AND EXISTS (SELECT 1 FROM Gestion.TipoParque 
                   WHERE nombre = @nombre AND idTipoParque <> @idTipoParque)
    BEGIN
        SET @errorMsg = 'Ya existe otro tipo de parque con el nombre: ' + @nombre;
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    UPDATE Gestion.TipoParque
    SET nombre = ISNULL(@nombre, nombre),
        descripcion = ISNULL(@descripcion, descripcion)
    WHERE idTipoParque = @idTipoParque;
END
GO


/*=========================================================
BAJA TIPO PARQUE
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.TipoParque_Baja
    @idTipoParque INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Gestion.TipoParque WHERE idTipoParque = @idTipoParque)
    BEGIN
        SET @errorMsg = 'No existe un tipo de parque con id: ' + CAST(@idTipoParque AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Gestion.Parque WHERE idTipoParque = @idTipoParque)
    BEGIN
        RAISERROR('No se puede eliminar: existen parques asociados a este tipo.', 16, 1);
        RETURN;
    END

    DELETE FROM Gestion.TipoParque
    WHERE idTipoParque = @idTipoParque;
END
GO


/*=========================================================
ALTA PARQUE
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.Parque_Alta
    @nombre VARCHAR(100),
    @superficie DECIMAL(12, 2),
    @idTipoParque INT,
    @provincia VARCHAR(50),
    @codigoPostal VARCHAR(10) = NULL,
    @calle VARCHAR(100) = NULL,
    @nro VARCHAR(10) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('El nombre del parque es obligatorio.', 16, 1);
        RETURN;
    END

    IF @provincia IS NULL OR LTRIM(RTRIM(@provincia)) = ''
    BEGIN
        RAISERROR('La provincia es obligatoria.', 16, 1);
        RETURN;
    END

    IF @superficie IS NULL OR @superficie <= 0
    BEGIN
        RAISERROR('La superficie debe ser mayor a 0.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Gestion.Parque WHERE nombre = @nombre)
    BEGIN
        SET @errorMsg = 'Ya existe un parque con el nombre: ' + @nombre;
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Gestion.TipoParque WHERE idTipoParque = @idTipoParque)
    BEGIN
        SET @errorMsg = 'No existe un tipo de parque con id: ' + CAST(@idTipoParque AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    INSERT INTO Gestion.Parque (nombre, superficie, idTipoParque, provincia, codigoPostal, calle, nro)
    VALUES (@nombre, @superficie, @idTipoParque, @provincia, @codigoPostal, @calle, @nro);
END
GO


-- MODIFICAR PARQUE

CREATE OR ALTER PROCEDURE Gestion.Parque_Modificar
    @idParque INT,
    @nombre VARCHAR(100) = NULL,
    @superficie DECIMAL(12, 2) = NULL,
    @idTipoParque INT = NULL,
    @provincia VARCHAR(50) = NULL,
    @codigoPostal VARCHAR(10) = NULL,
    @calle VARCHAR(100) = NULL,
    @nro VARCHAR(10) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Gestion.Parque WHERE idParque = @idParque)
    BEGIN
        SET @errorMsg = 'No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('El nombre no puede estar vacio.', 16, 1);
        RETURN;
    END

    IF @nombre IS NOT NULL 
       AND EXISTS (SELECT 1 FROM Gestion.Parque 
                   WHERE nombre = @nombre AND idParque <> @idParque)
    BEGIN
        SET @errorMsg = 'Ya existe otro parque con el nombre: ' + @nombre;
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @superficie IS NOT NULL AND @superficie <= 0
    BEGIN
        RAISERROR('La superficie debe ser mayor a 0.', 16, 1);
        RETURN;
    END

    IF @idTipoParque IS NOT NULL 
       AND NOT EXISTS (SELECT 1 FROM Gestion.TipoParque WHERE idTipoParque = @idTipoParque)
    BEGIN
        SET @errorMsg = 'No existe un tipo de parque con id: ' + CAST(@idTipoParque AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    UPDATE Gestion.Parque
    SET nombre = ISNULL(@nombre, nombre),
        superficie = ISNULL(@superficie, superficie),
        idTipoParque = ISNULL(@idTipoParque, idTipoParque),
        provincia = ISNULL(@provincia, provincia),
        codigoPostal = ISNULL(@codigoPostal, codigoPostal),
        calle = ISNULL(@calle, calle),
        nro = ISNULL(@nro, nro)
    WHERE idParque = @idParque;
END
GO


-- BAJA PARQUE

CREATE OR ALTER PROCEDURE Gestion.Parque_Baja
    @idParque INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Gestion.Parque WHERE idParque = @idParque)
    BEGIN
        SET @errorMsg = 'No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE idParque = @idParque)
    BEGIN
        RAISERROR('No se puede eliminar: el parque tiene concesiones asociadas.', 16, 1);
        RETURN;
    END

    DELETE FROM Gestion.Parque
    WHERE idParque = @idParque;
END
GO
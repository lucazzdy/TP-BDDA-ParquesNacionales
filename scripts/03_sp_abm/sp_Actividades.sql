/* 
    Script generado el 15/06/26

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Este script genera los stored procedures ABM 
                        para el esquema de Actividades y sus tablas.
*/

USE GestionParquesNacionales
go

------ SPs para tabla Actividades.TipoActividad ------
-----------------------------------------------------


-- Insert solo con descripcion opcional
CREATE OR ALTER PROCEDURE Actividades.TipoActividad_Alta @descripcion VARCHAR(200) = NULL
AS
BEGIN
    IF @descripcion IS NOT NULL AND LEN(@descripcion) > 199
    BEGIN
        ;THROW 50100, 'La descripcion no puede superar los 200 caracteres',1
    END

	INSERT INTO Actividades.TipoActividad(descripcion)
	VALUES (@descripcion)
END
go

-- Modificar la descripcion del tipo de actividad segun idTipoActividad
CREATE OR ALTER PROCEDURE Actividades.TipoActividad_Modificar
        @idTipoActividad INT,
        @descripcion VARCHAR(200) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)
    
    -- Chequeo que el idTipoActividad a MODIFICAR exista en tabla Actividades.TipoActividad
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.TipoActividad
        WHERE idTipoActividad = @idTipoActividad
        )
    BEGIN
        SET @errorMsg = 'No existe un Tipo de Actividad con id: ' + CAST(@idTipoActividad AS VARCHAR)
        ;THROW 50200, @errorMsg,1
    END

    IF @descripcion IS NOT NULL AND LEN(@descripcion) > 199
    BEGIN
        ;THROW 50201, 'La descripcion no puede superar los 200 caracteres',2
    END

    UPDATE Actividades.TipoActividad
    SET descripcion = @descripcion
    WHERE idTipoActividad = @idTipoActividad
END
go

-- Eliminar una entrada de tipo de actividad segun idTipoActividad
CREATE OR ALTER PROCEDURE Actividades.TipoActividad_Baja
        @idTipoActividad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)
    -- Chequeo que el idTipoActividad a ELIMINAR exista en tabla Actividades.TipoActividad
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.TipoActividad
        WHERE idTipoActividad = @idTipoActividad
        )
    BEGIN
        SET @errorMsg = 'No existe un Tipo de Actividad con id: ' + CAST(@idTipoActividad AS VARCHAR)
        ;THROW 50300, @errorMsg,1
    END
    DELETE FROM Actividades.TipoActividad
    WHERE idTipoActividad = @idTipoActividad
END
go


------ SPs para tabla Actividades.Actividad ------
-------------------------------------------------

-- Insert con nombre, duracion y idTipoActividad obligatorio, ademas el nombre debe ser unico
CREATE OR ALTER PROCEDURE Actividades.Actividad_Alta
        @nombre VARCHAR(100),  
        @costo DECIMAL(8,2) = 0.0,
        @duracion DECIMAL(3,1),
        @idTipoActividad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chequeo que el nombre a INSERTAR no prexista en tabla Actividades.Actividad
    IF @nombre IN(SELECT nombre FROM Actividades.Actividad)
    BEGIN
        SET @errorMsg = 'Ya existe una actividad con nombre: ' + @nombre
        ;THROW 51100, @errorMsg,1
    END

    -- Chequeo que el nombre a INSERTAR no este vacio
    IF LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        ;THROW 51101, 'El nombre no puede estar vacio!',2
    END

    -- Chequeo que la duracion a INSERTAR no sea NULL
    IF @duracion IS NULL
    BEGIN
        ;THROW 51102, 'La duracion es un campo obligatorio',3
    END
    -- Chequeo que la duracion a INSERTAR sea mayor a 0
    IF @duracion <= 0
    BEGIN
        ;THROW 51103, 'El tiempo de duracion debe ser mayor a 0',4
    END

    -- Chqueo que el costo a INSERTAR sea 0 (gratis) o mas
    IF @costo < 0
    BEGIN
        ;THROW 51104, 'El costo debe ser mayor o igual a 0',5
    END

    -- Chequeo que la idTipoActividad a INSERTAR exista en tabla Actividad.TipoActividad
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.TipoActividad
        WHERE idTipoActividad = @idTipoActividad
        )
    BEGIN
        SET @errorMsg = 'No existe un tipo de actividad con id: ' + CAST(@idTipoActividad AS VARCHAR)
        ;THROW 51105, @errorMsg, 6
    END

    INSERT INTO Actividades.Actividad(nombre, costo, duracion, idTipoActividad)
    VALUES (@nombre, @costo, @duracion, @idTipoActividad)
END
go

-- Modificar datos de actividad segun idActividad
CREATE OR ALTER PROCEDURE Actividades.Actividad_Modificar
        @idActividad INT,
        @nombre VARCHAR(100) = NULL,
        @costo DECIMAL(8,2) = NULL,
        @duracion DECIMAL(3,1) = NULL,
        @idTipoActividad INT = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chequeo que la Actividad a MODIFICAR exista en tabla Actividades.Actividad
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.Actividad
        WHERE idActividad = @idActividad
        )
    BEGIN
        SET @errorMsg = 'No existe la Actividad con id: ' + CAST(@idActividad AS VARCHAR)
        ;THROW 51200, @errorMsg,1
    END

    -- Si se especifica nombre para MODIFICAR este no debe prexistir en la tabla Actividades.Actividad
    IF @nombre IS NOT NULL AND @nombre IN(SELECT nombre FROM Actividades.Actividad)
    BEGIN
        SET @errorMsg = 'Ya existe una actividad con nombre: ' + @nombre
        ;THROW 51201, @errorMsg,2
    END

     -- Chequeo que el nombre a MODIFICAR no este vacio
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        ;THROW 51202, 'El nombre no puede estar vacio!',3
    END

    -- Chequeo que la duracion a MODIFICAR sea mayor a 0
    IF @duracion IS NOT NULL AND @duracion <= 0
    BEGIN
        ;THROW 51203, 'El tiempo de duracion debe ser mayor a 0',4
    END

    -- Chequeo que el costo a MODIFICAR no sea negativo
    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        ;THROW 51204, 'El costo debe ser mayor o igual a 0',5
    END

    -- Chequeo que el idTipoActividad a MODIFICAR exista en tabla Actividades.TipoActividad
    IF @idTipoActividad IS NOT NULL 
        AND NOT EXISTS (
        SELECT  1
        FROM Actividades.TipoActividad
        WHERE TipoActividad.idTipoActividad = @idTipoActividad
        )
    BEGIN
        SET @errorMsg = 'No existe el tipo de Actividad con id: ' + CAST(@idTipoActividad AS VARCHAR)
        ;THROW 51205, @errorMsg, 6
    END


    UPDATE Actividades.Actividad
    SET nombre = ISNULL(@nombre, nombre), 
        costo = ISNULL(@costo, costo), 
        duracion = ISNULL(@duracion, duracion), 
        idTipoActividad = ISNULL(@idTipoActividad, idTipoActividad)
    WHERE idActividad = @idActividad
END
go

-- Eliminar una entrada de actividad segun idActividad
CREATE OR ALTER PROCEDURE Actividades.Actividad_Baja
        @idActividad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chequeo que la Actividad a ELIMINAR exista en tabla Actividades.Actividad
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.Actividad
        WHERE idActividad = @idActividad
        )
    BEGIN
        SET @errorMsg = 'No existe la Actividad con id: ' + CAST(@idActividad AS VARCHAR)
        ;THROW 51300, @errorMsg,1
    END
    
    DELETE FROM Actividades.Actividad
    WHERE idActividad = @idActividad
END
go

------ SPs para tabla Actividades.Especialidad ------
-----------------------------------------------------


--Insert con nombre obligatorio
CREATE OR ALTER PROCEDURE Actividades.Especialidad_Alta
        @nombre VARCHAR(100),
        @descripcion VARCHAR(200) = ''
 AS       
 BEGIN
    
    -- Chequeo que el nombre de especialidad a INSERTAR no este vacio
    IF LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        ;THROW 52100, 'El nombre de la especialidad no puede estar vacio',1
    END

    INSERT INTO Actividades.Especialidad(nombre, descripcion)
    VALUES (@nombre, @descripcion)
 END
 go

 -- Modificar la descripcion de Especialidad segun codEspecialidad
CREATE OR ALTER PROCEDURE Actividades.Especialidad_Modificar
        @codEspecialidad INT,
        @descripcion VARCHAR(200) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chequeo que la Especialidad a MODIFICAR exista en tabla Actividades.Especialidad
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.Especialidad
        WHERE codEspecialidad = @codEspecialidad
        )
    BEGIN
        SET @errorMsg = 'No existe la Especialidad con codigo: ' + CAST(@codEspecialidad AS VARCHAR)
        ;THROW 52200, @errorMsg,1
    END

    UPDATE Actividades.Especialidad
    SET descripcion = ISNULL(@descripcion, descripcion)
    WHERE codEspecialidad = @codEspecialidad
END
go

-- Eliminar una entrada de Especialidad segun codEspecialidad
CREATE OR ALTER PROCEDURE Actividades.Especialidad_Baja
        @codEspecialidad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chequeo que la Especialidad a ELIMINAR exista en tabla Actividades.Especialidad
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.Especialidad
        WHERE codEspecialidad = @codEspecialidad
        )
    BEGIN
        SET @errorMsg = 'No existe la Especialidad con codigo: ' + CAST(@codEspecialidad AS VARCHAR)
        ;THROW 52300, @errorMsg,1
    END
    DELETE FROM Actividades.Especialidad
    WHERE codEspecialidad = @codEspecialidad
END
go

 ------ SP para tabla Actividades.Guia ------
---------------------------------------------
 
 -- Alta con idEspecialidad obligatorio y fecha actual sino se especifica
 CREATE OR ALTER PROCEDURE Actividades.Guia_Alta
        @fecha DATE = NULL,
        @codEspecialidad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chequeo que el codEspecialidad a INSERTAR exista en tabla Actividades.Especialidad
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.Especialidad
        WHERE codEspecialidad = @codEspecialidad
        )
    BEGIN
        SET @errorMsg = 'No existe la Especialidad con codigo: ' + CAST(@codEspecialidad AS VARCHAR)
        ;THROW 53100, @errorMsg,1
    END

    -- Si la fecha a INSERTAR no es especificada se crea con la fecha actual
    IF @fecha IS NULL
        SET @fecha = CAST(GETDATE() AS DATE)

    INSERT INTO Actividades.Guia(fecha, codEspecialidad)
    VALUES (@fecha, @codEspecialidad)
END
go

-- Modificar fecha y/o Especialidad del Guia segun idGuia
CREATE OR ALTER PROCEDURE Actividades.Guia_Modificar 
        @idGuia INT,
        @fecha DATE = NULL,
        @codEspecialidad INT = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)
    
    -- Chqueo que la idGuia a MODIFICAR exista en tabla Actividades.Guia
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.Guia
        WHERE idGuia = @idGuia
        )
    BEGIN
        SET @errorMsg = 'No existe el Guia con id: ' + CAST(@idGuia AS VARCHAR)
        ;THROW 53200, @errorMsg,1
    END

    -- Chequeo que la Especialidad a MODIFICAR exista en tabla Actividades.Especialidad
    IF @codEspecialidad IS NOT NULL AND NOT EXISTS (
        SELECT 1 
        FROM Actividades.Especialidad
        WHERE codEspecialidad = @codEspecialidad
        )
    BEGIN
        SET @errorMsg = 'No existe la Especialidad con codigo: ' + CAST(@codEspecialidad AS VARCHAR)
        ;THROW 53201, @errorMsg,2
    END
    
    UPDATE Actividades.Guia
    SET fecha = ISNULL(@fecha, fecha),
        codEspecialidad = ISNULL(@codEspecialidad, codEspecialidad)
    WHERE idGuia = @idGuia
END
go

-- Eliminar una entrada de Guia segun idGuia
CREATE OR ALTER PROCEDURE Actividades.Guia_Baja 
        @idGuia INT
AS
BEGIN
     DECLARE @errorMsg VARCHAR(100)
    
    -- Chqueo que la idGuia a ELIMINAR exista en tabla Actividades.Guia
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.Guia
        WHERE idGuia = @idGuia
        )
    BEGIN
        SET @errorMsg = 'No existe el Guia con id: ' + CAST(@idGuia AS VARCHAR)
        ;THROW 53300, @errorMsg,1
    END

    DELETE FROM Actividades.Guia
    WHERE idGuia = @idGuia
END
go

------ SP para tabla Actividades.Titulo ------
----------------------------------------------


-- Alta con nombre e idGuia obligatorio
CREATE OR ALTER PROCEDURE Actividades.Titulo_Alta
        @nombre VARCHAR(100),
        @descripcion VARCHAR(200) = '',
        @idGuia INT
AS
BEGIN
     DECLARE @errorMsg VARCHAR(100)
    
    -- Chqueo que la idGuia a INSERTAR exista en tabla Actividades.Guia
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.Guia
        WHERE idGuia = @idGuia
        )
    BEGIN
        SET @errorMsg = 'No existe el Guia con id: ' + CAST(@idGuia AS VARCHAR)
        ;THROW 54100, @errorMsg,1
    END

    -- Chequeo que el nombre de titulo a INSERTAR no este vacio
    IF LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        ;THROW 54101,'El nombre de titulo no debe estar vacio',2
    END

    INSERT INTO Actividades.Titulo(nombre, descripcion, idGuia)
    VALUES (@nombre, @descripcion, @idGuia)
END
go

-- Modificar datos del Titulo segun codTitulo
CREATE OR ALTER PROCEDURE Actividades.Titulo_Modificar 
        @codTitulo INT,
        @nombre VARCHAR(100) = NULL,
        @descripcion VARCHAR(200) = '',
        @idGuia INT = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chqueo que el codTitulo a MODIFICAR exista en tabla Actividades.Titulo
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.Titulo
        WHERE codTitulo = @codTitulo
    )
    BEGIN
        SET @errorMsg = 'No existe titulo con codigo: ' + CAST(@codTitulo AS VARCHAR)
        ;THROW 54200, @errorMsg,1
    END

    -- Chequeo que el nombre a MODIFICAR no este vacio
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        ;THROW 54201,'El nombre de titulo no debe estar vacio',2
    END

    -- Chequeo que el idGuia a MODIFICAR exista en tabla Actividades.Guia
    IF @idGuia IS NOT NULL AND NOT EXISTS (
        SELECT 1 
        FROM Actividades.Guia
        WHERE idGuia = @idGuia
        )
    BEGIN
        SET @errorMsg = 'No existe el Guia con id: ' + CAST(@idGuia AS VARCHAR)
        ;THROW 54202, @errorMsg,3
    END

    UPDATE Actividades.Titulo
    SET nombre = ISNULL(@nombre,nombre),
        descripcion = ISNULL(@descripcion, descripcion),
        idGuia = ISNULL(@idGuia, idGuia)
    WHERE codTitulo = @codTitulo
END
go

-- Eliminar una entrada de Titulo segun codTitulo
CREATE OR ALTER PROCEDURE Actividades.Titulo_Baja
        @codTitulo INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

      -- Chqueo que el codTitulo a ELIMINAR exista en tabla Actividades.Titulo
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.Titulo
        WHERE codTitulo = @codTitulo
    )
    BEGIN
        SET @errorMsg = 'No existe titulo con codigo: ' + CAST(@codTitulo AS VARCHAR)
        ;THROW 54300, @errorMsg,1
    END

    DELETE FROM Actividades.Titulo
    WHERE codTitulo = @codTitulo
END
go

------ SP para tabla Actividades.Tour ------
--------------------------------------------


-- Alta de Tour con idActividad, idGuia y fechaInicio obligatorio y fechaDesde actual sino se especifica
CREATE OR ALTER PROCEDURE Actividades.Tour_Alta
        @idActividad INT,
        @idGuia INT,
        @fechaInicio DATE,
        @fechaDesde DATE = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

      -- Chequeo que el idActividad a INSERTAR exista en tabla Actividades.Actividad
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.Actividad
        WHERE idActividad = @idActividad
    )
    BEGIN
        SET @errorMsg = 'No existe actividad con id: ' + CAST(@idActividad AS VARCHAR)
        ;THROW 55100, @errorMsg,1
    END

      -- Chequeo que el idGuia a INSERTAR exista en tabla Actividades.Guia
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.Guia
        WHERE idGuia = @idGuia
    )
    BEGIN
        SET @errorMsg = 'No existe guia con id: ' + CAST(@idGuia AS VARCHAR)
        ;THROW 55101, @errorMsg,2
    END

    -- Chequeo que fechaInicio a INSERTAR no sea menor a la fecha actual
    IF @fechaInicio < CAST(GETDATE() AS DATE)
    BEGIN
        ;THROW 55102, 'El tour no puede iniciar previo a la fecha del dia.',3
    END

    IF @fechaDesde IS NULL
        SET @fechaDesde = CAST(GETDATE() AS DATE)

    INSERT INTO Actividades.Tour(idActividad, idGuia, fechaInicio, fechaDesde)
    VALUES (@idActividad, @idGuia, @fechaInicio, @fechaDesde)
END
go

-- Modificar datos de Tour segun idGuia y idActividad
CREATE OR ALTER PROCEDURE Actividades.Tour_Modificar
        @idGuia INT = NULL,
        @idGuiaFinal INT = NULL,
        @idActividad INT = NULL,
        @idActividadFinal INT = NULL,
        @fechaInicio DATE = NULL,
        @fechaDesde DATE = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chequeo que el idGuia y idActividad a MODIFICAR no sean ambos NULL
    IF @idGuia IS NULL AND @idActividad IS NULL
    BEGIN
        ;THROW 55200,'Se necesita un id de guia o actividad de referencia.',1
    END

    -- Chequeo que el idGuiaFinal a MODIFICAR exista en tabla Actividades.Guia
    IF @idGuiaFinal IS NOT NULL 
               AND EXISTS (
                   SELECT 1
                   FROM Actividades.Guia
                   WHERE idGuia = @idGuiaFinal
                   )
    BEGIN
        SET @errorMsg = 'No existe un guia con id: ' + CAST(@idGuiaFinal AS VARCHAR)
        ;THROW 55201,@errorMsg,2
    END

    -- Chequeo que el idActividadFinal a MODIFICAR exista en tabla Actividades.Actividades
    IF @idActividadFinal IS NOT NULL 
               AND EXISTS (
                   SELECT 1
                   FROM Actividades.Actividad
                   WHERE idActividad = @idActividadFinal
                   )
    BEGIN
        SET @errorMsg = 'No existe una actividad con id: ' + CAST(@idActividadFinal AS VARCHAR)
        ;THROW 55202,@errorMsg,3
    END

    -- Chequeo que fechaInicio a MODIFICAR no sea menor a la fecha actual
    IF @fechaInicio IS NOT NULL AND @fechaInicio < CAST(GETDATE() AS DATE)
    BEGIN
        ;THROW 55203, 'El tour no puede iniciar previo a la fecha del dia.',4
    END

    -- Chequeo que fechaDesde a MODIFICAR no sea menor a la fecha actual
    IF @fechaDesde IS NOT NULL AND @fechaDesde < CAST(GETDATE() AS DATE)
    BEGIN
        ;THROW 55204, 'El tour no puede iniciar previo a la fecha del dia.',5
    END


    UPDATE Actividades.Tour
    SET idGuia = ISNULL(@idGuiaFinal, idGuia),
        idActividad = ISNULL(@idActividadFinal, idActividad),
        fechaInicio = ISNULL(@fechaInicio, fechaInicio),
        fechaDesde = ISNULL(@fechaDesde, fechaDesde)
    WHERE idGuia = @idGuia AND idActividad = @idActividad
END
go

-- Eliminar una entrada de Tour segun idGuia y idActividad
CREATE OR ALTER PROCEDURE Actividades.Tour_Baja
        @idGuia INT,
        @idActividad INT
AS
BEGIN
    DELETE FROM Actividades.Tour
    WHERE idGuia = @idGuia AND idActividad = @idActividad
END
go

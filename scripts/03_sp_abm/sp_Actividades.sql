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
CREATE PROCEDURE sp_insertTipoActividad @descripcion VARCHAR(200) = ''
AS
BEGIN
	INSERT INTO Actividades.TipoActividad(descripcion)
	VALUES (@descripcion)
END
go

-- Modificar la descripcion del tipo de actividad segun idTipoActividad
CREATE PROCEDURE sp_modTipoActividad 
        @idTipoActividad INT,
        @descripcion VARCHAR(200) = ''
AS
BEGIN
    UPDATE Actividades.TipoActividad
    SET descripcion = @descripcion
    WHERE idTipoActividad = @idTipoActividad
END
go

-- Eliminar una entrada de tipo de actividad segun idTipoActividad
CREATE PROCEDURE sp_deleteTipoActividad 
        @idTipoActividad INT
AS
BEGIN
    DELETE FROM Actividades.TipoActividad
    WHERE idTipoActividad = @idTipoActividad
END
go


------ SPs para tabla Actividades.Actividad ------
-------------------------------------------------

-- Insert con nombre y idTipoActividad obligatorio, ademas el nombre debe ser unico
CREATE PROCEDURE sp_insertActividad 
        @nombre VARCHAR(100),  
        @costo DECIMAL(8,2) = 0.0,
        @duracion DECIMAL(3,1) = 0.0,
        @idTipoActividad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chequeo que el nombre sea unico
    IF @nombre IN(SELECT nombre FROM Actividades.Actividad)
    BEGIN
        SET @errorMsg = 'Ya existe una actividad con nombre: ' + @nombre
        ;THROW 50100, @errorMsg,1
    END

    INSERT INTO Actividades.Actividad(nombre, costo, duracion, idTipoActividad)
    VALUES (@nombre, @costo, @duracion, @idTipoActividad)
END
go

-- Modificar datos de actividad segun idActividad
CREATE PROCEDURE sp_modActividad
        @idActividad INT,
        @nombre VARCHAR(100) = NULL,
        @costo DECIMAL(8,2) = NULL,
        @duracion DECIMAL(3,1) = NULL,
        @idTipoActividad INT = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    IF @nombre IS NOT NULL AND @nombre IN(SELECT nombre FROM Actividades.Actividad)
    BEGIN
        SET @errorMsg = 'Ya existe una actividad con nombre: ' + @nombre
        ;THROW 50100, @errorMsg,1
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
CREATE PROCEDURE sp_deleteActividad 
        @idTipoActividad INT
AS
BEGIN
    DELETE FROM Actividades.TipoActividad
    WHERE idTipoActividad = @idTipoActividad
END
go

------ SPs para tabla Actividades.Especialidad ------
-----------------------------------------------------


--Insert con nombre obligatorio
CREATE PROCEDURE sp_insertEspecialidad
        @nombre VARCHAR(100),
        @descripcion VARCHAR(200) = ''
 AS       
 BEGIN
    INSERT INTO Actividades.Especialidad(nombre, descripcion)
    VALUES (@nombre, @descripcion)
 END
 go

 -- Modificar la descripcion de Especialidad segun codEspecialidad
CREATE PROCEDURE sp_modEspecialidad 
        @codEspecialidad INT,
        @descripcion VARCHAR(200) = NULL
AS
BEGIN
    UPDATE Actividades.Especialidad
    SET descripcion = ISNULL(@descripcion, descripcion)
    WHERE codEspecialidad = @codEspecialidad
END
go

-- Eliminar una entrada de Especialidad segun codEspecialidad
CREATE PROCEDURE sp_deleteEspecialidad
        @codEspecialidad INT
AS
BEGIN
    DELETE FROM Actividades.Especialidad
    WHERE codEspecialidad = @codEspecialidad
END
go

 ------ SP para tabla Actividades.Guia ------
---------------------------------------------
 
 -- Insert con idEspecialidad obligatorio y fecha actual sino se especifica
 CREATE PROCEDURE sp_insertGuia
        @fecha DATE = NULL,
        @codEspecialidad INT
AS
BEGIN
    IF @fecha IS NULL
        SET @fecha = CAST(GETDATE() AS DATE)

    INSERT INTO Actividades.Guia(fecha, codEspecialidad)
    VALUES (@fecha, @codEspecialidad)
END
go

-- Modificar fecha y/o Especialidad del Guia segun idGuia
CREATE PROCEDURE sp_modGuia 
        @idGuia INT,
        @fecha DATE = NULL,
        @codEspecialidad INT = NULL
AS
BEGIN
    UPDATE Actividades.Guia
    SET fecha = ISNULL(@fecha, fecha),
        codEspecialidad = ISNULL(@codEspecialidad, codEspecialidad)
    WHERE codEspecialidad = @codEspecialidad
END
go

-- Eliminar una entrada de Guia segun idGuia
CREATE PROCEDURE sp_deleteGuia 
        @idGuia INT
AS
BEGIN
    DELETE FROM Actividades.Guia
    WHERE idGuia = @idGuia
END
go

------ SP para tabla Actividades.Titulo ------
----------------------------------------------


-- Insert con nombre e idTitulo obligatorio
CREATE PROCEDURE sp_insertTitulo
        @nombre VARCHAR(100),
        @descripcion VARCHAR(200) = '',
        @idGuia INT
AS
BEGIN
    INSERT INTO Actividades.Titulo(nombre, descripcion, idGuia)
    VALUES (@nombre, @descripcion, @idGuia)
END
go

-- Modificar datos del Titulo segun codTitulo
CREATE PROCEDURE sp_modTitulo 
        @codTitulo INT,
        @nombre VARCHAR(100) = NULL,
        @descripcion VARCHAR(200) = NULL,
        @idGuia INT = NULL
AS
BEGIN
    UPDATE Actividades.Titulo
    SET nombre = ISNULL(@nombre,nombre),
        descripcion = ISNULL(@descripcion, descripcion),
        idGuia = ISNULL(@idGuia, idGuia)
    WHERE codTitulo = @codTitulo
END
go

-- Eliminar una entrada de Titulo segun codTitulo
CREATE PROCEDURE sp_deleteTitulo
        @codTitulo INT
AS
BEGIN
    DELETE FROM Actividades.Titulo
    WHERE codTitulo = @codTitulo
END
go

------ SP para tabla Actividades.Tour ------
--------------------------------------------


-- Insert con idActividad, idGuia y fechaInicio obligatorio y fechaDesde actual sino se especifica
CREATE PROCEDURE sp_insertTour
        @idActividad INT,
        @idGuia INT,
        @fechaInicio DATE,
        @fechaDesde DATE = NULL
AS
BEGIN
    IF @fechaDesde IS NULL
        SET @fechaDesde = CAST(GETDATE() AS DATE)

    INSERT INTO Actividades.Tour(idActividad, idGuia, fechaInicio, fechaDesde)
    VALUES (@idActividad, @idGuia, @fechaInicio, @fechaDesde)
END
go

-- Modificar datos de Tour segun idGuia y idActividad
CREATE PROCEDURE sp_modTour
        @idGuia INT,
        @idGuiaFinal INT = NULL,
        @idActividad INT,
        @idActividadFinal INT,
        @fechaInicio DATE = NULL,
        @fechaDesde DATE = NULL
AS
BEGIN
    UPDATE Actividades.Tour
    SET idGuia = ISNULL(@idGuiaFinal, idGuia),
        idActividad = ISNULL(@idActividadFinal, idActividad),
        fechaInicio = ISNULL(@fechaInicio, fechaInicio),
        fechaDesde = ISNULL(@fechaDesde, fechaDesde)
    WHERE idGuia = @idGuia AND idActividad = @idActividad
END
go

-- Eliminar una entrada de Tour segun idGuia y idActividad
CREATE PROCEDURE sp_deleteTour
        @idGuia INT,
        @idActividad INT
AS
BEGIN
    DELETE FROM Actividades.Tour
    WHERE idGuia = @idGuia AND idActividad = @idActividad
END
go

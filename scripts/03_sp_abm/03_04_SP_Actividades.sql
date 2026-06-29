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

USE GestionParquesNacionales_Com5600_Grupo07
go

------ SPs para tabla Actividades.tipoActividad ------
-----------------------------------------------------


-- Insert solo con descripcion opcional
CREATE OR ALTER PROCEDURE Actividades.tipoActividadAlta(
    @descripcion VARCHAR(200) = NULL
    )
AS
BEGIN
    IF @descripcion IS NOT NULL AND LEN(@descripcion) > 199
    BEGIN
        ;THROW 50100, 'La descripcion no puede superar los 200 caracteres',1
    END

	INSERT INTO Actividades.tipoActividad(descripcion)
	VALUES (@descripcion)
END
go

-- Modificar la descripcion del tipo de actividad segun idTipoActividad
CREATE OR ALTER PROCEDURE Actividades.tipoActividadModificar(
        @idTipoActividad INT,
        @descripcion VARCHAR(200) = NULL
        )
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = ''
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10)
    
    -- Chequeo que el idTipoActividad a MODIFICAR exista en tabla Actividades.tipoActividad
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.tipoActividad
        WHERE idTipoActividad = @idTipoActividad
        )
    BEGIN
        SET @errorMsg = 'No existe un Tipo de actividad con id: ' + CAST(@idTipoActividad AS VARCHAR) + '.' + @saltoLinea
    END

    IF @descripcion IS NOT NULL AND LEN(@descripcion) > 199
    BEGIN
        SET @errorMsg = @errorMsg + '- La descripcion no puede superar los 200 caracteres.' + @saltoLinea
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50200, @errorMsg,1
    END

    UPDATE Actividades.tipoActividad
    SET descripcion = @descripcion
    WHERE idTipoActividad = @idTipoActividad
END
go

-- Eliminar una entrada de tipo de actividad segun idTipoActividad
CREATE OR ALTER PROCEDURE Actividades.tipoActividadBaja(
        @idTipoActividad INT
        )
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)
    -- Chequeo que el idTipoActividad a ELIMINAR exista en tabla Actividades.tipoActividad
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.tipoActividad
        WHERE idTipoActividad = @idTipoActividad
        )
    BEGIN
        SET @errorMsg = 'No existe un Tipo de actividad con id: ' + CAST(@idTipoActividad AS VARCHAR)
        ;THROW 50300, @errorMsg,1
    END
    DELETE FROM Actividades.tipoActividad
    WHERE idTipoActividad = @idTipoActividad
END
go


------ SPs para tabla Actividades.actividad ------
-------------------------------------------------

-- Insert con nombre, duracion y idTipoActividad obligatorio, ademas el nombre debe ser unico
CREATE OR ALTER PROCEDURE Actividades.actividadAlta(
        @nombre VARCHAR(100),  
        @costo DECIMAL(8,2) = 0.0,
        @duracion DECIMAL(3,1),
        @turno VARCHAR(10),
        @diaDisponible VARCHAR(3),
        @idTipoActividad INT
        )
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = ''
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10)

    -- Chequeo que el nombre a INSERTAR no prexista en tabla Actividades.actividad
    IF @nombre IN(SELECT nombre FROM Actividades.actividad)
    BEGIN
        SET @errorMsg = 'Ya existe una actividad con nombre: ' + @nombre + '.' + @saltoLinea
    END

    -- Chequeo que el nombre a INSERTAR no este vacio
    IF LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        SET @errorMsg = @errorMsg + 'El nombre no puede estar vacio!' + @saltoLinea
    END

    -- Chequeo que la duracion a INSERTAR no sea NULL
    IF @duracion IS NULL
    BEGIN
        SET @errorMsg = @errorMsg + 'La duracion es un campo obligatorio' + @saltoLinea
    END
    -- Chequeo que la duracion a INSERTAR sea mayor a 0
    IF @duracion <= 0
    BEGIN
        SET @errorMsg = @errorMsg + 'El tiempo de duracion debe ser mayor a 0.' + @saltoLinea
    END

    -- Chqueo que el costo a INSERTAR sea 0 (gratis) o mas
    IF @costo < 0
    BEGIN
        SET @errorMsg = @errorMsg + 'El costo debe ser mayor o igual a 0.' + @saltoLinea
    END

    -- Chequeo que el turno sea correcto
    IF @diaDisponible NOT IN ('LUN','MAR','MIE','JUE','VIE','SAB','DOM')
    BEGIN
        SET @errorMsg = @errorMsg + 'El dia disponible debe ser LUN, MAR, MIE, JUE, VIE, SAB O DOM' + @saltoLinea
    END

    -- Chequeo que el turno sea correcto
    IF @turno NOT IN ('MANANA','TARDE','NOCHE')
    BEGIN
        SET @errorMsg = @errorMsg + 'El turno debe ser MANANA, TARDE O NOCHE' + @saltoLinea
    END

    -- Chequeo que la idTipoActividad a INSERTAR exista en tabla Actividad.tipoActividad
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.tipoActividad
        WHERE idTipoActividad = @idTipoActividad
        )
    BEGIN
        SET @errorMsg = @errorMsg + 'No existe un tipo de actividad con id: ' + CAST(@idTipoActividad AS VARCHAR) + '.' + @saltoLinea
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50400, @errorMsg,1
    END

    INSERT INTO Actividades.actividad(nombre, costo, duracion,turno, diaDisponible, idTipoActividad)
    VALUES (@nombre, @costo, @duracion, @turno, @diaDisponible, @idTipoActividad)
END
go

-- Modificar datos de actividad segun idActividad
CREATE OR ALTER PROCEDURE Actividades.actividadModificar(
        @idActividad INT,
        @nombre VARCHAR(100) = NULL,
        @costo DECIMAL(8,2) = NULL,
        @duracion DECIMAL(3,1) = NULL,
        @turno VARCHAR(10) = NULL,
        @diaDisponible VARCHAR(3) = NULL,
        @idTipoActividad INT = NULL
        )
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500)
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10)

    -- Chequeo que la actividad a MODIFICAR exista en tabla Actividades.actividad
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.actividad
        WHERE idActividad = @idActividad
        )
    BEGIN
        SET @errorMsg = 'No existe la actividad con id: ' + CAST(@idActividad AS VARCHAR) + '.' + @saltoLinea
    END

    -- Si se especifica nombre para MODIFICAR este no debe prexistir en la tabla Actividades.actividad
    IF @nombre IS NOT NULL AND @nombre IN(SELECT nombre FROM Actividades.actividad)
    BEGIN
        SET @errorMsg = @errorMsg + 'Ya existe una actividad con nombre: ' + @nombre + '.' + @saltoLinea
    END

     -- Chequeo que el nombre a MODIFICAR no este vacio
    IF @nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        SET @errorMsg = @errorMsg + 'El nombre no puede estar vacio!' + @saltoLinea
    END

    -- Chequeo que la duracion a MODIFICAR sea mayor a 0
    IF @duracion IS NOT NULL AND @duracion <= 0
    BEGIN
        SET @errorMsg = @errorMsg + 'El tiempo de duracion debe ser mayor a 0.' + @saltoLinea
    END

    -- Chequeo que el costo a MODIFICAR no sea negativo
    IF @costo IS NOT NULL AND @costo < 0
    BEGIN
        SET @errorMsg = @errorMsg + 'El costo debe ser mayor o igual a 0.' + @saltoLinea
    END

    -- Chequeo que el turno sea correcto
    IF @diaDisponible IS NOT NULL AND @diaDisponible NOT IN ('LUN','MAR','MIE','JUE','VIE','SAB','DOM')
    BEGIN
        SET @errorMsg = @errorMsg + 'El dia disponible debe ser LUN, MAR, MIE, JUE, VIE, SAB O DOM' + @saltoLinea
    END

    -- Chequeo que el turno sea correcto
    IF @turno IS NOT NULL AND @turno NOT IN ('MANANA','TARDE','NOCHE')
    BEGIN
        SET @errorMsg = @errorMsg + 'El turno debe ser MANANA, TARDE O NOCHE' + @saltoLinea
    END

    -- Chequeo que el idTipoActividad a MODIFICAR exista en tabla Actividades.tipoActividad
    IF @idTipoActividad IS NOT NULL 
        AND NOT EXISTS (
        SELECT  1
        FROM Actividades.tipoActividad
        WHERE tipoActividad.idTipoActividad = @idTipoActividad
        )
    BEGIN
        SET @errorMsg = @errorMsg + 'No existe el tipo de actividad con id: ' + CAST(@idTipoActividad AS VARCHAR) + '.' + @saltoLinea
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50500, @errorMsg,1
    END

    UPDATE Actividades.actividad
    SET nombre = ISNULL(@nombre, nombre), 
        costo = ISNULL(@costo, costo), 
        duracion = ISNULL(@duracion, duracion),
        turno = ISNULL(@turno, turno),
        diaDisponible = ISNULL(@diaDisponible, diaDisponible),
        idTipoActividad = ISNULL(@idTipoActividad, idTipoActividad)
    WHERE idActividad = @idActividad
END
go

-- Eliminar una entrada de actividad segun idActividad
CREATE OR ALTER PROCEDURE Actividades.actividadBaja(
        @idActividad INT
        )
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)

    -- Chequeo que la actividad a ELIMINAR exista en tabla Actividades.actividad
    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.actividad
        WHERE idActividad = @idActividad
        )
    BEGIN
        SET @errorMsg = 'No existe la actividad con id: ' + CAST(@idActividad AS VARCHAR)
        ;THROW 51300, @errorMsg,1
    END
    
    DELETE FROM Actividades.actividad
    WHERE idActividad = @idActividad
END
go


------ SP para tabla Actividades.tour ------
--------------------------------------------


-- Alta de tour con idActividad, idGuia y fechaInicio obligatorio y fechaDesde actual sino se especifica
CREATE OR ALTER PROCEDURE Actividades.tourAlta(
        @idActividad INT,
        @legajo INT,
        @fechaInicio DATE,
        @fechaDesde DATE = NULL,
        @cupoMaximo INT = NULL
        )
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500)
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10)

      -- Chequeo que el idActividad a INSERTAR exista en tabla Actividades.actividad
    IF NOT EXISTS (
        SELECT 1
        FROM Actividades.actividad
        WHERE idActividad = @idActividad
    )
    BEGIN
        SET @errorMsg = 'No existe actividad con id: ' + CAST(@idActividad AS VARCHAR) + '.' + @saltoLinea
    END

      -- Chequeo que el legajo a INSERTAR exista en tabla Personal.guias
    IF NOT EXISTS (
        SELECT 1
        FROM Personal.guias
        WHERE legajo = @legajo
    )
    BEGIN
        SET @errorMsg = @errorMsg + 'No existe guia con legajo: ' + CAST(@legajo AS VARCHAR) + '.' + @saltoLinea
    END

    -- Chequeo que fechaInicio a INSERTAR no sea menor a la fecha actual
    IF @fechaInicio < CAST(GETDATE() AS DATE)
    BEGIN
        SET @errorMsg = @errorMsg + 'El tour no puede iniciar previo a la fecha del dia.' + @saltoLinea
    END

    IF @fechaDesde IS NULL
        SET @fechaDesde = CAST(GETDATE() AS DATE)

    IF @fechaDesde < CAST(GETDATE() AS DATE)
    BEGIN
        SET @errorMsg = @errorMsg + 'El tour no puede ser desde tiempo previo a la fecha del dia.' + @saltoLinea
    END

    IF @cupoMaximo IS NULL
    BEGIN 
        SET @errorMsg = @errorMsg + 'El cupo maximo es un campo obligatorio.' + @saltoLinea
    END

    IF @cupoMaximo <= 0
    BEGIN
        SET @errorMsg = @errorMsg + 'El cupo maximo debe ser mayor a 0.' + @saltoLinea
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50600, @errorMsg,1
    END

    INSERT INTO Actividades.tour(idActividad, legajo, fechaInicio, fechaDesde, cupoMaximo)
    VALUES (@idActividad, @legajo, @fechaInicio, @fechaDesde, @cupoMaximo)
END
go

-- Modificar datos de tour segun idGuia y idActividad Y fechaInicio
CREATE OR ALTER PROCEDURE Actividades.tourModificar(
        @legajo INT,
        @idActividad INT,
        @fechaInicio DATE,
        @fechaDesde DATE = NULL,
        @cupoMaximo INT = NULL
        )
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500)
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10)

    -- Chequeo que el legajo y idActividad a MODIFICAR no sean ambos NULL
    IF @legajo IS NULL OR @idActividad IS NULL OR @fechaInicio IS NULL
    BEGIN
        SET @errorMsg = 'Se necesita un legajo de guia, ID actividad y fecha de inicio de referencia.' + @saltoLinea
    END

    IF NOT EXISTS (SELECT 1 FROM Actividades.tour WHERE idActividad = @idActividad AND legajo = @legajo AND fechaInicio = @fechaInicio)
    BEGIN
        SET @errorMsg = @errorMsg + 'No existe un tour con legajo: ' + CAST(@legajo AS VARCHAR) + ', id actividad: ' + CAST(@idActividad AS VARCHAR) + ' y fecha de inicio: ' + CAST(@fechaInicio AS VARCHAR) + @saltoLinea
    END

    -- Chequeo que fechaDesde a MODIFICAR no sea menor a la fecha actual
    IF @fechaDesde IS NOT NULL AND @fechaDesde < CAST(GETDATE() AS DATE)
    BEGIN
        SET @errorMsg = @errorMsg + 'El tour no puede ser desde tiempo previo a la fecha del dia.' + @saltoLinea
    END

    IF @cupoMaximo IS NOT NULL AND @cupoMaximo <= 0
    BEGIN
        SET @errorMsg = @errorMsg + 'El cupo maximo debe ser mayor a 0.' + @saltoLinea
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50700, @errorMsg,1
    END


    UPDATE Actividades.tour
    SET fechaDesde = ISNULL(@fechaDesde, fechaDesde),
        cupoMaximo = ISNULL(@cupoMaximo, cupoMaximo)
    WHERE legajo = @legajo AND idActividad = @idActividad
END
go

-- Eliminar una entrada de tour segun legajo y/o idActividad
CREATE OR ALTER PROCEDURE Actividades.tourBaja(
        @legajo INT,
        @idActividad INT,
        @fechaInicio DATE
        )
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100)
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10)

    IF NOT EXISTS (
        SELECT 1 
        FROM Actividades.tour
        WHERE legajo = @legajo AND idActividad = @idActividad AND fechaInicio = @fechaInicio
        )
        SET @errorMsg = 'No existe un tour con legajo: ' + CAST(@legajo AS VARCHAR) + 
        ', idActividad: ' + CAST(@idActividad AS VARCHAR) + 
        ' o fecha de inicio: ' + CAST(@fechaInicio AS VARCHAR) + @saltoLinea
        ;THROW 50800, @errorMsg,1

    DELETE FROM Actividades.tour
    WHERE legajo = @legajo AND idActividad = @idActividad AND fechaInicio = @fechaInicio
END
go

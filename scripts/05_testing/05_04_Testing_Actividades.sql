/* 
    Script generado el 19/06/2026

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Este script es de testing para los procedimientos almacenados del esquema Actividades.
*/
USE GestionParquesNacionales_Com5600_Grupo07;
go

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Crear tabla de resultados para registrar pruebas
IF OBJECT_ID('tempdb..#TestResultados') IS NOT NULL
    DROP TABLE #TestResultados;

CREATE TABLE #TestResultados (
    TestID INT IDENTITY(1,1),
    NombreTest NVARCHAR(255),
    Procedimiento NVARCHAR(128),
    Estado VARCHAR(20), -- 'EXITOSO' o 'ERROR'
    Mensaje NVARCHAR(MAX),
    FechaEjecucion DATETIME2 DEFAULT SYSUTCDATETIME()
);


PRINT '========================================';
PRINT 'INICIO DE PRUEBAS - PROCEDIMIENTOS ABM';
PRINT '========================================';
PRINT '';

-- ========================================
-- 1. PROCEDIMIENTO: tipoActividadAlta
-- ========================================
PRINT '1. Probando tipoActividadAlta...';
BEGIN TRY
    -- Caso 1: Alta exitosa con todos los parámetros
    EXEC Actividades.tipoActividadAlta
        @descripcion = 'Deportes Acuáticos';
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Caso exitoso con todos los parámetros', 'tipoActividadAlta', 'EXITOSO', 
            'Tipo Actividad registrada correctamente');
    PRINT 'Caso 1: Alta exitosa';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Caso exitoso con todos los parámetros', 'tipoActividadAlta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Alta con descripcion NULL (campo opcional)
    EXEC Actividades.tipoActividadAlta
        @descripcion = NULL;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion NULL (campo opcional)', 'tipoActividadAlta', 'EXITOSO', 
            'Tipo Actividad con descripcion NULL registrada');
    PRINT 'Caso 2: descripcion NULL';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion NULL (campo opcional)', 'tipoActividadAlta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 2 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 3: Alta con descripcion Vacia (campo opcional)
    EXEC Actividades.tipoActividadAlta
        @descripcion = '';
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion vacia (campo opcional)', 'tipoActividadAlta', 'EXITOSO', 
            'Tipo Actividad con descripcion vacia registrada');
    PRINT 'Caso 3: descripcion vacia';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion vacia (campo opcional)', 'tipoActividadAlta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 3 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 4: Alta con descripcion muy larga (debe fallar)
    DECLARE @descripcionMuyLarga VARCHAR(300) = REPLICATE(N'A', 300); -- Ajusta la longitud según la definición de la columna
    EXEC Actividades.tipoActividadAlta
        @descripcion = @descripcionMuyLarga -- Asumiendo que el campo tiene un límite menor
    
    print LEN(@descripcionMuyLarga);
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion muy larga (validación de longitud)', 'tipoActividadAlta', 'ERROR', 
            'Se esperaba error por longitud excedida pero el procedimiento fue exitoso');
    PRINT 'Caso 4: Validación de longitud (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion muy larga (validación de longitud)', 'tipoActividadAlta', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 4: Validación de longitud funcionando';
END CATCH

PRINT '';

-- ========================================
-- 2. PROCEDIMIENTO: tipoActividadModificar
-- ========================================

PRINT '2. Probando tipoActividadModificar...';
BEGIN TRY
    -- Obtener primer ID de tipo actividad para prueba
    DECLARE @idTipoActividadTest INT;
    SELECT TOP 1 @idTipoActividadTest = idTipoActividad FROM Actividades.tipoActividad;
    
    IF @idTipoActividadTest IS NOT NULL
    BEGIN
        -- Caso 1: Modificación exitosa de la descripción
        EXEC Actividades.tipoActividadModificar
            @idTipoActividad = @idTipoActividadTest,
            @descripcion = 'Deportes Acuáticos Modificado';
        
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Modificar - Actualización de descripcion', 'tipoActividadModificar', 'EXITOSO', 
                'Tipo Actividad ID ' + CAST(@idTipoActividadTest AS VARCHAR) + ' modificada');
        PRINT 'Caso 1: Modificación exitosa';
    END
    ELSE
    BEGIN
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Modificar - Actualización de descripcion', 'tipoActividadModificar', 'ERROR', 
                'No hay tipos de actividad en la tabla para modificar');
        PRINT 'Caso 1: No hay datos de prueba';
    END
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Actualización de descripcion', 'tipoActividadModificar', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Modificación con ID inexistente
    EXEC Actividades.tipoActividadModificar
        @idTipoActividad = 9999,
        @descripcion = 'Tipo Actividad Fantasma';
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'tipoActividadModificar', 'ERROR', 
            'Se esperaba error con ID inexistente pero fue exitoso');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'tipoActividadModificar', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

BEGIN TRY
    -- Caso 3: Modificación con descripcion muy larga (debe fallar)
    DECLARE @descripcionMuyLarga2 VARCHAR(300) = REPLICATE(N'A', 300); -- Ajusta la longitud según la definición de la columna
    EXEC Actividades.tipoActividadModificar
        @idTipoActividad = @idTipoActividadTest,
        @descripcion = @descripcionMuyLarga; -- Asumiendo que el campo tiene un límite menor
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Descripcion muy larga (validación de longitud)', 'tipoActividadModificar', 'ERROR', 
            'Se esperaba error por longitud excedida pero el procedimiento fue exitoso');
    PRINT 'Caso 3: Validación de longitud (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Descripcion muy larga (validación de longitud)', 'tipoActividadModificar', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 3: Validación de longitud funcionando';
END CATCH

PRINT '';

-- ========================================
-- 3. PROCEDIMIENTO: tipoActividadBaja
-- ========================================

PRINT '3. Probando tipoActividadBaja...';
BEGIN TRY
    -- Primero inserto un tipo de actividad para prueba de baja
    DECLARE @idTipoActividadBaja INT;
    
    EXEC Actividades.tipoActividadAlta
        @descripcion = 'Tipo Actividad Prueba Baja';
    
    -- Obtengo el ID recién insertado
    SELECT TOP 1 @idTipoActividadBaja = idTipoActividad 
    FROM Actividades.tipoActividad 
    WHERE descripcion = 'Tipo Actividad Prueba Baja'
    
    -- Caso 1: Baja exitosa
    IF @idTipoActividadBaja IS NOT NULL
    BEGIN
        EXEC Actividades.tipoActividadBaja @idTipoActividad = @idTipoActividadBaja;
        
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Baja - Eliminación exitosa', 'tipoActividadBaja', 'EXITOSO', 
                'Tipo Actividad ID ' + CAST(@idTipoActividadBaja AS VARCHAR) + ' eliminada');
        PRINT 'Caso 1: Baja exitosa';
    END
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - Eliminación exitosa', 'tipoActividadBaja', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Baja de ID inexistente
    EXEC Actividades.tipoActividadBaja @idTipoActividad = 9999;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'tipoActividadBaja', 'ERROR', 
            'Se esperaba error con ID inexistente');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'tipoActividadBaja', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

SELECT * FROM Actividades.tipoActividad

PRINT '';

-- ========================================
-- 1. PROCEDIMIENTO: actividadAlta
-- ========================================
DECLARE @idTipoActividadParaActividad INT;
SET @idTipoActividadParaActividad = (SELECT TOP 1 idTipoActividad FROM Actividades.tipoActividad ORDER BY idTipoActividad DESC);

PRINT '1. Probando actividadAlta...';
BEGIN TRY
    -- Caso 1: Alta exitosa con todos los parámetros
    EXEC Actividades.actividadAlta
        @nombre = 'Senderismo en Montaña',
        @costo = 450.50,
        @duracion = 8.0,
        @idTipoActividad = @idTipoActividadParaActividad;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Caso exitoso con todos los parámetros', 'actividadAlta', 'EXITOSO', 
            'Actividad registrada correctamente');
    PRINT 'Caso 1: Alta exitosa';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Caso exitoso con todos los parámetros', 'actividadAlta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Alta con costo NULL (campo opcional)
    EXEC Actividades.actividadAlta
        @nombre = 'Fotografía de Fauna',
        @costo = NULL,
        @duracion = 4.5,
        @idTipoActividad = @idTipoActividadParaActividad;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Costo NULL (campo opcional)', 'actividadAlta', 'EXITOSO', 
            'Actividad con costo NULL registrada');
    PRINT 'Caso 2: Costo NULL';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Costo NULL (campo opcional)', 'actividadAlta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 2 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 3: Alta con duración NULL (campo opcional)
    EXEC Actividades.actividadAlta
        @nombre = 'Observación de Aves',
        @costo = 150.00,
        @duracion = NULL,
        @idTipoActividad = @idTipoActividadParaActividad;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Duración NULL', 'actividadAlta', 'ERROR', 
            'Se esperaba error por campo obligatorio como NULL pero el procedimiento fue exitoso');
    PRINT 'Caso 3: Duración NULL';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Duración NULL Validacion', 'actividadAlta', 'EXITOSO', 'Error capturado correctamente: ' + 
            ERROR_MESSAGE());
    PRINT 'Caso 3 : Validacion de duracion funcionando';
END CATCH

BEGIN TRY
    -- Caso 4: Alta con idTipoActividad inválido (debe fallar)
    EXEC Actividades.actividadAlta
        @nombre = 'Actividad Inválida',
        @costo = 100.00,
        @duracion = 2.0,
        @idTipoActividad = 9999;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - idTipoActividad inválido (validación FK)', 'actividadAlta', 'ERROR', 
            'Se esperaba error por FK inválida pero el procedimiento fue exitoso');
    PRINT 'Caso 4: Validación de FK (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - idTipoActividad inválido (validación FK)', 'actividadAlta', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 4: FK validada correctamente';
END CATCH

PRINT '';

-- ========================================
-- 2. PROCEDIMIENTO: actividadModificar
-- ========================================
PRINT '2. Probando actividadModificar...';
BEGIN TRY
    -- Obtener primer ID de actividad para prueba
    DECLARE @idActividadTest INT;
    SELECT TOP 1 @idActividadTest = idActividad FROM Actividades.actividad WHERE nombre = 'Senderismo en Montaña';
    
    IF @idActividadTest IS NOT NULL
    BEGIN
        -- Caso 1: Modificación exitosa de todos los campos
        EXEC Actividades.actividadModificar
            @idActividad = @idActividadTest,
            @nombre = 'Senderismo Modificado',
            @costo = 550.00,
            @duracion = 9.0,
            @idTipoActividad = @idTipoActividadParaActividad;
        
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Modificar - Actualización de todos los campos', 'actividadModificar', 'EXITOSO', 
                'Actividad ID ' + CAST(@idActividadTest AS VARCHAR) + ' modificada');
        PRINT 'Caso 1: Modificación exitosa';
    END
    ELSE
    BEGIN
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Modificar - Actualización de todos los campos', 'actividadModificar', 'ERROR', 
                'No hay actividades en la tabla para modificar');
        PRINT 'Caso 1: No hay datos de prueba';
    END
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Actualización de todos los campos', 'actividadModificar', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Modificación con ID inexistente
    EXEC Actividades.actividadModificar
        @idActividad = 99999,
        @nombre = 'Actividad Fantasma',
        @costo = 100.00,
        @duracion = 1.0,
        @idTipoActividad = 1;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'actividadModificar', 'ERROR', 
            'Se esperaba error con ID inexistente pero fue exitoso');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'actividadModificar', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

PRINT '';

-- ========================================
-- 3. PROCEDIMIENTO: actividadBaja
-- ========================================
PRINT '3. Probando actividadBaja...';
BEGIN TRY
    -- Primero insertamos una actividad específica para prueba de baja
    DECLARE @idActividadBaja INT;
    
    EXEC Actividades.actividadAlta
        @nombre = 'Actividad Para Prueba Baja',
        @costo = 100.00,
        @duracion = 1.0,
        @idTipoActividad = @idTipoActividadParaActividad;
    
    -- Obtener el ID recién insertado
    SELECT TOP 1 @idActividadBaja = idActividad 
    FROM Actividades.actividad 
    WHERE nombre = 'Actividad Para Prueba Baja'
    ORDER BY idActividad DESC;
    
    -- Caso 1: Baja exitosa
    IF @idActividadBaja IS NOT NULL
    BEGIN
        EXEC Actividades.actividadBaja @idActividad = @idActividadBaja;
        
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Baja - Eliminación exitosa', 'actividadBaja', 'EXITOSO', 
                'Actividad ID ' + CAST(@idActividadBaja AS VARCHAR) + ' eliminada');
        PRINT 'Caso 1: Baja exitosa';
    END
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - Eliminación exitosa', 'actividadBaja', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Baja de ID inexistente
    EXEC Actividades.actividadBaja @idActividad = 99999;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'actividadBaja', 'ERROR', 
            'Se esperaba error con ID inexistente');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'actividadBaja', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

PRINT '';

SELECT * FROM Actividades.actividad



-- ========================================
-- 1. PROCEDIMIENTO: tourAlta
-- ========================================
PRINT '1. Probando tourAlta...';

--- Comprobamos si hay guías existentes para usar en las pruebas, si no, creamos una guía de prueba con titulo y especialidad válidos. 
--- Esto es necesario para poder realizar las pruebas de tourAlta, ya que requiere un legajo de guía válido.
DECLARE @legajoPrueba INT,
        @codTituloPrueba INT,
        @codEspecialidadPrueba INT;

IF (SELECT TOP 1 legajo FROM Personal.guias) IS NULL
BEGIN
    IF (SELECT TOP 1 codTitulo FROM Personal.titulos) IS NULL
        BEGIN
            -- Insertamos un título de prueba si no existe ninguno
            EXEC Personal.altaTitulo
                @nombre = 'Titulo Prueba',
                @descripcion = 'Descripcion Titulo Prueba';
        END
    SET @codTituloPrueba = (SELECT TOP 1 codTitulo FROM Personal.titulos)

    IF (SELECT TOP 1 codEspecialidad FROM Personal.especialidad) IS NULL
    BEGIN
        -- Insertamos una especialidad de prueba si no existe ninguna
        EXEC Personal.altaEspecialidad
            @nombre = 'Especialidad Prueba',
            @descripcion = 'Descripcion Especialidad Prueba';
    END
    SET @codEspecialidadPrueba = (SELECT TOP 1 codEspecialidad FROM Personal.especialidad)
    
    EXEC Personal.altaGuia
            @nombre = 'Guia Prueba',
            @apellido = 'Apellido Prueba',
            @documento = '12345678',
            @codTitulo = @codTituloPrueba,
            @codEspecialidad = @codEspecialidadPrueba,
            @fechaNacimiento = '1990-01-01';
END
SET @legajoPrueba = (SELECT TOP 1 legajo FROM Personal.guias)

BEGIN TRY
    -- Caso 1: Alta exitosa con todos los parámetros
    EXEC Actividades.tourAlta
        @idActividad = @idActividadTest,
        @legajo = @legajoPrueba,
        @fechaInicio = '2026-07-01',
        @fechaDesde = '2026-07-10',
        @cupoMaximo = 15;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Alta exitoso con todos los parámetros', 'tourAlta', 'EXITOSO', 
            'Tour registrado correctamente');
    PRINT 'Caso 1: Alta exitosa';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Alta exitoso con todos los parámetros', 'tourAlta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Alta con fechaDesde NULL (campo opcional)
    EXEC Actividades.tourAlta
        @idActividad = @idActividadTest,
        @legajo = @legajoPrueba,
        @fechaInicio = '2026-07-15',
        @fechaDesde = NULL,
        @cupoMaximo = 10;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - fechaDesde NULL (campo opcional)', 'tourAlta', 'EXITOSO', 
            'Tour con fechaDesde NULL registrado');
    PRINT 'Caso 2: fechaDesde NULL';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - fechaDesde NULL (campo opcional)', 'tourAlta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 2 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 3: Alta con idActividad inválido (debe fallar)
    EXEC Actividades.tourAlta
        @idActividad = 99999,
        @legajo = @legajoPrueba,
        @fechaInicio = '2026-07-20',
        @fechaDesde = '2026-07-25',
        @cupoMaximo = 10;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - idActividad inválido (validación FK)', 'tourAlta', 'ERROR', 
            'Se esperaba error por FK inválida pero el procedimiento fue exitoso');
    PRINT 'Caso 3: Validación de FK (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - idActividad inválido (validación FK)', 'tourAlta', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 3: FK validada correctamente';
END CATCH

BEGIN TRY
    -- Caso 4: Alta con legajo inválido (debe fallar)
    EXEC Actividades.tourAlta
        @idActividad = @idActividadTest,
        @legajo = 99999,
        @fechaInicio = '2026-07-30',
        @fechaDesde = '2026-08-05',
        @cupoMaximo = 15;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - legajo inválido (validación FK)', 'tourAlta', 'ERROR', 
            'Se esperaba error por FK inválida pero el procedimiento fue exitoso');
    PRINT 'Caso 4: Validación de FK (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - legajo inválido (validación FK)', 'tourAlta', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 4: FK validada correctamente';
END CATCH

BEGIN TRY
    -- Caso 5: Alta con cupoMaximo <= 0 (debe fallar)
    EXEC Actividades.tourAlta
        @idActividad = @idActividadTest,
        @legajo = @legajoPrueba,
        @fechaInicio = '2026-08-10',
        @fechaDesde = '2026-08-15',
        @cupoMaximo = 0;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - cupoMaximo <= 0 (validación CHECK)', 'tourAlta', 'ERROR', 
            'Se esperaba error por cupoMaximo inválido pero el procedimiento fue exitoso');
    PRINT 'Caso 5: Validación de CHECK (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - cupoMaximo <= 0 (validación CHECK)', 'tourAlta', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 5: Validación de CHECK funcionando';
END CATCH

-- ========================================
-- 2. PROCEDIMIENTO: tourModificar
-- ========================================

BEGIN TRY
    -- Caso 1: Modificación exitosa de todos los campos
    EXEC Actividades.tourModificar
        @idActividad = @idActividadTest,
        @legajo = @legajoPrueba,
        @fechaInicio = '2026-07-01',
        @fechaDesde = '2026-07-15',
        @cupoMaximo = 20;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Actualización de todos los campos', 'tourModificar', 'EXITOSO', 
            'Tour modificado correctamente');
    PRINT 'Caso 1: Modificación exitosa';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Actualización de todos los campos', 'tourModificar', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Modificación con ID inexistente
    EXEC Actividades.tourModificar
        @idActividad = 99999,
        @legajo = 99999,
        @fechaInicio = '2026-08-01',
        @fechaDesde = '2026-08-10',
        @cupoMaximo = 15;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'tourModificar', 'ERROR', 
            'Se esperaba error con ID inexistente pero fue exitoso');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'tourModificar', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

BEGIN TRY
    -- Caso 3: Modificación con cupoMaximo <= 0 (debe fallar)
    EXEC Actividades.tourModificar
        @idActividad = @idActividadTest,
        @legajo = @legajoPrueba,
        @fechaInicio = '2026-07-01',
        @fechaDesde = '2026-07-15',
        @cupoMaximo = 0;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - cupoMaximo <= 0 (validación CHECK)', 'tourModificar', 'ERROR', 
            'Se esperaba error por cupoMaximo inválido pero el procedimiento fue exitoso');
    PRINT 'Caso 3: Validación de CHECK (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - cupoMaximo <= 0 (validación CHECK)', 'tourModificar', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 3: Validación de CHECK funcionando';
END CATCH

-- ========================================
-- 3. PROCEDIMIENTO: tourBaja
-- ========================================

BEGIN TRY
    -- Caso 1: Baja exitosa
    EXEC Actividades.tourBaja
        @idActividad = @idActividadTest,
        @legajo = @legajoPrueba;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - Eliminación exitosa', 'tourBaja', 'EXITOSO', 
            'Tour eliminado correctamente');
    PRINT 'Caso 1: Baja exitosa';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - Eliminación exitosa', 'tourBaja', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Baja de ID inexistente
    EXEC Actividades.tourBaja
        @idActividad = 99999,
        @legajo = 99999;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'tourBaja', 'ERROR', 
            'Se esperaba error con ID inexistente pero fue exitoso');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'tourBaja', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

SELECT * FROM Actividades.tour

-- ========================================
-- REPORTE FINAL
-- ========================================
PRINT '========================================';
PRINT 'RESUMEN DE RESULTADOS';
PRINT '========================================';
PRINT '';

SELECT 
    TestID,
    NombreTest,
    Procedimiento,
    Estado,
    Mensaje,
    FechaEjecucion
FROM #TestResultados
ORDER BY TestID;

PRINT '';
PRINT 'Total de pruebas: ' + CAST(@@ROWCOUNT AS VARCHAR);
DECLARE @totalExitosas INT = (SELECT COUNT(*) FROM #TestResultados WHERE Estado = 'EXITOSO'),
        @totalFallidas INT = (SELECT COUNT(*) FROM #TestResultados WHERE Estado = 'ERROR');

PRINT 'Exitosas: ' + CAST(@totalExitosas AS VARCHAR);
PRINT 'Fallidas: ' + CAST(@totalFallidas AS VARCHAR);
PRINT '';

-- Limpiar tablas temporales
DROP TABLE #TestResultados;

PRINT 'PRUEBAS COMPLETADAS';
PRINT '========================================';

-- Limpieza de datos de prueba en tablas tipoActividad y actividad.
DELETE FROM Actividades.actividad 
    WHERE idActividad IN (
        SELECT TOP 3 idActividad 
        FROM Actividades.actividad 
        ORDER BY idActividad DESC
        );

DELETE FROM Actividades.tipoActividad 
    WHERE idTipoActividad IN (
        SELECT TOP 4 idTipoActividad 
        FROM Actividades.tipoActividad 
        ORDER BY idTipoActividad DESC
        );

DELETE FROM Actividades.tour 
    WHERE idActividad = @idActividadTest AND legajo = @legajoPrueba;
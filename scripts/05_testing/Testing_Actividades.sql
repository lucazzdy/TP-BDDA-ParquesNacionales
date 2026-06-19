/* 
    Script generado el 19/06/2026

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Este script es de testing para los procedimientos almacenados del esquema Actividades.
*/
USE GestionParquesNacionales;
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
-- 1. PROCEDIMIENTO: TipoActividad_Alta
-- ========================================
PRINT '1. Probando TipoActividad_Alta...';
BEGIN TRY
    -- Caso 1: Alta exitosa con todos los parámetros
    EXEC Actividades.TipoActividad_Alta
        @descripcion = 'Deportes Acuáticos';
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Caso exitoso con todos los parámetros', 'TipoActividad_Alta', 'EXITOSO', 
            'Tipo Actividad registrada correctamente');
    PRINT 'Caso 1: Alta exitosa';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Caso exitoso con todos los parámetros', 'TipoActividad_Alta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Alta con descripcion NULL (campo opcional)
    EXEC Actividades.TipoActividad_Alta
        @descripcion = NULL;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion NULL (campo opcional)', 'TipoActividad_Alta', 'EXITOSO', 
            'Tipo Actividad con descripcion NULL registrada');
    PRINT 'Caso 2: descripcion NULL';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion NULL (campo opcional)', 'TipoActividad_Alta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 2 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 3: Alta con descripcion Vacia (campo opcional)
    EXEC Actividades.TipoActividad_Alta
        @descripcion = '';
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion vacia (campo opcional)', 'TipoActividad_Alta', 'EXITOSO', 
            'Tipo Actividad con descripcion vacia registrada');
    PRINT 'Caso 3: descripcion vacia';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion vacia (campo opcional)', 'TipoActividad_Alta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 3 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 4: Alta con descripcion muy larga (debe fallar)
    DECLARE @descripcionMuyLarga VARCHAR(300) = REPLICATE(N'A', 300); -- Ajusta la longitud según la definición de la columna
    EXEC Actividades.TipoActividad_Alta
        @descripcion = @descripcionMuyLarga -- Asumiendo que el campo tiene un límite menor
    
    print LEN(@descripcionMuyLarga);
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion muy larga (validación de longitud)', 'TipoActividad_Alta', 'ERROR', 
            'Se esperaba error por longitud excedida pero el procedimiento fue exitoso');
    PRINT 'Caso 4: Validación de longitud (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Descripcion muy larga (validación de longitud)', 'TipoActividad_Alta', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 4: Validación de longitud funcionando';
END CATCH

PRINT '';

-- ========================================
-- 2. PROCEDIMIENTO: TipoActividad_Modificar
-- ========================================

PRINT '2. Probando TipoActividad_Modificar...';
BEGIN TRY
    -- Obtener primer ID de tipo actividad para prueba
    DECLARE @idTipoActividadTest INT;
    SELECT TOP 1 @idTipoActividadTest = idTipoActividad FROM Actividades.TipoActividad;
    
    IF @idTipoActividadTest IS NOT NULL
    BEGIN
        -- Caso 1: Modificación exitosa de la descripción
        EXEC Actividades.TipoActividad_Modificar
            @idTipoActividad = @idTipoActividadTest,
            @descripcion = 'Deportes Acuáticos Modificado';
        
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Modificar - Actualización de descripcion', 'TipoActividad_Modificar', 'EXITOSO', 
                'Tipo Actividad ID ' + CAST(@idTipoActividadTest AS VARCHAR) + ' modificada');
        PRINT 'Caso 1: Modificación exitosa';
    END
    ELSE
    BEGIN
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Modificar - Actualización de descripcion', 'TipoActividad_Modificar', 'ERROR', 
                'No hay tipos de actividad en la tabla para modificar');
        PRINT 'Caso 1: No hay datos de prueba';
    END
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Actualización de descripcion', 'TipoActividad_Modificar', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Modificación con ID inexistente
    EXEC Actividades.TipoActividad_Modificar
        @idTipoActividad = 9999,
        @descripcion = 'Tipo Actividad Fantasma';
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'TipoActividad_Modificar', 'ERROR', 
            'Se esperaba error con ID inexistente pero fue exitoso');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'TipoActividad_Modificar', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

BEGIN TRY
    -- Caso 3: Modificación con descripcion muy larga (debe fallar)
    DECLARE @descripcionMuyLarga2 VARCHAR(300) = REPLICATE(N'A', 300); -- Ajusta la longitud según la definición de la columna
    EXEC Actividades.TipoActividad_Modificar
        @idTipoActividad = @idTipoActividadTest,
        @descripcion = @descripcionMuyLarga; -- Asumiendo que el campo tiene un límite menor
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Descripcion muy larga (validación de longitud)', 'TipoActividad_Modificar', 'ERROR', 
            'Se esperaba error por longitud excedida pero el procedimiento fue exitoso');
    PRINT 'Caso 3: Validación de longitud (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Descripcion muy larga (validación de longitud)', 'TipoActividad_Modificar', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 3: Validación de longitud funcionando';
END CATCH

PRINT '';

-- ========================================
-- 3. PROCEDIMIENTO: TipoActividad_Baja
-- ========================================

PRINT '3. Probando TipoActividad_Baja...';
BEGIN TRY
    -- Primero inserto un tipo de actividad para prueba de baja
    DECLARE @idTipoActividadBaja INT;
    
    EXEC Actividades.TipoActividad_Alta
        @descripcion = 'Tipo Actividad Prueba Baja';
    
    -- Obtengo el ID recién insertado
    SELECT TOP 1 @idTipoActividadBaja = idTipoActividad 
    FROM Actividades.TipoActividad 
    WHERE descripcion = 'Tipo Actividad Prueba Baja'
    
    -- Caso 1: Baja exitosa
    IF @idTipoActividadBaja IS NOT NULL
    BEGIN
        EXEC Actividades.TipoActividad_Baja @idTipoActividad = @idTipoActividadBaja;
        
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Baja - Eliminación exitosa', 'TipoActividad_Baja', 'EXITOSO', 
                'Tipo Actividad ID ' + CAST(@idTipoActividadBaja AS VARCHAR) + ' eliminada');
        PRINT 'Caso 1: Baja exitosa';
    END
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - Eliminación exitosa', 'TipoActividad_Baja', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Baja de ID inexistente
    EXEC Actividades.TipoActividad_Baja @idTipoActividad = 9999;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'TipoActividad_Baja', 'ERROR', 
            'Se esperaba error con ID inexistente');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'TipoActividad_Baja', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

SELECT * FROM Actividades.TipoActividad

PRINT '';

-- ========================================
-- 1. PROCEDIMIENTO: Actividad_Alta
-- ========================================
DECLARE @idTipoActividadParaActividad INT;
SET @idTipoActividadParaActividad = (SELECT TOP 1 idTipoActividad FROM Actividades.TipoActividad ORDER BY idTipoActividad DESC);

PRINT '1. Probando Actividad_Alta...';
BEGIN TRY
    -- Caso 1: Alta exitosa con todos los parámetros
    EXEC Actividades.Actividad_Alta
        @nombre = 'Senderismo en Montaña',
        @costo = 450.50,
        @duracion = 8.0,
        @idTipoActividad = @idTipoActividadParaActividad;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Caso exitoso con todos los parámetros', 'Actividad_Alta', 'EXITOSO', 
            'Actividad registrada correctamente');
    PRINT 'Caso 1: Alta exitosa';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Caso exitoso con todos los parámetros', 'Actividad_Alta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Alta con costo NULL (campo opcional)
    EXEC Actividades.Actividad_Alta
        @nombre = 'Fotografía de Fauna',
        @costo = NULL,
        @duracion = 4.5,
        @idTipoActividad = @idTipoActividadParaActividad;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Costo NULL (campo opcional)', 'Actividad_Alta', 'EXITOSO', 
            'Actividad con costo NULL registrada');
    PRINT 'Caso 2: Costo NULL';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Costo NULL (campo opcional)', 'Actividad_Alta', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 2 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 3: Alta con duración NULL (campo opcional)
    EXEC Actividades.Actividad_Alta
        @nombre = 'Observación de Aves',
        @costo = 150.00,
        @duracion = NULL,
        @idTipoActividad = @idTipoActividadParaActividad;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Duración NULL', 'Actividad_Alta', 'ERROR', 
            'Se esperaba error por campo obligatorio como NULL pero el procedimiento fue exitoso');
    PRINT 'Caso 3: Duración NULL';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - Duración NULL Validacion', 'Actividad_Alta', 'EXITOSO', 'Error capturado correctamente: ' + 
            ERROR_MESSAGE());
    PRINT 'Caso 3 : Validacion de duracion funcionando';
END CATCH

BEGIN TRY
    -- Caso 4: Alta con idTipoActividad inválido (debe fallar)
    EXEC Actividades.Actividad_Alta
        @nombre = 'Actividad Inválida',
        @costo = 100.00,
        @duracion = 2.0,
        @idTipoActividad = 9999;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - idTipoActividad inválido (validación FK)', 'Actividad_Alta', 'ERROR', 
            'Se esperaba error por FK inválida pero el procedimiento fue exitoso');
    PRINT 'Caso 4: Validación de FK (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Alta - idTipoActividad inválido (validación FK)', 'Actividad_Alta', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 4: FK validada correctamente';
END CATCH

PRINT '';

-- ========================================
-- 2. PROCEDIMIENTO: Actividad_Modificar
-- ========================================
PRINT '2. Probando Actividad_Modificar...';
BEGIN TRY
    -- Obtener primer ID de actividad para prueba
    DECLARE @idActividadTest INT;
    SELECT TOP 1 @idActividadTest = idActividad FROM Actividades.Actividad WHERE nombre = 'Senderismo en Montaña';
    
    IF @idActividadTest IS NOT NULL
    BEGIN
        -- Caso 1: Modificación exitosa de todos los campos
        EXEC Actividades.Actividad_Modificar
            @idActividad = @idActividadTest,
            @nombre = 'Senderismo Modificado',
            @costo = 550.00,
            @duracion = 9.0,
            @idTipoActividad = @idTipoActividadParaActividad;
        
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Modificar - Actualización de todos los campos', 'Actividad_Modificar', 'EXITOSO', 
                'Actividad ID ' + CAST(@idActividadTest AS VARCHAR) + ' modificada');
        PRINT 'Caso 1: Modificación exitosa';
    END
    ELSE
    BEGIN
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Modificar - Actualización de todos los campos', 'Actividad_Modificar', 'ERROR', 
                'No hay actividades en la tabla para modificar');
        PRINT 'Caso 1: No hay datos de prueba';
    END
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - Actualización de todos los campos', 'Actividad_Modificar', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Modificación con ID inexistente
    EXEC Actividades.Actividad_Modificar
        @idActividad = 99999,
        @nombre = 'Actividad Fantasma',
        @costo = 100.00,
        @duracion = 1.0,
        @idTipoActividad = 1;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'Actividad_Modificar', 'ERROR', 
            'Se esperaba error con ID inexistente pero fue exitoso');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Modificar - ID inexistente (validación)', 'Actividad_Modificar', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

PRINT '';

-- ========================================
-- 3. PROCEDIMIENTO: Actividad_Baja
-- ========================================
PRINT '3. Probando Actividad_Baja...';
BEGIN TRY
    -- Primero insertamos una actividad específica para prueba de baja
    DECLARE @idActividadBaja INT;
    
    EXEC Actividades.Actividad_Alta
        @nombre = 'Actividad Para Prueba Baja',
        @costo = 100.00,
        @duracion = 1.0,
        @idTipoActividad = @idTipoActividadParaActividad;
    
    -- Obtener el ID recién insertado
    SELECT TOP 1 @idActividadBaja = idActividad 
    FROM Actividades.Actividad 
    WHERE nombre = 'Actividad Para Prueba Baja'
    ORDER BY idActividad DESC;
    
    -- Caso 1: Baja exitosa
    IF @idActividadBaja IS NOT NULL
    BEGIN
        EXEC Actividades.Actividad_Baja @idActividad = @idActividadBaja;
        
        INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
        VALUES ('Baja - Eliminación exitosa', 'Actividad_Baja', 'EXITOSO', 
                'Actividad ID ' + CAST(@idActividadBaja AS VARCHAR) + ' eliminada');
        PRINT 'Caso 1: Baja exitosa';
    END
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - Eliminación exitosa', 'Actividad_Baja', 'ERROR', 
            ERROR_MESSAGE());
    PRINT 'Caso 1 falló: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    -- Caso 2: Baja de ID inexistente
    EXEC Actividades.Actividad_Baja @idActividad = 99999;
    
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'Actividad_Baja', 'ERROR', 
            'Se esperaba error con ID inexistente');
    PRINT 'Caso 2: ID inexistente (como se esperaba)';
END TRY
BEGIN CATCH
    INSERT INTO #TestResultados (NombreTest, Procedimiento, Estado, Mensaje)
    VALUES ('Baja - ID inexistente (validación)', 'Actividad_Baja', 'EXITOSO', 
            'Error capturado correctamente: ' + ERROR_MESSAGE());
    PRINT 'Caso 2: Validación de ID funcionando';
END CATCH

PRINT '';

SELECT * FROM Actividades.Actividad



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

-- Limpieza de datos de prueba en tablas TipoActividad y Actividad.
DELETE FROM Actividades.Actividad 
    WHERE idActividad IN (
        SELECT TOP 3 idActividad 
        FROM Actividades.Actividad 
        ORDER BY idActividad DESC
        );

DELETE FROM Actividades.TipoActividad 
    WHERE idTipoActividad IN (
        SELECT TOP 3 idTipoActividad 
        FROM Actividades.TipoActividad 
        ORDER BY idTipoActividad DESC
        );
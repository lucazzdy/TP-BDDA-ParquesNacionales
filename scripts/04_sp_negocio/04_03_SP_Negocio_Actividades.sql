/* 
    Script generado el 19/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures de logica de negocio
                            del esquema Actividades. Delegan la
                            persistencia a los SPs ABM y aplican
                            transacciones cuando tocan varias tablas.
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO

/*=========================================================
IMPORTAR Actividad
Upsert: si existe una actividad con el mismo nombre, actualiza
sus datos. Si no existe, la crea. Delega las validaciones
y la persistencia a los SPs ABM (actividadAlta, actividadModificar).
=========================================================*/
CREATE OR ALTER PROCEDURE Actividades.importarActividad(
    @nombre VARCHAR(100),
    @costo DECIMAL(8, 2),
    @duracion DECIMAL(5, 2),
    @idTipoActividad INT
    )
    
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @idActividadExistente INT;

    -- Verifico si el parque ya existe (matchea por nombre)
    SELECT @idActividadExistente = idActividad
    FROM Actividades.actividad
    WHERE nombre = @nombre;

    IF @idActividadExistente IS NULL
    BEGIN
        -- No existe: alta delegada al SP ABM
        EXEC Actividades.actividadAlta
            @nombre = @nombre,
            @costo = @costo,
            @duracion = @duracion,
            @idTipoActividad = @idTipoActividad
            
    END
    ELSE
    BEGIN
        -- Ya existe: modificacion delegada al SP ABM
        EXEC Actividades.actividadModificar
            @idActividad = @idActividadExistente,
            @costo = @costo,
            @duracion = @duracion,
            @idTipoActividad = @idTipoActividad
    END
END
GO


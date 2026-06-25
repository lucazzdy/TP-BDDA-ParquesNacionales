/* 
    Script generado el 24/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Seed data del esquema Actividades.
                            
    IMPORTANTE: este seed genera actividades. 
    Antes de correr este script se deben haber generado la importacion de parques y la seed de personal.
                                                      
    Incluye:
    - Generacion de tipos de actividades
    - Generacion de actividades
    - Generacion de tours

*/

USE GestionParquesNacionales
GO

-- Insertar al menos 10 tipos de actividades

EXEC Actividades.tipoActividadAlta @descripcion = 'Senderismo';
EXEC Actividades.tipoActividadAlta @descripcion = 'Kayak';
EXEC Actividades.tipoActividadAlta @descripcion = 'Pesca';
EXEC Actividades.tipoActividadAlta @descripcion = 'Observación de especies';
EXEC Actividades.tipoActividadAlta @descripcion = 'Escalada';
EXEC Actividades.tipoActividadAlta @descripcion = 'Fotografía';
EXEC Actividades.tipoActividadAlta @descripcion = 'Ciclismo';
EXEC Actividades.tipoActividadAlta @descripcion = 'Camping';
EXEC Actividades.tipoActividadAlta @descripcion = 'Rafting';
EXEC Actividades.tipoActividadAlta @descripcion = 'Cabalgata';


-- Insertar actividades

DECLARE @cantidadActividades INT = 30,
        @cantidadTipoActividad INT = (SELECT COUNT(*) FROM Actividades.tipoActividad);

WHILE @cantidadActividades > 0
BEGIN
    DECLARE @idTipoActividad INT = (ABS(CHECKSUM(NEWID())) % @cantidadTipoActividad + 1) ; -- ID de tipo de actividad entre 1 y 10
    -- Generar un nombre de actividad aleatorio basado en el tipo de actividad y un número secuencial para evitar duplicados.
    DECLARE @nombreActividad VARCHAR(100) = CONCAT((
                                                SELECT descripcion
                                                FROM Actividades.tipoActividad 
                                                WHERE idTipoActividad = @idTipoActividad
                                                ), @cantidadActividades);

    -- Generar un costo aleatorio entre 0 y 50000 con dos decimales
    DECLARE @costo DECIMAL(8,2) = ROUND(ABS(CHECKSUM(NEWID())) % 50000, 2);

    -- Generar una duración aleatoria entre 1 y 10 horas con un decimal
    DECLARE @duracion DECIMAL(3,1) = ROUND(ABS(CHECKSUM(NEWID())) % 9 + 1, 1);

    EXEC Actividades.actividadAlta 
        @nombre = @nombreActividad,
        @costo = @costo,
        @duracion = @duracion,
        @idTipoActividad = @idTipoActividad;

    SET @cantidadActividades -= 1;
END

-- Generar tours para las actividades creadas

IF (SELECT COUNT(*) FROM Personal.guias) < 1
BEGIN
    ;THROW 59000,'No hay guías disponibles para asignar a los tours. Por favor, ejecute primero la seed de Personal.', 1
END

DECLARE @cantidadTours INT = 50,
        @cantidadActividadesExistentes INT = (SELECT COUNT(*) FROM Actividades.actividad),
        @cantidadGuiasExistentes INT = (SELECT COUNT(*) FROM Personal.guias),
        @legajoInicialGuia INT = (SELECT MIN(legajo) FROM Personal.guias);

WHILE @cantidadTours > 0
BEGIN
    DECLARE @idActividad INT = (ABS(CHECKSUM(NEWID())) % @cantidadActividadesExistentes + 1); -- ID de actividad entre 1 y cantidad de actividades

    DECLARE @legajoGuia INT = (ABS(CHECKSUM(NEWID())) % @cantidadGuiasExistentes + @legajoInicialGuia); -- Legajo de guía entre 1 y cantidad de guías


    -- Generar una fecha de inicio aleatoria en el rango del año actual
    DECLARE @fechaInicio DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, CAST(YEAR(GETDATE()) AS VARCHAR) + '-01-01');


    -- Generar una fecha desde aleatoria que sea posterior a la fecha de inicio
    DECLARE @fechaDesde DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 30, @fechaInicio);


    -- Generar un cupo máximo aleatorio entre 5 y 20
    DECLARE @cupoMaximo TINYINT = ABS(CHECKSUM(NEWID())) % 16 + 5;

    EXEC Actividades.tourAlta 
        @idActividad = @idActividad,
        @legajo = @legajoGuia,
        @fechaInicio = @fechaInicio,
        @fechaDesde = @fechaDesde,
        @cupoMaximo = @cupoMaximo;


    SET @cantidadTours -= 1;
END


SELECT * FROM Actividades.tipoActividad;
SELECT * FROM Actividades.actividad;
SELECT * FROM Actividades.tour;
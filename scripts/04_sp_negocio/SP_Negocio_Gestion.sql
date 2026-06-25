/* 
    Script generado el 21/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures de logica de negocio
                            del esquema Gestion.
*/

USE GestionParquesNacionales;
GO


/*=========================================================
IMPORTAR PARQUE
Upsert: si existe un parque con el mismo nombre, actualiza
sus datos. Si no existe, lo crea. Delega las validaciones
y la persistencia a los SPs ABM (parque_Alta, parque_Modificar).
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.importarParque
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
    SET NOCOUNT ON;
    DECLARE @idParqueExistente INT;

    -- Verifico si el parque ya existe (matchea por nombre)
    SELECT @idParqueExistente = idParque
    FROM Gestion.parque
    WHERE nombre = @nombre;

    IF @idParqueExistente IS NULL
    BEGIN
        -- No existe: alta delegada al SP ABM
        EXEC Gestion.parque_Alta 
            @nombre = @nombre,
            @superficie = @superficie,
            @idTipoParque = @idTipoParque,
            @provincia = @provincia,
            @codigoPostal = @codigoPostal,
            @calle = @calle,
            @nro = @nro,
            @latitud = @latitud,
            @longitud = @longitud;
    END
    ELSE
    BEGIN
        -- Ya existe: modificacion delegada al SP ABM
        EXEC Gestion.parque_Modificar
            @idParque = @idParqueExistente,
            @superficie = @superficie,
            @idTipoParque = @idTipoParque,
            @provincia = @provincia,
            @codigoPostal = @codigoPostal,
            @calle = @calle,
            @nro = @nro,
            @latitud = @latitud,
            @longitud = @longitud;
    END
END
GO


/*=========================================================
CONSULTAR PARQUE CON CONCESIONES
Devuelve los datos del parque y sus concesiones activas
(las que tienen fecha actual entre fechaInicio y fechaFin).
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.consultarParqueConConcesiones
    @idParque INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
    BEGIN
        SET @errorMsg = @errorMsg + '- No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10)) + '.' + @saltoLinea;
        ;THROW 50151, @errorMsg, 1;
    END

    -- Datos del parque
    SELECT 
        p.idParque,
        p.nombre AS parque,
        tp.nombre AS tipoParque,
        p.superficie,
        p.provincia,
        p.latitud,
        p.longitud
    FROM Gestion.parque p
    INNER JOIN Gestion.tipoParque tp ON tp.idTipoParque = p.idTipoParque
    WHERE p.idParque = @idParque;

    -- Concesiones activas
    SELECT 
        c.idConcesion,
        e.nombre AS empresa,
        tc.descripcion AS tipoConcesion,
        c.fechaInicio,
        c.fechaFin,
        c.montoCanonMensual
    FROM Concesiones.concesion c
    INNER JOIN Concesiones.empresa e ON e.idEmpresa = c.idEmpresa
    INNER JOIN Concesiones.tipoConcesion tc ON tc.idTipoConcesion = c.idTipoConcesion
    WHERE c.idParque = @idParque
      AND CAST(GETDATE() AS DATE) BETWEEN c.fechaInicio AND c.fechaFin
    ORDER BY c.fechaFin;
END
GO

-- ================================================================
-- SP consultarClimaParque
-- ================================================================
CREATE OR ALTER PROCEDURE Gestion.consultarClimaParque
    @idParque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @latitud DECIMAL(9,6), @longitud DECIMAL(9,6), @nombre VARCHAR(100);
    SELECT @latitud = latitud, @longitud = longitud, @nombre = nombre
    FROM Gestion.parque WHERE idParque = @idParque;

    IF @latitud IS NULL OR @longitud IS NULL
        THROW 50601, 'El parque no tiene coordenadas cargadas.', 1;

    -- Llamada a la API
    DECLARE @cmd VARCHAR(600);
    SET @cmd = 'curl -s "https://api.open-meteo.com/v1/forecast?latitude='
        + CAST(@latitud AS VARCHAR(20))
        + '&longitude=' + CAST(@longitud AS VARCHAR(20))
        + '&current_weather=true"';

    CREATE TABLE #raw (linea VARCHAR(MAX));
    INSERT INTO #raw EXEC xp_cmdshell @cmd;
    DECLARE @json VARCHAR(MAX);
    SELECT @json = STRING_AGG(linea, '') FROM #raw WHERE linea IS NOT NULL;
    DROP TABLE #raw;

    IF @json IS NULL
        THROW 50602, 'No se obtuvo respuesta de la API de clima.', 1;

    -- Parsear
    DECLARE @temperatura    DECIMAL(5,1) = TRY_CAST(JSON_VALUE(@json, '$.current_weather.temperature')  AS DECIMAL(5,1));
    DECLARE @viento         DECIMAL(6,1) = TRY_CAST(JSON_VALUE(@json, '$.current_weather.windspeed')    AS DECIMAL(6,1));
    DECLARE @direccion      INT          = TRY_CAST(JSON_VALUE(@json, '$.current_weather.winddirection') AS INT);
    DECLARE @weatherCode    INT          = TRY_CAST(JSON_VALUE(@json, '$.current_weather.weathercode')   AS INT);
    DECLARE @esDeDia        BIT          = TRY_CAST(JSON_VALUE(@json, '$.current_weather.is_day')        AS BIT);

    DECLARE @descripcion VARCHAR(100) = CASE @weatherCode
        WHEN 0  THEN 'Despejado'
        WHEN 1  THEN 'Principalmente despejado'
        WHEN 2  THEN 'Parcialmente nublado'
        WHEN 3  THEN 'Nublado'
        WHEN 45 THEN 'Niebla'
        WHEN 48 THEN 'Niebla con escarcha'
        WHEN 51 THEN 'Llovizna leve'
        WHEN 53 THEN 'Llovizna moderada'
        WHEN 55 THEN 'Llovizna intensa'
        WHEN 61 THEN 'Lluvia leve'
        WHEN 63 THEN 'Lluvia moderada'
        WHEN 65 THEN 'Lluvia intensa'
        WHEN 71 THEN 'Nieve leve'
        WHEN 73 THEN 'Nieve moderada'
        WHEN 75 THEN 'Nieve intensa'
        WHEN 80 THEN 'Chubascos leves'
        WHEN 81 THEN 'Chubascos moderados'
        WHEN 82 THEN 'Chubascos violentos'
        WHEN 95 THEN 'Tormenta'
        WHEN 96 THEN 'Tormenta con granizo leve'
        WHEN 99 THEN 'Tormenta con granizo intenso'
        ELSE 'Código ' + CAST(@weatherCode AS VARCHAR(5))
    END;

    INSERT INTO Gestion.registroClima
        (idParque, temperatura, velocidadViento, direccionViento, weatherCode, esDeDia, descripcion)
    VALUES
        (@idParque, @temperatura, @viento, @direccion, @weatherCode, @esDeDia, @descripcion);

    SELECT
        @nombre      AS parque,
        @temperatura AS temperatura_C,
        @viento      AS viento_kmh,
        @direccion   AS direccion_grados,
        @descripcion AS condicion,
        CASE @esDeDia WHEN 1 THEN 'Día' ELSE 'Noche' END AS momento,
        GETDATE()    AS fechaConsulta;
END
GO
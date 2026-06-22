/* 
    Script generado el 20/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Script demo de importacion completa.
                            Carga los CSV con BULK INSERT, procesa
                            y muestra el log de resultados.

    - SIB:  https://sib.gob.ar/areas-protegidas  (XLSX convertido a CSV)
    - CIAM: https://ciam.ambiente.gob.ar/repositorio.php?tid=5

    PREREQUISITO:
    Ajustar @rutaBase a la ubicacion del repo en su PC.
    El path debe terminar con barra invertida.
*/

USE GestionParquesNacionales;
GO


-- ===========================================================
-- CONFIGURACION: cada integrante debe ajustar esta ruta
-- ===========================================================
DECLARE @rutaBase VARCHAR(500) = 'C:\Users\Lucas\Desktop\facu\bda\TP\TP-BDDA-ParquesNacionales\scripts\06_seed\datasets\';

DECLARE @rutaSib VARCHAR(500) = @rutaBase + 'sib_areas_protegidas.csv';
DECLARE @rutaCiam VARCHAR(500) = @rutaBase + 'ciam_superficies.csv';
DECLARE @sql NVARCHAR(MAX);


-- ===========================================================
-- PASO 0: limpiar staging y log (por si quedo data anterior)
-- ===========================================================
TRUNCATE TABLE Gestion.stagingSib;
TRUNCATE TABLE Gestion.stagingCiam;
TRUNCATE TABLE Gestion.logImportacion;


-- ===========================================================
-- PASO 1: cargar el CSV del SIB en su staging
-- ===========================================================
SET @sql = '
BULK INSERT Gestion.stagingSib
FROM ''' + @rutaSib + '''
WITH (
    FIELDTERMINATOR = '';'',
    ROWTERMINATOR = ''0x0A'',
    CODEPAGE = ''65001'',         -- UTF-8
    FIRSTROW = 1,                 -- No tiene encabezado (lo sacamos al convertir)
    FIELDQUOTE = ''"''            -- SQL Server 2017+
);';
EXEC sp_executesql @sql;

SELECT TOP 5 * FROM Gestion.stagingSib;


-- ===========================================================
-- PASO 2: cargar el CSV del CIAM en su staging
-- ===========================================================
SET @sql = '
BULK INSERT Gestion.stagingCiam
FROM ''' + @rutaCiam + '''
WITH (
    FIELDTERMINATOR = '';'',
    ROWTERMINATOR = ''0x0A'',
    CODEPAGE = ''65001'',
    FIRSTROW = 2,                 -- Saltea el encabezado
    FIELDQUOTE = ''"''
);';
EXEC sp_executesql @sql;

SELECT TOP 5 * FROM Gestion.stagingCiam;


-- ===========================================================
-- PASO 3: procesar la importacion del SIB
-- ===========================================================
EXEC Gestion.procesarImportacionSib;


-- ===========================================================
-- PASO 4: procesar la actualizacion del CIAM
-- ===========================================================
EXEC Gestion.procesarImportacionCiam;


-- ===========================================================
-- VERIFICACION
-- ===========================================================

-- Cantidad de parques cargados
SELECT COUNT(*) AS totalParques FROM Gestion.parque;

-- Resumen por estado
SELECT origen, estado, COUNT(*) AS cantidad
FROM Gestion.logImportacion
GROUP BY origen, estado
ORDER BY origen, estado;

-- Detalle de errores
SELECT * FROM Gestion.logImportacion 
WHERE estado IN ('ERROR', 'SALTADO')
ORDER BY fechaProceso DESC;

-- Ver los parques cargados
SELECT 
    p.idParque, p.nombre, tp.nombre AS tipo, p.provincia,
    p.superficie, p.latitud, p.longitud
FROM Gestion.parque p
INNER JOIN Gestion.tipoParque tp ON tp.idTipoParque = p.idTipoParque
ORDER BY p.idParque;
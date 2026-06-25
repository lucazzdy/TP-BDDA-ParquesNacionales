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

    - SIB:  https://sib.gob.ar/areas-protegidas    (XLSX nativo via OPENROWSET)
    - CIAM: https://ciam.ambiente.gob.ar/repositorio.php?tid=5
    - GUIAS:https://datosabiertos.mendoza.gov.ar/dataset/guias-turisticos/archivo/d81872d8-890d-42c3-8624-34117bc88f53

    PREREQUISITOS:
    1. Driver Microsoft.ACE.OLEDB.12.0 instalado.
       Descarga: https://www.microsoft.com/en-us/download/details.aspx?id=54920
    2. Habilitar Ad Hoc Distributed Queries (una sola vez):
       EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
       EXEC sp_configure 'Ad Hoc Distributed Queries', 1; RECONFIGURE;
    3. Ajustar @rutaBase a la ubicacion del repo en tu PC.
       El path debe terminar con barra invertida.
*/

USE GestionParquesNacionales;
GO


-- ===========================================================
-- CONFIGURACION: cada integrante debe ajustar esta ruta
-- ===========================================================
DECLARE @rutaBase VARCHAR(500) = 'C:\Users\Lucas\Desktop\facu\bda\TP\TP-BDDA-ParquesNacionales\scripts\06_seed\datasets\';

DECLARE @rutaSib VARCHAR(500) = @rutaBase + 'sib_areas_protegidas.xlsx';
DECLARE @rutaCiam VARCHAR(500) = @rutaBase + 'aprn_h_ubicacion_superycatint_ha.csv';
DECLARE @rutaGuias VARCHAR(500) = @rutaBase + 'guias-a-julio-2019.csv';
DECLARE @sql NVARCHAR(MAX);


-- ===========================================================
-- PASO 0: limpiar staging y log (por si quedo data anterior)
-- ===========================================================
TRUNCATE TABLE Gestion.stagingSib;
TRUNCATE TABLE Gestion.stagingCiam;
TRUNCATE TABLE Gestion.logImportacion;
TRUNCATE TABLE Personal.stagingCsvGuias;

-- ===========================================================
-- PASO 1: leer el XLSX del SIB con OPENROWSET y cargar en staging
-- El XLSX tiene un titulo en fila 1 y encabezados en fila 2, por eso
-- el rango arranca en A3.
-- ===========================================================
SET @sql = '
INSERT INTO Gestion.stagingSib 
    (provincia, nombreCompleto, anioCreacion, region, superficie, latitud, longitud, 
     leyCreacion, ecorregiones, categoriaInternacional, 
     especiesRegistradas, animales, bacterias, hongos, plantas)
SELECT 
    CAST(F1 AS VARCHAR(100))  AS provincia,
    CAST(F2 AS VARCHAR(200))  AS nombreCompleto,
    CAST(F3 AS VARCHAR(20))   AS anioCreacion,
    CAST(F4 AS VARCHAR(100))  AS region,
    CAST(F5 AS VARCHAR(30))   AS superficie,
    CAST(F6 AS VARCHAR(30))   AS latitud,
    CAST(F7 AS VARCHAR(30))   AS longitud,
    CAST(F8 AS VARCHAR(100))  AS leyCreacion,
    CAST(F9 AS VARCHAR(200))  AS ecorregiones,
    CAST(F10 AS VARCHAR(200)) AS categoriaInternacional,
    CAST(F11 AS VARCHAR(20))  AS especiesRegistradas,
    CAST(F12 AS VARCHAR(20))  AS animales,
    CAST(F13 AS VARCHAR(20))  AS bacterias,
    CAST(F14 AS VARCHAR(20))  AS hongos,
    CAST(F15 AS VARCHAR(20))  AS plantas
FROM OPENROWSET(
    ''Microsoft.ACE.OLEDB.12.0'',
    ''Excel 12.0;Database=' + @rutaSib + ';HDR=NO'',
    ''SELECT * FROM [Sheet1$A3:O1000]''
) AS xlsx;';
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
    ROWTERMINATOR = ''0x0A0D'',
    CODEPAGE = ''65001'',
    FIRSTROW = 2,
    FIELDQUOTE = ''"''
);';
EXEC sp_executesql @sql;

SELECT TOP 5 * FROM Gestion.stagingCiam;

-- ===========================================================
-- PASO 3: cargar el CSV de guias en su staging
-- ===========================================================

BULK INSERT Personal.stagingCsvGuias
FROM 'C:\Users\Lucas\Desktop\facu\bda\TP\TP-BDDA-ParquesNacionales\scripts\06_seed\datasets\guias-a-julio-2019.csv' -- Tu ruta física real
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001' -- UTF-8 para caracteres especiales
);


-- ===========================================================
-- PASO 4: procesar la importacion del SIB
-- ===========================================================
EXEC Gestion.procesarImportacionSib;


-- ===========================================================
-- PASO 5: procesar la actualizacion del CIAM
-- ===========================================================
EXEC Gestion.procesarImportacionCiam;


-- ===========================================================
-- PASO 6: procesar la actualizacion del CIAM
-- ===========================================================

EXEC Personal.procesarImportacionGuiasCsv;


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

SELECT g.legajo, g.nombre, g.apellido, t.Nombre  FROM Personal.guias g
INNER JOIN Personal.titulos t ON t.codTitulo = g.legajo
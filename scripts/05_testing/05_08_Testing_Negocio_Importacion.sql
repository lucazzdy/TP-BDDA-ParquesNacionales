/* 
    Script generado el 22/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Testing de los SP de importacion masiva.
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO


-- parsearNombreParque

-- OK: separa "Parque Nacional Iguazu" en tipo + nombre limpio
DECLARE @tipo VARCHAR(50), @nombre VARCHAR(100);

EXEC Gestion.parsearNombreParque 
    @nombreCompleto = 'Parque Nacional Iguazu',
    @tipoParque = @tipo OUTPUT,
    @nombreLimpio = @nombre OUTPUT;
SELECT @tipo AS tipo, @nombre AS nombre;
-- ESPERADO: tipo='Parque Nacional', nombre='Iguazu'

-- OK: prefijos largos antes que cortos (Parque Interjurisdiccional Marino Costero)
EXEC Gestion.parsearNombreParque 
    @nombreCompleto = 'Parque Interjurisdiccional Marino Costero Patagonia Austral',
    @tipoParque = @tipo OUTPUT,
    @nombreLimpio = @nombre OUTPUT;
SELECT @tipo AS tipo, @nombre AS nombre;
-- ESPERADO: tipo='Parque Interjurisdiccional Marino Costero', nombre='Patagonia Austral'

-- OK: Reserva Natural Estricta
EXEC Gestion.parsearNombreParque 
    @nombreCompleto = 'Reserva Natural Estricta San Antonio',
    @tipoParque = @tipo OUTPUT,
    @nombreLimpio = @nombre OUTPUT;
SELECT @tipo AS tipo, @nombre AS nombre;
-- ESPERADO: tipo='Reserva Natural Estricta', nombre='San Antonio'

-- OK: Area Marina Protegida (con tilde y sin tilde)
EXEC Gestion.parsearNombreParque 
    @nombreCompleto = N'Área Marina Protegida Yaganes',
    @tipoParque = @tipo OUTPUT,
    @nombreLimpio = @nombre OUTPUT;
SELECT @tipo AS tipo, @nombre AS nombre;
-- ESPERADO: tipo='Area Marina Protegida', nombre='Yaganes'

-- Caso borde: nombre sin prefijo conocido devuelve NULL en tipo
EXEC Gestion.parsearNombreParque 
    @nombreCompleto = 'Nombre Raro Sin Prefijo',
    @tipoParque = @tipo OUTPUT,
    @nombreLimpio = @nombre OUTPUT;
SELECT @tipo AS tipo, @nombre AS nombre;
-- ESPERADO: tipo=NULL, nombre='Nombre Raro Sin Prefijo'


-- procesarImportacionSib

-- OK: importacion masiva desde staging (asume stagingSib cargada con BULK INSERT)
-- Si la staging esta vacia, cargar antes algunas filas de prueba:
INSERT INTO Gestion.stagingSib (provincia, nombreCompleto, anioCreacion, region, superficie, latitud, longitud, leyCreacion, categoriaInternacional)
VALUES 
    ('Misiones', 'Parque Nacional TestImport1', '1934', 'NEA', '67000', '-25.6', '-54.4', 'Ley 12345', 'Sitio'),
    (NULL, 'Area Marina Protegida TestImport2', '2018', 'Mar Argentino', '500000', '-55.0', '-65.0', 'Ley 27490', '-'),
    ('Salta', 'Reserva Natural Educativa TestImport3', '2000', 'NOA', '1000', '-24.5', '-65.5', NULL, NULL);

EXEC Gestion.procesarImportacionSib;
-- ESPERADO: 3 importadosOk, 0 importadosConError

SELECT * FROM Gestion.parque WHERE nombre LIKE 'TestImport%';
SELECT * FROM Gestion.logImportacion WHERE origen = 'SIB' AND nombreCompleto LIKE '%TestImport%';

-- OK: importacion parcial con error en una fila (nombre sin prefijo)
TRUNCATE TABLE Gestion.stagingSib;
INSERT INTO Gestion.stagingSib (provincia, nombreCompleto, superficie)
VALUES 
    ('Buenos Aires', 'Parque Nacional TestParcial1', '1000'),
    ('Cordoba', 'Nombre Invalido Sin Prefijo', '500'),
    ('Tucuman', 'Parque Nacional TestParcial2', '2000');

EXEC Gestion.procesarImportacionSib;
-- ESPERADO: 2 OK + 1 ERROR (importacion parcial)

SELECT * FROM Gestion.logImportacion WHERE origen = 'SIB' AND fechaProceso > DATEADD(MINUTE, -5, GETDATE());


-- procesarImportacionCiam

-- OK: actualizacion de superficies desde staging
TRUNCATE TABLE Gestion.stagingCiam;
INSERT INTO Gestion.stagingCiam (region, nombreCompleto, hectareas, categoriaInternacional)
VALUES 
    ('NEA', 'Parque Nacional TestImport1', '70000', 'Sitio actualizado'),
    ('NOA', 'Parque Nacional NoExisteEnBD', '5000', '-');

EXEC Gestion.procesarImportacionCiam;
-- ESPERADO: 1 actualizadoOk, 0 conError, 1 saltado (el que no existe)

SELECT * FROM Gestion.parque WHERE nombre = 'TestImport1';
SELECT * FROM Gestion.logImportacion WHERE origen = 'CIAM' AND fechaProceso > DATEADD(MINUTE, -5, GETDATE());


-- Cleanup
DELETE FROM Gestion.parque WHERE nombre LIKE 'TestImport%' OR nombre LIKE 'TestParcial%';
TRUNCATE TABLE Gestion.stagingSib;
TRUNCATE TABLE Gestion.stagingCiam;

/* 
    Script generado el 22/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripcion del Script: Testing de los SP de negocio del esquema Gestion.
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO


-- importarParque

-- OK: alta de parque nuevo via importarParque
EXEC Gestion.importarParque 
    @nombre = 'TestParque1',
    @superficie = 5000,
    @idTipoParque = 1,
    @provincia = 'Buenos Aires',
    @latitud = -34.6,
    @longitud = -58.4;

SELECT * FROM Gestion.parque WHERE nombre = 'TestParque1';

-- OK: upsert, segundo llamado actualiza datos existentes sin crear duplicado
EXEC Gestion.importarParque 
    @nombre = 'TestParque1',
    @superficie = 6000,
    @idTipoParque = 1,
    @provincia = 'Buenos Aires',
    @latitud = -34.7,
    @longitud = -58.5;

SELECT * FROM Gestion.parque WHERE nombre = 'TestParque1';
-- ESPERADO: una sola fila con superficie 6000 y nuevas coordenadas

-- ERROR: nombre vacio -> "El nombre del parque es obligatorio."
EXEC Gestion.importarParque 
    @nombre = '',
    @superficie = 1000,
    @idTipoParque = 1,
    @provincia = 'Buenos Aires';

-- ERROR: provincia vacia -> "La provincia es obligatoria."
EXEC Gestion.importarParque 
    @nombre = 'TestX',
    @superficie = 1000,
    @idTipoParque = 1,
    @provincia = '';

-- ERROR: superficie <= 0 -> "La superficie debe ser mayor a 0."
EXEC Gestion.importarParque 
    @nombre = 'TestX',
    @superficie = -100,
    @idTipoParque = 1,
    @provincia = 'Buenos Aires';

-- ERROR: idTipoParque no existe -> "No existe un tipo de parque con id: 999"
EXEC Gestion.importarParque 
    @nombre = 'TestX',
    @superficie = 1000,
    @idTipoParque = 999,
    @provincia = 'Buenos Aires';

-- ERROR: latitud fuera de rango -> "La latitud debe estar entre -90 y 90."
EXEC Gestion.importarParque 
    @nombre = 'TestX',
    @superficie = 1000,
    @idTipoParque = 1,
    @provincia = 'Buenos Aires',
    @latitud = 200;

-- ERROR: longitud fuera de rango -> "La longitud debe estar entre -180 y 180."
EXEC Gestion.importarParque 
    @nombre = 'TestX',
    @superficie = 1000,
    @idTipoParque = 1,
    @provincia = 'Buenos Aires',
    @longitud = -300;

-- ERROR: multiples validaciones falladas juntas
EXEC Gestion.importarParque 
    @nombre = '',
    @superficie = -100,
    @idTipoParque = 999,
    @provincia = '',
    @latitud = 200,
    @longitud = -300;
-- ESPERADO: error con 6 mensajes acumulados:
-- - El nombre del parque es obligatorio.
-- - La provincia es obligatoria.
-- - La superficie debe ser mayor a 0.
-- - No existe un tipo de parque con id: 999.
-- - La latitud debe estar entre -90 y 90.
-- - La longitud debe estar entre -180 y 180.


-- consultarParqueConConcesiones

-- OK: parque con concesiones (asume idParque=1 cargado desde seed o importacion)
EXEC Gestion.consultarParqueConConcesiones @idParque = 1;
-- ESPERADO: 2 recordsets, el primero con los datos del parque y el segundo con sus concesiones activas

-- OK: parque sin concesiones activas
DECLARE @idParqueSinConcesiones INT;
SELECT TOP 1 @idParqueSinConcesiones = idParque FROM Gestion.parque WHERE idParque NOT IN (SELECT idParque FROM Concesiones.concesion);
EXEC Gestion.consultarParqueConConcesiones @idParque = @idParqueSinConcesiones;
-- ESPERADO: primer recordset con datos del parque, segundo recordset vacio

-- ERROR: id no existe -> "No existe un parque con id: 999"
EXEC Gestion.consultarParqueConConcesiones @idParque = 999;


-- Cleanup
DELETE FROM Gestion.parque WHERE nombre = 'TestParque1';
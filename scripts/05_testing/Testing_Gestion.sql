/* 
    Script generado el 19/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Testing de los SP del esquema Gestion.
*/

USE GestionParquesNacionales;
GO


-- TipoParque_Alta

-- OK: alta valida
EXEC Gestion.TipoParque_Alta @nombre = 'Parque Nacional';
EXEC Gestion.TipoParque_Alta @nombre = 'Reserva Natural', @descripcion = 'Area protegida';

SELECT * FROM Gestion.TipoParque;

-- ERROR: nombre vacio -> "El nombre del tipo de parque es obligatorio."
EXEC Gestion.TipoParque_Alta @nombre = '   ';

-- ERROR: nombre duplicado -> "Ya existe un tipo de parque con el nombre: Parque Nacional"
EXEC Gestion.TipoParque_Alta @nombre = 'Parque Nacional';


-- TipoParque_Modificar

-- OK: modificar descripcion
EXEC Gestion.TipoParque_Modificar @idTipoParque = 1, @descripcion = 'Mayor categoria de proteccion';

-- OK: modificar nombre (al mismo, no debe autobloquearse)
EXEC Gestion.TipoParque_Modificar @idTipoParque = 1, @nombre = 'Parque Nacional';

-- ERROR: id no existe -> "No existe un tipo de parque con id: 999"
EXEC Gestion.TipoParque_Modificar @idTipoParque = 999, @nombre = 'X';

-- ERROR: nombre vacio -> "El nombre no puede estar vacio."
EXEC Gestion.TipoParque_Modificar @idTipoParque = 1, @nombre = '';

-- ERROR: nombre duplicado con otro -> "Ya existe otro tipo de parque con el nombre: Reserva Natural"
EXEC Gestion.TipoParque_Modificar @idTipoParque = 1, @nombre = 'Reserva Natural';


-- TipoParque_Baja

-- OK: borrar tipo sin parques asociados
EXEC Gestion.TipoParque_Alta @nombre = 'Monumento Natural';
EXEC Gestion.TipoParque_Baja @idTipoParque = (SELECT idTipoParque FROM Gestion.TipoParque WHERE nombre = 'Monumento Natural');

-- ERROR: id no existe -> "No existe un tipo de parque con id: 999"
EXEC Gestion.TipoParque_Baja @idTipoParque = 999;

-- ERROR: tipo con parques asociados, se prueba mas abajo, despues de Parque_Alta


-- Parque_Alta

-- OK: alta valida
EXEC Gestion.Parque_Alta 
    @nombre = 'Iguazu',
    @superficie = 67000,
    @idTipoParque = 1,
    @provincia = 'Misiones';

EXEC Gestion.Parque_Alta 
    @nombre = 'Nahuel Huapi',
    @superficie = 717261,
    @idTipoParque = 1,
    @provincia = 'Rio Negro';

SELECT * FROM Gestion.Parque;

-- ERROR: nombre vacio -> "El nombre del parque es obligatorio."
EXEC Gestion.Parque_Alta 
    @nombre = '',
    @superficie = 1000,
    @idTipoParque = 1,
    @provincia = 'Buenos Aires';

-- ERROR: provincia vacia -> "La provincia es obligatoria."
EXEC Gestion.Parque_Alta 
    @nombre = 'Test',
    @superficie = 1000,
    @idTipoParque = 1,
    @provincia = '';

-- ERROR: superficie <= 0 -> "La superficie debe ser mayor a 0."
EXEC Gestion.Parque_Alta 
    @nombre = 'Test',
    @superficie = -100,
    @idTipoParque = 1,
    @provincia = 'Buenos Aires';

-- ERROR: nombre duplicado -> "Ya existe un parque con el nombre: Iguazu"
EXEC Gestion.Parque_Alta 
    @nombre = 'Iguazu',
    @superficie = 1000,
    @idTipoParque = 1,
    @provincia = 'Buenos Aires';

-- ERROR: idTipoParque no existe -> "No existe un tipo de parque con id: 999"
EXEC Gestion.Parque_Alta 
    @nombre = 'Test',
    @superficie = 1000,
    @idTipoParque = 999,
    @provincia = 'Buenos Aires';


-- ERROR pendiente de TipoParque_Baja: tipo con parques asociados
EXEC Gestion.TipoParque_Baja @idTipoParque = 1;
-- ESPERADO: "No se puede eliminar: existen parques asociados a este tipo."


-- Parque_Modificar

-- OK: modificar superficie
EXEC Gestion.Parque_Modificar @idParque = 1, @superficie = 67500;

-- OK: modificar varios campos
EXEC Gestion.Parque_Modificar 
    @idParque = 2,
    @provincia = 'Rio Negro / Neuquen',
    @codigoPostal = '8400';

SELECT * FROM Gestion.Parque;

-- ERROR: id no existe -> "No existe un parque con id: 999"
EXEC Gestion.Parque_Modificar @idParque = 999, @nombre = 'X';

-- ERROR: nombre vacio -> "El nombre no puede estar vacio."
EXEC Gestion.Parque_Modificar @idParque = 1, @nombre = '';

-- ERROR: nombre duplicado con otro -> "Ya existe otro parque con el nombre: Nahuel Huapi"
EXEC Gestion.Parque_Modificar @idParque = 1, @nombre = 'Nahuel Huapi';

-- ERROR: superficie <= 0 -> "La superficie debe ser mayor a 0."
EXEC Gestion.Parque_Modificar @idParque = 1, @superficie = -50;

-- ERROR: idTipoParque no existe -> "No existe un tipo de parque con id: 999"
EXEC Gestion.Parque_Modificar @idParque = 1, @idTipoParque = 999;


-- Parque_Baja

-- OK: borrar parque sin dependencias
EXEC Gestion.Parque_Baja @idParque = 2;

SELECT * FROM Gestion.Parque;

-- ERROR: id no existe -> "No existe un parque con id: 999"
EXEC Gestion.Parque_Baja @idParque = 999;

-- ERROR: parque con concesiones asociadas -> se prueba desde Testing_Concesiones
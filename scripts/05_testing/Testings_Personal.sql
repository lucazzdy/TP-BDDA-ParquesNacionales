USE GestionParquesNacionales;
GO

/*=========================================================
TESTING STORE PROCEDURE TABLA GUARDAPARQUES
=========================================================*/

---------------------------------------------------------
-- ALTA DE GUARDAPARQUES
---------------------------------------------------------

/*=======================================================
TEST 1
Alta correcta de guardaparque
Resultado esperado:
Se inserta correctamente.
=======================================================*/

EXEC Personal.altaGuardaparques
    @documento = '12345678',
    @nombre = 'Juan',
    @apellido = 'Perez',
    @fechaNacimiento = '1990-05-10',
    @estado = 'ACTIVO';

EXEC Personal.altaGuardaparques
    @documento = '11111111',
    @nombre = 'Matias',
    @apellido = 'Perez',
    @fechaNacimiento = '2000-05-10',
    @estado = 'ACTIVO';

EXEC Personal.altaGuardaparques
    @documento = '12345679',
    @nombre = 'Juana',
    @apellido = 'Perez',
    @fechaNacimiento = '1995-05-10',
    @estado = 'ACTIVO';

SELECT *
FROM Personal.guardaparques;
GO

/*=======================================================
TEST 2
Resultado esperado:
Error - El nombre es obligatorio.
=======================================================*/

EXEC Personal.altaGuardaparques
    @documento = '11111111',
    @nombre = '',
    @apellido = 'Perez',
    @fechaNacimiento = '1990-05-10',
    @estado = 'ACTIVO';
GO

/*=======================================================
TEST 3
Resultado esperado:
Error - El apellido es obligatorio.
=======================================================*/

EXEC Personal.altaGuardaparques
    @documento = '22222222',
    @nombre = 'Juan',
    @apellido = '',
    @fechaNacimiento = '1990-05-10',
    @estado = 'ACTIVO';
GO

/*=======================================================
TEST 4
Resultado esperado:
Error - Ya existe un guardaparque con ese documento.
=======================================================*/

EXEC Personal.altaGuardaparques
    @documento = '12345678',
    @nombre = 'Pedro',
    @apellido = 'Gomez',
    @fechaNacimiento = '1991-01-01',
    @estado = 'ACTIVO';
GO

/*=======================================================
TEST 5
Resultado esperado:
Error - Debe ser mayor de 18 años.
=======================================================*/

EXEC Personal.altaGuardaparques
    @documento = '33333333',
    @nombre = 'Lucas',
    @apellido = 'Martinez',
    @fechaNacimiento = '2025-01-01',
    @estado = 'ACTIVO';
GO

---------------------------------------------------------
-- MODIFICACION DE GUARDAPARQUES POR LEGAJO
---------------------------------------------------------

/*=======================================================
TEST 6
Resultado esperado:
Se modifica correctamente.
=======================================================*/

EXEC Personal.modificarGuardaparque
    @legajo = 1,
    @nuevoNombre = 'Juan Carlos';

SELECT *
FROM Personal.guardaparques
WHERE legajo = 1;
GO

/*=======================================================
TEST 7
Resultado esperado:
Error - El legajo no existe.
=======================================================*/

EXEC Personal.modificarGuardaparque
    @legajo = 999;
GO

/*=======================================================
TEST 8
Resultado esperado:
Error - Ya existe otro guardaparque con ese documento.
=======================================================*/

EXEC Personal.modificarGuardaparque
    @legajo = 1,
    @nuevoDocumento = '11111111';
GO

---------------------------------------------------------
-- BAJA DE GUARDAPARQUES
---------------------------------------------------------

/*=======================================================
TEST 9
Resultado esperado:
Estado = INACTIVO
=======================================================*/

EXEC Personal.bajaGuardaparque
    @Legajo = 1;

SELECT legajo, estado
FROM personal.guardaParques
WHERE legajo = 1;
GO

/*=======================================================
TEST 10
Resultado esperado:
Error - El legajo no existe.
=======================================================*/

EXEC Personal.bajaGuardaparque
    @legajo = 999;
GO

/*=======================================================
TEST 11
Resultado esperado:
Error - El guardaparque ya se encuentra inactivo.
=======================================================*/

EXEC Personal.bajaGuardaparque
    @legajo = 1;
GO

/*=========================================================
TESTING STORE PROCEDURE TABLA HISTORIAL GUARDAPARQUES
=========================================================*/

---------------------------------------------------------
-- ASIGNACION DE GUARDAPARQUES A UN PARQUE
---------------------------------------------------------

/*=======================================================
TEST 12
Resultado esperado:
Asignación realizada correctamente.
=======================================================*/

--PUEDE FALLAR SI NO HAY UN PARQUE CREADO

EXEC Personal.asignarGuardaparqueParque
    @legajo = 2,
    @idParque = 1,
    @fechaIngreso = '2025-01-01';

SELECT *
FROM Personal.historialGuardaparques
WHERE legajoGuardaparques = 2;
GO

/*=======================================================
TEST 13
Resultado esperado:
Error - El guardaparque no existe.
=======================================================*/

EXEC Personal.asignarGuardaparqueParque
    @legajo = 999,
    @idParque = 1,
    @fechaIngreso = '2025-01-01';
GO

/*=======================================================
TEST 14
Resultado esperado:
Error - El parque no existe.
=======================================================*/

EXEC Personal.asignarGuardaparqueParque
    @legajo = 2,
    @idParque = 999,
    @fechaIngreso = '2025-01-01';
GO

/*=======================================================
TEST 15
Resultado esperado:
Error - Ya posee una asignación activa.
=======================================================*/

EXEC Personal.asignarGuardaparqueParque
    @legajo = 2,
    @idParque = 2,
    @fechaIngreso = '2025-01-01';
GO

---------------------------------------------------------
-- REASIGNACION DE GUARDAPARQUES A UN PARQUE
---------------------------------------------------------

/*=======================================================
TEST 16
Resultado esperado:
Se cierra la asignación actual y se crea una nueva.
=======================================================*/

--PUEDE FALLAR SI NO HAY MAS PARQUES CREADOS O OTRO GUIA

EXEC Personal.ReasignarGuardaparque
    @legajo = 2,
    @nuevoParque = 2,
    @fechaCambio = '2026-12-01',
    @motivoEgreso = 'Traslado operativo';

SELECT *
FROM Personal.historialGuardaParques
WHERE legajoGuardaparques = 2
ORDER BY idHistorial;
GO

/*=======================================================
TEST 17
Resultado esperado:
MotivoEgreso queda NULL.
=======================================================*/

EXEC Personal.reasignarGuardaparque
    @legajo = 2,
    @nuevoParque = 3,
    @fechaCambio = '2026-12-01'
GO

/*=======================================================
TEST 18
Resultado esperado:
Error - El guardaparque no existe.
=======================================================*/

EXEC Personal.reasignarGuardaparque
    @legajo = 999,
    @nuevoParque = 1,
    @fechaCambio = '2026-12-01';
GO

/*=======================================================
TEST 19
Resultado esperado:
Error - El parque no existe.
=======================================================*/

EXEC Personal.reasignarGuardaparque
    @legajo = 2,
    @nuevoParque = 999,
    @fechaCambio = '2026-12-01';
GO

/*=======================================================
TESTING STORE PROCEDURE TABLA TITULOS GUIAS
=======================================================*/

---------------------------------------------------------
-- ALTA TITULOS GUIA
---------------------------------------------------------
/*=======================================================
TEST 20
Resultado esperado:
Se crean correctamente 3 títulos.
=======================================================*/

EXEC Personal.altaTitulo
    @nombre = 'Licenciado en Turismo',
    @descripcion = 'Titulo universitario';

EXEC Personal.altaTitulo
    @nombre = 'Biologo',
    @descripcion = 'Especialista en fauna';

EXEC Personal.altaTitulo
    @nombre = 'Guia de Montaña',
    @descripcion = 'Especialista en montaña';

SELECT *
FROM Personal.titulos;
GO

/*=======================================================
TEST 21
Resultado esperado:
Error - Ya existe un título con ese nombre.
=======================================================*/

EXEC Personal.altaTitulo
    @nombre = 'Biologo',
    @descripcion = 'Duplicado';
GO

---------------------------------------------------------
-- MODIFICACION TITULOS GUIAS
---------------------------------------------------------
/*=======================================================
TEST 22
Resultado esperado:
Se modifica correctamente el título.
=======================================================*/

EXEC Personal.modificarTitulo
    @codTitulo = 1,
    @nombre = 'Licenciado en Ecoturismo',
    @descripcion = 'Titulo actualizado';

SELECT *
FROM Personal.titulos
WHERE codTitulo = 1;
GO

/*=======================================================
TEST 23
Resultado esperado:
Error - El titulo no existe.
=======================================================*/

EXEC Personal.modificarTitulo
    @codTitulo = 999,
    @nombre = 'Prueba',
    @descripcion = 'Prueba';
GO

---------------------------------------------------------
-- BAJA TITULOS GUIAS
---------------------------------------------------------
/*=======================================================
TEST 24
Resultado esperado:
Se elimina correctamente el título.
=======================================================*/

EXEC Personal.bajaTitulo
    @codTitulo = 3;

SELECT *
FROM Personal.titulos;
GO

/*=======================================================
TEST 25
Resultado esperado:
Error - No se puede eliminar el titulo porque está asignado a uno o más guias.
=======================================================*/

EXEC Personal.bajaTitulo
    @codTitulo = 1;
GO

/*=======================================================
TESTING STORE PROCEDURE TABLA ESPECIALIDAD GUIAS
=======================================================*/

---------------------------------------------------------
-- ALTA ESPECIALIDAD GUIAS
---------------------------------------------------------
/*=======================================================
TEST 26
Resultado esperado:
Se crean correctamente 3 especialidades.
=======================================================*/

EXEC Personal.altaEspecialidad
    @nombre = 'Fauna',
    @descripcion = 'Especialista en animales';

EXEC Personal.altaEspecialidad
    @nombre = 'Flora',
    @descripcion = 'Especialista en vegetación';

EXEC Personal.altaEspecialidad
    @nombre = 'Geologia',
    @descripcion = 'Especialista en geología';

SELECT *
FROM Personal.especialidad;
GO

/*=======================================================
TEST 27
Resultado esperado:
Error - La especialidad ya existe.
=======================================================*/

EXEC Personal.altaEspecialidad
    @nombre = 'Fauna',
    @descripcion = 'Duplicada';
GO

---------------------------------------------------------
-- MODIFICACION ESPECIALIDAD GUIAS
---------------------------------------------------------
/*=======================================================
TEST 28
Resultado esperado:
Se modifica correctamente la especialidad.
=======================================================*/

EXEC Personal.modificarEspecialidad
    @codEspecialidad = 1,
    @nombre = 'Fauna Silvestre',
    @descripcion = 'Actualizada';

SELECT *
FROM Personal.especialidad
WHERE codEspecialidad = 1;
GO

/*=======================================================
TEST 29
Resultado esperado:
Error - La especialidad no existe.
=======================================================*/

EXEC Personal.modificarEspecialidad
    @codEspecialidad = 999,
    @nombre = 'Prueba',
    @descripcion = 'Prueba';
GO

---------------------------------------------------------
-- BAJA ESPECIALIDAD GUIAS
---------------------------------------------------------

/*=======================================================
TEST 30
Resultado esperado:
Se elimina correctamente la especialidad.
=======================================================*/

EXEC Personal.bajaEspecialidad
    @codEspecialidad = 3;

SELECT *
FROM Personal.especialidad;
GO

/*=======================================================
TESTING STORE PROCEDURE TABLA GUIAS
=======================================================*/

---------------------------------------------------------
-- ALTA GUIA
---------------------------------------------------------
/*=======================================================
TEST 31
Resultado esperado:
Se crean correctamente 3 guías.
=======================================================*/

EXEC Personal.altaGuia
    '11111111','Pedro','Lopez','1985-01-01',1,1;

EXEC Personal.altaGuia
    '22222222','Maria','Perez','1988-02-02',1,2;

EXEC Personal.altaGuia
    '33333333','Carlos','Gomez','1990-03-03',2,1;

SELECT *
FROM Personal.guias;
GO

/*=======================================================
TEST 32
Resultado esperado:
Error - El documento ya existe.
=======================================================*/

EXEC Personal.altaGuia
    '11111111','Juan','Prueba','1995-01-01',1,1;
GO

---------------------------------------------------------
-- MODIFICACION GUIA
---------------------------------------------------------

/*=======================================================
TEST 33
Resultado esperado:
Se modifica correctamente el guía.
=======================================================*/

EXEC Personal.modificarGuia
    @legajo = 1,
    @nombre = 'Pedro Modificado',
    @apellido = 'Lopez Modificado',
    @fechaNacimiento = '1985-01-01',
    @codTitulo = 2,
    @codEspecialidad = 2;

SELECT *
FROM Personal.guias
WHERE legajo = 1;
GO

---------------------------------------------------------
-- BAJA GUIA
---------------------------------------------------------
/*=======================================================
TEST 34
Resultado esperado:
Se elimina correctamente el guía.
=======================================================*/

EXEC Personal.bajaGuia
    @legajo = 3;

SELECT *
FROM Personal.guias;
GO

/*=======================================================
STORE PROCEDURE TABLA HABILITACIONES
=======================================================*/
---------------------------------------------------------
-- ALTA HABILITACIONES
---------------------------------------------------------
/*=======================================================
TEST 35
Resultado esperado:
Se crean correctamente 3 habilitaciones.
=======================================================*/

EXEC Personal.altaHabilitacion
    'Senderismo',
    'Recorridos de senderos';

EXEC Personal.altaHabilitacion
    'Montañismo',
    'Actividades de montaña';

EXEC Personal.altaHabilitacion
    'Avistaje',
    'Observación de fauna';

SELECT *
FROM Personal.habilitaciones;
GO
---------------------------------------------------------
-- MODIFICACION HABILITACIONES
---------------------------------------------------------
/*=======================================================
TEST 36
Resultado esperado:
Se modifica correctamente la habilitación.
=======================================================*/

EXEC Personal.modificarHabilitacion
    @idHabilitacion = 1,
    @nombre = 'Senderismo Avanzado',
    @descripcion = 'Actualizada';

SELECT *
FROM Personal.habilitaciones
WHERE idHabilitaciones = 1;
GO

/*=======================================================
TEST 37
Resultado esperado:
Error - La habilitación no existe.
=======================================================*/

EXEC Personal.modificarHabilitacion
    @idHabilitacion = 999,
    @nombre = 'Prueba',
    @descripcion = 'Prueba';
GO
---------------------------------------------------------
-- BAJA HABILITACIONES
---------------------------------------------------------

/*=======================================================
TEST 38
Resultado esperado:
Se elimina correctamente la habilitación.
=======================================================*/

EXEC Personal.bajaHabilitacion
    @idHabilitacion = 3;

SELECT *
FROM Personal.habilitaciones;
GO

/*=======================================================
TEST 39
Resultado esperado:
Error - No se puede eliminar la habilitación porque está asociada a guías.
=======================================================*/

EXEC Personal.bajaHabilitacion
    @idHabilitacion = 1;
GO

/*=======================================================
TEST 40
Resultado esperado:
Error - La habilitación no existe.
=======================================================*/

EXEC Personal.bajaHabilitacion
    @idHabilitacion = 999;
GO

/*=======================================================
STORE PROCEDURE TABLA HABILITACIONES GUIAS POR PARQUE
=======================================================*/
---------------------------------------------------------
-- ALTA HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------
/*=======================================================
TEST 41
Resultado esperado:
Se crea correctamente la habilitación de guía.
=======================================================*/

EXEC Personal.altaHabilitacionGuia
    @idHabilitacion = 1,
    @legajoGuia = 1,
    @idParque = 1,
    @fechaComienzo = '2026-01-01',
    @fechaFin = '2026-12-31';

SELECT *
FROM Personal.habilitacionesGuias;
GO


---------------------------------------------------------
-- MODIFICACION HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------

/*=======================================================
TEST 42
Resultado esperado:
Se modifica correctamente la habilitación de guía.
=======================================================*/

EXEC Personal.modificarHabilitacionGuia
    @idHabilitacionGuia = 1,
    @idHabilitacion = 2,
    @legajoGuia = 1,
    @idParque = 2,
    @fechaComienzo = '2026-02-01',
    @fechaFin = '2026-11-30';

SELECT *
FROM Personal.habilitacionesGuias
WHERE idHabilitacionGuia = 1;
GO

/*=======================================================
TEST 43
Resultado esperado:
Error - La habilitación del guía no existe.
=======================================================*/

EXEC Personal.modificarHabilitacionGuia
    @idHabilitacionGuia = 999,
    @idHabilitacion = 1,
    @legajoGuia = 1,
    @idParque = 1,
    @fechaComienzo = '2026-01-01',
    @fechaFin = '2026-12-31';
GO

---------------------------------------------------------
-- BAJA HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------

/*=======================================================
TEST 44
Resultado esperado:
Se elimina correctamente la habilitación del guía.
=======================================================*/

EXEC Personal.bajaHabilitacionGuia
    @idHabilitacionGuia = 1;

SELECT *
FROM Personal.habilitacionesGuias;
GO

/*=======================================================
TEST 45
Resultado esperado:
Error - La habilitación del guía no existe.
=======================================================*/

EXEC Personal.bajaHabilitacionGuia
    @idHabilitacionGuia = 999;
GO
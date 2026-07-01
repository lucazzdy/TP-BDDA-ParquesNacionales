USE GestionParquesNacionales_Com5600_Grupo07;
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

EXEC Personal.guardaparquesAlta
    @documento = '12345678',
    @nombre = 'Juan',
    @apellido = 'Perez',
    @fechaNacimiento = '1990-05-10',
    @estado = 'ACTIVO';

EXEC Personal.guardaparquesAlta
    @documento = '11111111',
    @nombre = 'Matias',
    @apellido = 'Perez',
    @fechaNacimiento = '2000-05-10',
    @estado = 'ACTIVO';

EXEC Personal.guardaparquesAlta
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

EXEC Personal.guardaparquesAlta
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

EXEC Personal.guardaparquesAlta
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

EXEC Personal.guardaparquesAlta
    @documento = '12345678',
    @nombre = 'Pedro',
    @apellido = 'Gomez',
    @fechaNacimiento = '1991-01-01',
    @estado = 'ACTIVO';
GO

/*=======================================================
TEST 5
Resultado esperado:
Error - Debe ser mayor de 18 a�os.
=======================================================*/

EXEC Personal.guardaparquesAlta
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

EXEC Personal.guardaparquesModificar
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

EXEC Personal.guardaparquesModificar
    @legajo = 999;
GO

/*=======================================================
TEST 8
Resultado esperado:
Error - Ya existe otro guardaparque con ese documento.
=======================================================*/

EXEC Personal.guardaparquesModificar
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

EXEC Personal.guardaparqueBaja
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

EXEC Personal.guardaparqueBaja
    @legajo = 999;
GO

/*=======================================================
TEST 11
Resultado esperado:
Error - El guardaparque ya se encuentra inactivo.
=======================================================*/

EXEC Personal.guardaparqueBaja
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
Asignaci�n realizada correctamente.
=======================================================*/

--PUEDE FALLAR SI NO HAY UN PARQUE CREADO

EXEC Personal.guardaparqueParqueAsignar
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

EXEC Personal.guardaparqueParqueAsignar
    @legajo = 999,
    @idParque = 1,
    @fechaIngreso = '2025-01-01';
GO

/*=======================================================
TEST 14
Resultado esperado:
Error - El parque no existe.
=======================================================*/

EXEC Personal.guardaparqueParqueAsignar
    @legajo = 2,
    @idParque = 999,
    @fechaIngreso = '2025-01-01';
GO

/*=======================================================
TEST 15
Resultado esperado:
Error - Ya posee una asignaci�n activa.
=======================================================*/

EXEC Personal.guardaparqueParqueAsignar
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
Se cierra la asignaci�n actual y se crea una nueva.
=======================================================*/

--PUEDE FALLAR SI NO HAY MAS PARQUES CREADOS O OTRO GUIA

EXEC Personal.guardaparqueReasignar
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

EXEC Personal.guardaparqueReasignar
    @legajo = 2,
    @nuevoParque = 3,
    @fechaCambio = '2026-12-01'
GO

/*=======================================================
TEST 18
Resultado esperado:
Error - El guardaparque no existe.
=======================================================*/

EXEC Personal.guardaparqueReasignar
    @legajo = 999,
    @nuevoParque = 1,
    @fechaCambio = '2026-12-01';
GO

/*=======================================================
TEST 19
Resultado esperado:
Error - El parque no existe.
=======================================================*/

EXEC Personal.guardaparqueReasignar
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
Se crean correctamente 3 t�tulos.
=======================================================*/

EXEC Personal.tituloAlta
    @nombre = 'Licenciado en Turismo',
    @descripcion = 'Titulo universitario';

EXEC Personal.tituloAlta
    @nombre = 'Biologo',
    @descripcion = 'Especialista en fauna';

EXEC Personal.tituloAlta
    @nombre = 'Guia de Monta�a',
    @descripcion = 'Especialista en monta�a';

SELECT *
FROM Personal.titulos;
GO

/*=======================================================
TEST 21
Resultado esperado:
Error - Ya existe un t�tulo con ese nombre.
=======================================================*/

EXEC Personal.tituloAlta
    @nombre = 'Biologo',
    @descripcion = 'Duplicado';
GO

---------------------------------------------------------
-- MODIFICACION TITULOS GUIAS
---------------------------------------------------------
/*=======================================================
TEST 22
Resultado esperado:
Se modifica correctamente el t�tulo.
=======================================================*/

EXEC Personal.tituloModificar
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

EXEC Personal.tituloModificar
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
Se elimina correctamente el t�tulo.
=======================================================*/

EXEC Personal.tituloBaja
    @codTitulo = 3;

SELECT *
FROM Personal.titulos;
GO

/*=======================================================
TEST 25
Resultado esperado:
Error - No se puede eliminar el titulo porque est� asignado a uno o m�s guias.
=======================================================*/

EXEC Personal.tituloBaja
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

EXEC Personal.especialidadAlta
    @nombre = 'Fauna',
    @descripcion = 'Especialista en animales';

EXEC Personal.especialidadAlta
    @nombre = 'Flora',
    @descripcion = 'Especialista en vegetaci�n';

EXEC Personal.especialidadAlta
    @nombre = 'Geologia',
    @descripcion = 'Especialista en geolog�a';

SELECT *
FROM Personal.especialidad;
GO

/*=======================================================
TEST 27
Resultado esperado:
Error - La especialidad ya existe.
=======================================================*/

EXEC Personal.especialidadAlta
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

EXEC Personal.especialidadModificar
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

EXEC Personal.especialidadModificar
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

EXEC Personal.especialidadBaja
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
Se crean correctamente 3 gu�as.
=======================================================*/

EXEC Personal.guiaAlta
    '11111111','Pedro','Lopez','1985-01-01',1,1;

EXEC Personal.guiaAlta
    '22222222','Maria','Perez','1988-02-02',1,2;

EXEC Personal.guiaAlta
    '33333333','Carlos','Gomez','1990-03-03',2,1;

SELECT *
FROM Personal.guias;
GO

/*=======================================================
TEST 32
Resultado esperado:
Error - El documento ya existe.
=======================================================*/

EXEC Personal.guiaAlta
    '11111111','Juan','Prueba','1995-01-01',1,1;
GO

---------------------------------------------------------
-- MODIFICACION GUIA
---------------------------------------------------------

/*=======================================================
TEST 33
Resultado esperado:
Se modifica correctamente el gu�a.
=======================================================*/

EXEC Personal.guiaModificar
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
Se elimina correctamente el gu�a.
=======================================================*/

EXEC Personal.guiaBaja
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

EXEC Personal.habilitacionAlta
    'Senderismo',
    'Recorridos de senderos';

EXEC Personal.habilitacionAlta
    'Monta�ismo',
    'Actividades de monta�a';

EXEC Personal.habilitacionAlta
    'Avistaje',
    'Observaci�n de fauna';

SELECT *
FROM Personal.habilitaciones;
GO
---------------------------------------------------------
-- MODIFICACION HABILITACIONES
---------------------------------------------------------
/*=======================================================
TEST 36
Resultado esperado:
Se modifica correctamente la habilitaci�n.
=======================================================*/

EXEC Personal.habilitacionModificar
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
Error - La habilitaci�n no existe.
=======================================================*/

EXEC Personal.habilitacionModificar
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
Se elimina correctamente la habilitaci�n.
=======================================================*/

EXEC Personal.habilitacionBaja
    @idHabilitacion = 3;

SELECT *
FROM Personal.habilitaciones;
GO

/*=======================================================
TEST 39
Resultado esperado:
Error - No se puede eliminar la habilitaci�n porque est� asociada a gu�as.
=======================================================*/

EXEC Personal.habilitacionBaja
    @idHabilitacion = 1;
GO

/*=======================================================
TEST 40
Resultado esperado:
Error - La habilitaci�n no existe.
=======================================================*/

EXEC Personal.habilitacionBaja
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
Se crea correctamente la habilitaci�n de gu�a.
=======================================================*/

EXEC Personal.habilitacionGuiaAlta
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
Se modifica correctamente la habilitaci�n de gu�a.
=======================================================*/

EXEC Personal.habilitacionGuiaModificar
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
Error - La habilitaci�n del gu�a no existe.
=======================================================*/

EXEC Personal.habilitacionGuiaModificar
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
Se elimina correctamente la habilitaci�n del gu�a.
=======================================================*/

EXEC Personal.habilitacionGuiaBaja
    @idHabilitacionGuia = 1;

SELECT *
FROM Personal.habilitacionesGuias;
GO

/*=======================================================
TEST 45
Resultado esperado:
Error - La habilitaci�n del gu�a no existe.
=======================================================*/

EXEC Personal.habilitacionGuiaBaja
    @idHabilitacionGuia = 999;
GO
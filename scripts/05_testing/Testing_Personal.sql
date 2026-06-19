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

EXEC Personal.Guardaparques_Alta
    @Documento = '12345678',
    @Nombre = 'Juan',
    @Apellido = 'Perez',
    @FechaNacimiento = '1990-05-10',
    @Estado = 'ACTIVO';

EXEC Personal.Guardaparques_Alta
    @Documento = '11111111',
    @Nombre = 'Matias',
    @Apellido = 'Perez',
    @FechaNacimiento = '2000-05-10',
    @Estado = 'ACTIVO';

EXEC Personal.Guardaparques_Alta
    @Documento = '12345679',
    @Nombre = 'Juana',
    @Apellido = 'Perez',
    @FechaNacimiento = '1995-05-10',
    @Estado = 'ACTIVO';

SELECT *
FROM Personal.GuardaParques;
GO

/*=======================================================
TEST 2
Resultado esperado:
Error - El nombre es obligatorio.
=======================================================*/

EXEC Personal.Guardaparques_Alta
    @Documento = '11111111',
    @Nombre = '',
    @Apellido = 'Perez',
    @FechaNacimiento = '1990-05-10',
    @Estado = 'ACTIVO';
GO

/*=======================================================
TEST 3
Resultado esperado:
Error - El apellido es obligatorio.
=======================================================*/

EXEC Personal.Guardaparques_Alta
    @Documento = '22222222',
    @Nombre = 'Juan',
    @Apellido = '',
    @FechaNacimiento = '1990-05-10',
    @Estado = 'ACTIVO';
GO

/*=======================================================
TEST 4
Resultado esperado:
Error - Ya existe un guardaparque con ese documento.
=======================================================*/

EXEC Personal.Guardaparques_Alta
    @Documento = '12345678',
    @Nombre = 'Pedro',
    @Apellido = 'Gomez',
    @FechaNacimiento = '1991-01-01',
    @Estado = 'ACTIVO';
GO

/*=======================================================
TEST 5
Resultado esperado:
Error - Debe ser mayor de 18 años.
=======================================================*/

EXEC Personal.Guardaparques_Alta
    @Documento = '33333333',
    @Nombre = 'Lucas',
    @Apellido = 'Martinez',
    @FechaNacimiento = '2025-01-01',
    @Estado = 'ACTIVO';
GO

---------------------------------------------------------
-- MODIFICACION DE GUARDAPARQUES POR LEGAJO
---------------------------------------------------------

/*=======================================================
TEST 6
Resultado esperado:
Se modifica correctamente.
=======================================================*/

EXEC Personal.ModificarGuardaparques
    @Legajo = 1,
    @NuevoNombre = 'Juan Carlos';

SELECT *
FROM Personal.GuardaParques
WHERE Legajo = 1;
GO

/*=======================================================
TEST 7
Resultado esperado:
Error - El legajo no existe.
=======================================================*/

EXEC Personal.ModificarGuardaparques
    @Legajo = 999;
GO

/*=======================================================
TEST 8
Resultado esperado:
Error - Ya existe otro guardaparque con ese documento.
=======================================================*/

EXEC Personal.ModificarGuardaparques
    @Legajo = 1,
    @NuevoDocumento = '87654321';
GO

---------------------------------------------------------
-- BAJA DE GUARDAPARQUES
---------------------------------------------------------

/*=======================================================
TEST 9
Resultado esperado:
Estado = INACTIVO
=======================================================*/

EXEC Personal.Guardaparque_Baja
    @Legajo = 1;

SELECT Legajo, Estado
FROM Personal.GuardaParques
WHERE Legajo = 1;
GO

/*=======================================================
TEST 10
Resultado esperado:
Error - El legajo no existe.
=======================================================*/

EXEC Personal.Guardaparque_Baja
    @Legajo = 999;
GO

/*=======================================================
TEST 11
Resultado esperado:
Error - El guardaparque ya se encuentra inactivo.
=======================================================*/

EXEC Personal.Guardaparque_Baja
    @Legajo = 1;
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

EXEC Personal.AsignarGuardaparqueParque
    @Legajo = 2,
    @IDParque = 1,
    @FechaIngreso = '2025-01-01';

SELECT *
FROM Personal.HistorialGuardaParques
WHERE LegajoGuardaParques = 2;
GO

/*=======================================================
TEST 13
Resultado esperado:
Error - El guardaparque no existe.
=======================================================*/

EXEC Personal.AsignarGuardaparqueParque
    @Legajo = 999,
    @IDParque = 1,
    @FechaIngreso = '2025-01-01';
GO

/*=======================================================
TEST 14
Resultado esperado:
Error - El parque no existe.
=======================================================*/

EXEC Personal.AsignarGuardaparqueParque
    @Legajo = 2,
    @IDParque = 999,
    @FechaIngreso = '2025-01-01';
GO

/*=======================================================
TEST 15
Resultado esperado:
Error - Ya posee una asignación activa.
=======================================================*/

EXEC Personal.AsignarGuardaparqueParque
    @Legajo = 2,
    @IDParque = 2,
    @FechaIngreso = '2025-01-01';
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
    @Legajo = 2,
    @NuevoParque = 2,
    @FechaCambio = '2026-12-01',
    @MotivoEgreso = 'Traslado operativo';

SELECT *
FROM Personal.HistorialGuardaParques
WHERE LegajoGuardaParques = 2
ORDER BY IDHistorial;
GO

/*=======================================================
TEST 17
Resultado esperado:
MotivoEgreso queda NULL.
=======================================================*/

EXEC Personal.ReasignarGuardaparque
    @Legajo = 2,
    @NuevoParque = 3,
    @FechaCambio = '2026-12-01'
GO

/*=======================================================
TEST 18
Resultado esperado:
Error - El guardaparque no existe.
=======================================================*/

EXEC Personal.ReasignarGuardaparque
    @Legajo = 999,
    @NuevoParque = 1,
    @FechaCambio = '2026-12-01';
GO

/*=======================================================
TEST 19
Resultado esperado:
Error - El parque no existe.
=======================================================*/

EXEC Personal.ReasignarGuardaparque
    @Legajo = 2,
    @NuevoParque = 999,
    @FechaCambio = '2026-12-01';
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

EXEC Personal.AltaTitulo
    @Nombre = 'Licenciado en Turismo',
    @Descripcion = 'Titulo universitario';

EXEC Personal.AltaTitulo
    @Nombre = 'Biologo',
    @Descripcion = 'Especialista en fauna';

EXEC Personal.AltaTitulo
    @Nombre = 'Guia de Montaña',
    @Descripcion = 'Especialista en montaña';

SELECT *
FROM Personal.Titulos;
GO

/*=======================================================
TEST 21
Resultado esperado:
Error - Ya existe un título con ese nombre.
=======================================================*/

EXEC Personal.AltaTitulo
    @Nombre = 'Biologo',
    @Descripcion = 'Duplicado';
GO

---------------------------------------------------------
-- MODIFICACION TITULOS GUIAS
---------------------------------------------------------
/*=======================================================
TEST 22
Resultado esperado:
Se modifica correctamente el título.
=======================================================*/

EXEC Personal.ModificarTitulo
    @CodTitulo = 1,
    @Nombre = 'Licenciado en Ecoturismo',
    @Descripcion = 'Titulo actualizado';

SELECT *
FROM Personal.Titulos
WHERE CodTitulo = 1;
GO

/*=======================================================
TEST 23
Resultado esperado:
Error - El titulo no existe.
=======================================================*/

EXEC Personal.ModificarTitulo
    @CodTitulo = 999,
    @Nombre = 'Prueba',
    @Descripcion = 'Prueba';
GO

---------------------------------------------------------
-- BAJA TITULOS GUIAS
---------------------------------------------------------
/*=======================================================
TEST 24
Resultado esperado:
Se elimina correctamente el título.
=======================================================*/

EXEC Personal.BajaTitulo
    @CodTitulo = 3;

SELECT *
FROM Personal.Titulos;
GO

/*=======================================================
TEST 25
Resultado esperado:
Error - No se puede eliminar el titulo porque está asignado a uno o más guias.
=======================================================*/

EXEC Personal.BajaTitulo
    @CodTitulo = 1;
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

EXEC Personal.AltaEspecialidad
    @Nombre = 'Fauna',
    @Descripcion = 'Especialista en animales';

EXEC Personal.AltaEspecialidad
    @Nombre = 'Flora',
    @Descripcion = 'Especialista en vegetación';

EXEC Personal.AltaEspecialidad
    @Nombre = 'Geologia',
    @Descripcion = 'Especialista en geología';

SELECT *
FROM Personal.Especialidad;
GO

/*=======================================================
TEST 27
Resultado esperado:
Error - La especialidad ya existe.
=======================================================*/

EXEC Personal.AltaEspecialidad
    @Nombre = 'Fauna',
    @Descripcion = 'Duplicada';
GO

---------------------------------------------------------
-- MODIFICACION ESPECIALIDAD GUIAS
---------------------------------------------------------
/*=======================================================
TEST 28
Resultado esperado:
Se modifica correctamente la especialidad.
=======================================================*/

EXEC Personal.ModificarEspecialidad
    @CodEspecialidad = 1,
    @Nombre = 'Fauna Silvestre',
    @Descripcion = 'Actualizada';

SELECT *
FROM Personal.Especialidad
WHERE CodEspecialidad = 1;
GO

/*=======================================================
TEST 29
Resultado esperado:
Error - La especialidad no existe.
=======================================================*/

EXEC Personal.ModificarEspecialidad
    @CodEspecialidad = 999,
    @Nombre = 'Prueba',
    @Descripcion = 'Prueba';
GO

---------------------------------------------------------
-- BAJA ESPECIALIDAD GUIAS
---------------------------------------------------------

/*=======================================================
TEST 30
Resultado esperado:
Se elimina correctamente la especialidad.
=======================================================*/

EXEC Personal.BajaEspecialidad
    @CodEspecialidad = 3;

SELECT *
FROM Personal.Especialidad;
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

EXEC Personal.AltaGuia
    '11111111','Pedro','Lopez','1985-01-01',1,1;

EXEC Personal.AltaGuia
    '22222222','Maria','Perez','1988-02-02',1,2;

EXEC Personal.AltaGuia
    '33333333','Carlos','Gomez','1990-03-03',2,1;

SELECT *
FROM Personal.Guias;
GO

/*=======================================================
TEST 32
Resultado esperado:
Error - El documento ya existe.
=======================================================*/

EXEC Personal.AltaGuia
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

EXEC Personal.ModificarGuia
    @Legajo = 1,
    @Nombre = 'Pedro Modificado',
    @Apellido = 'Lopez Modificado',
    @FechaNacimiento = '1985-01-01',
    @CodTitulo = 2,
    @CodEspecialidad = 2;

SELECT *
FROM Personal.Guias
WHERE Legajo = 1;
GO

---------------------------------------------------------
-- BAJA GUIA
---------------------------------------------------------
/*=======================================================
TEST 34
Resultado esperado:
Se elimina correctamente el guía.
=======================================================*/

EXEC Personal.BajaGuia
    @Legajo = 3;

SELECT *
FROM Personal.Guias;
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

EXEC Personal.AltaHabilitacion
    'Senderismo',
    'Recorridos de senderos';

EXEC Personal.AltaHabilitacion
    'Montañismo',
    'Actividades de montaña';

EXEC Personal.AltaHabilitacion
    'Avistaje',
    'Observación de fauna';

SELECT *
FROM Personal.Habilitaciones;
GO
---------------------------------------------------------
-- MODIFICACION HABILITACIONES
---------------------------------------------------------
/*=======================================================
TEST 36
Resultado esperado:
Se modifica correctamente la habilitación.
=======================================================*/

EXEC Personal.ModificarHabilitacion
    @IDHabilitacion = 1,
    @Nombre = 'Senderismo Avanzado',
    @Descripcion = 'Actualizada';

SELECT *
FROM Personal.Habilitaciones
WHERE IDHabilitaciones = 1;
GO

/*=======================================================
TEST 37
Resultado esperado:
Error - La habilitación no existe.
=======================================================*/

EXEC Personal.ModificarHabilitacion
    @IDHabilitacion = 999,
    @Nombre = 'Prueba',
    @Descripcion = 'Prueba';
GO
---------------------------------------------------------
-- BAJA HABILITACIONES
---------------------------------------------------------

/*=======================================================
TEST 38
Resultado esperado:
Se elimina correctamente la habilitación.
=======================================================*/

EXEC Personal.BajaHabilitacion
    @IDHabilitacion = 3;

SELECT *
FROM Personal.Habilitaciones;
GO

/*=======================================================
TEST 39
Resultado esperado:
Error - No se puede eliminar la habilitación porque está asociada a guías.
=======================================================*/

EXEC Personal.BajaHabilitacion
    @IDHabilitacion = 1;
GO

/*=======================================================
TEST 40
Resultado esperado:
Error - La habilitación no existe.
=======================================================*/

EXEC Personal.BajaHabilitacion
    @IDHabilitacion = 999;
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

EXEC Personal.AltaHabilitacionGuia
    @IDHabilitacion = 1,
    @LegajoGuia = 1,
    @IDParque = 1,
    @FechaComienzo = '2026-01-01',
    @FechaFin = '2026-12-31';

SELECT *
FROM Personal.HabilitacionesGuias;
GO


---------------------------------------------------------
-- MODIFICACION HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------

/*=======================================================
TEST 42
Resultado esperado:
Se modifica correctamente la habilitación de guía.
=======================================================*/

EXEC Personal.ModificarHabilitacionGuia
    @IDHabilitacionGuia = 1,
    @IDHabilitacion = 2,
    @LegajoGuia = 1,
    @IDParque = 2,
    @FechaComienzo = '2026-02-01',
    @FechaFin = '2026-11-30';

SELECT *
FROM Personal.HabilitacionesGuias
WHERE IDHabilitacionGuia = 1;
GO

/*=======================================================
TEST 43
Resultado esperado:
Error - La habilitación del guía no existe.
=======================================================*/

EXEC Personal.ModificarHabilitacionGuia
    @IDHabilitacionGuia = 999,
    @IDHabilitacion = 1,
    @LegajoGuia = 1,
    @IDParque = 1,
    @FechaComienzo = '2026-01-01',
    @FechaFin = '2026-12-31';
GO

---------------------------------------------------------
-- BAJA HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------

/*=======================================================
TEST 44
Resultado esperado:
Se elimina correctamente la habilitación del guía.
=======================================================*/

EXEC Personal.BajaHabilitacionGuia
    @IDHabilitacionGuia = 1;

SELECT *
FROM Personal.HabilitacionesGuias;
GO

/*=======================================================
TEST 45
Resultado esperado:
Error - La habilitación del guía no existe.
=======================================================*/

EXEC Personal.BajaHabilitacionGuia
    @IDHabilitacionGuia = 999;
GO
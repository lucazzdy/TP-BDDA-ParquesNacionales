USE GestionParquesNacionales;
GO

/*

/*=========================================================
TEST 1 - ALTA CORRECTA
=========================================================*/

PRINT 'TEST 1 - Alta correcta';

EXEC Personal.Guardaparque_Alta
    @TipoDocumento = 'DNI',
    @Documento = '40111222',
    @Nombre = 'Juan',
    @Apellido = 'Perez',
    @FechaNacimiento = '1990-05-10',
    @Estado = 'ACTIVO';
GO

SELECT *
FROM Personal.Guardaparque;
GO

/*=========================================================
TEST 2 - DOCUMENTO DUPLICADO
DEBE FALLAR
=========================================================*/

PRINT 'TEST 2 - Documento duplicado';

EXEC Personal.Guardaparque_Alta
    @TipoDocumento = 'DNI',
    @Documento = '40111222',
    @Nombre = 'Pedro',
    @Apellido = 'Gomez',
    @FechaNacimiento = '1992-02-10',
    @Estado = 'ACTIVO';
GO

/*=========================================================
TEST 3 - NOMBRE VACIO
DEBE FALLAR
=========================================================*/

PRINT 'TEST 3 - Nombre vacio';

EXEC Personal.Guardaparque_Alta
    @TipoDocumento = 'DNI',
    @Documento = '45555111',
    @Nombre = '',
    @Apellido = 'Lopez',
    @FechaNacimiento = '1993-03-15',
    @Estado = 'ACTIVO';
GO

/*=========================================================
TEST 4 - FECHA NACIMIENTO INVALIDA
DEBE FALLAR
=========================================================*/

PRINT 'TEST 4 - Fecha invalida';

EXEC Personal.Guardaparque_Alta
    @TipoDocumento = 'DNI',
    @Documento = '47777888',
    @Nombre = 'Mario',
    @Apellido = 'Diaz',
    @FechaNacimiento = '2050-01-01',
    @Estado = 'ACTIVO';
GO

/*=========================================================
TEST 5 - MODIFICACION CORRECTA
=========================================================*/

PRINT 'TEST 5 - Modificacion correcta';

EXEC Personal.ModificarGuardaparque
    @Legajo = 1,
    @NuevoNombre = 'Juan Carlos',
    @NuevoEstado = 'LICENCIA';
GO

SELECT *
FROM Personal.Guardaparque
WHERE Legajo = 1;
GO

/*=========================================================
TEST 6 - MODIFICAR LEGAJO INEXISTENTE
DEBE FALLAR
=========================================================*/

PRINT 'TEST 6 - Legajo inexistente';

EXEC Personal.ModificarGuardaparque
    @Legajo = 999,
    @NuevoNombre = 'Prueba';
GO

/*=========================================================
TEST 7 - BAJA LOGICA
=========================================================*/

PRINT 'TEST 7 - Baja logica';

EXEC Personal.Guardaparque_Baja
    @Legajo = 1;
GO

SELECT *
FROM Personal.Guardaparque
WHERE Legajo = 1;
GO

/*=========================================================
TEST 8 - ASIGNACION CORRECTA
=========================================================*/

PRINT 'TEST 8 - Asignacion correcta';

EXEC Personal.AsignarGuardaparqueParque
    @Legajo = 1,
    @IDParque = 1,
    @FechaIngreso = '2026-01-01';
GO

SELECT *
FROM Personal.HistorialGuardaparque;
GO

/*=========================================================
TEST 9 - SEGUNDA ASIGNACION ACTIVA
DEBE FALLAR
=========================================================*/

PRINT 'TEST 9 - Asignacion duplicada';

EXEC Personal.AsignarGuardaparqueParque
    @Legajo = 1,
    @IDParque = 2,
    @FechaIngreso = '2026-02-01';
GO

/*=========================================================
TEST 10 - REASIGNACION CORRECTA
=========================================================*/

PRINT 'TEST 10 - Reasignacion correcta';

EXEC Personal.ReasignarGuardaparque
    @Legajo = 1,
    @NuevoParque = 2,
    @FechaCambio = '2026-06-01';
GO

SELECT *
FROM Personal.HistorialGuardaparque
WHERE Legajo = 1
ORDER BY FechaIngreso;
GO

/*=========================================================
TEST 11 - REASIGNAR A PARQUE INEXISTENTE
DEBE FALLAR
=========================================================*/

PRINT 'TEST 11 - Parque inexistente';

EXEC Personal.ReasignarGuardaparque
    @Legajo = 1,
    @NuevoParque = 999,
    @FechaCambio = '2026-07-01';
GO

/*=========================================================
TEST 12 - CONSULTA HISTORIAL
=========================================================*/

PRINT 'TEST 12 - Historial completo';

SELECT
    G.Legajo,
    G.Nombre,
    G.Apellido,
    H.IDParque,
    H.FechaIngreso,
    H.FechaEgreso,
    H.MotivoEgreso
FROM Personal.Guardaparque G
INNER JOIN Personal.HistorialGuardaparque H
    ON G.Legajo = H.Legajo
ORDER BY G.Legajo, H.FechaIngreso;
GO

*/
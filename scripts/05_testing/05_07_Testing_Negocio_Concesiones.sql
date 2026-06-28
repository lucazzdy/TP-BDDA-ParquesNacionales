/* 
    Script generado el 22/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Testing de los SP de negocio del esquema Concesiones.
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO


-- registrarConcesionConPagos

-- OK: alta de concesion con generacion automatica de pagos pendientes
EXEC Concesiones.registrarConcesionConPagos 
    @idEmpresa = 1,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-01-01',
    @fechaFin = '2026-06-30',
    @montoCanonMensual = 100000;

SELECT * FROM Concesiones.concesion WHERE idEmpresa = 1 AND idParque = 1 AND fechaInicio = '2026-01-01';
SELECT * FROM Concesiones.pagoCanon WHERE idConcesion = (SELECT TOP 1 idConcesion FROM Concesiones.concesion WHERE fechaInicio = '2026-01-01' ORDER BY idConcesion DESC);
-- ESPERADO: 1 concesion creada y 6 pagos pendientes (uno por mes entre enero y junio)

-- ERROR: idEmpresa no existe -> "No existe una empresa con id: 999"
EXEC Concesiones.registrarConcesionConPagos 
    @idEmpresa = 999,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-01-01',
    @fechaFin = '2026-06-30',
    @montoCanonMensual = 100000;

-- ERROR: fechaFin <= fechaInicio -> "La fecha de fin debe ser posterior a la fecha de inicio."
EXEC Concesiones.registrarConcesionConPagos 
    @idEmpresa = 1,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-06-30',
    @fechaFin = '2026-01-01',
    @montoCanonMensual = 100000;

-- ERROR: monto <= 0 -> "El monto del canon mensual debe ser mayor a 0."
EXEC Concesiones.registrarConcesionConPagos 
    @idEmpresa = 1,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-01-01',
    @fechaFin = '2026-06-30',
    @montoCanonMensual = -500;

-- ERROR: multiples validaciones falladas juntas
EXEC Concesiones.registrarConcesionConPagos 
    @idEmpresa = 999,
    @idParque = 999,
    @idTipoConcesion = 999,
    @fechaInicio = '2026-06-30',
    @fechaFin = '2026-01-01',
    @montoCanonMensual = -500;
-- ESPERADO: error con 5 mensajes acumulados:
-- - No existe una empresa con id: 999.
-- - No existe un parque con id: 999.
-- - No existe un tipo de concesion con id: 999.
-- - La fecha de fin debe ser posterior a la fecha de inicio.
-- - El monto del canon mensual debe ser mayor a 0.


-- registrarPagoCanon

-- OK: registrar pago de un periodo pendiente
DECLARE @idConcesionTest INT;
SELECT TOP 1 @idConcesionTest = idConcesion FROM Concesiones.concesion WHERE fechaInicio = '2026-01-01' ORDER BY idConcesion DESC;

EXEC Concesiones.registrarPagoCanon 
    @idConcesion = @idConcesionTest,
    @periodo = '2026-01',
    @monto = 100000,
    @fecha = '2026-01-15';

SELECT * FROM Concesiones.pagoCanon WHERE idConcesion = @idConcesionTest AND periodo = '2026-01';
-- ESPERADO: el pago de 2026-01 ahora figura como Pagado

-- ERROR: idConcesion no existe -> "No existe una concesion con id: 999"
EXEC Concesiones.registrarPagoCanon 
    @idConcesion = 999,
    @periodo = '2026-01',
    @monto = 100000,
    @fecha = '2026-01-15';

-- ERROR: formato periodo invalido -> "El periodo debe tener el formato YYYY-MM."
EXEC Concesiones.registrarPagoCanon 
    @idConcesion = @idConcesionTest,
    @periodo = 'enero',
    @monto = 100000,
    @fecha = '2026-01-15';

-- ERROR: monto <= 0 -> "El monto del pago debe ser mayor a 0."
EXEC Concesiones.registrarPagoCanon 
    @idConcesion = @idConcesionTest,
    @periodo = '2026-02',
    @monto = -100,
    @fecha = '2026-02-15';

-- ERROR: pago ya esta pagado -> "El pago del periodo 2026-01 ya esta registrado como Pagado."
EXEC Concesiones.registrarPagoCanon 
    @idConcesion = @idConcesionTest,
    @periodo = '2026-01',
    @monto = 100000,
    @fecha = '2026-01-20';

-- ERROR: multiples validaciones falladas juntas
EXEC Concesiones.registrarPagoCanon 
    @idConcesion = 999,
    @periodo = 'enero',
    @monto = -100,
    @fecha = '2026-01-15';
-- ESPERADO: error con 3 mensajes acumulados:
-- - No existe una concesion con id: 999.
-- - El periodo debe tener el formato YYYY-MM.
-- - El monto del pago debe ser mayor a 0.


-- marcarPagosAtrasados

-- OK: marca como Atrasado los Pendientes de periodos pasados
-- Primero forzamos un pago "viejo" pendiente
INSERT INTO Concesiones.pagoCanon (idConcesion, fecha, monto, periodo, estado)
VALUES (@idConcesionTest, '2024-01-15', 100000, '2024-01', 'Pendiente');

EXEC Concesiones.marcarPagosAtrasados;
-- ESPERADO: devuelve cantidad de pagos actualizados a 'Atrasado'

SELECT * FROM Concesiones.pagoCanon WHERE periodo = '2024-01' AND idConcesion = @idConcesionTest;
-- ESPERADO: estado = Atrasado


-- cerrarConcesion

-- OK: cerrar concesion antes de tiempo y eliminar pagos pendientes futuros
EXEC Concesiones.cerrarConcesion 
    @idConcesion = @idConcesionTest,
    @fechaCierre = '2026-03-31';

SELECT * FROM Concesiones.concesion WHERE idConcesion = @idConcesionTest;
SELECT * FROM Concesiones.pagoCanon WHERE idConcesion = @idConcesionTest;
-- ESPERADO: la concesion tiene fechaFin = 2026-03-31 y solo quedan pagos hasta marzo

-- ERROR: id no existe -> "No existe una concesion con id: 999"
EXEC Concesiones.cerrarConcesion @idConcesion = 999;

-- ERROR: fechaCierre anterior a fechaInicio -> "La fecha de cierre no puede ser anterior a la fecha de inicio."
EXEC Concesiones.cerrarConcesion 
    @idConcesion = @idConcesionTest,
    @fechaCierre = '2020-01-01';

-- ERROR: fechaCierre posterior a fechaFin actual -> "La fecha de cierre no puede ser posterior a la fecha de fin actual."
EXEC Concesiones.cerrarConcesion 
    @idConcesion = @idConcesionTest,
    @fechaCierre = '2030-01-01';

-- ERROR: multiples validaciones falladas juntas
EXEC Concesiones.cerrarConcesion 
    @idConcesion = 999,
    @fechaCierre = '2020-01-01';
-- ESPERADO: error con 2 mensajes acumulados:
-- - No existe una concesion con id: 999.
-- - La fecha de cierre no puede ser anterior a la fecha de inicio.


-- consultarProximasAVencer

-- OK: con umbral por defecto (30 dias)
EXEC Concesiones.consultarProximasAVencer;
-- ESPERADO: lista de concesiones que vencen en los proximos 30 dias

-- OK: con umbral personalizado de 365 dias
EXEC Concesiones.consultarProximasAVencer @diasUmbral = 365;
-- ESPERADO: lista mucho mas amplia

-- ERROR: umbral <= 0 -> "El umbral en dias debe ser mayor a 0."
EXEC Concesiones.consultarProximasAVencer @diasUmbral = 0;


-- consultarAtrasadas

-- OK: lista las concesiones con pagos atrasados
EXEC Concesiones.consultarAtrasadas;
-- ESPERADO: lista con empresa, parque, meses atrasados y monto adeudado
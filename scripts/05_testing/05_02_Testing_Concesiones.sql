/* Script generado el 19/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Testing de los SP del esquema Concesiones.
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO


-- TipoConcesion_Alta

-- OK: alta valida
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Gastronomia';
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Kiosco';
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Excursion';

SELECT * FROM Concesiones.tipoConcesion;

-- ERROR: descripcion vacia -> "La descripcion del tipo de concesion es obligatoria."
EXEC Concesiones.tipoConcesion_Alta @descripcion = '   ';

-- ERROR: descripcion duplicada -> "Ya existe un tipo de concesion con la descripcion: Gastronomia"
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Gastronomia';


-- TipoConcesion_Modificar

-- OK: modificar descripcion
EXEC Concesiones.tipoConcesion_Modificar @idTipoConcesion = 1, @descripcion = 'Gastronomia y Restaurantes';

-- ERROR: id no existe -> "No existe un tipo de concesion con id: 999"
EXEC Concesiones.tipoConcesion_Modificar @idTipoConcesion = 999, @descripcion = 'X';

-- ERROR: descripcion vacia -> "La descripcion no puede estar vacia."
EXEC Concesiones.tipoConcesion_Modificar @idTipoConcesion = 1, @descripcion = '';

-- ERROR: descripcion duplicada con otro -> "Ya existe otro tipo de concesion con la descripcion: Kiosco"
EXEC Concesiones.tipoConcesion_Modificar @idTipoConcesion = 1, @descripcion = 'Kiosco';


-- TipoConcesion_Baja

-- OK: borrar tipo sin concesiones
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Temporal Borrar';
EXEC Concesiones.tipoConcesion_Baja @idTipoConcesion = (SELECT idTipoConcesion FROM Concesiones.tipoConcesion WHERE descripcion = 'Temporal Borrar');

-- ERROR: id no existe -> "No existe un tipo de concesion con id: 999"
EXEC Concesiones.tipoConcesion_Baja @idTipoConcesion = 999;

-- ERROR: tipo con concesiones asociadas, se prueba mas abajo, despues de Concesion_Alta


-- Empresa_Alta

-- OK: alta valida
EXEC Concesiones.empresa_Alta @nombre = 'Patagonia Tours S.A.';
EXEC Concesiones.empresa_Alta @nombre = 'Sabores del Parque SRL';

SELECT * FROM Concesiones.empresa;

-- ERROR: nombre vacio -> "El nombre de la empresa es obligatorio."
EXEC Concesiones.empresa_Alta @nombre = '';

-- ERROR: nombre duplicado -> "Ya existe una empresa con el nombre: Patagonia Tours S.A."
EXEC Concesiones.empresa_Alta @nombre = 'Patagonia Tours S.A.';


-- Empresa_Modificar

-- OK: modificar nombre
EXEC Concesiones.empresa_Modificar @idEmpresa = 1, @nombre = 'Patagonia Tours S.A. e Hijos';

-- ERROR: id no existe -> "No existe una empresa con id: 999"
EXEC Concesiones.empresa_Modificar @idEmpresa = 999, @nombre = 'Test';

-- ERROR: nombre vacio -> "El nombre no puede estar vacio."
EXEC Concesiones.empresa_Modificar @idEmpresa = 1, @nombre = '   ';

-- ERROR: nombre duplicado con otra -> "Ya existe otra empresa con el nombre: Sabores del Parque SRL"
EXEC Concesiones.empresa_Modificar @idEmpresa = 1, @nombre = 'Sabores del Parque SRL';


-- Empresa_Baja

-- OK: borrar empresa sin concesiones
EXEC Concesiones.empresa_Alta @nombre = 'Empresa Ficticia';
EXEC Concesiones.empresa_Baja @idEmpresa = (SELECT idEmpresa FROM Concesiones.empresa WHERE nombre = 'Empresa Ficticia');

-- ERROR: id no existe -> "No existe una empresa con id: 999"
EXEC Concesiones.empresa_Baja @idEmpresa = 999;

-- ERROR: empresa con concesiones asociadas, se prueba mas abajo, despues de Concesion_Alta


-- Concesion_Alta

-- OK: alta valida (Se asume idParque = 1 creado previamente en Testing_Gestion.sql)
EXEC Concesiones.concesion_Alta 
    @idEmpresa = 1,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-01-01',
    @fechaFin = '2026-12-31',
    @montoCanonMensual = 150000.00;

EXEC Concesiones.concesion_Alta 
    @idEmpresa = 2,
    @idParque = 1,
    @idTipoConcesion = 2,
    @fechaInicio = '2026-03-01',
    @fechaFin = '2027-03-01',
    @montoCanonMensual = 85000.00;

SELECT * FROM Concesiones.concesion;

-- ERROR: idEmpresa no existe -> "No existe una empresa con id: 999"
EXEC Concesiones.concesion_Alta 
    @idEmpresa = 999,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-01-01',
    @fechaFin = '2026-12-31',
    @montoCanonMensual = 150000.00;

-- ERROR: idParque no existe -> "No existe un parque con id: 999"
EXEC Concesiones.concesion_Alta 
    @idEmpresa = 1,
    @idParque = 999,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-01-01',
    @fechaFin = '2026-12-31',
    @montoCanonMensual = 150000.00;

-- ERROR: idTipoConcesion no existe -> "No existe un tipo de concesion con id: 999"
EXEC Concesiones.concesion_Alta 
    @idEmpresa = 1,
    @idParque = 1,
    @idTipoConcesion = 999,
    @fechaInicio = '2026-01-01',
    @fechaFin = '2026-12-31',
    @montoCanonMensual = 150000.00;

-- ERROR: fechas NULL -> "Las fechas de inicio y fin son obligatorias."
EXEC Concesiones.concesion_Alta 
    @idEmpresa = 1,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = NULL,
    @fechaFin = '2026-12-31',
    @montoCanonMensual = 150000.00;

-- ERROR: fechaFin <= fechaInicio -> "La fecha de fin debe ser posterior a la fecha de inicio."
EXEC Concesiones.concesion_Alta 
    @idEmpresa = 1,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-05-01',
    @fechaFin = '2026-01-01',
    @montoCanonMensual = 150000.00;

-- ERROR: monto <= 0 -> "El monto del canon mensual debe ser mayor a 0."
EXEC Concesiones.concesion_Alta 
    @idEmpresa = 1,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-01-01',
    @fechaFin = '2026-12-31',
    @montoCanonMensual = -500.00;


-- ERROR pendiente de TipoConcesion_Baja: tipo con concesiones asociadas
EXEC Concesiones.tipoConcesion_Baja @idTipoConcesion = 1;
-- ESPERADO: "No se puede eliminar: existen concesiones asociadas a este tipo."


-- ERROR pendiente de Empresa_Baja: empresa con concesiones asociadas
EXEC Concesiones.empresa_Baja @idEmpresa = 1;
-- ESPERADO: "No se puede eliminar: la empresa tiene concesiones asociadas."


-- Concesion_Modificar

-- OK: modificar monto
EXEC Concesiones.concesion_Modificar @idConcesion = 1, @montoCanonMensual = 165000.00;

-- OK: modificar fechas validas
EXEC Concesiones.concesion_Modificar @idConcesion = 2, @fechaInicio = '2026-04-01', @fechaFin = '2027-04-01';

SELECT * FROM Concesiones.concesion;

-- ERROR: id no existe -> "No existe una concesion con id: 999"
EXEC Concesiones.concesion_Modificar @idConcesion = 999, @montoCanonMensual = 1000.00;

-- ERROR: idEmpresa no existe -> "No existe una empresa con id: 999"
EXEC Concesiones.concesion_Modificar @idConcesion = 1, @idEmpresa = 999;

-- ERROR: idParque no existe -> "No existe un parque con id: 999"
EXEC Concesiones.concesion_Modificar @idConcesion = 1, @idParque = 999;

-- ERROR: idTipoConcesion no existe -> "No existe un tipo de concesion con id: 999"
EXEC Concesiones.concesion_Modificar @idConcesion = 1, @idTipoConcesion = 999;

-- ERROR: fechaFin <= fechaInicio -> "La fecha de fin debe ser posterior a la fecha de inicio."
EXEC Concesiones.concesion_Modificar @idConcesion = 1, @fechaInicio = '2026-12-31', @fechaFin = '2026-01-01';

-- ERROR: monto <= 0 -> "El monto del canon mensual debe ser mayor a 0."
EXEC Concesiones.concesion_Modificar @idConcesion = 1, @montoCanonMensual = -10.00;


-- Concesion_Baja

-- OK: borrar concesion sin pagos
EXEC Concesiones.concesion_Alta 
    @idEmpresa = 1,
    @idParque = 1,
    @idTipoConcesion = 1,
    @fechaInicio = '2026-06-01',
    @fechaFin = '2026-08-01',
    @montoCanonMensual = 50000.00;

EXEC Concesiones.concesion_Baja @idConcesion = 3;

-- ERROR: id no existe -> "No existe una concesion con id: 999"
EXEC Concesiones.concesion_Baja @idConcesion = 999;

-- ERROR: concesion con pagos asociados, se prueba mas abajo, despues de PagoCanon_Alta


-- PagoCanon_Alta

-- OK: pago valido
EXEC Concesiones.pagoCanon_Alta 
    @idConcesion = 1,
    @fecha = '2026-01-10',
    @monto = 165000.00,
    @periodo = '2026-01',
    @estado = 'Pagado';

EXEC Concesiones.pagoCanon_Alta 
    @idConcesion = 1,
    @fecha = '2026-02-12',
    @monto = 165000.00,
    @periodo = '2026-02',
    @estado = 'Pendiente';

SELECT * FROM Concesiones.pagoCanon;

-- ERROR: idConcesion no existe -> "No existe una concesion con id: 999"
EXEC Concesiones.pagoCanon_Alta 
    @idConcesion = 999,
    @fecha = '2026-01-10',
    @monto = 165000.00,
    @periodo = '2026-01',
    @estado = 'Pagado';

-- ERROR: fecha NULL -> "La fecha del pago es obligatoria."
EXEC Concesiones.pagoCanon_Alta 
    @idConcesion = 1,
    @fecha = NULL,
    @monto = 165000.00,
    @periodo = '2026-03',
    @estado = 'Pagado';

-- ERROR: monto <= 0 -> "El monto del pago debe ser mayor a 0."
EXEC Concesiones.pagoCanon_Alta 
    @idConcesion = 1,
    @fecha = '2026-01-10',
    @monto = 0.00,
    @periodo = '2026-03',
    @estado = 'Pagado';

-- ERROR: formato periodo invalido -> "El periodo debe tener el formato YYYY-MM."
EXEC Concesiones.pagoCanon_Alta 
    @idConcesion = 1,
    @fecha = '2026-01-10',
    @monto = 165000.00,
    @periodo = '26-01',
    @estado = 'Pagado';

-- ERROR: estado invalido -> "El estado debe ser Pagado, Pendiente o Atrasado."
EXEC Concesiones.pagoCanon_Alta 
    @idConcesion = 1,
    @fecha = '2026-01-10',
    @monto = 165000.00,
    @periodo = '2026-03',
    @estado = 'Invalido';

-- ERROR: periodo duplicado en misma concesion -> "Ya existe un pago para el periodo 2026-01 en esta concesion."
EXEC Concesiones.pagoCanon_Alta 
    @idConcesion = 1,
    @fecha = '2026-01-20',
    @monto = 165000.00,
    @periodo = '2026-01',
    @estado = 'Pagado';


-- ERROR pendiente de Concesion_Baja: concesion con pagos asociados
EXEC Concesiones.concesion_Baja @idConcesion = 1;
-- ESPERADO: "No se puede eliminar: la concesion tiene pagos de canon asociados."


-- PagoCanon_Modificar

-- OK: modificar estado
EXEC Concesiones.pagoCanon_Modificar @idPagoCanon = 2, @estado = 'Pagado';

SELECT * FROM Concesiones.pagoCanon;

-- ERROR: id no existe -> "No existe un pago de canon con id: 999"
EXEC Concesiones.pagoCanon_Modificar @idPagoCanon = 999, @estado = 'Pagado';

-- ERROR: monto <= 0 -> "El monto del pago debe ser mayor a 0."
EXEC Concesiones.pagoCanon_Modificar @idPagoCanon = 1, @monto = -50.00;

-- ERROR: estado invalido -> "El estado debe ser Pagado, Pendiente o Atrasado."
EXEC Concesiones.pagoCanon_Modificar @idPagoCanon = 1, @estado = 'Cancelado';


-- PagoCanon_Baja

-- OK: borrar pago existente
EXEC Concesiones.pagoCanon_Baja @idPagoCanon = 2;

SELECT * FROM Concesiones.pagoCanon;

-- ERROR: id no existe -> "No existe un pago de canon con id: 999"
EXEC Concesiones.pagoCanon_Baja @idPagoCanon = 999;



-- ERROR: multiples validaciones falladas juntas
EXEC Concesiones.concesion_Alta 
    @idEmpresa = 999,
    @idParque = 999,
    @idTipoConcesion = 999,
    @fechaInicio = '2026-01-01',
    @fechaFin = '2025-01-01',
    @montoCanonMensual = -500;
-- ESPERADO: error con 5 mensajes acumulados:
-- - No existe una empresa con id: 999.
-- - No existe un parque con id: 999.
-- - No existe un tipo de concesion con id: 999.
-- - La fecha de fin debe ser posterior a la fecha de inicio.
-- - El monto del canon mensual debe ser mayor a 0.
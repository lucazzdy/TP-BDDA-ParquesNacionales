/* 
    Script generado el 

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Testing de los SP del esquema Ventas.
*/
USE GestionParquesNacionales_Com5600_Grupo07;
GO

--  ================================    Pruebas para Ventas.tipoVisitante   ================================
--1. Alta

-- TODO OK
EXEC Ventas.tipoVisitanteAlta @descripcion = 'Estudiante';

SELECT * FROM Ventas.tipoVisitante;
GO

-- ERROR DUPLICADO
EXEC Ventas.tipoVisitanteAlta @descripcion = 'Estudiante';

--2. Modificar

-- TODO OK:
DECLARE @idValido INT;
SELECT TOP 1 @idValido = idTipoVisitante FROM Ventas.tipoVisitante WHERE descripcion = 'Estudiante';

EXEC Ventas.tipoVisitanteModificar @idTipoVisitante = @idValido, @nuevadescripcion = 'Estudiante Uni';

SELECT * FROM Ventas.tipoVisitante;
GO

-- ERROR ID tipo de visitante

EXEC Ventas.tipoVisitanteModificar @idTipoVisitante = -1, @nuevadescripcion = 'errror';

--3. Baja

-- Baja exitosa
DECLARE @idABorrar INT;
SELECT TOP 1 @idABorrar = idTipoVisitante FROM Ventas.tipoVisitante WHERE descripcion = 'Estudiante Uni';

EXEC Ventas.tipoVisitanteBaja @idTipoVisitante = @idABorrar;

SELECT * FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idABorrar;
GO

-- Baja fallida. Devuelve 'El tipo de visitante con id = 99999 especificado no existe.'

EXEC Ventas.tipoVisitanteBaja @idTipoVisitante = 99999;


--  ================================    Pruebas para Ventas.visitante   ================================
--1. Alta

-- Alta Exitosa. Requisito: debe haber al menos un registro en TipoVisitante.
EXEC Ventas.tipoVisitanteAlta @descripcion = 'General';

DECLARE @idTipo INT;
SELECT TOP 1 @idTipo = idTipoVisitante FROM Ventas.tipoVisitante WHERE descripcion = 'General';
PRINT '--- Test visitanteAlta: Caso Exitoso ---';
EXEC Ventas.visitanteAlta 
    @idTipoVisitante = @idTipo, 
    @nombre = 'Mijael', 
    @apellido = 'Zambrana', 
    @fechaNacimiento = '2000-05-20', 
    @tipoDocumento = 'DNI', 
    @numeroDocumento = 45123456;

SELECT * FROM Ventas.visitante WHERE numeroDocumento = 45123456;
GO

--Alta Fallida. Resultado: error en DNI, Nombre, fechaNacimiento y numero de documento

EXEC Ventas.visitanteAlta 
        @idTipoVisitante = 999,      -- ID Inexistente
        @nombre = '',                -- Vacío
        @apellido = 'Gomez', 
        @fechaNacimiento = '2030-01-01', -- Fecha futura
        @tipoDocumento = 'DNI', 
        @numeroDocumento = -100;     -- Negativo

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.
DECLARE @idValido INT;
SELECT TOP 1 @idValido = idVisitante FROM Ventas.visitante WHERE numeroDocumento = 45123456;

EXEC Ventas.visitanteModificar 
    @idVisitante = @idValido, 
    @idTipoVisitante = NULL, 
    @nombre = 'Javier', -- Cambio de nombre
    @apellido = 'Zambrano', -- Cambio de apellido
    @fechaNacimiento = '2004-05-20', -- Cambio de fechaNac
    @tipoDocumento = NULL,
    @numeroDocumento = NULL

SELECT * FROM Ventas.visitante WHERE numeroDocumento = 45123456;
GO

-- Modificacion fallida. Resultado: Errores en idVisitante, idTipoVisitante y numero de documento

EXEC Ventas.visitanteModificar 
        @idVisitante = -99, 
        @idTipoVisitante = -2, 
        @nombre = 'Test', 
        @apellido = NULL,
        @fechaNacimiento = '1995-01-01', 
        @tipoDocumento = 'DNI', 
        @numeroDocumento = 0;

--3. Baja 
-- Baja Exitosa.

DECLARE @idABorrar INT;
SELECT TOP 1 @idABorrar = idVisitante FROM Ventas.visitante WHERE numeroDocumento = 45123456;

EXEC Ventas.visitanteBaja @idVisitante = @idABorrar;

SELECT * FROM Ventas.visitante WHERE idVisitante = @idABorrar;
GO

-- Baja fallida. Resultado: No existe un visitante con id = 99999

EXEC Ventas.visitanteBaja @idVisitante = 99999;


--  ================================    Pruebas para Ventas.formaPago   ================================

--1. Alta

-- Alta Exitosa. 

EXEC Ventas.formaPagoAlta @descripcion = 'Tarjeta de Debito';

SELECT * FROM Ventas.formaPago WHERE descripcion = 'Tarjeta de Debito';
GO

-- Alta Fallida. Resultado: La descripción de la forma de pago no puede estar vacía.

EXEC Ventas.formaPagoAlta @descripcion = '';

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.

DECLARE @idValido INT;
SELECT TOP 1 @idValido = idFormaPago FROM Ventas.formaPago WHERE descripcion = 'Tarjeta de Debito';

EXEC Ventas.formaPagoModificar @idFormaPago = @idValido, @descripcion = 'Pago Facil';

SELECT * FROM Ventas.formaPago;
GO

-- Modificacion fallida. Resultado: La nueva descripción no puede estar vacía

DECLARE @idValidoError INT;
SELECT TOP 1 @idValidoError = idFormaPago FROM Ventas.formaPago WHERE descripcion = 'Pago Facil';
EXEC Ventas.formaPagoModificar @idFormaPago = @idValidoError, @descripcion = '   ';

--3. Baja 

-- Baja Exitosa.

DECLARE @idABorrar INT;
SELECT TOP 1 @idABorrar = idFormaPago FROM Ventas.formaPago WHERE descripcion = 'Pago Facil';

EXEC Ventas.formaPagoBaja @idFormaPago = @idABorrar;

-- Verificación final de inexistencia
SELECT * FROM Ventas.formaPago
GO

-- Baja fallida. Resultado: El ID de la forma de pago especificada no existe


EXEC Ventas.formaPagoBaja @idFormaPago = -50;

--  ================================    Pruebas para Ventas.preciosParque   ================================

--1. Alta

-- Alta Exitosa. Requisitos: debe existir al menos un parque
EXEC Gestion.tipoParqueAlta @nombre = 'Parque Nacional';

EXEC Gestion.parqueAlta 
    @nombre = 'Iguazu',
    @superficie = 67000,
    @idTipoParque = 1,
    @provincia = 'Misiones';


DECLARE @idTipoVis INT 
SELECT TOP 1 @idTipoVis = idTipoVisitante FROM Ventas.tipoVisitante WHERE descripcion = 'General'
EXEC Ventas.preciosParqueAlta 
    @idParque = 1, 
    @idTipoVisitante = @idTipoVis,
    @fechaDesde = '2026-01-01', 
    @precio = 3500.00;

SELECT * FROM Ventas.preciosParque

-- Alta Fallida. Resultado: El ID de Parque especificado no existe. El ID de Tipo de Visitante no existe. El precio debe ser un valor mayor o igual a cero.

EXEC Ventas.preciosParqueAlta 
        @idParque = 9999,            -- ID Inexistente
        @idTipoVisitante = 1, 
        @fechaDesde = '2026-12-31', 
        @precio = -120.50;

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.

DECLARE @idTipoVis2 INT 
SELECT TOP 1 @idTipoVis2 = idTipoVisitante FROM Ventas.tipoVisitante WHERE descripcion = 'General'

EXEC Ventas.preciosParqueModificar 
    @idParque = 1, 
    @idTipoVisitante = @idTipoVis2, 
    @fechaDesde = '2026-01-01', 
    @nuevoPrecio = 4200.00;

SELECT * FROM Ventas.preciosParque

-- Modificacion fallida. Resultado:  No existe una tarifa registrada que coincida con el Parque, Tipo de Visitante y Fecha especificados

EXEC Ventas.preciosParqueModificar 
    @idParque = 1, 
    @idTipoVisitante = 1, 
    @fechaDesde = '1990-05-10', -- Fecha sin registros
    @nuevoPrecio = 1000.00;

--3. Baja 

-- Baja Exitosa. Elimina la tarifa

DECLARE @idTipoVis3 INT 
SELECT TOP 1 @idTipoVis3 = idTipoVisitante FROM Ventas.tipoVisitante WHERE descripcion = 'General'
EXEC Ventas.preciosParqueBaja 
    @idParque = 1, 
    @idTipoVisitante = @idTipoVis3, 
    @fechaDesde = '2026-01-01';

SELECT * FROM Ventas.preciosParque

-- Baja fallida. Resultado: No se encontró la tarifa histórica que intenta eliminar.

EXEC Ventas.preciosParqueBaja 
    @idParque = 1, 
    @idTipoVisitante = 99, 
    @fechaDesde = '2026-01-01';

--  ================================    Pruebas para Ventas.ventas   ================================

--1. Alta

-- Alta Exitosa. Requisitos: Debe existir al menos un parque

EXEC Gestion.tipoParqueAlta @nombre = 'Parque Nacional';

EXEC Gestion.ParqueAlta 
    @nombre = 'Iguazu',
    @superficie = 67000,
    @idTipoParque = 1,
    @provincia = 'Misiones';

EXEC Ventas.ventaAlta 
    @idParque = 1, 
    @numeroFactura = 1001, 
    @puntoVenta = 1, 
    @total = 7500.00;

SELECT * FROM Ventas.venta

-- Alta Fallida.  Resultados: El punto de venta debe ser mayor a cero. El total de la venta no puede ser un valor negativo.

EXEC Ventas.ventaAlta 
    @idParque = 1, 
    @numeroFactura = 1002, 
    @puntoVenta = -5,       
    @total = -250.00;       

--2. Modificar

-- Modificacion exitosa. Resultado, se cambia el total de la venta

DECLARE @idValido INT;
SELECT TOP 1 @idValido = idVenta FROM Ventas.venta WHERE puntoVenta = 1 AND numeroFactura = 1001;

EXEC Ventas.ventaModificar 
    @idVenta = @idValido, 
    @idParque = 1, 
    @numeroFactura = NULL, 
    @puntoVenta = 1, 
    @total = 8900.00; -- cambio el total

SELECT * FROM Ventas.venta;

-- Modificacion fallida. Resultado: La combinación de Punto de Venta y Factura ya está asignada a otro ticket.

-- Creo otra venta
EXEC Ventas.ventaAlta @idParque = 1, @numeroFactura = 2222, @puntoVenta = 2, @total = 50.00;
GO


DECLARE @idValidoChoque INT;
SELECT TOP 1 @idValidoChoque = idVenta FROM Ventas.venta WHERE puntoVenta = 2 AND numeroFactura = 2222;
EXEC Ventas.ventaModificar 
    @idVenta = @idValidoChoque, 
    @idParque = 1, 
    @numeroFactura = 1001, -- uso el nro de factura de la primera venta
    @puntoVenta = 1,       -- uso el punto de venta de la primera venta
    @total = 1000.00;

--3. Baja 

-- Baja Exitosa.

DECLARE @idABorrar INT;
SELECT TOP 1 @idABorrar = idVenta FROM Ventas.venta WHERE puntoVenta = 1 AND numeroFactura = 1001;

EXEC Ventas.ventaBaja @idVenta = @idABorrar;

-- Baja fallida. Resultado: El ID de Venta especificado no existe. 

EXEC Ventas.ventaBaja @idVenta = -999;

--  ================================    Pruebas para Ventas.itemVenta   ================================

--1. Alta

-- Alta Exitosa. Requisitos: Debe tener al menos una venta y una forma de pago

EXEC Ventas.itemVentaAlta 
    @idVenta = 2, -- es el id de la venta extra que creamos para que se choquen las restricciones
    @nroItem = 1, 
    @tipoItem = 'Entrada', 
    @cantidad = 2, 
    @precioUnitario = 1500.00;

SELECT * FROM Ventas.itemVenta

-- Alta Fallida. Resultado: El tipo de ítem no es válido. Debe ser 'Entrada' o 'Actividad'. La cantidad debe ser un valor mayor a cero.

EXEC Ventas.itemVentaAlta 
    @idVenta = 2, 
    @nroItem = 2, 
    @tipoItem = 'Souvenir', 
    @cantidad = -1,         
    @precioUnitario = 450.00;

--2. Modificar

-- Modificacion exitosa. Resultado, se cambia la cantidad a 3 y el tipoItem por Actividad

EXEC Ventas.itemVentaModificar 
    @idVenta = 2, 
    @nroItem = 1, 
    @tipoItem = 'Actividad', 
    @cantidad = 3, 
    @precioUnitario = 1500.00;

-- Modificacion fallida. Resultado: No existe el item de venta que intenta modificar para la venta ingresada.

EXEC Ventas.itemVentaModificar 
    @idVenta = 1, 
    @nroItem = 99,
    @tipoItem = 'Actividad', 
    @cantidad = 1, 
    @precioUnitario = 2000.00;

--3. Baja 

-- Baja Exitosa.

EXEC Ventas.itemVentaBaja @idVenta = 2, @nroItem = 1;

SELECT * FROM Ventas.itemVenta

-- Baja fallida. Resultado: No se encontró el item de venta que intenta eliminar para esa venta.

EXEC Ventas.itemVentaBaja @idVenta = 1, @nroItem = 88;


--  ================================    Pruebas para Ventas.pago   ================================

--preparacion
EXEC Ventas.formaPagoAlta @descripcion = 'Tarjeta de Debito';
SELECT * FROM Ventas.venta
SELECT * FROM Ventas.formaPago

--1. Alta

-- Alta Exitosa. Requisitos: Debe haber al menos una venta y una forma de pago

EXEC Ventas.pagoAlta 
    @idVenta = 2, 
    @idFormaPago = 2, 
    @fecha = NULL, -- Pruebo que el DEFAULT tome el GETDATE()
    @estado = 'Aprobado', 
    @importe = 5000.00;


-- Alta Fallida. Resultados: La forma de pago no existe. El importe debe ser mayor a cero.

EXEC Ventas.pagoAlta 
    @idVenta = 2, 
    @idFormaPago = 9999, -- ID que no existe
    @fecha = NULL, 
    @estado = 'Pendiente', 
    @importe = -250.00;   -- Importe negativo/inválido

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.

DECLARE @idVenta INT;
DECLARE @idFormaPago INT;
SELECT TOP 1 @idVenta = idVenta FROM Ventas.venta WHERE idParque = 1
SELECT TOP 1 @idFormaPago = idFormaPago FROM Ventas.formaPago WHERE descripcion = 'Tarjeta de Debito'
EXEC Ventas.pagoModificar 
    @idPago = 1, 
    @idVenta = @idVenta, 
    @idFormaPago = @idFormaPago, 
    @fecha = NULL, 
    @estado = 'Rechazado', -- Modificación de estado
    @importe = 4000.00;

SELECT * FROM Ventas.pago

-- Modificacion fallida. Resultado: El ID de pago no existe. El importe debe ser mayor a cero. La fecha del pago no puede ser despues de la fecha actual.

DECLARE @idVenta2 INT;
DECLARE @idFormaPago2 INT;
SELECT TOP 1 @idVenta2 = idVenta FROM Ventas.venta WHERE idParque = 1
SELECT TOP 1 @idFormaPago2 = idFormaPago FROM Ventas.formaPago WHERE descripcion = 'Tarjeta de Debito'
EXEC Ventas.pagoModificar 
    @idPago = -999,              
    @idVenta = @idVenta, 
    @idFormaPago = @idFormaPago, 
    @fecha = '2035-01-01',       
    @estado = 'Aprobado', 
    @importe = -150.00;

--3. Baja 

-- Baja Exitosa.

EXEC Ventas.pagoBaja @idPago = 1;

-- Baja fallida. Resultado: El ID de pago ingresado no existe

EXEC Ventas.pagoBaja @idPago = 8888;


--  ================================    Pruebas para Ventas.entrada   ================================

-- preparacion
EXEC Ventas.ventaAlta 
    @idParque = 1, 
    @numeroFactura = 1001, 
    @puntoVenta = 1, 
    @total = 7500.00;

SELECT * FROM Ventas.venta

EXEC Ventas.formaPagoAlta @descripcion = 'Tarjeta de Debito';

SELECT * FROM Ventas.visitante

DECLARE @idTipo INT;
SELECT TOP 1 @idTipo = idTipoVisitante FROM Ventas.tipoVisitante WHERE descripcion = 'Estudiante'
EXEC Ventas.visitanteAlta 
    @idTipoVisitante = @idTipo, 
    @nombre = 'Mijael', 
    @apellido = 'Zambrana', 
    @fechaNacimiento = '2000-05-20', 
    @tipoDocumento = 'DNI', 
    @numeroDocumento = 45123456;


--1. Alta

-- Alta Exitosa. Requisitos: debe tener una venta y una forma de pago activa

DECLARE @idVisitante INT;
DECLARE @idTipo3 INT;
SELECT TOP 1 @idVisitante = idVisitante, @idTipo3 = idTipoVisitante FROM Ventas.visitante WHERE tipoDocumento = 'DNI' AND numeroDocumento = 45123456
EXEC Ventas.entradaAlta 
    @codigoEntrada = 'A-111222-Z', 
    @fechaAcceso = '2026-11-20', 
    @fechaCompra = NULL, 
    @idVisitante = @idVisitante, 
    @idParque = 1, 
    @idTipoVisitante = @idTipo3, 
    @precio = 2500.00;

SELECT * FROM Ventas.entrada

-- Alta Fallida. Resultado: - Formato de código de entrada inválido. El visitante no existe. El tipo de visitante no existe. El precio no puede ser negativo.

EXEC Ventas.entradaAlta 
    @codigoEntrada = 'ABC-123',   
    @fechaAcceso = '2026-11-20', 
    @fechaCompra = NULL, 
    @idVisitante = 1, 
    @idParque = 1, 
    @idTipoVisitante = 1, 
    @precio = -500.00;

--2. Modificar

-- Modificacion exitosa. Resultado: se modifica el precio


DECLARE @idVisitante4 INT;
DECLARE @idTipo4 INT;
SELECT TOP 1 @idVisitante = idVisitante, @idTipo = idTipoVisitante FROM Ventas.visitante WHERE tipoDocumento = 'DNI' AND numeroDocumento = 45123456
EXEC Ventas.entradaModificar 
    @codigoEntrada = 'A-111222-Z', 
    @fechaAcceso = '2026-11-20', 
    @fechaCompra = NULL, 
    @idVisitante = @idVisitante4, 
    @idParque = 1, 
    @idTipoVisitante = @idTipo4, 
    @precio = 3100.00; 

-- Modificacion fallida. Resultado: La fecha de acceso no puede ser anterior a la fecha actual. La fecha de compra no puede ser despues de la fecha actual.

DECLARE @idVisitante5 INT;
DECLARE @idTipo5 INT;
SELECT TOP 1 @idVisitante5 = idVisitante, @idTipo5 = idTipoVisitante FROM Ventas.visitante WHERE tipoDocumento = 'DNI' AND numeroDocumento = 45123456
EXEC Ventas.entradaModificar 
    @codigoEntrada = 'A-111222-Z', 
    @fechaAcceso = '2020-01-01',  
    @fechaCompra = '2030-05-20',  
    @idVisitante = @idVisitante5, 
    @idParque = 1, 
    @idTipoVisitante = @idTipo5, 
    @precio = 3100.00;

--3. Baja 

-- Baja Exitosa.

EXEC Ventas.entradaBaja @codigoEntrada = 'A-111222-Z';

-- Baja fallida. Resultado: El código de entrada especificado no existe.

EXEC Ventas.entradaBaja @codigoEntrada = 'Z-000000-Z';

--  ================================    Pruebas para Ventas.entradaActividad   ================================

--preparacion

DECLARE @idVisitante6 INT;
DECLARE @idTipo6 INT;
SELECT TOP 1 @idVisitante6 = idVisitante, @idTipo6 = idTipoVisitante FROM Ventas.visitante WHERE tipoDocumento = 'DNI' AND numeroDocumento = 45123456
EXEC Ventas.entradaAlta 
    @codigoEntrada = 'A-111222-Z', 
    @fechaAcceso = '2026-11-20', 
    @fechaCompra = NULL, 
    @idVisitante = @idVisitante6, 
    @idParque = 1, 
    @idTipoVisitante = @idTipo6, 
    @precio = 2500.00;

EXEC Actividades.TipoActividadAlta @descripcion = 'Tour'

EXEC Actividades.GuiaAlta
    @codEspecialidad = 1

SELECT * FROM Actividades.actividad

EXEC Actividades.actividadAlta
    @nombre = 'Paseo en Gomón Gran Aventura',
    @costo = 0.0,
    @duracion = 2.4,
    @idTipoActividad = 1

EXEC Actividades.actividadAlta
    @nombre = 'Paseo en Un Parque Gran Aventura',
    @costo = 2.0,
    @duracion = 2.4,
    @idTipoActividad = 1

--1. Alta

-- Alta Exitosa. Requisitos debe existir una actividad y una entrada

EXEC Ventas.entradaActividadAlta 
    @codigoEntrada = 'A-111222-Z', 
    @idActividad = 1;

SELECT * FROM Ventas.entradaActividad

-- Alta Fallida. Resultado: La entrada especificada no existe. La actividad especificada no existe.

EXEC Ventas.entradaActividadAlta 
        @codigoEntrada = 'X-000000-X', -- Código de entrada inexistente
        @idActividad = 999;

-- Alta fallida por cupo lleno. Resultado: El tour esta lleno. No hay cupo disponible.

DECLARE @idActDemo INT, @codEntradaLibre CHAR(10);

SELECT @idActDemo = idActividad 
FROM Actividades.actividad 
WHERE nombre = 'Tour Demo Cupo Completo';

SELECT TOP 1 @codEntradaLibre = codigoEntrada
FROM Ventas.entrada e
WHERE NOT EXISTS (
    SELECT 1 FROM Ventas.entradaActividad ea
    WHERE ea.codigoEntrada = e.codigoEntrada AND ea.idActividad = @idActDemo
);

EXEC Ventas.entradaActividadAlta 
    @codigoEntrada = @codEntradaLibre,
    @idActividad = @idActDemo;
GO

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.

EXEC Ventas.entradaActividadModificar 
    @codigoEntrada = 'A-111222-Z', 
    @idActividadActual = 1, 
    @idActividadNueva = 2;

SELECT * FROM Ventas.entradaActividad

-- Modificacion fallida. Resultado: - No existe la relación original especificada. La nueva actividad a asignar no existe.

EXEC Ventas.entradaActividadModificar 
    @codigoEntrada = 'A-999888-Z', 
    @idActividadActual = 10, 
    @idActividadNueva = 20;

--3. Baja 

-- Baja Exitosa.

EXEC Ventas.entradaActividadBaja 
    @codigoEntrada = 'A-111222-Z', 
    @idActividad = 2;


-- Baja fallida. Resultado: No existe la relación ingresada. 

EXEC Ventas.entradaActividadBaja 
        @codigoEntrada = 'A-999888-Z', 
        @idActividad = 555;


--  ================================    Pruebas para Ventas.entradaActividad   ================================

-- preparacion

IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = 1)
BEGIN
    SET IDENTITYINSERT Gestion.Parque ON;
    INSERT INTO Gestion.Parque (idParque, Nombre) VALUES (1, 'Parque Nacional Iguazú');
    SET IDENTITYINSERT Gestion.Parque OFF;
END

IF NOT EXISTS (SELECT 1 FROM Ventas.formaPago WHERE idFormaPago = 1)
BEGIN
    SET IDENTITYINSERT Ventas.formaPago ON;
    INSERT INTO Ventas.formaPago (idFormaPago, descripcion) VALUES (1, 'Tarjeta de Crédito');
    SET IDENTITYINSERT Ventas.formaPago OFF;
END

IF NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante WHERE idTipoVisitante = 1)
BEGIN
    SET IDENTITYINSERT Ventas.tipoVisitante ON;
    INSERT INTO Ventas.tipoVisitante (idTipoVisitante, descripcion) VALUES (1, 'Nacional');
    SET IDENTITYINSERT Ventas.tipoVisitante OFF;
END

IF NOT EXISTS (SELECT 1 FROM Ventas.visitante WHERE idVisitante = 1)
BEGIN
    SET IDENTITYINSERT Ventas.visitante ON;
    INSERT INTO Ventas.visitante (idVisitante, idTipoVisitante, Nombre, Apellido, FechaNacimiento, tipoDocumento, numeroDocumento)
    VALUES (1, 1, 'Mijael', 'Zambrana', '2000-01-01', 'DNI', 45000000);
    SET IDENTITYINSERT Ventas.visitante OFF;
END

IF NOT EXISTS (SELECT 1 FROM Ventas.visitante WHERE idVisitante = 2)
BEGIN
    SET IDENTITYINSERT Ventas.visitante ON;
    INSERT INTO Ventas.visitante (idVisitante, idTipoVisitante, Nombre, Apellido, FechaNacimiento, tipoDocumento, numeroDocumento)
    VALUES (2, 1, 'Lucas', 'Gomez', '1995-05-10', 'DNI', 38000000);
    SET IDENTITYINSERT Ventas.visitante OFF;
END

IF NOT EXISTS (SELECT 1 FROM Ventas.preciosParque WHERE idParque = 1 AND idTipoVisitante = 1 AND FechaDesde = '2026-01-01')
BEGIN
    INSERT INTO Ventas.preciosParque (idParque, idTipoVisitante, FechaDesde, Precio)
    VALUES (1, 1, '2026-01-01', 4000.00);
END

IF NOT EXISTS (SELECT 1 FROM Actividades.actividad WHERE idActividad = 10)
BEGIN
    SET IDENTITYINSERT Actividades.actividad ON;
    INSERT INTO Actividades.actividad (idActividad, Nombre, costo) VALUES (10, 'Bautismo de Buceo', 2500.00);
    INSERT INTO Actividades.actividad (idActividad, Nombre, costo) VALUES (20, 'Paseo en Gomón', 3500.00);
    SET IDENTITYINSERT Actividades.actividad OFF;
END
GO

--1.Venta individual exitosa.

EXEC Ventas.procesarVentaIndividual
    @codigoEntrada = 'A-123456-Z',
    @idVisitante = 1,
    @fechaAcceso = '2026-10-15',
    @idParque = 1,
    @idFormaPago = 1,
    @puntoVenta = 1,
    @numeroFactura = 100001,
    @jsonActividades = N'[{"idActividad": 10}]';

-- Comprobación física
SELECT * FROM Ventas.venta WHERE numeroFactura = 100001; -- Total debe ser 6500.00
SELECT * FROM Ventas.itemVenta WHERE idVenta = (SELECT idVenta FROM Ventas.venta WHERE numeroFactura = 100001);
SELECT * FROM Ventas.entrada WHERE CodigoEntrada = 'A-123456-Z';
GO

--2. Venta individual fallida: Resultado Malo (Fallo por Actividades Repetidas o Inexistentes)
-- Resultado esperado: Resultado: Lanza la excepción personalizada 60001 indicando que hay actividades repetidas y frena la transacción sin guardar datos.

EXEC Ventas.procesarVentaIndividual
    @codigoEntrada = 'A-123456-Z',   -- Usamos el mismo código adrede para forzar colisiones
    @idVisitante = 1,
    @fechaAcceso = '2026-10-15',
    @idParque = 1,
    @idFormaPago = 1,
    @puntoVenta = 1,
    @numeroFactura = 100001,         -- Factura duplicada
    @jsonActividades = N'[{"idActividad": 10}, {"idActividad": 10}]'; -- Duplicadas en el carrito


--  ================================    Pruebas para Ventas.entradaActividad   ================================

--1. Venta masiva exitosa.

DECLARE @jsonValido NVARCHAR(MAX);
SET @jsonValido = N'{
    "entradas": [
        { "codigoEntrada": "M-100200-X", "idVisitante": 1, "fechaAcceso": "2026-11-01" },
        { "codigoEntrada": "M-300400-Y", "idVisitante": 2, "fechaAcceso": "2026-11-01" }
    ],
    "actividades": [
        { "codigoEntrada": "M-100200-X", "idActividad": 10 },
        { "codigoEntrada": "M-300400-Y", "idActividad": 20 }
    ]
}';

EXEC Ventas.procesarVentaMasiva
    @idParque = 1,
    @idFormaPago = 1,
    @puntoVenta = 5,
    @numeroFactura = 200001,
    @jsonCompra = @jsonValido;

-- Comprobación masiva
SELECT * FROM Ventas.venta WHERE numeroFactura = 200001;
SELECT * FROM Ventas.itemVenta WHERE idVenta = (SELECT idVenta FROM Ventas.venta WHERE numeroFactura = 200001);
SELECT * FROM Ventas.entrada WHERE CodigoEntrada IN ('M-100200-X', 'M-300400-Y');
SELECT * FROM Ventas.pago WHERE idVenta = (SELECT idVenta FROM Ventas.venta WHERE numeroFactura = 200001);
GO

--2. Venta masiva fallida. Resultado: Lanza la excepción 60002 acumulando los errores de negocio detectados preventivamente.

DECLARE @jsonInvalido NVARCHAR(MAX);
SET @jsonInvalido = N'{
    "entradas": [
        { "codigoEntrada": "M-100200-X", "idVisitante": 1, "fechaAcceso": "2010-01-01" } -- Fecha vieja sin tarifas configuradas
    ],
    "actividades": [
        { "codigoEntrada": "M-100200-X", "idActividad": 9999 } -- ID de Actividad inexistente
    ]
}';

EXEC Ventas.procesarVentaMasiva
    @idParque = 1,
    @idFormaPago = 1,
    @puntoVenta = 5,
    @numeroFactura = 200001, -- Provoca colisión fiscal de número
    @jsonCompra = @jsonInvalido;


--  ================================    Caso obligatorio: Tour con cupo completo   ================================

-- Verifica que existe al menos un tour cuya cantidad de anotados iguale su cupo maximo.
-- Resultado esperado: 1 fila con actividad = 'Tour Demo Cupo Completo', anotados = 5, cupoMaximo = 5, estado = 'LLENO'.

SELECT 
    a.nombre AS actividad,
    t.cupoMaximo,
    COUNT(ea.codigoEntrada) AS anotados,
    CASE WHEN COUNT(ea.codigoEntrada) >= t.cupoMaximo THEN 'LLENO' ELSE 'DISPONIBLE' END AS estado
FROM Actividades.tour t
INNER JOIN Actividades.actividad a ON a.idActividad = t.idActividad
LEFT JOIN Ventas.entradaActividad ea ON ea.idActividad = t.idActividad
WHERE a.nombre = 'Tour Demo Cupo Completo'
GROUP BY a.nombre, t.cupoMaximo;
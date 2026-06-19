/* 
    Script generado el 

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Testing de los SP del esquema Ventas.
*/
USE GestionParquesNacionales;
GO

--  ================================    Pruebas para Ventas.TipoVisitante   ================================
--1. Alta

-- TODO OK
EXEC Ventas.TipoVisitante_Alta @descripcion = 'Estudiante';

SELECT * FROM Ventas.TipoVisitante;
GO

-- ERROR DUPLICADO
EXEC Ventas.TipoVisitante_Alta @descripcion = 'Estudiante';

--2. Modificar

-- TODO OK:
DECLARE @idValido INT;
SELECT TOP 1 @idValido = IDTipoVisitante FROM Ventas.TipoVisitante WHERE Descripcion = 'Estudiante';

EXEC Ventas.TipoVisitante_Modificar @idTipoVisitante = @idValido, @nuevaDescripcion = 'Estudiante Uni';

SELECT * FROM Ventas.TipoVisitante;
GO

-- ERROR ID tipo de visitante
EXEC Ventas.TipoVisitante_Modificar @idTipoVisitante = -1, @nuevaDescripcion = 'errror';


--3. Baja

-- Baja exitosa
DECLARE @idABorrar INT;
SELECT TOP 1 @idABorrar = IDTipoVisitante FROM Ventas.TipoVisitante WHERE Descripcion = 'Estudiante Uni';

EXEC Ventas.TipoVisitante_Baja @idTipoVisitante = @idABorrar;

SELECT * FROM Ventas.TipoVisitante WHERE IDTipoVisitante = @idABorrar;
GO

-- Baja fallida. Devuelve 'El tipo de visitante con id = 99999 especificado no existe.'

EXEC Ventas.TipoVisitante_Baja @idTipoVisitante = 99999;


--  ================================    Pruebas para Ventas.Visitante   ================================
--1. Alta

-- Alta Exitosa. Requisito: debe haber al menos un registro en TipoVisitante.
EXEC Ventas.TipoVisitante_Alta @descripcion = 'General';

DECLARE @idTipo INT;
SELECT TOP 1 @idTipo = IDTipoVisitante FROM Ventas.TipoVisitante WHERE Descripcion = 'General';
PRINT '--- Test Visitante_Alta: Caso Exitoso ---';
EXEC Ventas.Visitante_Alta 
    @idTipoVisitante = @idTipo, 
    @nombre = 'Mijael', 
    @apellido = 'Zambrana', 
    @fechaNacimiento = '2000-05-20', 
    @tipoDocumento = 'DNI', 
    @numeroDocumento = 45123456;

SELECT * FROM Ventas.Visitante WHERE NumeroDocumento = 45123456;
GO

--Alta Fallida. Resultado: error en DNI, Nombre, fechaNacimiento y numero de documento

EXEC Ventas.Visitante_Alta 
        @idTipoVisitante = 999,      -- ID Inexistente
        @nombre = '',                -- Vacío
        @apellido = 'Gomez', 
        @fechaNacimiento = '2030-01-01', -- Fecha futura
        @tipoDocumento = 'DNI', 
        @numeroDocumento = -100;     -- Negativo

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.
DECLARE @idValido INT;
SELECT TOP 1 @idValido = IDVisitante FROM Ventas.Visitante WHERE NumeroDocumento = 45123456;

EXEC Ventas.Visitante_Modificar 
    @idVisitante = @idValido, 
    @idTipoVisitante = NULL, 
    @nombre = 'Javier', -- Cambio de nombre
    @apellido = 'Zambrano', -- Cambio de apellido
    @fechaNacimiento = '2004-05-20', -- Cambio de fechaNac
    @tipoDocumento = NULL,
    @numeroDocumento = NULL

SELECT * FROM Ventas.Visitante WHERE NumeroDocumento = 45123456;
GO

-- Modificacion fallida. Resultado: Errores en idVisitante, idTipoVisitante y numero de documento

EXEC Ventas.Visitante_Modificar 
        @idVisitante = -99, 
        @idTipoVisitante = -2, 
        @nombre = 'Test', 
        @apellido = NULL
        @fechaNacimiento = '1995-01-01', 
        @tipoDocumento = 'DNI', 
        @numeroDocumento = 0;

--3. Baja 
-- Baja Exitosa.

DECLARE @idABorrar INT;
SELECT TOP 1 @idABorrar = IDVisitante FROM Ventas.Visitante WHERE NumeroDocumento = 45123456;

EXEC Ventas.Visitante_Baja @idVisitante = @idABorrar;

SELECT * FROM Ventas.Visitante WHERE IDVisitante = @idABorrar;
GO

-- Baja fallida. Resultado: No existe un visitante con id = 99999

EXEC Ventas.Visitante_Baja @idVisitante = 99999;


--  ================================    Pruebas para Ventas.FormaPago   ================================

--1. Alta

-- Alta Exitosa. 

EXEC Ventas.FormaPago_Alta @Descripcion = 'Tarjeta de Debito';

SELECT * FROM Ventas.FormaPago WHERE Descripcion = 'Tarjeta de Debito';
GO

-- Alta Fallida. Resultado: La descripción de la forma de pago no puede estar vacía.

EXEC Ventas.FormaPago_Alta @Descripcion = '';

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.

DECLARE @idValido INT;
SELECT TOP 1 @idValido = IDFormaPago FROM Ventas.FormaPago WHERE Descripcion = 'Tarjeta de Debito';

EXEC Ventas.FormaPago_Modificar @idFormaPago = @idValido, @descripcion = 'Pago Facil';

SELECT * FROM Ventas.FormaPago;
GO

-- Modificacion fallida. Resultado: La nueva descripción no puede estar vacía

DECLARE @idValidoError INT;
SELECT TOP 1 @idValidoError = IDFormaPago FROM Ventas.FormaPago WHERE Descripcion = 'Pago Facil';
EXEC Ventas.FormaPago_Modificar @idFormaPago = @idValidoError, @descripcion = '   ';

--3. Baja 

-- Baja Exitosa.

DECLARE @idABorrar INT;
SELECT TOP 1 @idABorrar = IDFormaPago FROM Ventas.FormaPago WHERE Descripcion = 'Pago Facil';

EXEC Ventas.FormaPago_Baja @idFormaPago = @idABorrar;

-- Verificación final de inexistencia
SELECT * FROM Ventas.FormaPago
GO

-- Baja fallida. Resultado: El ID de la forma de pago especificada no existe


EXEC Ventas.FormaPago_Baja @idFormaPago = -50;

--  ================================    Pruebas para Ventas.PreciosParque   ================================

--1. Alta

-- Alta Exitosa. Requisitos: debe existir al menos un parque
EXEC Gestion.TipoParque_Alta @nombre = 'Parque Nacional';

EXEC Gestion.Parque_Alta 
    @nombre = 'Iguazu',
    @superficie = 67000,
    @idTipoParque = 1,
    @provincia = 'Misiones';


DECLARE @idTipoVis INT 
SELECT TOP 1 @idTipoVis = IDTipoVisitante FROM Ventas.TipoVisitante WHERE Descripcion = 'General'
EXEC Ventas.PreciosParque_Alta 
    @idParque = 1, 
    @idTipoVisitante = @idTipoVis,
    @fechaDesde = '2026-01-01', 
    @precio = 3500.00;

SELECT * FROM Ventas.PreciosParque

-- Alta Fallida. Resultado: El ID de Parque especificado no existe. El ID de Tipo de Visitante no existe. El precio debe ser un valor mayor o igual a cero.

EXEC Ventas.PreciosParque_Alta 
        @idParque = 9999,            -- ID Inexistente
        @idTipoVisitante = 1, 
        @fechaDesde = '2026-12-31', 
        @precio = -120.50;

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.

DECLARE @idTipoVis INT 
SELECT TOP 1 @idTipoVis = IDTipoVisitante FROM Ventas.TipoVisitante WHERE Descripcion = 'General'

EXEC Ventas.PreciosParque_Modificar 
    @idParque = 1, 
    @idTipoVisitante = @idTipoVis, 
    @fechaDesde = '2026-01-01', 
    @nuevoPrecio = 4200.00;

SELECT * FROM Ventas.PreciosParque

-- Modificacion fallida. Resultado:  No existe una tarifa registrada que coincida con el Parque, Tipo de Visitante y Fecha especificados

EXEC Ventas.PreciosParque_Modificar 
    @idParque = 1, 
    @idTipoVisitante = 1, 
    @fechaDesde = '1990-05-10', -- Fecha sin registros
    @nuevoPrecio = 1000.00;

--3. Baja 

-- Baja Exitosa. Elimina la tarifa

DECLARE @idTipoVis INT 
SELECT TOP 1 @idTipoVis = IDTipoVisitante FROM Ventas.TipoVisitante WHERE Descripcion = 'General'
EXEC Ventas.PreciosParque_Baja 
    @idParque = 1, 
    @idTipoVisitante = @idTipoVis, 
    @fechaDesde = '2026-01-01';

SELECT * FROM Ventas.PreciosParque

-- Baja fallida. Resultado: No se encontró la tarifa histórica que intenta eliminar.

EXEC Ventas.PreciosParque_Baja 
    @idParque = 1, 
    @idTipoVisitante = 99, 
    @fechaDesde = '2026-01-01';

--  ================================    Pruebas para Ventas.FormaPago   ================================

--1. Alta

-- Alta Exitosa. Requisitos: Debe existir al menos un parque

EXEC Gestion.TipoParque_Alta @nombre = 'Parque Nacional';

EXEC Gestion.Parque_Alta 
    @nombre = 'Iguazu',
    @superficie = 67000,
    @idTipoParque = 1,
    @provincia = 'Misiones';

EXEC Ventas.Venta_Alta 
    @idParque = 1, 
    @numeroFactura = 1001, 
    @puntoVenta = 1, 
    @total = 7500.00;

SELECT * FROM Ventas.Venta

-- Alta Fallida.  Resultados: El punto de venta debe ser mayor a cero. El total de la venta no puede ser un valor negativo.

EXEC Ventas.Venta_Alta 
    @idParque = 1, 
    @numeroFactura = 1002, 
    @puntoVenta = -5,       
    @total = -250.00;       

--2. Modificar

-- Modificacion exitosa. Resultado, se cambia el total de la venta

DECLARE @idValido INT;
SELECT TOP 1 @idValido = IDVenta FROM Ventas.Venta WHERE PuntoVenta = 1 AND NumeroFactura = 1001;

EXEC Ventas.Venta_Modificar 
    @idVenta = @idValido, 
    @idParque = 1, 
    @numeroFactura = NULL, 
    @puntoVenta = 1, 
    @total = 8900.00; -- cambio el total

SELECT * FROM Ventas.Venta;

-- Modificacion fallida. Resultado: La combinación de Punto de Venta y Factura ya está asignada a otro ticket.

-- Creo otra venta
EXEC Ventas.Venta_Alta @idParque = 1, @numeroFactura = 2222, @puntoVenta = 2, @total = 50.00;
GO


DECLARE @idValidoChoque INT;
SELECT TOP 1 @idValidoChoque = IDVenta FROM Ventas.Venta WHERE PuntoVenta = 2 AND NumeroFactura = 2222;
EXEC Ventas.Venta_Modificar 
    @idVenta = @idValidoChoque, 
    @idParque = 1, 
    @numeroFactura = 1001, -- uso el nro de factura de la primera venta
    @puntoVenta = 1,       -- uso el punto de venta de la primera venta
    @total = 1000.00;

--3. Baja 

-- Baja Exitosa.

DECLARE @idABorrar INT;
SELECT TOP 1 @idABorrar = IDVenta FROM Ventas.Venta WHERE PuntoVenta = 1 AND NumeroFactura = 1001;

EXEC Ventas.Venta_Baja @idVenta = @idABorrar;

-- Baja fallida. Resultado: El ID de Venta especificado no existe. 

EXEC Ventas.Venta_Baja @idVenta = -999;

--  ================================    Pruebas para Ventas.ItemVenta   ================================

--1. Alta

-- Alta Exitosa. Requisitos: Debe tener al menos una venta y una forma de pago

EXEC Ventas.ItemVenta_Alta 
    @idVenta = 2, -- es el id de la venta extra que creamos para que se choquen las restricciones
    @idItemVenta = 1, 
    @tipoItem = 'Entrada', 
    @cantidad = 2, 
    @precioUnitario = 1500.00;

SELECT * FROM Ventas.ItemVenta

-- Alta Fallida. Resultado: El tipo de ítem no es válido. Debe ser 'Entrada' o 'Actividad'. La cantidad debe ser un valor mayor a cero.

EXEC Ventas.ItemVenta_Alta 
    @idVenta = 2, 
    @idItemVenta = 2, 
    @tipoItem = 'Souvenir', 
    @cantidad = -1,         
    @precioUnitario = 450.00;

--2. Modificar

-- Modificacion exitosa. Resultado, se cambia la cantidad a 3 y el tipoItem por Actividad

EXEC Ventas.ItemVenta_Modificar 
    @idVenta = 2, 
    @idItemVenta = 1, 
    @tipoItem = 'Actividad', 
    @cantidad = 3, 
    @precioUnitario = 1500.00;

-- Modificacion fallida. Resultado: No existe el item de venta que intenta modificar para la venta ingresada.

EXEC Ventas.ItemVenta_Modificar 
    @idVenta = 1, 
    @idItemVenta = 99,
    @tipoItem = 'Actividad', 
    @cantidad = 1, 
    @precioUnitario = 2000.00;

--3. Baja 

-- Baja Exitosa.

EXEC Ventas.ItemVenta_Baja @idVenta = 2, @idItemVenta = 1;

SELECT * FROM Ventas.ItemVenta

-- Baja fallida. Resultado: No se encontró el item de venta que intenta eliminar para esa venta.

EXEC Ventas.ItemVenta_Baja @idVenta = 1, @idItemVenta = 88;


--  ================================    Pruebas para Ventas.Pago   ================================


EXEC Ventas.FormaPago_Alta @Descripcion = 'Tarjeta de Debito';
SELECT * FROM Ventas.Venta
SELECT * FROM Ventas.FormaPago

--1. Alta

-- Alta Exitosa. Requisitos: Debe haber al menos una venta y una forma de pago

EXEC Ventas.Pago_Alta 
    @idVenta = 2, 
    @idFormaPago = 2, 
    @fecha = NULL, -- Pruebo que el DEFAULT tome el GETDATE()
    @estado = 'Aprobado', 
    @importe = 5000.00;


-- Alta Fallida. Resultados: La forma de pago no existe. El importe debe ser mayor a cero.

EXEC Ventas.Pago_Alta 
    @idVenta = 2, 
    @idFormaPago = 9999, -- ID que no existe
    @fecha = NULL, 
    @estado = 'Pendiente', 
    @importe = -250.00;   -- Importe negativo/inválido

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.

DECLARE @idVenta INT;
DECLARE @idFormaPago INT;
SELECT TOP 1 @idVenta = IDVenta FROM Ventas.Venta WHERE IDParque = 1
SELECT TOP 1 @idFormaPago = IDFormaPago FROM Ventas.FormaPago WHERE Descripcion = 'Tarjeta de Debito'
EXEC Ventas.Pago_Modificar 
    @idPago = 1, 
    @idVenta = @idVenta, 
    @idFormaPago = @idFormaPago, 
    @fecha = NULL, 
    @estado = 'Rechazado', -- Modificación de estado
    @importe = 4000.00;

SELECT * FROM Ventas.Pago

-- Modificacion fallida. Resultado: El ID de pago no existe. El importe debe ser mayor a cero. La fecha del pago no puede ser despues de la fecha actual.

DECLARE @idVenta INT;
DECLARE @idFormaPago INT;
SELECT TOP 1 @idVenta = IDVenta FROM Ventas.Venta WHERE IDParque = 1
SELECT TOP 1 @idFormaPago = IDFormaPago FROM Ventas.FormaPago WHERE Descripcion = 'Tarjeta de Debito'
EXEC Ventas.Pago_Modificar 
    @idPago = -999,              
    @idVenta = @idVenta, 
    @idFormaPago = @idFormaPago, 
    @fecha = '2035-01-01',       
    @estado = 'Aprobado', 
    @importe = -150.00;

--3. Baja 

-- Baja Exitosa.

EXEC Ventas.Pago_Baja @idPago = 1;

-- Baja fallida. Resultado: El ID de pago ingresado no existe

EXEC Ventas.Pago_Baja @idPago = 8888;


--  ================================    Pruebas para Ventas.Entrada   ================================

-- preparacion
EXEC Ventas.Venta_Alta 
    @idParque = 1, 
    @numeroFactura = 1001, 
    @puntoVenta = 1, 
    @total = 7500.00;

SELECT * FROM Ventas.Venta

EXEC Ventas.FormaPago_Alta @Descripcion = 'Tarjeta de Debito';

SELECT * FROM Ventas.Visitante

DECLARE @idTipo INT;
SELECT TOP 1 @idTipo = IDTipoVisitante FROM Ventas.TipoVisitante WHERE Descripcion = 'Estudiante'
EXEC Ventas.Visitante_Alta 
    @idTipoVisitante = @idTipo, 
    @nombre = 'Mijael', 
    @apellido = 'Zambrana', 
    @fechaNacimiento = '2000-05-20', 
    @tipoDocumento = 'DNI', 
    @numeroDocumento = 45123456;


--1. Alta

-- Alta Exitosa. Requisitos: debe tener una venta y una forma de pago activa

DECLARE @idVisitante INT;
DECLARE @idTipo INT;
SELECT TOP 1 @idVisitante = IDVisitante, @idTipo = IDTipoVisitante FROM Ventas.Visitante WHERE TipoDocumento = 'DNI' AND NumeroDocumento = 45123456
EXEC Ventas.Entrada_Alta 
    @codigoEntrada = 'A-111222-Z', 
    @fechaAcceso = '2026-11-20', 
    @fechaCompra = NULL, 
    @idVisitante = @idVisitante, 
    @idParque = 1, 
    @idTipoVisitante = @idTipo, 
    @precio = 2500.00;

SELECT * FROM Ventas.Entrada

-- Alta Fallida. Resultado: - Formato de código de entrada inválido. El visitante no existe. El tipo de visitante no existe. El precio no puede ser negativo.

EXEC Ventas.Entrada_Alta 
    @codigoEntrada = 'ABC-123',   
    @fechaAcceso = '2026-11-20', 
    @fechaCompra = NULL, 
    @idVisitante = 1, 
    @idParque = 1, 
    @idTipoVisitante = 1, 
    @precio = -500.00;

--2. Modificar

-- Modificacion exitosa. Resultado: se modifica el precio


DECLARE @idVisitante INT;
DECLARE @idTipo INT;
SELECT TOP 1 @idVisitante = IDVisitante, @idTipo = IDTipoVisitante FROM Ventas.Visitante WHERE TipoDocumento = 'DNI' AND NumeroDocumento = 45123456
EXEC Ventas.Entrada_Modificar 
    @codigoEntrada = 'A-111222-Z', 
    @fechaAcceso = '2026-11-20', 
    @fechaCompra = NULL, 
    @idVisitante = @idVisitante, 
    @idParque = 1, 
    @idTipoVisitante = @idTipo, 
    @precio = 3100.00; 

-- Modificacion fallida. Resultado: La fecha de acceso no puede ser anterior a la fecha actual. La fecha de compra no puede ser despues de la fecha actual.

DECLARE @idVisitante INT;
DECLARE @idTipo INT;
SELECT TOP 1 @idVisitante = IDVisitante, @idTipo = IDTipoVisitante FROM Ventas.Visitante WHERE TipoDocumento = 'DNI' AND NumeroDocumento = 45123456
EXEC Ventas.Entrada_Modificar 
    @codigoEntrada = 'A-111222-Z', 
    @fechaAcceso = '2020-01-01',  
    @fechaCompra = '2030-05-20',  
    @idVisitante = @idVisitante, 
    @idParque = 1, 
    @idTipoVisitante = @idTipo, 
    @precio = 3100.00;

--3. Baja 

-- Baja Exitosa.

EXEC Ventas.Entrada_Baja @codigoEntrada = 'A-111222-Z';

-- Baja fallida. Resultado: El código de entrada especificado no existe.

EXEC Ventas.Entrada_Baja @codigoEntrada = 'Z-000000-Z';

--  ================================    Pruebas para Ventas.EntradaActividad   ================================

--preparacion

DECLARE @idVisitante INT;
DECLARE @idTipo INT;
SELECT TOP 1 @idVisitante = IDVisitante, @idTipo = IDTipoVisitante FROM Ventas.Visitante WHERE TipoDocumento = 'DNI' AND NumeroDocumento = 45123456
EXEC Ventas.Entrada_Alta 
    @codigoEntrada = 'A-111222-Z', 
    @fechaAcceso = '2026-11-20', 
    @fechaCompra = NULL, 
    @idVisitante = @idVisitante, 
    @idParque = 1, 
    @idTipoVisitante = @idTipo, 
    @precio = 2500.00;



EXEC Actividades.TipoActividad_Alta @descripcion = 'Tour'

EXEC Actividades.Guia_Alta
    @codEspecialidad = 1

SELECT * FROM Actividades.Actividad

EXEC Actividades.Actividad_Alta
    @nombre = 'Paseo en Gomón Gran Aventura',
    @costo = 0.0,
    @duracion = 2.4,
    @idTipoActividad = 1

EXEC Actividades.Actividad_Alta
    @nombre = 'Paseo en Un Parque Gran Aventura',
    @costo = 2.0,
    @duracion = 2.4,
    @idTipoActividad = 1

--1. Alta

-- Alta Exitosa. Requisitos debe existir una actividad y una entrada

EXEC Ventas.EntradaActividad_Alta 
    @codigoEntrada = 'A-111222-Z', 
    @idActividad = 1;

SELECT * FROM Ventas.EntradaActividad

-- Alta Fallida. Resultado: La entrada especificada no existe. La actividad especificada no existe.

EXEC Ventas.EntradaActividad_Alta 
        @codigoEntrada = 'X-000000-X', -- Código de entrada inexistente
        @idActividad = 999;

--2. Modificar

-- Modificacion exitosa. Resultado, solo se ven cambios en los campos escritos.

EXEC Ventas.EntradaActividad_Modificar 
    @codigoEntrada = 'A-111222-Z', 
    @idActividadActual = 1, 
    @idActividadNueva = 2;

SELECT * FROM Ventas.EntradaActividad

-- Modificacion fallida. Resultado: - No existe la relación original especificada. La nueva actividad a asignar no existe.

EXEC Ventas.EntradaActividad_Modificar 
    @codigoEntrada = 'A-999888-Z', 
    @idActividadActual = 10, 
    @idActividadNueva = 20;

--3. Baja 

-- Baja Exitosa.

EXEC Ventas.EntradaActividad_Baja 
    @codigoEntrada = 'A-111222-Z', 
    @idActividad = 2;


-- Baja fallida. Resultado: No existe la relación ingresada. 

EXEC Ventas.EntradaActividad_Baja 
        @codigoEntrada = 'A-999888-Z', 
        @idActividad = 555;
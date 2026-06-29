/* 
    Script generado el 

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leonel
                - Zambrana, Mijael

Descripción del Script:  Stored procedures de logica de negocio de venta de entradas
                         del esquema Ventas. Contiene venta individual y masiva, utilizando
                         los SPs ABM para generar lo necesario y un insert to para agregar
                         varias filas. Tambien contiene los SPs de consulta de precios de parques en dolares 
                         (utilizan una API).


IMPORTANTE: debe ejecutar los siguientes comandos por unica vez para que los scripts funcionen

USE master;
GO

-- 1. Permitir ver las opciones avanzadas del servidor
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

-- 2. Habilitar los procedimientos de automatización OLE
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
GO
*/

USE GestionParquesNacionales_Com5600_Grupo07
GO


CREATE OR ALTER PROCEDURE Ventas.procesarVentaIndividual
    @codigoEntrada CHAR(10),
    @idVisitante INT,
    @fechaAcceso DATE,
    @idParque INT,
    @idFormaPago INT,
    @puntoVenta INT,
    @numeroFactura INT,
    @tipoFactura CHAR(1),
    @estadoPago VARCHAR(9),
    @jsonActividades NVARCHAR(400) = NULL -- Recibe todo el carrito de actividades estructurado
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @idTipoVisitante INT;

    DECLARE @total DECIMAL(10,2) = NULL;
    DECLARE @idVentaGenerado INT;
    DECLARE @cantActividadesAComprar INT;
    DECLARE @cantActividadesEncontradas INT;


    -- Tabla de activades en memoria para cargar el json
    DECLARE @actividades TABLE (
        idActividad INT
    );

    INSERT INTO @actividades(idActividad)
    SELECT idActividad FROM OPENJSON(@jsonActividades) WITH(
        idActividad INT '$.idActividad'
    );
    
    SELECT @idTipoVisitante = idTipoVisitante FROM Ventas.visitante WHERE idVisitante = @idVisitante;

    IF @idTipoVisitante IS NOT NULL AND @idParque IS NOT NULL
    BEGIN
        SELECT TOP 1 @total = precio FROM Ventas.preciosParque
        WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante AND fechaDesde <= @fechaAcceso ORDER BY fechaDesde DESC;

        IF @total IS NULL
            SET @errorMsg = @errorMsg + '- No hay una tarifa configurada para este tipo de visitante en la fecha elegida.' + @saltoLinea;
    END

    IF EXISTS ( SELECT idActividad FROM @actividades GROUP BY idActividad HAVING COUNT(*) > 1)
        SET @errorMsg +='- Hay actividades repetidas en la compra.' + @saltoLinea;

    SELECT @cantActividadesAComprar = COUNT(1) FROM @actividades;

    IF @cantActividadesAComprar > 0 -- si agrego alguna actividad
    BEGIN
        -- hago un join y para ver que cantidad de actividades seleccionadas encuentro
        SELECT @cantActividadesEncontradas = COUNT(1) FROM @actividades actAComprar
        INNER JOIN Actividades.actividad actRegistradas ON actRegistradas.idActividad = actAComprar.idActividad

        IF @cantActividadesAComprar <> @cantActividadesEncontradas
            SET @errorMsg = @errorMsg + '- Alguna de las actividades/tours seleccionados no existe.' + @saltoLinea;
    END

    -- validación preventiva para cumplir la restricción UNIQUE del ticket factura antes de operar
    IF EXISTS (SELECT 1 FROM Ventas.ticketFactura WHERE puntoVenta = @puntoVenta AND numeroFactura = @numeroFactura)
        SET @errorMsg = @errorMsg + '- Ya existe un ticket registrado con ese Punto de Venta y Número de Factura.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 60001, @errorMsg, 1;
    END

    BEGIN TRY
        BEGIN TRANSACTION

            EXEC Ventas.ventaAlta
                @idParque = @idParque,
                @idVenta = @idVentaGenerado OUTPUT

            EXEC Ventas.entradaAlta
                @codigoEntrada = @codigoEntrada,
                @idVenta = @idVentaGenerado,
                @fechaAcceso = @fechaAcceso,
                @fechaCompra = NULL, -- se asigna en el sp
                @idVisitante = @idVisitante,
                @idParque = @idParque,
                @idTipoVisitante = @idTipoVisitante,
                @precio = @total

            -- Con row_number se genera automáticamente 1 para la Entrada, y 2, 3... para las actividades
            INSERT INTO Ventas.itemVenta (idVenta, nroItem, idTipoVisitante, idActividad, tipoItem, cantidad, precioUnitario)
            SELECT @idVentaGenerado, ROW_NUMBER() OVER (ORDER BY tipoItem DESC, idActividad), idTipoVisitante, idActividad, tipoItem, cantidad, precioUnitario
            FROM (
                -- Registro base único de la Entrada
                SELECT @idTipoVisitante AS idTipoVisitante, NULL AS idActividad, 'Entrada' AS tipoItem, 1 AS cantidad, @total AS precioUnitario
                
                UNION ALL
                
                -- Registros correspondientes a las Actividades asociadas del JSON
                SELECT NULL AS idTipoVisitante, actRegistradas.idActividad, 'Actividad' AS tipoItem, 1 AS cantidad, actRegistradas.costo AS precioUnitario
                FROM Actividades.actividad actRegistradas 
                INNER JOIN @actividades actAComprar ON actAComprar.idActividad = actRegistradas.idActividad
            ) AS itemsUnificados;


            IF @cantActividadesAComprar > 0
            BEGIN
                INSERT INTO Ventas.entradaActividad (CodigoEntrada, IDActividad)
                SELECT 
                    @codigoEntrada,
                    idActividad
                FROM @actividades;
            END


            -- Calculamos el total final consolidado en base a los items cargados
            SET @total = (SELECT SUM(precioUnitario * cantidad) FROM Ventas.itemVenta WHERE idVenta = @idVentaGenerado)

            EXEC Ventas.ticketFacturaAlta
                @idVenta = @idVentaGenerado,
                @puntoVenta = @puntoVenta,
                @numeroFactura = @numeroFactura,
                @tipoFactura = @tipoFactura,
                @montoTotal = @total

            EXEC Ventas.pagoAlta 
                @idVenta = @idVentaGenerado,
                @idFormaPago = @idFormaPago,
                @fecha = NULL, -- se asigna en el sp
                @estado = @estadoPago,
                @importe = @total

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END

    SET @errorMsg = @errorMsg + '- Fallo la transaccion de venta de entrada individual.' + ERROR_MESSAGE() + @saltoLinea
    ;THROW 60001, @errorMsg, 1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Ventas.procesarVentaMasiva
    @idParque INT,
    @idFormaPago INT,
    @puntoVenta INT,
    @numeroFactura INT,
    @tipoFactura CHAR(1),
    @estadoPago VARCHAR(9),
    @jsonCompra NVARCHAR(MAX) -- Recibe todo el carrito estructurado
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);
    
    DECLARE @idVentaGenerado INT;
    DECLARE @totalFactura DECIMAL(10,2) = 0;
    DECLARE @subtotalEntradas DECIMAL(10,2) = 0;
    DECLARE @subtotalActividades DECIMAL(10,2) = 0;

    -- 1. tablas en memoria para guardar los datos del json
    DECLARE @entradas TABLE (
        codigoEntrada CHAR(10),
        idVisitante INT,
        idTipoVisitante INT,
        fechaAcceso DATE,
        precioCalculado DECIMAL(10,2)
    );

    DECLARE @actividades TABLE (
        codigoEntrada CHAR(10),
        idActividad INT,
        precioActividad DECIMAL (8,2)
    );

    -- 2. parseo del json
    
    -- leemos los campos de la entrada del json
    INSERT INTO @entradas (codigoEntrada, idVisitante, fechaAcceso)
    SELECT codigoEntrada, idVisitante, fechaAcceso
    FROM OPENJSON(@jsonCompra, '$.entradas')
    WITH (
        codigoEntrada CHAR(10) '$.codigoEntrada',
        idVisitante INT '$.idVisitante',
        fechaAcceso DATE '$.fechaAcceso'
    );

    -- leemos los campos de la la actividad del json
    INSERT INTO @actividades (codigoEntrada, idActividad)
    SELECT codigoEntrada, idActividad
    FROM OPENJSON(@jsonCompra, '$.actividades')
    WITH (
        codigoEntrada CHAR(10) '$.codigoEntrada',
        idActividad INT '$.idActividad'
    );

    -- 3. Validaciones

    IF NOT EXISTS (SELECT 1 FROM @entradas)
        SET @errorMsg += '- La venta debe contener al menos una entrada.' + @saltoLinea;

    IF EXISTS (SELECT codigoEntrada FROM @entradas GROUP BY codigoEntrada HAVING COUNT(*) > 1)
        SET @errorMsg = @errorMsg + '- Existen códigos de entrada repetidos en el lote.' + @saltoLinea;

    -- Validar formato del formato de pases del JSON
    IF EXISTS (SELECT 1 FROM @entradas WHERE codigoEntrada NOT LIKE '[A-Z]-[0-9][0-9][0-9][0-9][0-9][0-9]-[A-Z]')
        SET @errorMsg = @errorMsg + '- Formato de código de entrada inválido en el lote.' + @saltoLinea;

    -- Validar duplicados contra la base de datos
    IF EXISTS (SELECT 1 FROM Ventas.Entrada E INNER JOIN @entradas Ent ON E.CodigoEntrada = Ent.codigoEntrada)
        SET @errorMsg = @errorMsg + '- Uno o más códigos de entrada ya fueron emitidos.' + @saltoLinea;

    -- validación de control fiscal sobre la nueva tabla de tickets para evitar violar el UNIQUE
    IF EXISTS (SELECT 1 FROM Ventas.ticketFactura WHERE puntoVenta = @puntoVenta AND numeroFactura = @numeroFactura)
        SET @errorMsg = @errorMsg + '- Ya existe un ticket registrado con ese Punto de Venta y Número de Factura.' + @saltoLinea;

    UPDATE entAComprar
    SET entAComprar.idTipoVisitante = v.idTipoVisitante
    FROM @entradas entAComprar
    INNER JOIN Ventas.visitante v ON entAComprar.idVisitante = v.idVisitante 

    -- 4. busco los precios de cada entrada y actividad
    UPDATE ent
    SET ent.precioCalculado = ( SELECT TOP 1 pp.precio FROM Ventas.preciosParque pp
    WHERE pp.idParque = @idParque AND pp.idTipoVisitante = ent.idTipoVisitante AND pp.fechaDesde <= ent.fechaAcceso
    ORDER BY pp.fechaDesde DESC)
    FROM @entradas ent

    UPDATE actAComprar
    SET actAComprar.precioActividad = (SELECT TOP 1 actRegistradas.costo FROM Actividades.actividad actRegistradas WHERE actAComprar.idActividad = actRegistradas.idActividad)
    FROM @actividades actAComprar

    IF EXISTS (SELECT 1 FROM @entradas WHERE idTipoVisitante IS NULL )
        SET @errorMsg += '- Hay visitantes ingresados que no existen.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM @entradas WHERE precioCalculado IS NULL)
        SET @errorMsg += '- No existe precio configurado para alguna entrada.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM @actividades WHERE precioActividad IS NULL)
        SET @errorMsg += '- No existe alguna de las actividades ingresadas.'+ @saltoLinea;

    -- Despacho de errores preventivos
    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 60002, @errorMsg, 1;
    END

    -- 6. Transaccion

    SELECT @subtotalEntradas = SUM(precioCalculado) FROM @entradas;
    SELECT @subtotalActividades = ISNULL(SUM(precioActividad), 0) FROM @actividades; -- uso ISNULL, porque el visitante puede no comprar actividades
    SET @totalFactura = @subtotalEntradas + @subtotalActividades;
 
    BEGIN TRY
        BEGIN TRANSACTION;

            EXEC Ventas.ventaAlta
                @idParque = @idParque,
                @idVenta = @idVentaGenerado OUTPUT

            -- Detalle ItemVenta de entradas
            -- Detalle ItemVenta de actividades agrupadas (si existen)
            INSERT INTO Ventas.itemVenta (idVenta, nroItem, idTipoVisitante, idActividad, tipoItem, cantidad, precioUnitario)
            SELECT @idVentaGenerado, ROW_NUMBER() OVER (ORDER BY tipoItem DESC, idAgrupado), idTipoVisitante, idActividad, tipoItem, cantidad, precioUnitario
            FROM (
                SELECT idTipoVisitante, NULL AS idActividad, 'Entrada' AS tipoItem, COUNT(*) AS cantidad, AVG(precioCalculado) AS precioUnitario, idTipoVisitante AS idAgrupado
                FROM @entradas
                GROUP BY idTipoVisitante
                
                UNION ALL
                
                SELECT NULL AS idTipoVisitante, idActividad, 'Actividad' AS tipoItem, COUNT(*) AS cantidad, AVG(precioActividad) AS precioUnitario, idActividad AS idAgrupado
                FROM @actividades
                GROUP BY idActividad
            ) AS itemsUnificados;

            -- Registrar los pases físicos masivos
            INSERT INTO Ventas.entrada (codigoEntrada, idVenta, fechaAcceso, fechaCompra, idVisitante, idParque, idTipoVisitante, precio)
            SELECT codigoEntrada, @idVentaGenerado, fechaAcceso, GETDATE(), idVisitante, @idParque, idTipoVisitante, precioCalculado
            FROM @entradas;

            -- Registrar relaciones intermedias N:M de actividades
            IF EXISTS (SELECT 1 FROM @actividades)
            BEGIN
                INSERT INTO Ventas.entradaActividad (codigoEntrada, idActividad)
                SELECT 
                    codigoEntrada,
                    idActividad
                FROM @actividades;
            END

            -- ALTA DEL TICKET FISCAL 
            EXEC Ventas.ticketFacturaAlta
                @idVenta = @idVentaGenerado,
                @puntoVenta = @puntoVenta,
                @numeroFactura = @numeroFactura,
                @tipoFactura = @tipoFactura,
                @montoTotal = @totalFactura;

            -- Registrar el pago final unificado
            EXEC Ventas.pagoAlta 
                @idVenta = @idVentaGenerado,
                @idFormaPago = @idFormaPago,
                @fecha = NULL,
                @estado = @estadoPago,
                @importe = @totalFactura

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @errorMsg = @errorMsg + '- Fallo de la venta masiva. Error: ' + ERROR_MESSAGE() + @saltoLinea

        ;THROW 60002, @errorMsg, 1;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Ventas.consultarPrecioParqueEnDolares
    @idParque INT,
    @idTipoVisitante INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @precioPesos DECIMAL(10,2);
    DECLARE @url VARCHAR(255) = 'https://dolarapi.com/v1/dolares/oficial';
    
    -- Variables para el manejo del objeto HTTP
    DECLARE @objHttp INT;
    DECLARE @respuesta VARCHAR(8000);
    DECLARE @cotizacionDolar DECIMAL(10,2);
    DECLARE @precioDolares DECIMAL(10,2);

    SELECT TOP 1 @precioPesos = precio 
    FROM Ventas.preciosParque 
    WHERE idParque = @idParque 
      AND idTipoVisitante = @idTipoVisitante 
      AND fechaDesde <= GETDATE()
    ORDER BY fechaDesde DESC;

    IF @precioPesos IS NULL
    BEGIN
        PRINT 'No se encontró un precio para los parámetros ingresados.';
        RETURN;
    END

    EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @objHttp OUT;
    EXEC sp_OAMethod @objHttp, 'open', NULL, 'GET', @url, false;
    EXEC sp_OAMethod @objHttp, 'send', NULL, NULL;
    
    EXEC sp_OAMethod @objHttp, 'responseText', @respuesta OUT;
    EXEC sp_OADestroy @objHttp;

    DECLARE @posVenta INT = CHARINDEX('"venta":', @respuesta);
    
    IF @posVenta > 0
    BEGIN
        DECLARE @tempStr VARCHAR(50);
        SET @tempStr = SUBSTRING(@respuesta, @posVenta + 8, 20);
        SET @tempStr = SUBSTRING(@tempStr, 1, CHARINDEX(',', @tempStr) - 1);
        
        SET @cotizacionDolar = CAST(@tempStr AS DECIMAL(10,2));

        -- Calculo la conversión ($ARS / Cotización)
        SET @precioDolares = @precioPesos / @cotizacionDolar;

        SELECT 
            (SELECT TOP 1 nombre FROM Gestion.parque WHERE idParque = @idParque) AS [Parque],
            (SELECT TOP 1 descripcion FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante) AS [Tipo de visitante],
            @precioPesos AS [Precio en Pesos (ARS)],
            @cotizacionDolar AS [Cotización Dólar Oficial],
            @precioDolares AS [Precio Final (USD)];
    END
    ELSE
    BEGIN
        PRINT 'Error al parsear la respuesta de la API.';
    END
END;
GO


CREATE OR ALTER PROCEDURE Ventas.listarPreciosParqueEnPesosYDolares
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url VARCHAR(255) = 'https://dolarapi.com/v1/dolares/oficial';
    DECLARE @objHttp INT;
    DECLARE @respuesta VARCHAR(8000);
    DECLARE @cotizacionDolar DECIMAL(10,2);
    DECLARE @posVenta INT;

    EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @objHttp OUT;
    EXEC sp_OAMethod @objHttp, 'open', NULL, 'GET', @url, false;
    EXEC sp_OAMethod @objHttp, 'send', NULL, NULL;
    EXEC sp_OAMethod @objHttp, 'responseText', @respuesta OUT;
    EXEC sp_OADestroy @objHttp;

    SET @posVenta = CHARINDEX('"venta":', @respuesta);
    
    IF @posVenta > 0
    BEGIN
        DECLARE @tempStr VARCHAR(50);
        SET @tempStr = SUBSTRING(@respuesta, @posVenta + 8, 20);
        SET @tempStr = SUBSTRING(@tempStr, 1, CHARINDEX(',', @tempStr) - 1);
        SET @cotizacionDolar = CAST(@tempStr AS DECIMAL(10,2));
    END

    -- control de error por si la API falla o no devuelve datos
    IF @cotizacionDolar IS NULL OR @cotizacionDolar = 0
    BEGIN
        ;THROW  60004, 'No se pudo obtener la cotización del dólar desde la API.', 1;
    END

    SELECT p.nombre AS [Parque], tv.descripcion AS [Tipo de visitante], pp.fechaDesde, pp.precio AS [Precio en pesos], @cotizacionDolar AS [Cotización Dólar Oficial], CAST((pp.precio / @cotizacionDolar) AS DECIMAL(10,2)) AS [Precio en dolares]
    FROM Ventas.preciosParque pp
    INNER JOIN Gestion.parque p ON p.idParque = pp.idParque
    INNER JOIN Ventas.tipoVisitante tv ON tv.idTipoVisitante = pp.idTipoVisitante
    WHERE pp.fechaDesde = (
    SELECT MAX(sub.fechaDesde) FROM Ventas.preciosParque sub WHERE sub.idParque = pp.idParque AND sub.idTipoVisitante = pp.idTipoVisitante AND sub.fechaDesde <= GETDATE());
END;
GO
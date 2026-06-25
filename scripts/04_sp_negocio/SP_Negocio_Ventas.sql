USE GestionParquesNacionales
GO


CREATE OR ALTER PROCEDURE Ventas.procesarVentaIndividual
    @codigoEntrada CHAR(10),
    @idVisitante INT,
    @fechaAcceso DATE,
    @idParque INT,
    @idFormaPago INT,
    @puntoVenta INT,
    @numeroFactura INT,
    @jsonActividades NVARCHAR(400) = NULL -- Recibe todo el carrito de actividades estructurado
AS
BEGIN
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
    
    SELECT @idTipoVisitante = idTipoVisitante FROM Ventas.Visitante WHERE idVisitante = @idVisitante;

    IF @idTipoVisitante IS NOT NULL AND @idParque IS NOT NULL
    BEGIN
        SELECT TOP 1 @total = Precio FROM Ventas.PreciosParque
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
        INNER JOIN Actividades.Actividad actRegistradas ON actRegistradas.idActividad = actAComprar.idActividad

        IF @cantActividadesAComprar <> @cantActividadesEncontradas
            SET @errorMsg = @errorMsg + '- Alguna de las actividades/tours seleccionados no existe.' + @saltoLinea;
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 60001, @errorMsg, 1;
    END

    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @idItemVenta INT = 1;
            DECLARE @idActividad INT;
            DECLARE @costoActividad DECIMAL(10,2);

            EXEC Ventas.venta_Alta
                @idParque = @idParque,
                @numeroFactura = @numeroFactura,
                @puntoVenta = @puntoVenta,
                @total = @total,
                @idVenta = @idVentaGenerado OUTPUT

            EXEC Ventas.entrada_Alta
                @codigoEntrada = @codigoEntrada,
                @idVenta = @idVentaGenerado,
                @fechaAcceso = @fechaAcceso,
                @fechaCompra = NULL, -- se asigna en el sp
                @idVisitante = @idVisitante,
                @idParque = @idParque,
                @idTipoVisitante = @idTipoVisitante,
                @precio = @total

            EXEC Ventas.itemVenta_Alta
                @idVenta = @idVentaGenerado,
                @idItemVenta = @idItemVenta,
                @idTipoVisitante = @idTipoVisitante,
                @idActividad = NULL, -- es null porque es una entrada
                @tipoItem = 'Entrada',
                @cantidad = 1, -- es una venta individual
                @precioUnitario = @total

            

            SET @idItemVenta = 2;

            WHILE EXISTS(SELECT 1 FROM @actividades)
            BEGIN
                

                SELECT TOP 1 @idActividad = actRegistradas.idActividad, @costoActividad = actRegistradas.costo  FROM Actividades.Actividad actRegistradas 
                INNER JOIN @actividades actAComprar ON actAComprar.idActividad = actRegistradas.idActividad ORDER BY actRegistradas.idActividad;

                EXEC Ventas.itemVenta_Alta
                    @idVenta = @idVentaGenerado,
                    @idItemVenta = @idItemVenta,
                    @idTipoVisitante = NULL,
                    @idActividad = @idActividad,
                    @tipoItem = 'Actividad',
                    @cantidad = 1,
                    @precioUnitario = @costoActividad

                EXEC Ventas.entradaActividad_Alta
                    @codigoEntrada = @codigoEntrada,
                    @idActividad = @idActividad

                DELETE FROM @actividades WHERE idActividad = @idActividad; --la borro asi registro la siguiente actividad

                SET @idItemVenta += 1;
            END

            IF @cantActividadesAComprar > 0
            BEGIN
                SET @total = (SELECT SUM(PrecioUnitario) FROM Ventas.ItemVenta WHERE idVenta = @idVentaGenerado)

                EXEC Ventas.venta_Modificar 
                @idVenta = @idVentaGenerado,
                @idParque = NULL,
                @numeroFactura = NULL,
                @puntoVenta = NULL,
                @total = @total
            END

            EXEC Ventas.pago_Alta 
                @idVenta = @idVentaGenerado,
                @idFormaPago = @idFormaPago,
                @fecha = NULL, -- se asigna en el sp
                @estado = 'Aprobado',
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
    @jsonCompra NVARCHAR(MAX) -- Recibe todo el carrito estructurado
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);
    
    DECLARE @idVentaGenerado INT;
    DECLARE @totalFactura DECIMAL(10,2) = 0;
    DECLARE @subtotalEntradas DECIMAL(10,2) = 0;
    DECLARE @subtotalActividades DECIMAL(10,2) = 0;
    DECLARE @idItemVenta INT;

    -- variables de los cursores
    DECLARE @idTipoVisitante INT;
    DECLARE @cantidad INT;
    DECLARE @precioUnitario DECIMAL(10,2);

    DECLARE @idActividad INT;

    DECLARE @codigoEntrada CHAR(10);
    DECLARE @idVisitanteCursor INT;
    DECLARE @fechaAccesoCursor DATE;
    DECLARE @idTipoVisitanteCursor INT;
    DECLARE @precioCursor DECIMAL(10,2);

    DECLARE @codigoEntradaAct CHAR(10);
    DECLARE @idActividadAct INT;


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

    DECLARE curEntradas CURSOR FOR
    SELECT
        idTipoVisitante,
        COUNT(*) AS Cantidad,
        AVG(precioCalculado) AS PrecioUnitario
    FROM @entradas
    GROUP BY idTipoVisitante;

    DECLARE curActividades CURSOR FOR
    SELECT
        idActividad,
        COUNT(*) AS Cantidad,
        AVG(precioActividad) AS PrecioUnitario
    FROM @actividades
    GROUP BY idActividad;

    DECLARE curRegistroEntradas CURSOR FOR
    SELECT
        codigoEntrada,
        idVisitante,
        fechaAcceso,
        idTipoVisitante,
        precioCalculado
    FROM @entradas;

    DECLARE curEntradaActividad CURSOR FOR
    SELECT codigoEntrada, idActividad
    FROM @actividades;



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

    UPDATE entAComprar
    SET entAComprar.idTipoVisitante = v.IDTipoVisitante
    FROM @entradas entAComprar
    INNER JOIN Ventas.Visitante v ON entAComprar.idVisitante = v.IDVisitante 

    -- 4. busco los precios de cada entrada y actividad
    UPDATE ent
    SET ent.precioCalculado = ( SELECT TOP 1 pp.Precio FROM Ventas.PreciosParque pp
    WHERE pp.IDParque = @idParque AND pp.IDTipoVisitante = ent.idTipoVisitante AND pp.FechaDesde <= ent.fechaAcceso
    ORDER BY pp.FechaDesde DESC)
    FROM @entradas ent

    UPDATE actAComprar
    SET actAComprar.precioActividad = (SELECT TOP 1 actRegistradas.costo FROM Actividades.actividad actRegistradas WHERE actAComprar.idActividad = actRegistradas.idActividad)
    FROM @actividades actAComprar

    IF EXISTS (SELECT 1 FROM @entradas WHERE idTipoVisitante IS NULL )
        SET @errorMsg += '- Hay visitantes ingresados que no existen.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM @entradas WHERE precioCalculado IS NULL)
        SET @errorMsg += '- No existe precio configurado para alguna entrada.' + @saltoLinea;

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

            EXEC Ventas.venta_Alta
                @idParque = @idParque,
                @numeroFactura = @numeroFactura,
                @puntoVenta = @puntoVenta,
                @total = @totalFactura,
                @idVenta = @idVentaGenerado OUTPUT

            -- Detalle ItemVenta de entradas

            SET @idItemVenta = 1;

            OPEN curEntradas;

            FETCH NEXT FROM curEntradas
            INTO @idTipoVisitante, @cantidad, @precioUnitario;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC Ventas.itemVenta_Alta
                    @idVenta = @idVentaGenerado,
                    @idItemVenta = @idItemVenta,
                    @idTipoVisitante = @idTipoVisitante,
                    @idActividad = NULL,
                    @tipoItem = 'Entrada',
                    @cantidad = @cantidad,
                    @precioUnitario = @precioUnitario

                SET @idItemVenta += 1;

                FETCH NEXT FROM curEntradas
                INTO @idTipoVisitante, @cantidad, @precioUnitario;
            END

            CLOSE curEntradas;
            DEALLOCATE curEntradas;

            -- Detalle ItemVenta de actividades agrupadas (si existen)
            IF EXISTS (SELECT 1 FROM @actividades)
            BEGIN
                OPEN curActividades;

                FETCH NEXT FROM curActividades
                INTO @idActividad, @cantidad, @precioUnitario;

                WHILE @@FETCH_STATUS = 0
                BEGIN

                    EXEC Ventas.itemVenta_Alta
                        @idVenta = @idVentaGenerado,
                        @idItemVenta = @idItemVenta,
                        @idTipoVisitante = NULL,
                        @idActividad = @idActividad,
                        @tipoItem = 'Actividad',
                        @cantidad = @cantidad,
                        @precioUnitario = @precioUnitario;

                    SET @idItemVenta += 1;

                    FETCH NEXT FROM curActividades
                    INTO @idActividad, @cantidad, @precioUnitario;
                END

                CLOSE curActividades;
                DEALLOCATE curActividades;
            END

            OPEN curRegistroEntradas;

            FETCH NEXT FROM curRegistroEntradas
            INTO
                @codigoEntrada,
                @idVisitanteCursor,
                @fechaAccesoCursor,
                @idTipoVisitanteCursor,
                @precioCursor;

            -- Registrar los pases físicos masivos

            WHILE @@FETCH_STATUS = 0
            BEGIN

                EXEC Ventas.entrada_Alta
                    @codigoEntrada = @codigoEntrada,
                    @idVenta = @idVentaGenerado,
                    @fechaAcceso = @fechaAccesoCursor,
                    @fechaCompra = NULL,
                    @idVisitante = @idVisitanteCursor,
                    @idParque = @idParque,
                    @idTipoVisitante = @idTipoVisitanteCursor,
                    @precio = @precioCursor;

                FETCH NEXT FROM curRegistroEntradas
                INTO
                    @codigoEntrada,
                    @idVisitanteCursor,
                    @fechaAccesoCursor,
                    @idTipoVisitanteCursor,
                    @precioCursor;
            END

            CLOSE curRegistroEntradas;
            DEALLOCATE curRegistroEntradas;

            -- Registrar relaciones intermedias N:M de actividades
            IF EXISTS (SELECT 1 FROM @actividades)
            BEGIN
                OPEN curEntradaActividad;

                FETCH NEXT FROM curEntradaActividad
                INTO @codigoEntradaAct, @idActividadAct;

                WHILE @@FETCH_STATUS = 0
                BEGIN

                    EXEC Ventas.entradaActividad_Alta
                        @codigoEntrada = @codigoEntradaAct,
                        @idActividad = @idActividadAct;

                    FETCH NEXT FROM curEntradaActividad
                    INTO @codigoEntradaAct, @idActividadAct;
                END

                CLOSE curEntradaActividad;
                DEALLOCATE curEntradaActividad;
            END

            -- Registrar el pago final unificado

            EXEC Ventas.pago_Alta 
                @idVenta = @idVentaGenerado,
                @idFormaPago = @idFormaPago,
                @fecha = NULL,
                @estado = 'Aprobado',
                @importe = @totalFactura

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF CURSOR_STATUS('local','curEntradas') >= -1
        BEGIN
            CLOSE curEntradas;
            DEALLOCATE curEntradas;
        END

        IF CURSOR_STATUS('local','curActividades') >= -1
        BEGIN
            CLOSE curActividades;
            DEALLOCATE curActividades;
        END

        IF CURSOR_STATUS('local','curRegistroEntradas') >= -1
        BEGIN
            CLOSE curRegistroEntradas;
            DEALLOCATE curRegistroEntradas;
        END

        IF CURSOR_STATUS('local','curEntradaActividad') >= -1
        BEGIN
            CLOSE curEntradaActividad;
            DEALLOCATE curEntradaActividad;
        END

        

        SET @errorMsg = @errorMsg + '- Fallo de la venta masiva.' + @saltoLinea

        ;THROW 60002, @errorMsg,1;
    END CATCH
END
GO
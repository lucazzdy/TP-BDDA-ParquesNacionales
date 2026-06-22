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

    DECLARE @precioEntrada DECIMAL(10,2) = NULL;
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

    IF NOT EXISTS (SELECT 1 FROM Gestion.Parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El Parque ingresado no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.FormaPago WHERE IDFormaPago = @idFormaPago)
        SET @errorMsg = @errorMsg + '- La forma de pago ingresada no existe.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM Ventas.Entrada WHERE CodigoEntrada = @codigoEntrada)
        SEt @errorMsg = @errorMsg + '- El codigo de entrada ya fue asignado.' + @saltoLinea; 
    
    SELECT @idTipoVisitante = IDTipoVisitante FROM Ventas.Visitante WHERE IDVisitante = @idVisitante;

    IF @idTipoVisitante IS NULL
        SET @errorMsg = @errorMsg + '- El visitante especificado no está registrado.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM Ventas.Venta WHERE PuntoVenta = @puntoVenta AND NumeroFactura = @numeroFactura)
        SET @errorMsg = @errorMsg + '- Ya existe una factura registrada con ese punto de venta y número.' + @saltoLinea;

    IF @idTipoVisitante IS NOT NULL AND @idParque IS NOT NULL
    BEGIN
        SELECT TOP 1 @precioEntrada = Precio FROM Ventas.PreciosParque
        WHERE IDParque = @idParque AND IDTipoVisitante = @idTipoVisitante AND FechaDesde <= @fechaAcceso ORDER BY FechaDesde DESC;

        IF @precioEntrada IS NULL
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

            INSERT INTO Ventas.Venta (IDParque, NumeroFactura, PuntoVenta, Total)
            VALUES(@idParque, @numeroFactura, @puntoVenta, @precioEntrada);

            SET @idVentaGenerado = SCOPE_IDENTITY()

            INSERT INTO Ventas.ItemVenta (IDVenta, IDItemVenta, TipoItem, Cantidad, PrecioUnitario)
            VALUES (@idVentaGenerado, @idItemVenta, 'Entrada', 1, @precioEntrada);

            INSERT INTO Ventas.Entrada (CodigoEntrada, FechaAcceso, FechaCompra, IDVisitante, IDParque, IDTipoVisitante, Precio)
            VALUES(@codigoEntrada, @fechaAcceso, GETDATE(), @idVisitante, @idParque, @idTipoVisitante, @precioEntrada);

            SET @idItemVenta = 2;

            WHILE EXISTS(SELECT 1 FROM @actividades)
            BEGIN
                

                SELECT TOP 1 @idActividad = actRegistradas.idActividad, @costoActividad = actRegistradas.costo  FROM Actividades.Actividad actRegistradas 
                INNER JOIN @actividades actAComprar ON actAComprar.idActividad = actRegistradas.idActividad ORDER BY actRegistradas.idActividad;

                INSERT INTO Ventas.ItemVenta (IDVenta, IDItemVenta, TipoItem, Cantidad, PrecioUnitario)
                VALUES (@idVentaGenerado, @idItemVenta, 'Actividad', 1, @costoActividad);

                INSERT INTO Ventas.EntradaActividad (CodigoEntrada, IDActividad)
                VALUES(@codigoEntrada, @idActividad)

                DELETE FROM @actividades WHERE idActividad = @idActividad; --la borro asi registro la siguiente actividad

                SET @idItemVenta += 1;
            END

            IF @cantActividadesAComprar > 0
            BEGIN
                UPDATE Ventas.Venta 
                SET Total = (SELECT SUM(PrecioUnitario) FROM Ventas.ItemVenta WHERE IDVenta = @idVentaGenerado)
                WHERE IDVenta = @idVentaGenerado;
            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END

    SET @errorMsg = @errorMsg + '- Fallo la transaccion de venta de entrada individual.' + @saltoLinea
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
    DECLARE @cantEntradas INT;

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

    IF NOT EXISTS (SELECT 1 FROM Gestion.Parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El parque especificado no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.FormaPago WHERE IDFormaPago = @idFormaPago)
        SET @errorMsg = @errorMsg + '- La forma de pago seleccionada no existe.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM Ventas.Venta WHERE PuntoVenta = @puntoVenta AND NumeroFactura = @numeroFactura)
        SET @errorMsg = @errorMsg + '- Ya existe esa combinación de factura fiscal.' + @saltoLinea;

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

    -- 5. Mas validaciones
    IF EXISTS (SELECT 1 FROM @entradas WHERE idTipoVisitante IS NULL)
        SET @errorMsg = @errorMsg + '- No se encontro alguno de los visitantes ingresados.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM @entradas WHERE fechaAcceso IS NULL)
        SET @errorMsg = @errorMsg + '- No se encontro alguno de las entradas ingresadas.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM @entradas WHERE precioCalculado IS NULL)
        SET @errorMsg = @errorMsg + '- Falta configurar tarifas para alugnos de los tipos de visitante ingresados.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM @actividades WHERE precioActividad IS NULL)
        SET @errorMsg = @errorMsg + '-Alguna de las actividades ingresadas no existe.' + @saltoLinea;

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

            INSERT INTO Ventas.Venta (IDParque, NumeroFactura, PuntoVenta, Total)
            VALUES (@idParque, @numeroFactura, @puntoVenta, @totalFactura);

            SET @idVentaGenerado = SCOPE_IDENTITY(); --obtengo el ultido idVenta generado

            -- Detalle ItemVenta de entradas
            INSERT INTO Ventas.ItemVenta (IDVenta, IDItemVenta, TipoItem, idTipoVisitante, Cantidad, PrecioUnitario)
            SELECT @idVentaGenerado, ROW_NUMBER() OVER (ORDER BY idTipoVisitante), 'Entrada', idTipoVisitante, COUNT(*), AVG(precioCalculado) AS PrecioUnitario 
            FROM @entradas GROUP BY idTipoVisitante;

            SET @cantEntradas = (SELECT COUNT(1) FROM @entradas);

            -- Detalle ItemVenta de actividades agrupadas (si existen)
            IF @subtotalActividades > 0
            BEGIN
                INSERT INTO Ventas.ItemVenta (IDVenta, IDItemVenta, TipoItem, idActividad, Cantidad, PrecioUnitario)
                SELECT @idVentaGenerado, @cantEntradas + ROW_NUMBER() OVER (ORDER BY idActividad), 'Actividad', idActividad, COUNT(1), AVG(precioActividad) AS PrecioUnitario 
                FROM @actividades GROUP BY idActividad;
            END

            -- Registrar los pases físicos masivos
            INSERT INTO Ventas.Entrada (CodigoEntrada, idVenta, FechaAcceso, FechaCompra, IDVisitante, IDParque, IDTipoVisitante, Precio)
            SELECT codigoEntrada, @idVentaGenerado,fechaAcceso, GETDATE(), idVisitante, @idParque, idTipoVisitante, precioCalculado FROM @entradas;

            -- Registrar relaciones intermedias N:M de actividades
            IF EXISTS (SELECT 1 FROM @actividades)
            BEGIN
                INSERT INTO Ventas.EntradaActividad (CodigoEntrada, IDActividad)
                SELECT codigoEntrada, idActividad FROM @actividades;
            END

            -- Registrar el pago final unificado
            INSERT INTO Ventas.Pago (IDVenta, IDFormaPago, Fecha, Estado, Importe)
            VALUES (@idVentaGenerado, @idFormaPago, GETDATE(), 'Aprobado', @totalFactura);

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @errorMsg = @errorMsg + '- Fallo de la venta masiva.' + @saltoLinea

        ;THROW 60002, @errorMsg,1;
    END CATCH
END
GO
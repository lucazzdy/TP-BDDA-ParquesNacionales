/* 
    Script generado el 24/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Seed data del esquema Ventas.
                            
    IMPORTANTE: este seed genera ventas de entrada y/o actividades. 
    Antes de correr este script se deben haber generado la importacion de parques, la seed de visitantes y la seed de actividaes
                                                      
    Incluye:
    - Generacion de precios de parques
    - Generacion de ventas individuales y masivas

*/

USE GestionParquesNacionales_Com5600_Grupo07
GO

IF NOT EXISTS (SELECT 1 FROM Gestion.parque)
BEGIN
    ;THROW 50801, 'No hay parques cargados. Ejecutar primero script_importacion.sql para importar desde SIB.', 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM Ventas.visitante)
BEGIN
    ;THROW 50802, 'No hay visitantes cargados. Ejecutar primero Seed_Ventas_visitantes.sql', 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM Actividades.actividad)
BEGIN
    ;THROW 50801, 'No hay actividades cargadas. Ejecutar primero Seed_Actividades_Actividades.sql', 1;
END
GO


/* ===========================
    ALTA DE PRECIOS DE PARQUE
   ===========================*/

IF NOT EXISTS (SELECT 1 FROM Ventas.preciosParque)
BEGIN
    DECLARE @idParque INT = 1;

    WHILE @idParque <= 51
        BEGIN

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 1,
                @fechaDesde ='2025-01-01',
                @precio = 12000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 2,
                @fechaDesde = '2025-01-01',
                @precio = 9000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 3,
                @fechaDesde = '2025-01-01',
                @precio = 45000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 4,
                @fechaDesde ='2025-01-01',
                @precio = 15000


            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 5,
                @fechaDesde ='2025-01-01',
                @precio = 6000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 6,
                @fechaDesde = '2025-01-01',
                @precio = 7000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 7,
                @fechaDesde ='2025-01-01',
                @precio = 0

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 1,
                @fechaDesde ='2026-01-01',
                @precio = 15000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 2,
                @fechaDesde = '2026-01-01',
                @precio = 12000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 3,
                @fechaDesde = '2026-01-01',
                @precio = 55000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 4,
                @fechaDesde ='2026-01-01',
                @precio = 18000


            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 5,
                @fechaDesde ='2026-01-01',
                @precio = 8000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 6,
                @fechaDesde = '2026-01-01',
                @precio = 9000

            EXEC Ventas.preciosParque_Alta 
                @idParque = @idParque,
                @idTipoVisitante = 7,
                @fechaDesde ='2026-01-01',
                @precio = 0

            SET @idParque += 1;

        END
END
GO

/* ===========================
    ALTA DE VENTAS
   ===========================*/

IF NOT EXISTS (SELECT 1 FROM Ventas.venta)
BEGIN
    DECLARE @i INT = 1;
    DECLARE @codigoEntrada CHAR(10);
    DECLARE @idVisitante INT;
    DECLARE @idParque INT;
    DECLARE @idTipoVisitante INT;
    DECLARE @idFormaPago INT;
    DECLARE @fechaAcceso DATE;
    DECLARE @puntoVenta INT;
    DECLARE @numeroFactura INT;
    DECLARE @tipoFactura CHAR(1);
    DECLARE @estadoPago VARCHAR(9);
    DECLARE @rnd INT;
    DECLARE @json NVARCHAR(400);


    WHILE @i <= 1000
    BEGIN

        -- Visitante aleatorio

        SELECT TOP 1 
            @idParque = IDParque, 
            @idTipoVisitante = IDTipoVisitante 
        FROM Ventas.preciosParque 
        ORDER BY NEWID();

        -- Luego busco un visitante que tenga ese @idTipoVisitante
        SELECT TOP 1 @idVisitante = idVisitante 
        FROM Ventas.visitante 
        WHERE idTipoVisitante = @idTipoVisitante
        ORDER BY NEWID();

        -- Forma pago

        SELECT TOP 1 @idFormaPago = idFormaPago FROM Ventas.formaPago ORDER BY NEWID();

        -- Fecha acceso

        SET @fechaAcceso = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2026-06-01');

        -- Factura

        SET @puntoVenta = 1 + ABS(CHECKSUM(NEWID())) % 5;

        SET @numeroFactura = 500000 + @i;

        -- Codigo entrada

        SET @codigoEntrada = CONCAT(CHAR(65 + ABS(CHECKSUM(NEWID())) % 26), '-', RIGHT('000000' + CAST(@i AS VARCHAR(6)),6), '-', CHAR(65 + ABS(CHECKSUM(NEWID())) % 26));

        -- estado de pago

        SET @rnd = ABS(CHECKSUM(NEWID())) % 100 + 1;

        IF @rnd <= 70
            SET @estadoPago = 'Aprobado';
        ELSE
            SET @estadoPago = 'Pendiente';

        
        -- tipo de factura

        SET @rnd = ABS(CHECKSUM(NEWID())) % 100 + 1;

        SET @tipoFactura = 
        CASE
            WHEN @rnd < 20 THEN 'A' -- 20% son A
            WHEN @rnd < 95 THEN 'B' -- 75% son B
            ELSE 'C'                -- 5%  son C
        END

        -- Actividades JSON
        -- algunas ventas sin actividades

        IF ABS(CHECKSUM(NEWID())) % 100 < 40
        BEGIN

            SET @json = NULL;

        END
        ELSE
        BEGIN

            SET @json =
            (
                SELECT TOP( 1 + ABS(CHECKSUM(NEWID())) % 3) idActividad FROM Actividades.actividad
                ORDER BY NEWID() FOR JSON PATH
            );

        END



        EXEC Ventas.procesarVentaIndividual
            @codigoEntrada = @codigoEntrada,
            @idVisitante = @idVisitante,
            @fechaAcceso = @fechaAcceso,
            @idParque = @idParque,
            @idFormaPago = @idFormaPago,
            @puntoVenta = @puntoVenta,
            @numeroFactura = @numeroFactura,
            @tipoFactura = @tipoFactura,
            @estadoPago = @estadoPago,
            @jsonActividades = @json;


        SET @i += 1;

    END
END;
GO

SELECT * FROM Ventas.preciosParque;
SELECT * FROM Ventas.pago;
SELECT * FROM Ventas.ticketFactura;
SELECT * FROM Ventas.venta;
SELECT * FROM Ventas.itemVenta ORDER BY idVenta ASC, idItemVenta ASC;
SELECT * FROM Ventas.entrada;
SELECT * FROM Ventas.entradaActividad;
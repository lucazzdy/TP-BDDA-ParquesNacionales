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

DECLARE @idParque INT = 1;

WHILE @idParque <= 51
BEGIN

    INSERT INTO Ventas.preciosParque
    (
        idParque,
        idTipoVisitante,
        fechaDesde,
        precio
    )
    VALUES
    (@idParque,1,'2025-01-01',12000),
    (@idParque,2,'2025-01-01',9000),
    (@idParque,3,'2025-01-01',15000),
    (@idParque,4,'2025-01-01',45000),
    (@idParque,5,'2025-01-01',6000),
    (@idParque,6,'2025-01-01',7000),
    (@idParque,7,'2025-01-01',0),

    (@idParque,1,'2026-01-01',15000),
    (@idParque,2,'2026-01-01',12000),
    (@idParque,3,'2026-01-01',18000),
    (@idParque,4,'2026-01-01',55000),
    (@idParque,5,'2026-01-01',8000),
    (@idParque,6,'2026-01-01',9000),
    (@idParque,7,'2026-01-01',0);

    SET @idParque += 1;

END


DECLARE @i INT = 1;
DECLARE @codigoEntrada CHAR(10);
DECLARE @idVisitante INT;
DECLARE @idFormaPago INT;
DECLARE @fechaAcceso DATE;
DECLARE @puntoVenta INT;
DECLARE @numeroFactura INT;
DECLARE @json NVARCHAR(400);


WHILE @i <= 1000
BEGIN

    -- Visitante aleatorio

    SELECT TOP 1
        @idVisitante = idVisitante
    FROM Ventas.visitante
    ORDER BY NEWID();

    -- Parque aleatorio

    SELECT TOP 1
        @idParque = idParque
    FROM Gestion.parque
    ORDER BY NEWID();

    -- Forma pago

    SET @idFormaPago =
        1 + ABS(CHECKSUM(NEWID())) % 5;


    -- Fecha acceso

    SET @fechaAcceso =
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2026-01-01');

    -- Factura

    SET @puntoVenta =
        1 + ABS(CHECKSUM(NEWID())) % 5;


    SET @numeroFactura =
        500000 + @i;


    -- Codigo entrada

    SET @codigoEntrada =  CHAR(65 + ABS(CHECKSUM(NEWID())) % 26) + '-' + RIGHT('000000' + CAST(@i AS VARCHAR(6)),6)+ '-' + CHAR(65 + ABS(CHECKSUM(NEWID())) % 26);



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
        @jsonActividades = @json;


    SET @i += 1;

END
GO

-- lo mismo pero con venta masiva

DECLARE @i INT = 1;
DECLARE @cantidadVentas INT = 100;

DECLARE @jsonCompra NVARCHAR(MAX);
DECLARE @numeroFactura INT;
DECLARE @idParque INT;
DECLARE @idFormaPago INT;

WHILE @i <= @cantidadVentas
BEGIN

    SET @idParque = (ABS(CHECKSUM(NEWID())) % 50) + 1;
    SET @idFormaPago = (ABS(CHECKSUM(NEWID())) % 4) + 1;

    SET @numeroFactura = ABS(CHECKSUM(NEWID())) % 900000 + 100000;


    ;WITH Entradas AS
    (
        SELECT TOP ((ABS(CHECKSUM(NEWID())) % 5) + 1)
            ROW_NUMBER() OVER(ORDER BY NEWID()) AS nro,
            'A-' +
            RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR(6)),6)
            + '-' +
            CHAR(65 + ABS(CHECKSUM(NEWID())) % 26) AS codigoEntrada,

            (ABS(CHECKSUM(NEWID())) % 20) + 1 AS idVisitante,

            CAST(
                DATEADD(
                    DAY,
                    -(ABS(CHECKSUM(NEWID())) % 365),
                    GETDATE()
                ) AS DATE
            ) AS fechaAcceso
        FROM sys.objects
    ),
    Actividades AS
    (
        SELECT TOP ((ABS(CHECKSUM(NEWID())) % 5))
            E.codigoEntrada,
            (ABS(CHECKSUM(NEWID())) % 10) + 1 AS idActividad
        FROM Entradas E
        CROSS APPLY (
            SELECT 1 AS x
        ) X
    )
    SELECT @jsonCompra =
    (
        SELECT
            (
                SELECT 
                    codigoEntrada,
                    idVisitante,
                    fechaAcceso
                FROM Entradas
                FOR JSON PATH
            ) AS entradas,

            (
                SELECT
                    codigoEntrada,
                    idActividad
                FROM Actividades
                FOR JSON PATH
            ) AS actividades

        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );


    EXEC Ventas.procesarVentaMasiva
        @idParque = @idParque,
        @idFormaPago = @idFormaPago,
        @puntoVenta = 1,
        @numeroFactura = @numeroFactura,
        @jsonCompra = @jsonCompra;


    SET @i += 1;
END
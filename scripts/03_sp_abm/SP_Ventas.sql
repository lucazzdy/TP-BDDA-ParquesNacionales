/* 
    Script generado el 

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Stored procedures ABM del esquema Ventas
*/

USE GestionParquesNacionales;
GO

--SP ABM de Ventas.TipoVisitante ALTA

CREATE OR ALTER PROCEDURE  Ventas.TipoVisitante_Alta
    @descripcion VARCHAR(20)
AS
BEGIN
    DECLARE @errorMsg VARCHAR (100) = '';

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errorMsg = '- Debe ingresar una descripción.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 from Ventas.TipoVisitante WHERE Descripcion = @descripcion)
        SET @errorMsg =  @errorMsg + '- Ya existe el tipo de visitante: ' + @descripcion

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5400, @errorMsg, 1;
    END


    INSERT INTO Ventas.TipoVisitante (Descripcion)
    VALUES (@descripcion)
END
GO

--SP ABM de Ventas.TipoVisitante Modificacion

CREATE OR ALTER PROCEDURE Ventas.TipoVisitante_Modificar
    @idTipoVisitante INT,
    @nuevaDescripcion VARCHAR (20)
AS
BEGIN
    DECLARE @errorMsg VARCHAR (100) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE IDTipoVisitante = @idTipoVisitante)
        SET @errorMsg = '- No existe un tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10))

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5401, @errorMsg, 1;
    END

    UPDATE Ventas.TipoVisitante 
    SET Descripcion = @nuevaDescripcion
    WHERE IDTipoVisitante = @idTipoVisitante;
END
GO

--SP ABM de Ventas.TipoVisitante Baja

CREATE OR ALTER PROCEDURE Ventas.TipoVisitante_Baja
    @idTipoVisitante INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR (200) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10); 

    --valido si el tipo de visitante existe
    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE IDTipoVisitante = @idTipoVisitante)
        SET @errorMsg = '- El tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10)) + ' especificado no existe.' + @saltoLinea;

    --valido si el tipo de visitante esta en algun precio de un parque
    IF EXISTS (SELECT 1 FROM Ventas.PreciosParque WHERE IDTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- No se puede eliminar el tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10)) 
        + ', porque tiene precios asociados en parques.' + @saltoLinea;

    --valido si el tipo de visitante esta en algun visitante
    IF EXISTS (SELECT 1 FROM Ventas.Visitante WHERE IDTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- No se puede eliminar el tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10)) 
        + ', porque existen visitantes registrados con ese tipo.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5402, @errorMsg, 1;
    END

    --Si pasa todo, borro el tipo de visitante
    DELETE FROM ventas.TipoVisitante WHERE IDTipoVisitante = @idTipoVisitante;
END
GO

--SP ABM de Ventas.Visitante Alta

CREATE OR ALTER PROCEDURE Ventas.Visitante_Alta
    @idTipoVisitante INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @fechaNacimiento DATE,
    @tipoDocumento VARCHAR (20),
    @numeroDocumento INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR (300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE IDTipoVisitante = @idTipoVisitante)
        SET @errorMsg = '- No existe un tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10)) + @saltoLinea


    IF @nombre IS NULL OR TRIM(@nombre) = ''
        SET @errorMsg = @errorMsg + '- Debe ingresar un nombre.' + @saltoLinea


    IF @apellido IS NULL OR TRIM(@apellido) = '' 
        SET @errorMsg = @errorMsg + '- Debe ingresar un apellido.' + @saltoLinea


    IF @fechaNacimiento IS NULL OR @fechaNacimiento > GETDATE()
        SET @errorMsg = @errorMsg + '- Fecha de nacimiento invalida.' + @saltoLinea


    IF @tipoDocumento IS NULL OR TRIM(@tipoDocumento) = ''
        SET @errorMsg = @errorMsg + '- Debe ingresar el tipo de documento.' + @saltoLinea


    IF @numeroDocumento IS NULL OR @numeroDocumento <= 0  
        SET @errorMsg = @errorMsg + '- Numero de documento inválido.' + @saltoLinea

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5403, @errorMsg, 1;
    END

    INSERT INTO Ventas.Visitante (IDTipoVisitante, Nombre, Apellido, FechaNacimiento, TipoDocumento, NumeroDocumento)
    VALUES (@idTipoVisitante, TRIM(@nombre), TRIM(@apellido), @fechaNacimiento, TRIM(@tipoDocumento), @numeroDocumento);
END
GO

--SP ABM de Ventas.Visitante Modificar
CREATE OR ALTER PROCEDURE Ventas.Visitante_Modificar
    @idVisitante INT,
    @idTipoVisitante INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @fechaNacimiento DATE,
    @tipoDocumento VARCHAR (20),
    @numeroDocumento INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10); 

    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE IDVisitante = @idVisitante)
        SET @errorMsg = @errorMsg + '- No existe un visitante con id = ' + CAST(@idVisitante AS VARCHAR(10)) + @saltoLinea;

    IF @idTipoVisitante IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE IDTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- No existe un tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10))  + @saltoLinea;


    IF @nombre IS NOT NULL AND TRIM(@nombre) = ''
        SET @errorMsg = @errorMsg + '- Debe ingresar un nombre.' + @saltoLinea


    IF @apellido IS NOT NULL AND TRIM(@apellido) = '' 
        SET @errorMsg = @errorMsg + '- Debe ingresar un apellido.' + @saltoLinea


    IF @fechaNacimiento IS NOT NULL AND @fechaNacimiento > GETDATE()
        SET @errorMsg = @errorMsg + '- Fecha de nacimiento invalida.' + @saltoLinea


    IF @tipoDocumento IS NOT NULL AND TRIM(@tipoDocumento) = '' 
        SET @errorMsg = @errorMsg + '- Debe ingresar el tipo de documento.' + @saltoLinea


    IF @numeroDocumento IS NOT NULL AND @numeroDocumento <= 0  
        SET @errorMsg = @errorMsg + '- Numero de documento inválido.' + @saltoLinea

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5403, @errorMsg, 1;
    END

    UPDATE Ventas.Visitante 
    SET IDTipoVisitante = ISNULL(@idTipoVisitante, IDTipoVisitante),
        Nombre = ISNULL(TRIM(@nombre), Nombre),
        Apellido = ISNULL(TRIM(@apellido), Apellido),
        FechaNacimiento = ISNULL(@fechaNacimiento, FechaNacimiento),
        TipoDocumento = ISNULL(TRIM(@tipoDocumento), TipoDocumento),
        NumeroDocumento = ISNULL(@numeroDocumento, NumeroDocumento)
    WHERE IDVisitante = @idVisitante;
END
GO

--SP ABM de Ventas.Visitante Baja
CREATE OR ALTER PROCEDURE Ventas.Visitante_Baja
    @idVisitante INT
AS
BEGIN  
    DECLARE @errorMsg VARCHAR (100) = ''

    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE IDVisitante = @idVisitante)
    BEGIN
        SET @errorMsg = @errorMsg + '- No existe un visitante con id = ' + CAST(@idVisitante AS VARCHAR(10));
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM Ventas.Entrada WHERE IDVisitante = @idVisitante)
            SET @errorMsg = @errorMsg + '- No se puede borrar el visitante con id = ' + CAST(@idVisitante AS VARCHAR(10)) + ', porque tiene un historial de compras';
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5404, @errorMsg, 1;
    END

    DELETE FROM Ventas.Visitante 
    WHERE IDVisitante = @IDVisitante;
END
GO


--SP ABM de Ventas.FormaPago Alta
CREATE OR ALTER PROCEDURE Ventas.FormaPago_Alta
    @Descripcion VARCHAR(30)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';

    -- valido que la descripción no esté vacia
    IF @Descripcion IS NULL OR TRIM(@Descripcion) = ''
        SET @errorMsg = @errorMsg + '- La descripción de la forma de pago no puede estar vacía. ';

    -- valido que no exista una forma de pago duplicada
    IF EXISTS (SELECT 1 FROM Ventas.FormaPago WHERE Descripcion = @Descripcion)
        SET @errorMsg = @errorMsg + '- La forma de pago ingresada ya está registrada. ';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5404, @errorMsg, 1;
    END

    INSERT INTO Ventas.FormaPago (Descripcion) 
    VALUES (TRIM(@Descripcion));
END
GO

--SP ABM de Ventas.FormaPago Modificar
CREATE OR ALTER PROCEDURE Ventas.FormaPago_Modificar
    @idFormaPago INT,
    @descripcion VARCHAR(30)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    -- Valido existencia del registro
    IF NOT EXISTS (SELECT 1 FROM Ventas.FormaPago WHERE IDFormaPago = @idFormaPago)
        SET @errorMsg = @errorMsg + '- El ID de la forma de pago especificado no existe.' + @saltoLinea;

    -- Valido descripción no vacía
    IF @descripcion IS NULL OR TRIM(@descripcion) = ''
        SET @errorMsg = @errorMsg + '- La nueva descripción no puede estar vacía.' + @saltoLinea;

    -- Valido que el nombre no se repita con el de OTRA forma de pago diferente
    IF EXISTS (SELECT 1 FROM Ventas.FormaPago WHERE Descripcion = @descripcion AND IDFormaPago <> @idFormaPago)
        SET @errorMsg = @errorMsg + '- La descripción ya pertenece a otra forma de pago registrada.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5405, @errorMsg, 1;
    END

    UPDATE Ventas.FormaPago
    SET Descripcion = TRIM(@descripcion)
    WHERE IDFormaPago = @idFormaPago;
END
GO

--SP ABM de Ventas.FormaPago Baja

CREATE OR ALTER PROCEDURE Ventas.FormaPago_Baja
    @idFormaPago INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';

    --Valido que el registro exista
    IF NOT EXISTS (SELECT 1 FROM Ventas.FormaPago WHERE IDFormaPago = @idFormaPago)
    BEGIN
        SET @errorMsg = @errorMsg + '- El ID de la forma de pago especificada no existe.';
    END
    ELSE
    BEGIN
        --Valido que no se use en la tabla Ventas.Pago
        IF EXISTS (SELECT 1 FROM Ventas.Pago WHERE IDFormaPago = @idFormaPago)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la forma de pago porque ya fue utilizada en transacciones comerciales comerciales. ';
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5405, @errorMsg, 1;
    END

    DELETE FROM Ventas.FormaPago 
    WHERE IDFormaPago = @idFormaPago;
END
GO

--SP ABM de Ventas.PreciosParque Alta

CREATE OR ALTER PROCEDURE Ventas.PreciosParque_Alta
    @idParque INT,
    @idTipoVisitante INT,
    @fechaDesde DATE,
    @precio DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200) = '';

    -- Valio existencia del parque
    IF NOT EXISTS (SELECT 1 FROM Gestion.Parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El ID de Parque especificado no existe. ';

    -- Valido existencia del tipo de visitante
    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE IDTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- El ID de Tipo de Visitante no existe. ';

    -- Valido que el precio no sea nulo ni negativo
    IF @precio IS NULL OR @precio < 0
        SET @errorMsg = @errorMsg + '- El precio debe ser un valor mayor o igual a cero. ';

    -- Valido que no exista un precio con la misma clave primaria exacta (Mismo Parque, Tipo y Fecha). Basicamente que no exista un repetido
    IF EXISTS (SELECT 1 FROM Ventas.PreciosParque WHERE IDParque = @idParque AND IDTipoVisitante = @idTipoVisitante AND FechaDesde = @fechaDesde)
        SET @errorMsg = @errorMsg + '- Ya existe una tarifa registrada para ese parque y tipo de visitante en la fecha especificada. ';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5406, @errorMsg, 1;
    END

    INSERT INTO Ventas.PreciosParque (IDParque, IDTipoVisitante, FechaDesde, Precio)
    VALUES (@idParque, @idTipoVisitante, @fechaDesde, @precio);
END
GO

--SP ABM de Ventas.PreciosParque Modificar

CREATE OR ALTER PROCEDURE Ventas.PreciosParque_Modificar
    @idParque INT,
    @idTipoVisitante INT,
    @fechaDesde DATE,
    @nuevoPrecio DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200) = '';

    -- Valido que exista el registro histórico exacto que se quiere modificar
    IF NOT EXISTS (SELECT 1 FROM Ventas.PreciosParque WHERE IDParque = @idParque AND IDTipoVisitante = @idTipoVisitante AND FechaDesde = @fechaDesde)
        SET @errorMsg = @errorMsg + '- No existe una tarifa registrada que coincida con el Parque, Tipo de Visitante y Fecha especificados. ';

    -- Valido el nuevo precio
    IF @nuevoPrecio IS NOT NULL AND @nuevoPrecio < 0
        SET @errorMsg = @errorMsg + '- El nuevo precio debe ser un valor mayor o igual a cero. ';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5407, @errorMsg, 1;
    END

    UPDATE Ventas.PreciosParque
    SET Precio = @nuevoPrecio
    WHERE IDParque = @idParque AND IDTipoVisitante = @idTipoVisitante AND FechaDesde = @fechaDesde;
END
GO

--SP ABM de Ventas.PreciosParque Baja

CREATE OR ALTER PROCEDURE Ventas.PreciosParque_Baja
    @idParque INT,
    @idTipoVisitante INT,
    @fechaDesde DATE
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200) = '';

    -- Valido que el registro exista antes de intentar borrarlo
    IF NOT EXISTS (SELECT 1 FROM Ventas.PreciosParque WHERE IDParque = @idParque AND IDTipoVisitante = @idTipoVisitante AND FechaDesde = @fechaDesde)
    BEGIN
        SET @errorMsg = @errorMsg + '- No se encontró la tarifa histórica que intenta eliminar. ';
    END
    ELSE
    BEGIN
        --Valido que que este precio de parque no fue utilizado en alguna venta
        IF EXISTS (SELECT 1 FROM Ventas.Entrada WHERE IDParque = @idParque AND IDTipoVisitante = @idTipoVisitante AND FechaAcceso >= @fechaDesde)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la tarifa porque existen entradas emitidas en un período que depende de este precio. ';
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5408, @errorMsg, 1;
    END

    DELETE FROM Ventas.PreciosParque
    WHERE IDParque = @idParque AND IDTipoVisitante = @idTipoVisitante AND FechaDesde = @FechaDesde;
END
GO

--SP ABM de Ventas.Venta_Alta

CREATE OR ALTER PROCEDURE Ventas.Venta_Alta
    @idParque INT,
    @numeroFactura INT,
    @puntoVenta INT,
    @total DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);


    IF NOT EXISTS (SELECT 1 FROM Gestion.Parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El ID de Parque especificado no existe.' + @saltoLinea;


    IF @numeroFactura IS NULL OR @numeroFactura <= 0
        SET @errorMsg = @errorMsg + '- El número de factura debe ser mayor a cero.'  + @saltoLinea;

    IF @puntoVenta IS NULL OR @puntoVenta <= 0
        SET @errorMsg = @errorMsg + '- El punto de venta debe ser mayor a cero.'  + @saltoLinea;


    IF @total IS NULL OR @total < 0
        SET @errorMsg = @errorMsg + '- El total de la venta no puede ser un valor negativo.'  + @saltoLinea;


    IF EXISTS (SELECT 1 FROM Ventas.Venta WHERE PuntoVenta = @puntoVenta AND NumeroFactura = @numeroFactura)
        SET @errorMsg = @errorMsg + '- Ya existe un ticket registrado con ese Punto de Venta y Número de Factura.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5409, @errorMsg, 1;
    END

    INSERT INTO Ventas.Venta (IDParque, NumeroFactura, PuntoVenta, Total)
    VALUES (@idParque, @numeroFactura, @puntoVenta, @total);
END
GO

--SP ABM de Ventas.Venta_Modificar

CREATE OR ALTER PROCEDURE Ventas.Venta_Modificar
    @idVenta INT,
    @idParque INT,
    @numeroFactura INT,
    @puntoVenta INT,
    @total DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE IDVenta = @idVenta)
        SET @errorMsg = @errorMsg + '- El ID de Venta especificado no existe.' + @saltoLinea;

    IF @idParque IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Gestion.Parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El ID de Parque especificado no existe.'  + @saltoLinea;

    IF @numeroFactura IS NOT NULL AND @numeroFactura <= 0
        SET @errorMsg = @errorMsg + '- El número de factura debe ser mayor a cero.'  + @saltoLinea;

    IF @puntoVenta IS NOT NULL AND @puntoVenta <= 0
        SET @errorMsg = @errorMsg + '- El punto de venta debe ser mayor a cero.'  + @saltoLinea;

    IF @Total IS NOT NULL AND @Total < 0
        SET @errorMsg = @errorMsg + '- El total no puede ser un valor negativo.'  + @saltoLinea;

    -- Validar que la combinación fiscal no choque con otra venta diferente
    IF EXISTS (SELECT 1 FROM Ventas.Venta WHERE PuntoVenta = @puntoVenta AND NumeroFactura = @numeroFactura AND IDVenta <> @idVenta)
        SET @errorMsg = @errorMsg + '- La combinación de Punto de Venta y Factura ya está asignada a otro ticket.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5410, @errorMsg, 1;
    END

    UPDATE Ventas.Venta
    SET IDParque = ISNULL(@idParque, IDParque),
        NumeroFactura = ISNULL(@numeroFactura, NumeroFactura),
        PuntoVenta = ISNULL(@puntoVenta, PuntoVenta),
        Total = ISNULL(@total, Total)
    WHERE IDVenta = @idVenta;
END
GO

--SP ABM de Ventas.Venta_Baja

CREATE OR ALTER PROCEDURE Ventas.Venta_Baja
    @idVenta INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE IDVenta = @idVenta)
    BEGIN
        SET @errorMsg = @errorMsg + '- El ID de Venta especificado no existe. ';
    END
    ELSE
    BEGIN
        -- valido que no tenga líneas de detalle asociadas en ItemVenta
        IF EXISTS (SELECT 1 FROM Ventas.ItemVenta WHERE IDVenta = @idVenta)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la venta porque contiene ítems de detalle asociados.' + @saltoLinea;
            
        -- Valdo que no tenga pagos asociados
        IF EXISTS (SELECT 1 FROM Ventas.Pago WHERE IDVenta = @idVenta)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la venta porque registra transacciones de pago asociadas.' + @saltoLinea;
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5411, @errorMsg, 1;
    END

    DELETE FROM Ventas.Venta 
    WHERE IDVenta = @idVenta;
END
GO

--SP ABM de Ventas.ItemVenta_Alta

CREATE OR ALTER PROCEDURE Ventas.ItemVenta_Alta
    @idVenta INT,
    @idItemVenta INT,
    @tipoItem VARCHAR(20),
    @cantidad INT,
    @precioUnitario DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE IDVenta = @idVenta)
        SET @errorMsg = @errorMsg + '- El ID de Venta especificado no existe en las cabeceras.' + @saltoLinea;

    IF @idItemVenta IS NULL OR @idItemVenta <= 0
        SET @errorMsg = @errorMsg + '- El ID de Item Venta debe ser mayor a cero.'  + @saltoLinea;

    IF @tipoItem IS NULL OR @tipoItem NOT IN ('Entrada', 'Actividad')
        SET @errorMsg = @errorMsg + '- El tipo de ítem no es válido. Debe ser ''Entrada'' o ''Actividad''.'  + @saltoLinea;

    IF @cantidad IS NULL OR @cantidad <= 0
        SET @errorMsg = @errorMsg + '- La cantidad debe ser un valor mayor a cero.'  + @saltoLinea;

    IF @precioUnitario IS NULL OR @precioUnitario < 0
        SET @errorMsg = @errorMsg + '- El precio unitario no puede ser un valor negativo.'  + @saltoLinea;

    -- Validar duplicidad de la clave primaria compuesta (Misma venta, misma línea)
    IF EXISTS (SELECT 1 FROM Ventas.ItemVenta WHERE IDVenta = @idVenta AND IDItemVenta = @idItemVenta)
        SET @errorMsg = @errorMsg + '- Ya existe una item de venta registrado con ese número para esta venta.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5412, @errorMsg, 1;
    END

    INSERT INTO Ventas.ItemVenta (IDVenta, IDItemVenta, TipoItem, Cantidad, PrecioUnitario)
    VALUES (@idVenta, @idItemVenta, @tipoItem, @cantidad, @precioUnitario);
END
GO

--SP ABM de Ventas.ItemVenta_Modificar

CREATE OR ALTER PROCEDURE Ventas.ItemVenta_Modificar
    @idVenta INT,
    @idItemVenta INT,
    @tipoItem VARCHAR(20),
    @cantidad INT,
    @precioUnitario DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    -- Valdo que exista el idItemVenta de la clave compuesta (idVenta + idItemVenta)
    IF NOT EXISTS (SELECT 1 FROM Ventas.ItemVenta WHERE IDVenta = @idVenta AND IDItemVenta = @idItemVenta)
        SET @errorMsg = @errorMsg + '- No existe la línea de detalle que intenta modificar para la venta especificada.' + @saltoLinea;

    -- Validar el dominio del tipo de ítem
    IF @tipoItem IS NOT NULL AND @tipoItem NOT IN ('Entrada', 'Actividad')
        SET @errorMsg = @errorMsg + '- El tipo de ítem no es válido. Debe ser ''Entrada'' o ''Actividad''.' + @saltoLinea;

    IF @cantidad IS NOT NULL AND @cantidad <= 0
        SET @errorMsg = @errorMsg + '- La cantidad debe ser un valor mayor a cero.'  + @saltoLinea;

    IF @precioUnitario IS NOT NULL AND @precioUnitario < 0
        SET @errorMsg = @errorMsg + '- El precio unitario no puede ser un valor negativo.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5412, @errorMsg, 1;
    END

    UPDATE Ventas.ItemVenta
    SET TipoItem = ISNULL(@tipoItem,TipoItem),
        Cantidad = ISNULL(@cantidad,Cantidad),
        PrecioUnitario = ISNULL(@precioUnitario, PrecioUnitario)
    WHERE IDVenta = @idVenta AND IDItemVenta = @idItemVenta;
END
GO

--SP ABM de Ventas.ItemVenta_Baja

CREATE OR ALTER PROCEDURE Ventas.ItemVenta_Baja
    @idVenta INT,
    @idItemVenta INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.ItemVenta WHERE IDVenta = @idVenta AND IDItemVenta = @idItemVenta)
        SET @errorMsg = @errorMsg + '- No se encontró el item de venta que intenta eliminar para esa venta.';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5413, @errorMsg, 1;
    END

    DELETE FROM Ventas.ItemVenta
    WHERE IDVenta = @idVenta AND IDItemVenta = @idItemVenta;
END
GO

--SP ABM de Ventas.Pago_Alta

CREATE OR ALTER PROCEDURE Ventas.Pago_Alta
    @idVenta INT,
    @idFormaPago INT,
    @fecha DATETIME,
    @estado NVARCHAR(9),
    @importe DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE IDVenta = @idVenta)
        SET @errorMsg = @errorMsg + '- La venta ingresada no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.FormaPago WHERE IDFormaPago = @idFormaPago)
        SET @errorMsg = @errorMsg + '- La forma de pago no existe.' + @saltoLinea;

    IF @estado IS NULL OR TRIM(@estado) = ''
        SET @errorMsg = @errorMsg + '- El estado del pago no puede estar vacío.' + @saltoLinea;

    IF @importe IS NULL OR @importe <= 0
        SET @errorMsg = @errorMsg + '- El importe debe ser mayor a cero.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5414, @errorMsg, 1;
    END

    IF @fecha IS NULL 
        SET @fecha = GETDATE();

    INSERT INTO Ventas.Pago (IDVenta, IDFormaPago, Fecha, Estado, Importe)
    VALUES (@idVenta, @idFormaPago, @fecha, TRIM(@estado), @importe);
END
GO

--SP ABM de Ventas.Pago_Modificar

CREATE OR ALTER PROCEDURE Ventas.Pago_Modificar
    @idPago INT,
    @idVenta INT,
    @idFormaPago INT,
    @fecha DATETIME,
    @estado NVARCHAR(9),
    @importe DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Pago WHERE IDPago = @idPago)
        SET @errorMsg = @errorMsg + '- El ID de pago no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE IDVenta = @idVenta)
        SET @errorMsg = @errorMsg + '- La venta ingresada no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.FormaPago WHERE IDFormaPago = @idFormaPago)
        SET @errorMsg = @errorMsg + '- La forma de pago no existe.' + @saltoLinea;

    IF @estado IS NULL OR TRIM(@estado) = ''
        SET @errorMsg = @errorMsg + '- El estado no puede estar vacío.' + @saltoLinea;

    IF @importe IS NULL OR @importe <= 0
        SET @errorMsg = @errorMsg + '- El importe debe ser mayor a cero.' + @saltoLinea;

    IF @fecha IS NOT NULL AND @fecha > GETDATE()
         SET @errorMsg = @errorMsg + '- La fecha del pago no puede ser despues de la fecha actual.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5415, @errorMsg, 1;
    END

    UPDATE Ventas.Pago
    SET IDVenta = ISNULL(@idVenta,IDVenta),
        IDFormaPago = ISNULL(@idFormaPago, IDFormaPago),
        Fecha =ISNULL(@fecha, Fecha),
        Estado = ISNULL(TRIM(@estado),Estado),
        Importe = ISNULL(@importe,Importe)
    WHERE IDPago = @idPago;
END
GO

--SP ABM de Ventas.Pago_Baja

CREATE OR ALTER PROCEDURE Ventas.Pago_Baja
    @idPago INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Pago WHERE IDPago = @idPago)
        SET @errorMsg = @errorMsg + '- El ID de pago ingresado no existe.';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5416, @errorMsg, 1;
    END

    DELETE FROM Ventas.Pago 
    WHERE IDPago = @idPago;
END
GO

--SP ABM de Ventas.Entrada_Alta

CREATE OR ALTER PROCEDURE Ventas.Entrada_Alta
    @codigoEntrada CHAR(10),
    @fechaAcceso DATE,
    @fechaCompra DATETIME,
    @idVisitante INT,
    @idParque INT,
    @idTipoVisitante INT,
    @precio DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    --valido que cumpla con el formato
    IF @codigoEntrada IS NULL OR @codigoEntrada NOT LIKE '[A-Z]-[0-9][0-9][0-9][0-9][0-9][0-9]-[A-Z]'
        SET @errorMsg = @errorMsg + '- Formato de código de entrada inválido.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM Ventas.Entrada WHERE CodigoEntrada = @codigoEntrada)
        SET @errorMsg = @errorMsg + '- El código de entrada ya se encuentra registrado.' + @saltoLinea;

    IF @fechaAcceso IS NULL
        SET @errorMsg = @errorMsg + '- La fecha de acceso es obligatoria.' + @saltoLinea;

    --valido claves foraneas
    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE IDVisitante = @idVisitante)
        SET @errorMsg = @errorMsg + '- El visitante no existe.'  + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Gestion.Parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El parque no existe. ' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE IDTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- El tipo de visitante no existe.' + @saltoLinea;
    --hasta aca las claves foraneas

    IF @precio IS NULL OR @precio < 0
        SET @errorMsg = @errorMsg + '- El precio no puede ser negativo.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5417, @errorMsg, 1;
    END

    -- Asignar fecha por defecto si viene nula
    IF @fechaCompra IS NULL 
        SET @fechaCompra = GETDATE();

    INSERT INTO Ventas.Entrada (CodigoEntrada, FechaAcceso, FechaCompra, IDVisitante, IDParque, IDTipoVisitante, Precio)
    VALUES (@codigoEntrada, @fechaAcceso, @fechaCompra, @idVisitante, @idParque, @idTipoVisitante, @precio);
END
GO

--SP ABM de Ventas.Entrada_Modificar

CREATE OR ALTER PROCEDURE Ventas.Entrada_Modificar
    @codigoEntrada CHAR(10),
    @fechaAcceso DATE,
    @fechaCompra DATETIME,
    @idVisitante INT,
    @idParque INT,
    @idTipoVisitante INT,
    @precio DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE CodigoEntrada = @codigoEntrada)
        SET @errorMsg = @errorMsg + '- No existe la entrada con el código ingresado.' + @saltoLinea;

    IF @fechaAcceso IS NOT NULL AND @fechaAcceso < GETDATE()
        SET @errorMsg = @errorMsg + '- La fecha de acceso no puede ser anterior a la fecha actual.' + @saltoLinea;

    --valido claves foraneas
    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE IDVisitante = @idVisitante)
        SET @errorMsg = @errorMsg + '- El visitante ingresado no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Gestion.Parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El parque ingresado no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE IDTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- El tipo de visitante ingresado no existe.' + @saltoLinea;
    --hasta aca

    IF @precio IS NOT NULL AND @precio < 0
        SET @errorMsg = @errorMsg + '- El precio no puede ser un valor negativo.' + @saltoLinea;

    IF @fechaCompra IS NOT NULL AND @fechaCompra > GETDATE()
        SET @errorMsg = @errorMsg + '- La fecha de compra no puede ser despues de la fecha actual.'

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5418, @errorMsg, 1;
    END

    UPDATE Ventas.Entrada
    SET FechaAcceso = ISNULL(@fechaAcceso, FechaAcceso),
        FechaCompra = ISNULL(@fechaCompra, FechaCompra),
        IDVisitante = ISNULL(@idVisitante, IDVisitante),
        IDParque = ISNULL(@idParque, IDParque),
        IDTipoVisitante = ISNULL(@idTipoVisitante, IDTipoVisitante),
        Precio = ISNULL(@precio, Precio)
    WHERE CodigoEntrada = @codigoEntrada
END
GO

--SP ABM de Ventas.Entrada_Baja

CREATE OR ALTER PROCEDURE Ventas.Entrada_Baja
    @codigoEntrada CHAR(10)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE CodigoEntrada = @codigoEntrada)
    BEGIN
        SET @errorMsg = @errorMsg + '- El código de entrada especificado no existe.' + @saltoLinea;
    END
    ELSE
    BEGIN
        -- Valido que no este relacionada en EntradaActividad con alguna actividad
        IF EXISTS (SELECT 1 FROM Ventas.EntradaActividad WHERE CodigoEntrada = @codigoEntrada)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la entrada porque tiene actividades/tours vinculados.' + @saltoLinea;
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5419, @errorMsg, 1;
    END

    DELETE FROM Ventas.Entrada 
    WHERE CodigoEntrada = @codigoEntrada;
END
GO

--SP ABM de Ventas.EntradaActividad_Alta

CREATE OR ALTER PROCEDURE Ventas.EntradaActividad_Alta
    @codigoEntrada CHAR(10),
    @idActividad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE CodigoEntrada = @codigoEntrada)
        SET @errorMsg = @errorMsg + '- La entrada especificada no existe.' + @saltoLinea;

    -- Valido existencia de la Actividad 
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividad WHERE idActividad = @idActividad)
        SET @errorMsg = @errorMsg + '- La actividad especificada no existe.' + @saltoLinea;

    -- Valido que no este duplicada
    IF EXISTS (SELECT 1 FROM Ventas.EntradaActividad WHERE CodigoEntrada = @codigoEntrada AND IDActividad = @idActividad)
        SET @errorMsg = @errorMsg + '- Esta actividad ya se encuentra vinculada a la entrada ingresada.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5420, @errorMsg, 1;
    END

    INSERT INTO Ventas.EntradaActividad (CodigoEntrada, IDActividad)
    VALUES (@codigoEntrada, @idActividad);
END
GO

--SP ABM de Ventas.EntradaActividad_Modificar

CREATE OR ALTER PROCEDURE Ventas.EntradaActividad_Modificar
    @codigoEntrada CHAR(10),
    @idActividadActual INT,
    @idActividadNueva INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.EntradaActividad WHERE CodigoEntrada = @codigoEntrada AND IDActividad = @idActividadActual)
        SET @errorMsg = @errorMsg + '- No existe la relación original especificada.' + @saltoLinea;

    -- Valido que exista la nueva actividad
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividad WHERE idActividad = @idActividadNueva)
        SET @errorMsg = @errorMsg + '- La nueva actividad a asignar no existe.' + @saltoLinea;

    -- Validar que la nueva combinación no este duplicada
    IF EXISTS (SELECT 1 FROM Ventas.EntradaActividad WHERE CodigoEntrada = @codigoEntrada AND IDActividad = @idActividadNueva)
        SET @errorMsg = @errorMsg + '- La entrada ya cuenta con esa nueva actividad asignada.';


    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5421, @errorMsg, 1;
    END

    UPDATE Ventas.EntradaActividad
    SET IDActividad = @idActividadNueva
    WHERE CodigoEntrada = @codigoEntrada AND IDActividad = @idActividadActual;
END
GO

--SP ABM de Ventas.EntradaActividad_Baja

CREATE OR ALTER PROCEDURE Ventas.EntradaActividad_Baja
    @codigoEntrada CHAR(10),
    @idActividad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';

    -- Validar existencia del registro compuesto antes de eliminar
    IF NOT EXISTS (SELECT 1 FROM Ventas.EntradaActividad WHERE CodigoEntrada = @codigoEntrada AND IDActividad = @idActividad)
        SET @errorMsg = @errorMsg + '- No existe la relación ingresada.';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5422, @errorMsg, 1;
    END

    DELETE FROM Ventas.EntradaActividad
    WHERE CodigoEntrada = @codigoEntrada AND IDActividad = @idActividad;
END
GO

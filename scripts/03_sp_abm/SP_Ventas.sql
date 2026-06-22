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

--SP ABM de Ventas.tipoVisitante ALTA

CREATE OR ALTER PROCEDURE  Ventas.tipoVisitante_Alta
    @descripcion VARCHAR(20)
AS
BEGIN
    DECLARE @errorMsg VARCHAR (100) = '';

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errorMsg = '- Debe ingresar una descripción.' + CHAR(13) + CHAR(10);

    IF EXISTS (SELECT 1 from Ventas.tipoVisitante WHERE descripcion = @descripcion)
        SET @errorMsg =  @errorMsg + '- Ya existe el tipo de visitante: ' + @descripcion

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50400, @errorMsg, 1;
    END


    INSERT INTO Ventas.tipoVisitante (descripcion)
    VALUES (@descripcion)
END
GO

--SP ABM de Ventas.tipoVisitante Modificacion

CREATE OR ALTER PROCEDURE Ventas.tipoVisitante_Modificar
    @idTipoVisitante INT,
    @nuevaDescripcion VARCHAR (20)
AS
BEGIN
    DECLARE @errorMsg VARCHAR (100) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errorMsg = '- No existe un tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10))

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50401, @errorMsg, 1;
    END

    UPDATE Ventas.tipoVisitante 
    SET descripcion = @nuevaDescripcion
    WHERE idTipoVisitante = @idTipoVisitante;
END
GO

--SP ABM de Ventas.tipoVisitante Baja

CREATE OR ALTER PROCEDURE Ventas.tipoVisitante_Baja
    @idTipoVisitante INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR (200) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10); 

    --valido si el tipo de visitante existe
    IF NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errorMsg = '- El tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10)) + ' especificado no existe.' + @saltoLinea;

    --valido si el tipo de visitante esta en algun precio de un parque
    IF EXISTS (SELECT 1 FROM Ventas.preciosParque WHERE idTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- No se puede eliminar el tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10)) 
        + ', porque tiene precios asociados en parques.' + @saltoLinea;

    --valido si el tipo de visitante esta en algun visitante
    IF EXISTS (SELECT 1 FROM Ventas.visitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- No se puede eliminar el tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10)) 
        + ', porque existen visitantes registrados con ese tipo.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50402, @errorMsg, 1;
    END

    --Si pasa todo, borro el tipo de visitante
    DELETE FROM ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante;
END
GO

--SP ABM de Ventas.visitante Alta

CREATE OR ALTER PROCEDURE Ventas.visitante_Alta
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

    IF NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errorMsg = '- No existe un tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10)) + @saltoLinea


    IF @nombre IS NULL OR TRIM(@nombre) = ''
        SET @errorMsg = @errorMsg + '- Debe ingresar un nombre.' + @saltoLinea


    IF @apellido IS NULL OR TRIM(@apellido) = '' 
        SET @errorMsg = @errorMsg + '- Debe ingresar un apellido.' + @saltoLinea


    IF @fechaNacimiento IS NULL OR @fechaNacimiento > GETDATE()
        SET @errorMsg = @errorMsg + '- fecha de nacimiento invalida.' + @saltoLinea


    IF @tipoDocumento IS NULL OR TRIM(@tipoDocumento) = ''
        SET @errorMsg = @errorMsg + '- Debe ingresar el tipo de documento.' + @saltoLinea


    IF @numeroDocumento IS NULL OR @numeroDocumento <= 0  
        SET @errorMsg = @errorMsg + '- Numero de documento inválido.' + @saltoLinea

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50403, @errorMsg, 1;
    END

    INSERT INTO Ventas.visitante (idTipoVisitante, nombre, apellido, fechaNacimiento, tipoDocumento, numeroDocumento)
    VALUES (@idTipoVisitante, TRIM(@nombre), TRIM(@apellido), @fechaNacimiento, TRIM(@tipoDocumento), @numeroDocumento);
END
GO

--SP ABM de Ventas.visitante Modificar
CREATE OR ALTER PROCEDURE Ventas.visitante_Modificar
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

    IF NOT EXISTS (SELECT 1 FROM Ventas.visitante WHERE idVisitante = @idVisitante)
        SET @errorMsg = @errorMsg + '- No existe un visitante con id = ' + CAST(@idVisitante AS VARCHAR(10)) + @saltoLinea;

    IF @idTipoVisitante IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- No existe un tipo de visitante con id = ' + CAST(@idTipoVisitante AS VARCHAR(10))  + @saltoLinea;


    IF @nombre IS NOT NULL AND TRIM(@nombre) = ''
        SET @errorMsg = @errorMsg + '- Debe ingresar un nombre.' + @saltoLinea


    IF @apellido IS NOT NULL AND TRIM(@apellido) = '' 
        SET @errorMsg = @errorMsg + '- Debe ingresar un apellido.' + @saltoLinea


    IF @fechaNacimiento IS NOT NULL AND @fechaNacimiento > GETDATE()
        SET @errorMsg = @errorMsg + '- fecha de nacimiento invalida.' + @saltoLinea


    IF @tipoDocumento IS NOT NULL AND TRIM(@tipoDocumento) = '' 
        SET @errorMsg = @errorMsg + '- Debe ingresar el tipo de documento.' + @saltoLinea


    IF @numeroDocumento IS NOT NULL AND @numeroDocumento <= 0  
        SET @errorMsg = @errorMsg + '- Numero de documento inválido.' + @saltoLinea

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50404, @errorMsg, 1;
    END

    UPDATE Ventas.visitante 
    SET idTipoVisitante = ISNULL(@idTipoVisitante, idTipoVisitante),
        nombre = ISNULL(TRIM(@nombre), nombre),
        apellido = ISNULL(TRIM(@apellido), apellido),
        fechaNacimiento = ISNULL(@fechaNacimiento, fechaNacimiento),
        tipoDocumento = ISNULL(TRIM(@tipoDocumento), tipoDocumento),
        numeroDocumento = ISNULL(@numeroDocumento, numeroDocumento)
    WHERE idVisitante = @idVisitante;
END
GO

--SP ABM de Ventas.visitante Baja
CREATE OR ALTER PROCEDURE Ventas.visitante_Baja
    @idVisitante INT
AS
BEGIN  
    DECLARE @errorMsg VARCHAR (100) = ''

    IF NOT EXISTS (SELECT 1 FROM Ventas.visitante WHERE idVisitante = @idVisitante)
    BEGIN
        SET @errorMsg = @errorMsg + '- No existe un visitante con id = ' + CAST(@idVisitante AS VARCHAR(10));
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM Ventas.entrada WHERE idVisitante = @idVisitante)
            SET @errorMsg = @errorMsg + '- No se puede borrar el visitante con id = ' + CAST(@idVisitante AS VARCHAR(10)) + ', porque tiene un historial de compras';
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50405, @errorMsg, 1;
    END

    DELETE FROM Ventas.visitante 
    WHERE idVisitante = @idVisitante;
END
GO


--SP ABM de Ventas.formaPago Alta
CREATE OR ALTER PROCEDURE Ventas.formaPago_Alta
    @descripcion VARCHAR(30)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';

    -- valido que la descripción no esté vacia
    IF @descripcion IS NULL OR TRIM(@descripcion) = ''
        SET @errorMsg = @errorMsg + '- La descripción de la forma de pago no puede estar vacía. ';

    -- valido que no exista una forma de pago duplicada
    IF EXISTS (SELECT 1 FROM Ventas.formaPago WHERE descripcion = @descripcion)
        SET @errorMsg = @errorMsg + '- La forma de pago ingresada ya está registrada. ';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50406, @errorMsg, 1;
    END

    INSERT INTO Ventas.formaPago (descripcion) 
    VALUES (TRIM(@descripcion));
END
GO

--SP ABM de Ventas.formaPago Modificar
CREATE OR ALTER PROCEDURE Ventas.formaPago_Modificar
    @idFormaPago INT,
    @descripcion VARCHAR(30)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    -- Valido existencia del registro
    IF NOT EXISTS (SELECT 1 FROM Ventas.formaPago WHERE idFormaPago = @idFormaPago)
        SET @errorMsg = @errorMsg + '- El ID de la forma de pago especificado no existe.' + @saltoLinea;

    -- Valido descripción no vacía
    IF @descripcion IS NULL OR TRIM(@descripcion) = ''
        SET @errorMsg = @errorMsg + '- La nueva descripción no puede estar vacía.' + @saltoLinea;

    -- Valido que el nombre no se repita con el de OTRA forma de pago diferente
    IF EXISTS (SELECT 1 FROM Ventas.formaPago WHERE Descripcion = @descripcion AND idFormaPago <> @idFormaPago)
        SET @errorMsg = @errorMsg + '- La descripción ya pertenece a otra forma de pago registrada.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50407, @errorMsg, 1;
    END

    UPDATE Ventas.formaPago
    SET descripcion = TRIM(@descripcion)
    WHERE idFormaPago = @idFormaPago;
END
GO

--SP ABM de Ventas.formaPago Baja

CREATE OR ALTER PROCEDURE Ventas.formaPago_Baja
    @idFormaPago INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';

    --Valido que el registro exista
    IF NOT EXISTS (SELECT 1 FROM Ventas.formaPago WHERE idFormaPago = @idFormaPago)
    BEGIN
        SET @errorMsg = @errorMsg + '- El ID de la forma de pago especificada no existe.';
    END
    ELSE
    BEGIN
        --Valido que no se use en la tabla Ventas.pago
        IF EXISTS (SELECT 1 FROM Ventas.pago WHERE idFormaPago = @idFormaPago)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la forma de pago porque ya fue utilizada en transacciones comerciales comerciales. ';
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50408, @errorMsg, 1;
    END

    DELETE FROM Ventas.formaPago 
    WHERE idFormaPago = @idFormaPago;
END
GO

--SP ABM de Ventas.preciosParque Alta

CREATE OR ALTER PROCEDURE Ventas.preciosParque_Alta
    @idParque INT,
    @idTipoVisitante INT,
    @fechaDesde DATE,
    @precio DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    -- Valio existencia del parque
    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El ID de Parque especificado no existe.' + @saltoLinea;

    -- Valido existencia del tipo de visitante
    IF NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- El ID de tipo de Visitante no existe.' + @saltoLinea;

    -- Valido que el precio no sea nulo ni negativo
    IF @precio IS NULL OR @precio < 0
        SET @errorMsg = @errorMsg + '- El precio debe ser un valor mayor o igual a cero.' + @saltoLinea;

    -- Valido que no exista un precio con la misma clave primaria exacta (Mismo Parque, tipo y fecha). Basicamente que no exista un repetido
    IF EXISTS (SELECT 1 FROM Ventas.preciosParque WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante AND fechaDesde = @fechaDesde)
        SET @errorMsg = @errorMsg + '- Ya existe una tarifa registrada para ese parque y tipo de visitante en la fecha especificada.';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50409, @errorMsg, 1;
    END

    INSERT INTO Ventas.preciosParque (idParque, idTipoVisitante, fechaDesde, precio)
    VALUES (@idParque, @idTipoVisitante, @fechaDesde, @precio);
END
GO

--SP ABM de Ventas.preciosParque Modificar

CREATE OR ALTER PROCEDURE Ventas.preciosParque_Modificar
    @idParque INT,
    @idTipoVisitante INT,
    @fechaDesde DATE,
    @nuevoprecio DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    -- Valido que exista el registro histórico exacto que se quiere modificar
    IF NOT EXISTS (SELECT 1 FROM Ventas.preciosParque WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante AND fechaDesde = @fechaDesde)
        SET @errorMsg = @errorMsg + '- No existe una tarifa registrada que coincida con el Parque, tipo de Visitante y fecha especificados.' + @saltoLinea;

    -- Valido el nuevo precio
    IF @nuevoprecio IS NOT NULL AND @nuevoprecio < 0
        SET @errorMsg = @errorMsg + '- El nuevo precio debe ser un valor mayor o igual a cero.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50410, @errorMsg, 1;
    END

    UPDATE Ventas.preciosParque
    SET precio = @nuevoprecio
    WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante AND fechaDesde = @fechaDesde;
END
GO

--SP ABM de Ventas.preciosParque Baja

CREATE OR ALTER PROCEDURE Ventas.preciosParque_Baja
    @idParque INT,
    @idTipoVisitante INT,
    @fechaDesde DATE
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200) = '';

    -- Valido que el registro exista antes de intentar borrarlo
    IF NOT EXISTS (SELECT 1 FROM Ventas.preciosParque WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante AND fechaDesde = @fechaDesde)
    BEGIN
        SET @errorMsg = @errorMsg + '- No se encontró la tarifa histórica que intenta eliminar. ';
    END
    ELSE
    BEGIN
        --Valido que que este precio de parque no fue utilizado en alguna venta
        IF EXISTS (SELECT 1 FROM Ventas.entrada WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante AND fechaAcceso >= @fechaDesde)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la tarifa porque existen entradas emitidas en un período que depende de este precio. ';
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50411, @errorMsg, 1;
    END

    DELETE FROM Ventas.preciosParque
    WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante AND fechaDesde = @fechaDesde;
END
GO

--SP ABM de Ventas.venta_Alta

CREATE OR ALTER PROCEDURE Ventas.venta_Alta
    @idParque INT,
    @numeroFactura INT,
    @puntoVenta INT,
    @total DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);


    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El ID de Parque especificado no existe.' + @saltoLinea;


    IF @numeroFactura IS NULL OR @numeroFactura <= 0
        SET @errorMsg = @errorMsg + '- El número de factura debe ser mayor a cero.'  + @saltoLinea;

    IF @puntoVenta IS NULL OR @puntoVenta <= 0
        SET @errorMsg = @errorMsg + '- El punto de venta debe ser mayor a cero.'  + @saltoLinea;


    IF @total IS NULL OR @total < 0
        SET @errorMsg = @errorMsg + '- El total de la venta no puede ser un valor negativo.'  + @saltoLinea;


    IF EXISTS (SELECT 1 FROM Ventas.venta WHERE puntoVenta = @puntoVenta AND numeroFactura = @numeroFactura)
        SET @errorMsg = @errorMsg + '- Ya existe un ticket registrado con ese Punto de Venta y Número de Factura.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50412, @errorMsg, 1;
    END

    INSERT INTO Ventas.venta (idParque, numeroFactura, puntoVenta, total)
    VALUES (@idParque, @numeroFactura, @puntoVenta, @total);
END
GO

--SP ABM de Ventas.venta_Modificar

CREATE OR ALTER PROCEDURE Ventas.venta_Modificar
    @idVenta INT,
    @idParque INT,
    @numeroFactura INT,
    @puntoVenta INT,
    @total DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.venta WHERE idVenta = @idVenta)
        SET @errorMsg = @errorMsg + '- El ID de Venta especificado no existe.' + @saltoLinea;

    IF @idParque IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El ID de Parque especificado no existe.'  + @saltoLinea;

    IF @numeroFactura IS NOT NULL AND @numeroFactura <= 0
        SET @errorMsg = @errorMsg + '- El número de factura debe ser mayor a cero.'  + @saltoLinea;

    IF @puntoVenta IS NOT NULL AND @puntoVenta <= 0
        SET @errorMsg = @errorMsg + '- El punto de venta debe ser mayor a cero.'  + @saltoLinea;

    IF @Total IS NOT NULL AND @Total < 0
        SET @errorMsg = @errorMsg + '- El total no puede ser un valor negativo.'  + @saltoLinea;

    -- Validar que la combinación fiscal no choque con otra venta diferente
    IF EXISTS (SELECT 1 FROM Ventas.venta WHERE puntoVenta = @puntoVenta AND numeroFactura = @numeroFactura AND idVenta <> @idVenta)
        SET @errorMsg = @errorMsg + '- La combinación de Punto de Venta y Factura ya está asignada a otro ticket.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50413, @errorMsg, 1;
    END

    UPDATE Ventas.venta
    SET idParque = ISNULL(@idParque, idParque),
        numeroFactura = ISNULL(@numeroFactura, numeroFactura),
        puntoVenta = ISNULL(@puntoVenta, puntoVenta),
        Total = ISNULL(@total, total)
    WHERE idVenta = @idVenta;
END
GO

--SP ABM de Ventas.venta_Baja

CREATE OR ALTER PROCEDURE Ventas.venta_Baja
    @idVenta INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.venta WHERE idVenta = @idVenta)
    BEGIN
        SET @errorMsg = @errorMsg + '- El ID de Venta especificado no existe. ';
    END
    ELSE
    BEGIN
        -- valido que no tenga líneas de detalle asociadas en ItemVenta
        IF EXISTS (SELECT 1 FROM Ventas.itemVenta WHERE idVenta = @idVenta)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la venta porque contiene ítems de detalle asociados.' + @saltoLinea;
            
        -- Valdo que no tenga pagos asociados
        IF EXISTS (SELECT 1 FROM Ventas.pago WHERE idVenta = @idVenta)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la venta porque registra transacciones de pago asociadas.' + @saltoLinea;
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50414, @errorMsg, 1;
    END

    DELETE FROM Ventas.venta 
    WHERE idVenta = @idVenta;
END
GO

--SP ABM de Ventas.itemVenta_Alta

CREATE OR ALTER PROCEDURE Ventas.itemVenta_Alta
    @idVenta INT,
    @idItemVenta INT,
    @idTipoVisitante INT NULL,
    @idActividad INT NULL,
    @tipoItem VARCHAR(20),
    @cantidad INT,
    @precioUnitario DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.venta WHERE idVenta = @idVenta)
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
    IF EXISTS (SELECT 1 FROM Ventas.itemVenta WHERE idVenta = @idVenta AND idItemVenta = @idItemVenta)
        SET @errorMsg = @errorMsg + '- Ya existe una item de venta registrado con ese número para esta venta.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50415, @errorMsg, 1;
    END

    IF @tipoItem = 'Entrada'
    BEGIN
        INSERT INTO Ventas.itemVenta (idVenta, idItemVenta, idTipoVisitante, idActividad, tipoItem, cantidad, precioUnitario)
        VALUES (@idVenta, @idItemVenta, @idTipoVisitante, NULL, @tipoItem, @cantidad, @precioUnitario);
    END
    ELSE
    BEGIN
        INSERT INTO Ventas.itemVenta (idVenta, idItemVenta, idTipoVisitante, idActividad, tipoItem, cantidad, precioUnitario)
        VALUES (@idVenta, @idItemVenta, NULL, @idActividad, @tipoItem, @cantidad, @precioUnitario);
    END
END
GO

--SP ABM de Ventas.itemVenta_Modificar

CREATE OR ALTER PROCEDURE Ventas.itemVenta_Modificar
    @idVenta INT,
    @idItemVenta INT,
    @idTipoVisitante INT NULL,
    @idActividad INT NULL,
    @tipoItem VARCHAR(20),
    @cantidad INT,
    @precioUnitario DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    -- Valdo que exista el idItemVenta de la clave compuesta (idVenta + idItemVenta)
    IF NOT EXISTS (SELECT 1 FROM Ventas.itemVenta WHERE idVenta = @idVenta AND idItemVenta = @idItemVenta)
        SET @errorMsg = @errorMsg + '- No existe el item de venta que intenta modificar para la venta ingresada.' + @saltoLinea;

    -- Validar el dominio del tipo de ítem

    IF @tipoItem IS NOT NULL
    BEGIN
        IF @tipoItem NOT IN ('Entrada', 'Actividad')
            SET @errorMsg = @errorMsg + '- El tipo de ítem no es válido. Debe ser ''Entrada'' o ''Actividad''.' + @saltoLinea;
        ELSE
        BEGIN
            IF @tipoItem = 'Entrada'
            BEGIN
                SET @idActividad = NULL;

                IF NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
                    SET @errorMsg = @errorMsg + '- Para cambiar el tipo de item a entrada se debe ingresar un tipo de visitante válido.' + @saltoLinea;
            END
            ELSE
            BEGIN
                SET @idTipoVisitante = NULL;

                IF NOT EXISTS (SELECT 1 FROM Actividades.actividad WHERE idActividad = @idActividad)
                    SET @errorMsg = @errorMsg + '- Para cambiar el tipo de item a Actividad se debe ingresar id de actividad válido.' + @saltoLinea;
            END
        END
    END

    IF @cantidad IS NOT NULL AND @cantidad <= 0
        SET @errorMsg = @errorMsg + '- La cantidad debe ser un valor mayor a cero.'  + @saltoLinea;

    IF @precioUnitario IS NOT NULL AND @precioUnitario < 0
        SET @errorMsg = @errorMsg + '- El precio unitario no puede ser un valor negativo.'  + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50416, @errorMsg, 1;
    END

    UPDATE Ventas.itemVenta
    SET idTipoVisitante = @idTipoVisitante,
        idActividad = @idActividad,
        tipoItem = ISNULL(@tipoItem,tipoItem),
        cantidad = ISNULL(@cantidad,cantidad),
        precioUnitario = ISNULL(@precioUnitario, precioUnitario)
    WHERE idVenta = @idVenta AND idItemVenta = @idItemVenta;
END
GO

--SP ABM de Ventas.itemVenta_Baja

CREATE OR ALTER PROCEDURE Ventas.itemVenta_Baja
    @idVenta INT,
    @idItemVenta INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.itemVenta WHERE idVenta = @idVenta AND idItemVenta = @idItemVenta)
        SET @errorMsg = @errorMsg + '- No se encontró el item de venta que intenta eliminar para esa venta.';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50417, @errorMsg, 1;
    END

    DELETE FROM Ventas.itemVenta
    WHERE idVenta = @idVenta AND idItemVenta = @idItemVenta;
END
GO

--SP ABM de Ventas.pago_Alta

CREATE OR ALTER PROCEDURE Ventas.pago_Alta
    @idVenta INT,
    @idFormaPago INT,
    @fecha DATETIME,
    @estado NVARCHAR(9),
    @importe DECIMAL(10,2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.venta WHERE idVenta = @idVenta)
        SET @errorMsg = @errorMsg + '- La venta ingresada no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.formaPago WHERE idFormaPago = @idFormaPago)
        SET @errorMsg = @errorMsg + '- La forma de pago no existe.' + @saltoLinea;

    IF @estado IS NULL OR TRIM(@estado) = ''
        SET @errorMsg = @errorMsg + '- El estado del pago no puede estar vacío.' + @saltoLinea;

    IF @importe IS NULL OR @importe <= 0
        SET @errorMsg = @errorMsg + '- El importe debe ser mayor a cero.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50418, @errorMsg, 1;
    END

    IF @fecha IS NULL 
        SET @fecha = GETDATE();

    INSERT INTO Ventas.pago (idVenta, idFormaPago, fecha, estado, Importe)
    VALUES (@idVenta, @idFormaPago, @fecha, TRIM(@estado), @importe);
END
GO

--SP ABM de Ventas.pago_Modificar

CREATE OR ALTER PROCEDURE Ventas.pago_Modificar
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

    IF NOT EXISTS (SELECT 1 FROM Ventas.pago WHERE idPago = @idPago)
        SET @errorMsg = @errorMsg + '- El ID de pago no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.venta WHERE idVenta = @idVenta)
        SET @errorMsg = @errorMsg + '- La venta ingresada no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.formaPago WHERE idFormaPago = @idFormaPago)
        SET @errorMsg = @errorMsg + '- La forma de pago no existe.' + @saltoLinea;

    IF @estado IS NULL OR TRIM(@estado) = ''
        SET @errorMsg = @errorMsg + '- El estado no puede estar vacío.' + @saltoLinea;

    IF @importe IS NULL OR @importe <= 0
        SET @errorMsg = @errorMsg + '- El importe debe ser mayor a cero.' + @saltoLinea;

    IF @fecha IS NOT NULL AND @fecha > GETDATE()
         SET @errorMsg = @errorMsg + '- La fecha del pago no puede ser despues de la fecha actual.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50419, @errorMsg, 1;
    END

    UPDATE Ventas.pago
    SET idVenta = ISNULL(@idVenta,idVenta),
        idFormaPago = ISNULL(@idFormaPago, idFormaPago),
        fecha =ISNULL(@fecha, fecha),
        estado = ISNULL(TRIM(@estado),estado),
        Importe = ISNULL(@importe,Importe)
    WHERE idPago = @idPago;
END
GO

--SP ABM de Ventas.pago_Baja

CREATE OR ALTER PROCEDURE Ventas.pago_Baja
    @idPago INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.pago WHERE idPago = @idPago)
        SET @errorMsg = @errorMsg + '- El ID de pago ingresado no existe.';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50420, @errorMsg, 1;
    END

    DELETE FROM Ventas.pago 
    WHERE idPago = @idPago;
END
GO

--SP ABM de Ventas.entrada_Alta

CREATE OR ALTER PROCEDURE Ventas.entrada_Alta
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

    IF EXISTS (SELECT 1 FROM Ventas.entrada WHERE codigoEntrada = @codigoEntrada)
        SET @errorMsg = @errorMsg + '- El código de entrada ya se encuentra registrado.' + @saltoLinea;

    IF @fechaAcceso IS NULL
        SET @errorMsg = @errorMsg + '- La fecha de acceso es obligatoria.' + @saltoLinea;

    --valido claves foraneas
    IF NOT EXISTS (SELECT 1 FROM Ventas.visitante WHERE idVisitante = @idVisitante)
        SET @errorMsg = @errorMsg + '- El visitante no existe.'  + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El parque no existe. ' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- El tipo de visitante no existe.' + @saltoLinea;
    --hasta aca las claves foraneas

    IF @precio IS NULL OR @precio < 0
        SET @errorMsg = @errorMsg + '- El precio no puede ser negativo.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50421, @errorMsg, 1;
    END

    -- Asignar fecha por defecto si viene nula
    IF @fechaCompra IS NULL 
        SET @fechaCompra = GETDATE();

    INSERT INTO Ventas.entrada (codigoEntrada, fechaAcceso, fechaCompra, idVisitante, idParque, idTipoVisitante, precio)
    VALUES (@codigoEntrada, @fechaAcceso, @fechaCompra, @idVisitante, @idParque, @idTipoVisitante, @precio);
END
GO

--SP ABM de Ventas.entrada_Modificar

CREATE OR ALTER PROCEDURE Ventas.entrada_Modificar
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

    IF NOT EXISTS (SELECT 1 FROM Ventas.entrada WHERE codigoEntrada = @codigoEntrada)
        SET @errorMsg = @errorMsg + '- No existe la entrada con el código ingresado.' + @saltoLinea;

    IF @fechaAcceso IS NOT NULL AND @fechaAcceso < GETDATE()
        SET @errorMsg = @errorMsg + '- La fecha de acceso no puede ser anterior a la fecha actual.' + @saltoLinea;

    --valido claves foraneas
    IF NOT EXISTS (SELECT 1 FROM Ventas.visitante WHERE idVisitante = @idVisitante)
        SET @errorMsg = @errorMsg + '- El visitante ingresado no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- El parque ingresado no existe.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errorMsg = @errorMsg + '- El tipo de visitante ingresado no existe.' + @saltoLinea;
    --hasta aca

    IF @precio IS NOT NULL AND @precio < 0
        SET @errorMsg = @errorMsg + '- El precio no puede ser un valor negativo.' + @saltoLinea;

    IF @fechaCompra IS NOT NULL AND @fechaCompra > GETDATE()
        SET @errorMsg = @errorMsg + '- La fecha de compra no puede ser despues de la fecha actual.'

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50422, @errorMsg, 1;
    END

    UPDATE Ventas.entrada
    SET fechaAcceso = ISNULL(@fechaAcceso, fechaAcceso),
        fechaCompra = ISNULL(@fechaCompra, fechaCompra),
        idVisitante = ISNULL(@idVisitante, idVisitante),
        idParque = ISNULL(@idParque, idParque),
        idTipoVisitante = ISNULL(@idTipoVisitante, idTipoVisitante),
        precio = ISNULL(@precio, precio)
    WHERE codigoEntrada = @codigoEntrada
END
GO

--SP ABM de Ventas.entrada_Baja

CREATE OR ALTER PROCEDURE Ventas.entrada_Baja
    @codigoEntrada CHAR(10)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.entrada WHERE codigoEntrada = @codigoEntrada)
    BEGIN
        SET @errorMsg = @errorMsg + '- El código de entrada especificado no existe.' + @saltoLinea;
    END
    ELSE
    BEGIN
        -- Valido que no este relacionada en EntradaActividad con alguna actividad
        IF EXISTS (SELECT 1 FROM Ventas.entradaActividad WHERE codigoEntrada = @codigoEntrada)
            SET @errorMsg = @errorMsg + '- No se puede eliminar la entrada porque tiene actividades/tours vinculados.' + @saltoLinea;
    END

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50423, @errorMsg, 1;
    END

    DELETE FROM Ventas.entrada 
    WHERE codigoEntrada = @codigoEntrada;
END
GO

--SP ABM de Ventas.entradaActividad_Alta

CREATE OR ALTER PROCEDURE Ventas.entradaActividad_Alta
    @codigoEntrada CHAR(10),
    @idActividad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.entrada WHERE codigoEntrada = @codigoEntrada)
        SET @errorMsg = @errorMsg + '- La entrada especificada no existe.' + @saltoLinea;

    -- Valido existencia de la Actividad 
    IF NOT EXISTS (SELECT 1 FROM Actividades.actividad WHERE idActividad = @idActividad)
        SET @errorMsg = @errorMsg + '- La actividad especificada no existe.' + @saltoLinea;

    -- Valido que no este duplicada
    IF EXISTS (SELECT 1 FROM Ventas.entradaActividad WHERE codigoEntrada = @codigoEntrada AND idActividad = @idActividad)
        SET @errorMsg = @errorMsg + '- Esta actividad ya se encuentra vinculada a la entrada ingresada.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50424, @errorMsg, 1;
    END

    INSERT INTO Ventas.entradaActividad (codigoEntrada, idActividad)
    VALUES (@codigoEntrada, @idActividad);
END
GO

--SP ABM de Ventas.entradaActividad_Modificar

CREATE OR ALTER PROCEDURE Ventas.entradaActividad_Modificar
    @codigoEntrada CHAR(10),
    @idActividadActual INT,
    @idActividadNueva INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.entradaActividad WHERE codigoEntrada = @codigoEntrada AND idActividad = @idActividadActual)
        SET @errorMsg = @errorMsg + '- No existe la relación original especificada.' + @saltoLinea;

    -- Valido que exista la nueva actividad
    IF NOT EXISTS (SELECT 1 FROM Actividades.actividad WHERE idActividad = @idActividadNueva)
        SET @errorMsg = @errorMsg + '- La nueva actividad a asignar no existe.' + @saltoLinea;

    -- Validar que la nueva combinación no este duplicada
    IF EXISTS (SELECT 1 FROM Ventas.entradaActividad WHERE codigoEntrada = @codigoEntrada AND idActividad = @idActividadNueva)
        SET @errorMsg = @errorMsg + '- La entrada ya cuenta con esa nueva actividad asignada.';


    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50425, @errorMsg, 1;
    END

    UPDATE Ventas.entradaActividad
    SET idActividad = @idActividadNueva
    WHERE codigoEntrada = @codigoEntrada AND idActividad = @idActividadActual;
END
GO

--SP ABM de Ventas.entradaActividad_Baja

CREATE OR ALTER PROCEDURE Ventas.entradaActividad_Baja
    @codigoEntrada CHAR(10),
    @idActividad INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(300) = '';

    -- Validar existencia del registro compuesto antes de eliminar
    IF NOT EXISTS (SELECT 1 FROM Ventas.entradaActividad WHERE codigoEntrada = @codigoEntrada AND idActividad = @idActividad)
        SET @errorMsg = @errorMsg + '- No existe la relación ingresada.';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50426, @errorMsg, 1;
    END

    DELETE FROM Ventas.entradaActividad
    WHERE codigoEntrada = @codigoEntrada AND idActividad = @idActividad;
END
GO

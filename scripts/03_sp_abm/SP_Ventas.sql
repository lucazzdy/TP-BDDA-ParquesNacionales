/* 
    Script generado el 

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: 
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(200) = '';

    -- Valido que exista el registro histórico exacto que se quiere modificar
    IF NOT EXISTS (SELECT 1 FROM Ventas.PreciosParque WHERE IDParque = @idParque AND IDTipoVisitante = @idTipoVisitante AND FechaDesde = @fechaDesde)
        SET @errorMsg = @errorMsg + '- No existe una tarifa registrada que coincida con el Parque, Tipo de Visitante y Fecha especificados. ';

    -- Valido el nuevo precio
    IF @nuevoPrecio IS NULL OR @nuevoPrecio < 0
        SET @errorMsg = @errorMsg + '- El nuevo precio debe ser un valor mayor o igual a cero. ';

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 5407, @errorMsg, 1;
    END

    UPDATE Ventas.PreciosParque
    SET Precio = @nuevoPrecio
    WHERE IDParque = @idParque AND IDTipoVisitante = @idTipoVisitante AND FechaDesde = @fechaDesde;

    PRINT 'Tarifa histórica modificada exitosamente.';
END
GO

--SP ABM de Ventas.PreciosParque Baja

CREATE OR ALTER PROCEDURE Ventas.PreciosParque_Baja
    @idParque INT,
    @idTipoVisitante INT,
    @fechaDesde DATE
AS
BEGIN
    SET NOCOUNT ON;
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


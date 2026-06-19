/* 
    Script generado el 18/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures ABM del esquema Concesiones (TipoConcesion, Empresa, Concesion, PagoCanon).
*/

USE GestionParquesNacionales;
GO


-- ALTA TIPO CONCESION

CREATE OR ALTER PROCEDURE Concesiones.tipoConcesion_Alta
    @descripcion VARCHAR(100)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
    BEGIN
        RAISERROR('La descripcion del tipo de concesion es obligatoria.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE descripcion = @descripcion)
    BEGIN
        SET @errorMsg = 'Ya existe un tipo de concesion con la descripcion: ' + @descripcion;
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    INSERT INTO Concesiones.tipoConcesion (descripcion)
    VALUES (@descripcion);
END
GO



-- MODIFICAR TIPO CONCESION

CREATE OR ALTER PROCEDURE Concesiones.tipoConcesion_Modificar
    @idTipoConcesion INT,
    @descripcion VARCHAR(100)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE idTipoConcesion = @idTipoConcesion)
    BEGIN
        SET @errorMsg = 'No existe un tipo de concesion con id: ' + CAST(@idTipoConcesion AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
    BEGIN
        RAISERROR('La descripcion no puede estar vacia.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Concesiones.tipoConcesion 
               WHERE descripcion = @descripcion AND idTipoConcesion <> @idTipoConcesion)
    BEGIN
        SET @errorMsg = 'Ya existe otro tipo de concesion con la descripcion: ' + @descripcion;
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    UPDATE Concesiones.tipoConcesion
    SET descripcion = @descripcion
    WHERE idTipoConcesion = @idTipoConcesion;
END
GO



-- BAJA TIPO CONCESION

CREATE OR ALTER PROCEDURE Concesiones.tipoConcesion_Baja
    @idTipoConcesion INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE idTipoConcesion = @idTipoConcesion)
    BEGIN
        SET @errorMsg = 'No existe un tipo de concesion con id: ' + CAST(@idTipoConcesion AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idTipoConcesion = @idTipoConcesion)
    BEGIN
        RAISERROR('No se puede eliminar: existen concesiones asociadas a este tipo.', 16, 1);
        RETURN;
    END

    DELETE FROM Concesiones.tipoConcesion
    WHERE idTipoConcesion = @idTipoConcesion;
END
GO



-- ALTA EMPRESA

CREATE OR ALTER PROCEDURE Concesiones.empresa_Alta
    @nombre VARCHAR(100)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('El nombre de la empresa es obligatorio.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Concesiones.empresa WHERE nombre = @nombre)
    BEGIN
        SET @errorMsg = 'Ya existe una empresa con el nombre: ' + @nombre;
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    INSERT INTO Concesiones.empresa (nombre)
    VALUES (@nombre);
END
GO



-- MODIFICAR EMPRESA

CREATE OR ALTER PROCEDURE Concesiones.empresa_Modificar
    @idEmpresa INT,
    @nombre VARCHAR(100)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.empresa WHERE idEmpresa = @idEmpresa)
    BEGIN
        SET @errorMsg = 'No existe una empresa con id: ' + CAST(@idEmpresa AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('El nombre no puede estar vacio.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Concesiones.empresa 
               WHERE nombre = @nombre AND idEmpresa <> @idEmpresa)
    BEGIN
        SET @errorMsg = 'Ya existe otra empresa con el nombre: ' + @nombre;
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    UPDATE Concesiones.empresa
    SET nombre = @nombre
    WHERE idEmpresa = @idEmpresa;
END
GO



-- BAJA EMPRESA

CREATE OR ALTER PROCEDURE Concesiones.empresa_Baja
    @idEmpresa INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.empresa WHERE idEmpresa = @idEmpresa)
    BEGIN
        SET @errorMsg = 'No existe una empresa con id: ' + CAST(@idEmpresa AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idEmpresa = @idEmpresa)
    BEGIN
        RAISERROR('No se puede eliminar: la empresa tiene concesiones asociadas.', 16, 1);
        RETURN;
    END

    DELETE FROM Concesiones.empresa
    WHERE idEmpresa = @idEmpresa;
END
GO


-- ALTA CONCESION


CREATE OR ALTER PROCEDURE Concesiones.concesion_Alta
    @idEmpresa INT,
    @idParque INT,
    @idTipoConcesion INT,
    @fechaInicio DATE,
    @fechaFin DATE,
    @montoCanonMensual DECIMAL(12, 2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.empresa WHERE idEmpresa = @idEmpresa)
    BEGIN
        SET @errorMsg = 'No existe una empresa con id: ' + CAST(@idEmpresa AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
    BEGIN
        SET @errorMsg = 'No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE idTipoConcesion = @idTipoConcesion)
    BEGIN
        SET @errorMsg = 'No existe un tipo de concesion con id: ' + CAST(@idTipoConcesion AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @fechaInicio IS NULL OR @fechaFin IS NULL
    BEGIN
        RAISERROR('Las fechas de inicio y fin son obligatorias.', 16, 1);
        RETURN;
    END

    IF @fechaFin <= @fechaInicio
    BEGIN
        RAISERROR('La fecha de fin debe ser posterior a la fecha de inicio.', 16, 1);
        RETURN;
    END

    IF @montoCanonMensual IS NULL OR @montoCanonMensual <= 0
    BEGIN
        RAISERROR('El monto del canon mensual debe ser mayor a 0.', 16, 1);
        RETURN;
    END

    INSERT INTO Concesiones.concesion (idEmpresa, idParque, idTipoConcesion, fechaInicio, fechaFin, montoCanonMensual)
    VALUES (@idEmpresa, @idParque, @idTipoConcesion, @fechaInicio, @fechaFin, @montoCanonMensual);
END
GO



-- MODIFICAR CONCESION

CREATE OR ALTER PROCEDURE Concesiones.concesion_Modificar
    @idConcesion INT,
    @idEmpresa INT = NULL,
    @idParque INT = NULL,
    @idTipoConcesion INT = NULL,
    @fechaInicio DATE = NULL,
    @fechaFin DATE = NULL,
    @montoCanonMensual DECIMAL(12, 2) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);
    DECLARE @fechaInicioFinal DATE, @fechaFinFinal DATE;

    IF NOT EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idConcesion = @idConcesion)
    BEGIN
        SET @errorMsg = 'No existe una concesion con id: ' + CAST(@idConcesion AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @idEmpresa IS NOT NULL 
       AND NOT EXISTS (SELECT 1 FROM Concesiones.empresa WHERE idEmpresa = @idEmpresa)
    BEGIN
        SET @errorMsg = 'No existe una empresa con id: ' + CAST(@idEmpresa AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @idParque IS NOT NULL 
       AND NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
    BEGIN
        SET @errorMsg = 'No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @idTipoConcesion IS NOT NULL 
       AND NOT EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE idTipoConcesion = @idTipoConcesion)
    BEGIN
        SET @errorMsg = 'No existe un tipo de concesion con id: ' + CAST(@idTipoConcesion AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    SELECT @fechaInicioFinal = ISNULL(@fechaInicio, fechaInicio),
           @fechaFinFinal = ISNULL(@fechaFin, fechaFin)
    FROM Concesiones.concesion
    WHERE idConcesion = @idConcesion;

    IF @fechaFinFinal <= @fechaInicioFinal
    BEGIN
        RAISERROR('La fecha de fin debe ser posterior a la fecha de inicio.', 16, 1);
        RETURN;
    END

    IF @montoCanonMensual IS NOT NULL AND @montoCanonMensual <= 0
    BEGIN
        RAISERROR('El monto del canon mensual debe ser mayor a 0.', 16, 1);
        RETURN;
    END

    UPDATE Concesiones.concesion
    SET idEmpresa = ISNULL(@idEmpresa, idEmpresa),
        idParque = ISNULL(@idParque, idParque),
        idTipoConcesion = ISNULL(@idTipoConcesion, idTipoConcesion),
        fechaInicio = ISNULL(@fechaInicio, fechaInicio),
        fechaFin = ISNULL(@fechaFin, fechaFin),
        montoCanonMensual = ISNULL(@montoCanonMensual, montoCanonMensual)
    WHERE idConcesion = @idConcesion;
END
GO



-- BAJA CONCESION

CREATE OR ALTER PROCEDURE Concesiones.concesion_Baja
    @idConcesion INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idConcesion = @idConcesion)
    BEGIN
        SET @errorMsg = 'No existe una concesion con id: ' + CAST(@idConcesion AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Concesiones.pagoCanon WHERE idConcesion = @idConcesion)
    BEGIN
        RAISERROR('No se puede eliminar: la concesion tiene pagos de canon asociados.', 16, 1);
        RETURN;
    END

    DELETE FROM Concesiones.concesion
    WHERE idConcesion = @idConcesion;
END
GO



-- ALTA PAGO CANON

CREATE OR ALTER PROCEDURE Concesiones.pagoCanon_Alta
    @idConcesion INT,
    @fecha DATE,
    @monto DECIMAL(12, 2),
    @periodo CHAR(7),
    @estado VARCHAR(20)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idConcesion = @idConcesion)
    BEGIN
        SET @errorMsg = 'No existe una concesion con id: ' + CAST(@idConcesion AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @fecha IS NULL
    BEGIN
        RAISERROR('La fecha del pago es obligatoria.', 16, 1);
        RETURN;
    END

    IF @monto IS NULL OR @monto <= 0
    BEGIN
        RAISERROR('El monto del pago debe ser mayor a 0.', 16, 1);
        RETURN;
    END

   
    IF @periodo IS NULL OR @periodo NOT LIKE '[0-9][0-9][0-9][0-9]-[0-1][0-9]'
    BEGIN
        RAISERROR('El periodo debe tener el formato YYYY-MM.', 16, 1);
        RETURN;
    END

    IF @estado NOT IN ('Pagado', 'Pendiente', 'Atrasado')
    BEGIN
        RAISERROR('El estado debe ser Pagado, Pendiente o Atrasado.', 16, 1);
        RETURN;
    END

    -- No puede haber dos pagos del mismo periodo para la misma concesion
    IF EXISTS (SELECT 1 FROM Concesiones.pagoCanon 
               WHERE idConcesion = @idConcesion AND periodo = @periodo)
    BEGIN
        SET @errorMsg = 'Ya existe un pago para el periodo ' + @periodo + ' en esta concesion.';
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    INSERT INTO Concesiones.pagoCanon (idConcesion, fecha, monto, periodo, estado)
    VALUES (@idConcesion, @fecha, @monto, @periodo, @estado);
END
GO



-- MODIFICAR PAGO CANON

CREATE OR ALTER PROCEDURE Concesiones.pagoCanon_Modificar
    @idPagoCanon INT,
    @fecha DATE = NULL,
    @monto DECIMAL(12, 2) = NULL,
    @estado VARCHAR(20) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.pagoCanon WHERE idPagoCanon = @idPagoCanon)
    BEGIN
        SET @errorMsg = 'No existe un pago de canon con id: ' + CAST(@idPagoCanon AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    IF @monto IS NOT NULL AND @monto <= 0
    BEGIN
        RAISERROR('El monto del pago debe ser mayor a 0.', 16, 1);
        RETURN;
    END

    IF @estado IS NOT NULL AND @estado NOT IN ('Pagado', 'Pendiente', 'Atrasado')
    BEGIN
        RAISERROR('El estado debe ser Pagado, Pendiente o Atrasado.', 16, 1);
        RETURN;
    END

    UPDATE Concesiones.pagoCanon
    SET fecha = ISNULL(@fecha, fecha),
        monto = ISNULL(@monto, monto),
        estado = ISNULL(@estado, estado)
    WHERE idPagoCanon = @idPagoCanon;
END
GO



-- BAJA PAGO CANON

CREATE OR ALTER PROCEDURE Concesiones.pagoCanon_Baja
    @idPagoCanon INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(200);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.pagoCanon WHERE idPagoCanon = @idPagoCanon)
    BEGIN
        SET @errorMsg = 'No existe un pago de canon con id: ' + CAST(@idPagoCanon AS VARCHAR(10));
        RAISERROR(@errorMsg, 16, 1);
        RETURN;
    END

    DELETE FROM Concesiones.pagoCanon
    WHERE idPagoCanon = @idPagoCanon;
END
GO
/* 
    Universidad Nacional de La Matanza
    Materia: Bases de Datos Aplicada (3641)
    Fecha: 19/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures ABM del esquema Concesiones.
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO

/*=========================================================
ALTA TIPO CONCESION
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.tipoConcesion_Alta
    @descripcion VARCHAR(100)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errorMsg = @errorMsg + '- La descripcion del tipo de concesion es obligatoria.' + @saltoLinea;

    IF @descripcion IS NOT NULL AND EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE descripcion = @descripcion)
        SET @errorMsg = @errorMsg + '- Ya existe un tipo de concesion con la descripcion: ' + @descripcion + '.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50501, @errorMsg, 1;
    END

    INSERT INTO Concesiones.tipoConcesion (descripcion)
    VALUES (@descripcion);
END
GO

/*=========================================================
MODIFICAR TIPO CONCESION
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.tipoConcesion_Modificar
    @idTipoConcesion INT,
    @descripcion VARCHAR(100)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE idTipoConcesion = @idTipoConcesion)
        SET @errorMsg = @errorMsg + '- No existe un tipo de concesion con id: ' + CAST(@idTipoConcesion AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errorMsg = @errorMsg + '- La descripcion no puede estar vacia.' + @saltoLinea;

    IF @descripcion IS NOT NULL AND EXISTS (
        SELECT 1 FROM Concesiones.tipoConcesion 
        WHERE descripcion = @descripcion AND idTipoConcesion <> @idTipoConcesion
    )
        SET @errorMsg = @errorMsg + '- Ya existe otro tipo de concesion con la descripcion: ' + @descripcion + '.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50502, @errorMsg, 1;
    END

    UPDATE Concesiones.tipoConcesion
    SET descripcion = @descripcion
    WHERE idTipoConcesion = @idTipoConcesion;
END
GO

/*=========================================================
BAJA TIPO CONCESION
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.tipoConcesion_Baja
    @idTipoConcesion INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE idTipoConcesion = @idTipoConcesion)
        SET @errorMsg = @errorMsg + '- No existe un tipo de concesion con id: ' + CAST(@idTipoConcesion AS VARCHAR(10)) + '.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idTipoConcesion = @idTipoConcesion)
        SET @errorMsg = @errorMsg + '- No se puede eliminar: existen concesiones asociadas a este tipo.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50503, @errorMsg, 1;
    END

    DELETE FROM Concesiones.tipoConcesion
    WHERE idTipoConcesion = @idTipoConcesion;
END
GO

/*=========================================================
ALTA EMPRESA
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.empresa_Alta
    @nombre VARCHAR(100)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errorMsg = @errorMsg + '- El nombre de la empresa es obligatorio.' + @saltoLinea;

    IF @nombre IS NOT NULL AND EXISTS (SELECT 1 FROM Concesiones.empresa WHERE nombre = @nombre)
        SET @errorMsg = @errorMsg + '- Ya existe una empresa con el nombre: ' + @nombre + '.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50504, @errorMsg, 1;
    END

    INSERT INTO Concesiones.empresa (nombre)
    VALUES (@nombre);
END
GO

/*=========================================================
MODIFICAR EMPRESA
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.empresa_Modificar
    @idEmpresa INT,
    @nombre VARCHAR(100)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.empresa WHERE idEmpresa = @idEmpresa)
        SET @errorMsg = @errorMsg + '- No existe una empresa con id: ' + CAST(@idEmpresa AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errorMsg = @errorMsg + '- El nombre no puede estar vacio.' + @saltoLinea;

    IF @nombre IS NOT NULL AND EXISTS (
        SELECT 1 FROM Concesiones.empresa 
        WHERE nombre = @nombre AND idEmpresa <> @idEmpresa
    )
        SET @errorMsg = @errorMsg + '- Ya existe otra empresa con el nombre: ' + @nombre + '.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50505, @errorMsg, 1;
    END

    UPDATE Concesiones.empresa
    SET nombre = @nombre
    WHERE idEmpresa = @idEmpresa;
END
GO

/*=========================================================
BAJA EMPRESA
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.empresa_Baja
    @idEmpresa INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.empresa WHERE idEmpresa = @idEmpresa)
        SET @errorMsg = @errorMsg + '- No existe una empresa con id: ' + CAST(@idEmpresa AS VARCHAR(10)) + '.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idEmpresa = @idEmpresa)
        SET @errorMsg = @errorMsg + '- No se puede eliminar: la empresa tiene concesiones asociadas.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50506, @errorMsg, 1;
    END

    DELETE FROM Concesiones.empresa
    WHERE idEmpresa = @idEmpresa;
END
GO

/*=========================================================
ALTA CONCESION
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.concesion_Alta
    @idEmpresa INT,
    @idParque INT,
    @idTipoConcesion INT,
    @fechaInicio DATE,
    @fechaFin DATE,
    @montoCanonMensual DECIMAL(12, 2)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.empresa WHERE idEmpresa = @idEmpresa)
        SET @errorMsg = @errorMsg + '- No existe una empresa con id: ' + CAST(@idEmpresa AS VARCHAR(10)) + '.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10)) + '.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE idTipoConcesion = @idTipoConcesion)
        SET @errorMsg = @errorMsg + '- No existe un tipo de concesion con id: ' + CAST(@idTipoConcesion AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @fechaInicio IS NULL OR @fechaFin IS NULL
        SET @errorMsg = @errorMsg + '- Las fechas de inicio y fin son obligatorias.' + @saltoLinea;

    IF @fechaInicio IS NOT NULL AND @fechaFin IS NOT NULL AND @fechaFin <= @fechaInicio
        SET @errorMsg = @errorMsg + '- La fecha de fin debe ser posterior a la fecha de inicio.' + @saltoLinea;

    IF @montoCanonMensual IS NULL OR @montoCanonMensual <= 0
        SET @errorMsg = @errorMsg + '- El monto del canon mensual debe ser mayor a 0.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50507, @errorMsg, 1;
    END

    INSERT INTO Concesiones.concesion (idEmpresa, idParque, idTipoConcesion, fechaInicio, fechaFin, montoCanonMensual)
    VALUES (@idEmpresa, @idParque, @idTipoConcesion, @fechaInicio, @fechaFin, @montoCanonMensual);
END
GO

/*=========================================================
MODIFICAR CONCESION
=========================================================*/

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
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @fechaInicioFinal DATE, @fechaFinFinal DATE;

    IF NOT EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idConcesion = @idConcesion)
        SET @errorMsg = @errorMsg + '- No existe una concesion con id: ' + CAST(@idConcesion AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @idEmpresa IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Concesiones.empresa WHERE idEmpresa = @idEmpresa)
        SET @errorMsg = @errorMsg + '- No existe una empresa con id: ' + CAST(@idEmpresa AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @idParque IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
        SET @errorMsg = @errorMsg + '- No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @idTipoConcesion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Concesiones.tipoConcesion WHERE idTipoConcesion = @idTipoConcesion)
        SET @errorMsg = @errorMsg + '- No existe un tipo de concesion con id: ' + CAST(@idTipoConcesion AS VARCHAR(10)) + '.' + @saltoLinea;

    -- Validacion de fechas combinando los valores nuevos con los actuales
    SELECT @fechaInicioFinal = ISNULL(@fechaInicio, fechaInicio),
           @fechaFinFinal = ISNULL(@fechaFin, fechaFin)
    FROM Concesiones.concesion
    WHERE idConcesion = @idConcesion;

    IF @fechaInicioFinal IS NOT NULL AND @fechaFinFinal IS NOT NULL AND @fechaFinFinal <= @fechaInicioFinal
        SET @errorMsg = @errorMsg + '- La fecha de fin debe ser posterior a la fecha de inicio.' + @saltoLinea;

    IF @montoCanonMensual IS NOT NULL AND @montoCanonMensual <= 0
        SET @errorMsg = @errorMsg + '- El monto del canon mensual debe ser mayor a 0.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50508, @errorMsg, 1;
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

/*=========================================================
BAJA CONCESION
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.concesion_Baja
    @idConcesion INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idConcesion = @idConcesion)
        SET @errorMsg = @errorMsg + '- No existe una concesion con id: ' + CAST(@idConcesion AS VARCHAR(10)) + '.' + @saltoLinea;

    IF EXISTS (SELECT 1 FROM Concesiones.pagoCanon WHERE idConcesion = @idConcesion)
        SET @errorMsg = @errorMsg + '- No se puede eliminar: la concesion tiene pagos de canon asociados.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50509, @errorMsg, 1;
    END

    DELETE FROM Concesiones.concesion
    WHERE idConcesion = @idConcesion;
END
GO

/*=========================================================
ALTA PAGO CANON
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.pagoCanon_Alta
    @idConcesion INT,
    @fecha DATE,
    @monto DECIMAL(12, 2),
    @periodo CHAR(7),
    @estado VARCHAR(20)
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idConcesion = @idConcesion)
        SET @errorMsg = @errorMsg + '- No existe una concesion con id: ' + CAST(@idConcesion AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @fecha IS NULL
        SET @errorMsg = @errorMsg + '- La fecha del pago es obligatoria.' + @saltoLinea;

    IF @monto IS NULL OR @monto <= 0
        SET @errorMsg = @errorMsg + '- El monto del pago debe ser mayor a 0.' + @saltoLinea;

    IF @periodo IS NULL OR @periodo NOT LIKE '[0-9][0-9][0-9][0-9]-[0-1][0-9]'
        SET @errorMsg = @errorMsg + '- El periodo debe tener el formato YYYY-MM.' + @saltoLinea;

    IF @estado NOT IN ('Pagado', 'Pendiente', 'Atrasado')
        SET @errorMsg = @errorMsg + '- El estado debe ser Pagado, Pendiente o Atrasado.' + @saltoLinea;

    IF @periodo IS NOT NULL AND EXISTS (
        SELECT 1 FROM Concesiones.pagoCanon 
        WHERE idConcesion = @idConcesion AND periodo = @periodo
    )
        SET @errorMsg = @errorMsg + '- Ya existe un pago para el periodo ' + @periodo + ' en esta concesion.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50510, @errorMsg, 1;
    END

    INSERT INTO Concesiones.pagoCanon (idConcesion, fecha, monto, periodo, estado)
    VALUES (@idConcesion, @fecha, @monto, @periodo, @estado);
END
GO

/*=========================================================
MODIFICAR PAGO CANON
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.pagoCanon_Modificar
    @idPagoCanon INT,
    @fecha DATE = NULL,
    @monto DECIMAL(12, 2) = NULL,
    @estado VARCHAR(20) = NULL
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.pagoCanon WHERE idPagoCanon = @idPagoCanon)
        SET @errorMsg = @errorMsg + '- No existe un pago de canon con id: ' + CAST(@idPagoCanon AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @monto IS NOT NULL AND @monto <= 0
        SET @errorMsg = @errorMsg + '- El monto del pago debe ser mayor a 0.' + @saltoLinea;

    IF @estado IS NOT NULL AND @estado NOT IN ('Pagado', 'Pendiente', 'Atrasado')
        SET @errorMsg = @errorMsg + '- El estado debe ser Pagado, Pendiente o Atrasado.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50511, @errorMsg, 1;
    END

    UPDATE Concesiones.pagoCanon
    SET fecha = ISNULL(@fecha, fecha),
        monto = ISNULL(@monto, monto),
        estado = ISNULL(@estado, estado)
    WHERE idPagoCanon = @idPagoCanon;
END
GO

/*=========================================================
BAJA PAGO CANON
=========================================================*/

CREATE OR ALTER PROCEDURE Concesiones.pagoCanon_Baja
    @idPagoCanon INT
AS
BEGIN
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.pagoCanon WHERE idPagoCanon = @idPagoCanon)
        SET @errorMsg = @errorMsg + '- No existe un pago de canon con id: ' + CAST(@idPagoCanon AS VARCHAR(10)) + '.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50512, @errorMsg, 1;
    END

    DELETE FROM Concesiones.pagoCanon
    WHERE idPagoCanon = @idPagoCanon;
END
GO
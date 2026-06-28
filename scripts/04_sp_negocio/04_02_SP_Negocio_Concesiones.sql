/* 
    Script generado el 19/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures de logica de negocio
                            del esquema Concesiones. Delegan la
                            persistencia a los SPs ABM y aplican
                            transacciones cuando tocan varias tablas.
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO


/*=========================================================
REGISTRAR CONCESION CON PAGOS
Alta de concesion + generacion automatica de pagos
mensuales pendientes (uno por cada mes entre fechaInicio
y fechaFin). Todo en una transaccion: si algo falla,
se hace rollback. Delega persistencia a los SPs ABM.
=========================================================*/
CREATE OR ALTER PROCEDURE Concesiones.registrarConcesionConPagos
    @idEmpresa INT,
    @idParque INT,
    @idTipoConcesion INT,
    @fechaInicio DATE,
    @fechaFin DATE,
    @montoCanonMensual DECIMAL(12, 2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @idConcesion INT;
    DECLARE @fechaActual DATE;
    DECLARE @periodo CHAR(7);

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC Concesiones.concesion_Alta
            @idEmpresa = @idEmpresa,
            @idParque = @idParque,
            @idTipoConcesion = @idTipoConcesion,
            @fechaInicio = @fechaInicio,
            @fechaFin = @fechaFin,
            @montoCanonMensual = @montoCanonMensual;

        -- Recupero el id generado por el ABM
        SET @idConcesion = IDENT_CURRENT('Concesiones.concesion');

        -- Generar un pago pendiente por cada mes entre fechaInicio y fechaFin
        SET @fechaActual = @fechaInicio;
        WHILE @fechaActual <= @fechaFin
        BEGIN
            SET @periodo = FORMAT(@fechaActual, 'yyyy-MM');

            EXEC Concesiones.pagoCanon_Alta
                @idConcesion = @idConcesion,
                @fecha = @fechaActual,
                @monto = @montoCanonMensual,
                @periodo = @periodo,
                @estado = 'Pendiente';

            SET @fechaActual = DATEADD(MONTH, 1, @fechaActual);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @errorMsg = 'Error al registrar concesion: ' + ERROR_MESSAGE();
        ;THROW 50551, @errorMsg, 1;
    END CATCH
END
GO


/*=========================================================
REGISTRAR PAGO CANON
Upsert de pago: si existe un pago para ese periodo en estado 
Pendiente o Atrasado, lo marca como Pagado.
Si no existe, lo crea como Pagado. Delega persistencia a 
pagoCanon_Alta y pagoCanon_Modificar.
=========================================================*/
CREATE OR ALTER PROCEDURE Concesiones.registrarPagoCanon
    @idConcesion INT,
    @periodo CHAR(7),
    @monto DECIMAL(12, 2),
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @idPagoCanonExistente INT;
    DECLARE @estadoActual VARCHAR(20);

    -- Verificar si ya existe un registro para este periodo
    SELECT @idPagoCanonExistente = idPagoCanon, @estadoActual = estado
    FROM Concesiones.pagoCanon
    WHERE idConcesion = @idConcesion AND periodo = @periodo;

    IF @estadoActual = 'Pagado'
    BEGIN
        SET @errorMsg = '- El pago del periodo ' + @periodo + ' ya esta registrado como Pagado.' + @saltoLinea;
        ;THROW 50553, @errorMsg, 1;
    END

    IF @idPagoCanonExistente IS NULL
    BEGIN
        -- No existe: alta delegada al SP ABM
        EXEC Concesiones.pagoCanon_Alta
            @idConcesion = @idConcesion,
            @fecha = @fecha,
            @monto = @monto,
            @periodo = @periodo,
            @estado = 'Pagado';
    END
    ELSE
    BEGIN
        -- Existia como Pendiente o Atrasado: modificacion delegada al SP ABM
        EXEC Concesiones.pagoCanon_Modificar
            @idPagoCanon = @idPagoCanonExistente,
            @fecha = @fecha,
            @monto = @monto,
            @estado = 'Pagado';
    END
END
GO


/*=========================================================
MARCAR PAGOS ATRASADOS
Recorre los pagos en estado Pendiente cuyo periodo ya 
paso (anterior al mes actual) y los marca como Atrasado.
Operacion masiva: por performance se hace UPDATE directo
en lugar de iterar pagoCanon_Modificar fila por fila.
=========================================================*/
CREATE OR ALTER PROCEDURE Concesiones.marcarPagosAtrasados
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @periodoActual CHAR(7) = FORMAT(GETDATE(), 'yyyy-MM');
    DECLARE @cantidad INT;

    UPDATE Concesiones.pagoCanon
    SET estado = 'Atrasado'
    WHERE estado = 'Pendiente' AND periodo < @periodoActual;

    SET @cantidad = @@ROWCOUNT;

    SELECT @cantidad AS pagosActualizados;
END
GO


/*=========================================================
CERRAR CONCESION
Termina una concesion antes de la fechaFin original.
Elimina los pagos pendientes futuros (posteriores a 
fechaCierre). Todo en transaccion. Delega persistencia
a los SPs ABM (concesion_Modificar y pagoCanon_Baja).
=========================================================*/
CREATE OR ALTER PROCEDURE Concesiones.cerrarConcesion
    @idConcesion INT,
    @fechaCierre DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @fechaInicio DATE, @fechaFinOriginal DATE;
    DECLARE @periodoCierre CHAR(7);
    DECLARE @idPagoCanonBaja INT;

    -- Por defecto se cierra al dia de hoy
    IF @fechaCierre IS NULL
        SET @fechaCierre = CAST(GETDATE() AS DATE);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.concesion WHERE idConcesion = @idConcesion)
    BEGIN
        SET @errorMsg = @errorMsg + '- No existe una concesion con id: ' + CAST(@idConcesion AS VARCHAR(10)) + '.' + @saltoLinea;
        ;THROW 50554, @errorMsg, 1;
    END

    SELECT @fechaInicio = fechaInicio, @fechaFinOriginal = fechaFin
    FROM Concesiones.concesion
    WHERE idConcesion = @idConcesion;

    IF @fechaCierre < @fechaInicio
        SET @errorMsg = @errorMsg + '- La fecha de cierre no puede ser anterior a la fecha de inicio.' + @saltoLinea;

    IF @fechaCierre > @fechaFinOriginal
        SET @errorMsg = @errorMsg + '- La fecha de cierre no puede ser posterior a la fecha de fin actual.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50555, @errorMsg, 1;
    END

    SET @periodoCierre = FORMAT(@fechaCierre, 'yyyy-MM');

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar fechaFin via SP ABM
        EXEC Concesiones.concesion_Modificar
            @idConcesion = @idConcesion,
            @fechaFin = @fechaCierre;

        -- Eliminar pagos pendientes futuros uno por uno via SP ABM
        WHILE EXISTS (
            SELECT 1 FROM Concesiones.pagoCanon 
            WHERE idConcesion = @idConcesion 
              AND estado = 'Pendiente' 
              AND periodo > @periodoCierre
        )
        BEGIN
            SELECT TOP 1 @idPagoCanonBaja = idPagoCanon
            FROM Concesiones.pagoCanon
            WHERE idConcesion = @idConcesion 
              AND estado = 'Pendiente' 
              AND periodo > @periodoCierre;

            EXEC Concesiones.pagoCanon_Baja @idPagoCanon = @idPagoCanonBaja;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @errorMsg = 'Error al cerrar concesion: ' + ERROR_MESSAGE();
        ;THROW 50556, @errorMsg, 1;
    END CATCH
END
GO


/*=========================================================
CONSULTAR CONCESIONES PROXIMAS A VENCER
Devuelve las concesiones cuya fechaFin esta dentro
de los proximos N dias.
=========================================================*/
CREATE OR ALTER PROCEDURE Concesiones.consultarProximasAVencer
    @diasUmbral INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF @diasUmbral <= 0
    BEGIN
        SET @errorMsg = @errorMsg + '- El umbral en dias debe ser mayor a 0.' + @saltoLinea;
        ;THROW 50557, @errorMsg, 1;
    END

    SELECT 
        c.idConcesion,
        e.nombre AS empresa,
        p.nombre AS parque,
        tc.descripcion AS tipoConcesion,
        c.fechaInicio,
        c.fechaFin,
        c.montoCanonMensual,
        DATEDIFF(DAY, GETDATE(), c.fechaFin) AS diasParaVencer
    FROM Concesiones.concesion c
    INNER JOIN Concesiones.empresa e ON e.idEmpresa = c.idEmpresa
    INNER JOIN Gestion.parque p ON p.idParque = c.idParque
    INNER JOIN Concesiones.tipoConcesion tc ON tc.idTipoConcesion = c.idTipoConcesion
    WHERE c.fechaFin BETWEEN CAST(GETDATE() AS DATE) 
                         AND DATEADD(DAY, @diasUmbral, CAST(GETDATE() AS DATE))
    ORDER BY c.fechaFin;
END
GO


/*=========================================================
CONSULTAR CONCESIONES ATRASADAS
Lista las concesiones que tienen al menos un pago en 
estado Atrasado, con cantidad de meses y monto adeudado.
=========================================================*/
CREATE OR ALTER PROCEDURE Concesiones.consultarAtrasadas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.idConcesion,
        e.nombre AS empresa,
        p.nombre AS parque,
        tc.descripcion AS tipoConcesion,
        COUNT(pc.idPagoCanon) AS mesesAtrasados,
        SUM(pc.monto) AS montoAdeudado
    FROM Concesiones.concesion c
    INNER JOIN Concesiones.empresa e ON e.idEmpresa = c.idEmpresa
    INNER JOIN Gestion.parque p ON p.idParque = c.idParque
    INNER JOIN Concesiones.tipoConcesion tc ON tc.idTipoConcesion = c.idTipoConcesion
    INNER JOIN Concesiones.pagoCanon pc ON pc.idConcesion = c.idConcesion
    WHERE pc.estado = 'Atrasado'
    GROUP BY c.idConcesion, e.nombre, p.nombre, tc.descripcion
    ORDER BY montoAdeudado DESC;
END
GO
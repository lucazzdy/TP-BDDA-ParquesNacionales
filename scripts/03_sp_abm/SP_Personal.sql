USE GestionParquesNacionales;
GO

/*=========================================================
ALTA DE GUARDAPARQUE
=========================================================*/

CREATE OR ALTER PROCEDURE Personal.Guardaparque_Alta
(
    @TipoDocumento VARCHAR(15),
    @Documento VARCHAR(20),
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @FechaNacimiento DATE,
    @Estado VARCHAR(10)
)
AS
BEGIN

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
    BEGIN
        RAISERROR('El nombre es obligatorio.',16,1);
        RETURN;
    END;

    IF @Apellido IS NULL OR LTRIM(RTRIM(@Apellido)) = ''
    BEGIN
        RAISERROR('El apellido es obligatorio.',16,1);
        RETURN;
    END;

    IF @Documento IS NULL OR LTRIM(RTRIM(@Documento)) = ''
    BEGIN
        RAISERROR('El documento es obligatorio.',16,1);
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM Personal.Guardaparque
        WHERE Documento = @Documento
    )
    BEGIN
        RAISERROR('Ya existe un guardaparque con ese documento.',16,1);
        RETURN;
    END;

    IF @FechaNacimiento >= GETDATE()
    BEGIN
        RAISERROR('La fecha de nacimiento es invalida.',16,1);
        RETURN;
    END;

    INSERT INTO Personal.Guardaparque
    (
        TipoDocumento,
        Documento,
        Nombre,
        Apellido,
        FechaNacimiento,
        Estado
    )
    VALUES
    (
        @TipoDocumento,
        @Documento,
        @Nombre,
        @Apellido,
        @FechaNacimiento,
        @Estado
    );

    PRINT 'Guardaparque dado de alta correctamente.';

END;
GO

/*=========================================================
BAJA LOGICA
=========================================================*/

CREATE OR ALTER PROCEDURE Personal.Guardaparque_Baja
(
    @Legajo INT
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.Guardaparque
        WHERE Legajo = @Legajo
    )
    BEGIN
        RAISERROR('El legajo no existe.',16,1);
        RETURN;
    END;

    UPDATE Personal.Guardaparque
    SET Estado = 'INACTIVO'
    WHERE Legajo = @Legajo;

    PRINT 'Guardaparque dado de baja correctamente.';

END;
GO

/*=========================================================
MODIFICACION
=========================================================*/

CREATE OR ALTER PROCEDURE Personal.ModificarGuardaparque
(
    @Legajo INT,
    @NuevoTipoDocumento VARCHAR(15) = NULL,
    @NuevoDocumento VARCHAR(20) = NULL,
    @NuevoNombre VARCHAR(50) = NULL,
    @NuevoApellido VARCHAR(50) = NULL,
    @NuevaFechaNacimiento DATE = NULL,
    @NuevoEstado VARCHAR(10) = NULL
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.Guardaparque
        WHERE Legajo = @Legajo
    )
    BEGIN
        RAISERROR('El legajo no existe.',16,1);
        RETURN;
    END;

    IF @NuevoDocumento IS NOT NULL
       AND EXISTS
       (
           SELECT 1
           FROM Personal.Guardaparque
           WHERE Documento = @NuevoDocumento
             AND Legajo <> @Legajo
       )
    BEGIN
        RAISERROR('Ya existe otro guardaparque con ese documento.',16,1);
        RETURN;
    END;

    UPDATE Personal.Guardaparque
    SET
        TipoDocumento = ISNULL(@NuevoTipoDocumento, TipoDocumento),
        Documento = ISNULL(@NuevoDocumento, Documento),
        Nombre = ISNULL(@NuevoNombre, Nombre),
        Apellido = ISNULL(@NuevoApellido, Apellido),
        FechaNacimiento = ISNULL(@NuevaFechaNacimiento, FechaNacimiento),
        Estado = ISNULL(@NuevoEstado, Estado)
    WHERE Legajo = @Legajo;

    PRINT 'Guardaparque modificado correctamente.';

END;
GO

/*=========================================================
ASIGNAR GUARDAPARQUE A PARQUE
=========================================================*/

CREATE OR ALTER PROCEDURE Personal.AsignarGuardaparqueParque
(
    @Legajo INT,
    @IDParque INT,
    @FechaIngreso DATE
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.Guardaparque
        WHERE Legajo = @Legajo
    )
    BEGIN
        RAISERROR('El guardaparque no existe.',16,1);
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Gestion.Parque
        WHERE IDParque = @IDParque
    )
    BEGIN
        RAISERROR('El parque no existe.',16,1);
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM Personal.HistorialGuardaparque
        WHERE Legajo = @Legajo
        AND FechaEgreso IS NULL
    )
    BEGIN
        RAISERROR('El guardaparque ya posee una asignacion activa.',16,1);
        RETURN;
    END;

    INSERT INTO Personal.HistorialGuardaparque
    (
        Legajo,
        IDParque,
        FechaIngreso
    )
    VALUES
    (
        @Legajo,
        @IDParque,
        @FechaIngreso
    );

    PRINT 'Asignacion realizada correctamente.';

END;
GO

/*=========================================================
REASIGNAR GUARDAPARQUE
=========================================================*/

CREATE OR ALTER PROCEDURE Personal.ReasignarGuardaparque
(
    @Legajo INT,
    @NuevoParque INT,
    @FechaCambio DATE
)
AS
BEGIN

    BEGIN TRY

        IF NOT EXISTS
        (
            SELECT 1
            FROM Personal.Guardaparque
            WHERE Legajo = @Legajo
        )
        BEGIN
            RAISERROR('El guardaparque no existe.',16,1);
            RETURN;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Gestion.Parque
            WHERE IDParque = @NuevoParque
        )
        BEGIN
            RAISERROR('El parque no existe.',16,1);
            RETURN;
        END;

        BEGIN TRANSACTION;

        UPDATE Personal.HistorialGuardaparque
        SET
            FechaEgreso = @FechaCambio,
            MotivoEgreso = 'Reasignacion'
        WHERE Legajo = @Legajo
          AND FechaEgreso IS NULL;

        INSERT INTO Personal.HistorialGuardaparque
        (
            Legajo,
            IDParque,
            FechaIngreso
        )
        VALUES
        (
            @Legajo,
            @NuevoParque,
            @FechaCambio
        );

        COMMIT TRANSACTION;

        PRINT 'Guardaparque reasignado correctamente.';

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH

END;
GO
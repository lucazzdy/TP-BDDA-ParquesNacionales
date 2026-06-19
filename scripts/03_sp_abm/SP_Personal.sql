/*=======================================================
    Script generado el 15/06/26

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Este script genera los stored procedures ABM para el esquema de Personal y sus tablas.
=======================================================*/

USE GestionParquesNacionales;
GO

/*=======================================================
CREACION DE LOS STORE PROCEDURE
=======================================================*/

/*=======================================================
STORE PROCEDURE TABLA GUARDAPARQUES
=======================================================*/

---------------------------------------------------------
-- ALTA DE GUARDAPARQUES
---------------------------------------------------------


CREATE OR ALTER PROCEDURE Personal.Guardaparques_Alta
(
    @Documento CHAR(8),
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @FechaNacimiento DATE,
    @Estado VARCHAR(10)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
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

    IF EXISTS (
        SELECT 1
        FROM Personal.Guardaparques
        WHERE Documento = @Documento
    )
    BEGIN
        RAISERROR('Ya existe un guardaparque con ese documento.',16,1);
        RETURN;
    END;

    IF @FechaNacimiento >= DATEADD(YEAR, -18, GETDATE())
    BEGIN
        RAISERROR('La fecha de nacimiento es inválida. Debe ser mayor de 18 años.',16,1);
        RETURN;
    END;

    -- Inserción
    INSERT INTO Personal.Guardaparques
    (
        Documento,
        Nombre,
        Apellido,
        FechaNacimiento,
        Estado
    )
    VALUES
    (
        @Documento,
        @Nombre,
        @Apellido,
        @FechaNacimiento,
        @Estado
    );
END;
GO

---------------------------------------------------------
-- MODIFICACION DE GUARDAPARQUES POR LEGAJO
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.ModificarGuardaparques
(
    @Legajo INT,
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
        FROM Personal.Guardaparques
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
           FROM Personal.Guardaparques
           WHERE Documento = @NuevoDocumento
             AND Legajo <> @Legajo
       )
    BEGIN
        RAISERROR('Ya existe otro guardaparque con ese documento.',16,1);
        RETURN;
    END;

    UPDATE Personal.Guardaparques
    SET
        Documento = ISNULL(@NuevoDocumento, Documento),
        Nombre = ISNULL(@NuevoNombre, Nombre),
        Apellido = ISNULL(@NuevoApellido, Apellido),
        FechaNacimiento = ISNULL(@NuevaFechaNacimiento, FechaNacimiento),
        Estado = ISNULL(@NuevoEstado, Estado)
    WHERE Legajo = @Legajo;

    PRINT 'Guardaparque modificado correctamente.';

END;
GO

---------------------------------------------------------
-- BAJA DE GUARDAPARQUES
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.Guardaparque_Baja
(
    @Legajo INT
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.GuardaParques
        WHERE Legajo = @Legajo
    )
    BEGIN
        RAISERROR('El legajo no existe.',16,1);
        RETURN;
    END;

    UPDATE Personal.GuardaParques
    SET Estado = 'INACTIVO'
    WHERE Legajo = @Legajo;

    PRINT 'Guardaparque dado de baja correctamente.';

END;
GO

/*=======================================================
STORE PROCEDURE TABLA HISTORIAL GUARDAPARQUES
=======================================================*/

---------------------------------------------------------
-- ASIGNACION DE GUARDAPARQUES A UN PARQUE
---------------------------------------------------------

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
        FROM Personal.GuardaParques
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
        FROM Personal.HistorialGuardaParques
        WHERE LegajoGuardaParques = @Legajo
        AND FechaEgreso IS NULL
    )
    BEGIN
        RAISERROR('El guardaparque ya posee una asignacion activa.',16,1);
        RETURN;
    END;

    INSERT INTO Personal.HistorialGuardaParques
    (
        LegajoGuardaParques,
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

---------------------------------------------------------
-- REASIGNACION DE GUARDAPARQUES A UN PARQUE
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.ReasignarGuardaparque
(
    @Legajo INT,
    @NuevoParque INT,
    @FechaCambio DATE,
    @MotivoEgreso VARCHAR(200) = NULL
)
AS
BEGIN

    BEGIN TRY

        IF NOT EXISTS
        (
            SELECT 1
            FROM Personal.GuardaParques
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

        UPDATE Personal.HistorialGuardaParques
        SET
            FechaEgreso = @FechaCambio,
            MotivoEgreso = @MotivoEgreso
        WHERE LegajoGuardaParques = @Legajo
          AND FechaEgreso IS NULL;

        INSERT INTO Personal.HistorialGuardaParques
        (
            LegajoGuardaParques,
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

/*=======================================================
STORE PROCEDURE TABLA GUIAS
=======================================================*/

---------------------------------------------------------
-- ALTA GUIA
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.AltaGuia
(
    @Documento CHAR(8),
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @FechaNacimiento DATE,
    @CodTitulo INT,
    @CodEspecialidad INT
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.Guias
        WHERE Documento = @Documento
    )
    BEGIN
        RAISERROR('El documento ya existe.',16,1);
        RETURN;
    END;

    INSERT INTO Personal.Guias
    (
        Documento,
        Nombre,
        Apellido,
        FechaNacimiento,
        CodTitulo,
        CodEspecialidad
    )
    VALUES
    (
        @Documento,
        @Nombre,
        @Apellido,
        @FechaNacimiento,
        @CodTitulo,
        @CodEspecialidad
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION GUIA
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.ModificarGuia
(
    @Legajo INT,
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @FechaNacimiento DATE,
    @CodTitulo INT,
    @CodEspecialidad INT
)
AS
BEGIN

    UPDATE Personal.Guias
    SET
        Nombre = @Nombre,
        Apellido = @Apellido,
        FechaNacimiento = @FechaNacimiento,
        CodTitulo = @CodTitulo,
        CodEspecialidad = @CodEspecialidad
    WHERE Legajo = @Legajo;

END;
GO

---------------------------------------------------------
-- BAJA GUIA
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.BajaGuia
(
    @Legajo INT
)
AS
BEGIN

    DELETE FROM Personal.Guias
    WHERE Legajo = @Legajo;

END;
GO

/*=======================================================
STORE PROCEDURE TABLA TITULOS GUIAS
=======================================================*/

---------------------------------------------------------
-- ALTA TITULOS GUIA
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.AltaTitulo
(
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.Titulos
        WHERE Nombre = @Nombre
    )
    BEGIN
        RAISERROR('Ya existe un título con ese nombre.',16,1);
        RETURN;
    END

    INSERT INTO Personal.Titulos
    (
        Nombre,
        Descripcion
    )
    VALUES
    (
        @Nombre,
        @Descripcion
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION TITULOS GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.ModificarTitulo
(
    @CodTitulo INT,
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.Titulos
        WHERE CodTitulo = @CodTitulo
    )
    BEGIN
        RAISERROR('El titulo no existe.',16,1);
        RETURN;
    END;

    UPDATE Personal.Titulos
    SET
        Nombre = @Nombre,
        Descripcion = @Descripcion
    WHERE CodTitulo = @CodTitulo;

END;
GO

---------------------------------------------------------
-- BAJA TITULOS GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.BajaTitulo
(
    @CodTitulo INT
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.Guias
        WHERE CodTitulo = @CodTitulo
    )
    BEGIN
        RAISERROR('No se puede eliminar el titulo porque está asignado a uno o más guias.',16,1);
        RETURN;
    END;

    DELETE FROM Personal.Titulos
    WHERE CodTitulo = @CodTitulo;

END;
GO

/*=======================================================
STORE PROCEDURE TABLA ESPECIALIDAD GUIAS
=======================================================*/

---------------------------------------------------------
-- ALTA ESPECIALIDAD GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.AltaEspecialidad
(
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.Especialidad
        WHERE Nombre = @Nombre
    )
    BEGIN
        RAISERROR('La especialidad ya existe.',16,1);
        RETURN;
    END

    INSERT INTO Personal.Especialidad
    (
        Nombre,
        Descripcion
    )
    VALUES
    (
        @Nombre,
        @Descripcion
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION ESPECIALIDAD GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.ModificarEspecialidad
(
    @CodEspecialidad INT,
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.Especialidad
        WHERE CodEspecialidad = @CodEspecialidad
    )
    BEGIN
        RAISERROR('La especialidad no existe.',16,1);
        RETURN;
    END;

    UPDATE Personal.Especialidad
    SET
        Nombre = @Nombre,
        Descripcion = @Descripcion
    WHERE CodEspecialidad = @CodEspecialidad;

END;
GO

---------------------------------------------------------
-- BAJA ESPECIALIDAD GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.BajaEspecialidad
(
    @CodEspecialidad INT
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.Guias
        WHERE CodEspecialidad = @CodEspecialidad
    )
    BEGIN
        RAISERROR('No se puede eliminar la especialidad porque está asignada a uno o más guias.',16,1);
        RETURN;
    END;

    DELETE FROM Personal.Especialidad
    WHERE CodEspecialidad = @CodEspecialidad;

END;
GO

/*=======================================================
STORE PROCEDURE TABLA HABILITACIONES
=======================================================*/
---------------------------------------------------------
-- ALTA HABILITACIONES
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.AltaHabilitacion
(
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(200)=NULL
)
AS
BEGIN

    INSERT INTO Personal.Habilitaciones
    (
        Nombre,
        Descripcion
    )
    VALUES
    (
        @Nombre,
        @Descripcion
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION HABILITACIONES
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.ModificarHabilitacion
(
    @IDHabilitacion INT,
    @Nombre VARCHAR(50),
    @Descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.Habilitaciones
        WHERE IDHabilitaciones = @IDHabilitacion
    )
    BEGIN
        RAISERROR('La habilitación no existe.',16,1);
        RETURN;
    END;

    UPDATE Personal.Habilitaciones
    SET
        Nombre = @Nombre,
        Descripcion = @Descripcion
    WHERE IDHabilitaciones = @IDHabilitacion;

END;
GO

---------------------------------------------------------
-- BAJA HABILITACIONES
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.BajaHabilitacion
(
    @IDHabilitacion INT
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.HabilitacionesGuias
        WHERE IDHabilitacion = @IDHabilitacion
    )
    BEGIN
        RAISERROR('No se puede eliminar la habilitación porque está asociada a guias.',16,1);
        RETURN;
    END;

    DELETE FROM Personal.Habilitaciones
    WHERE IDHabilitaciones = @IDHabilitacion;

END;
GO

/*=======================================================
STORE PROCEDURE TABLA HABILITACIONES GUIAS POR PARQUE
=======================================================*/
---------------------------------------------------------
-- ALTA HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.AltaHabilitacionGuia
(
    @IDHabilitacion INT,
    @LegajoGuia INT,
    @IDParque INT,
    @FechaComienzo DATE,
    @FechaFin DATE
)
AS
BEGIN

    IF @FechaFin < @FechaComienzo
    BEGIN
        RAISERROR('La fecha fin no puede ser menor a la fecha inicio.',16,1);
        RETURN;
    END

    INSERT INTO Personal.HabilitacionesGuias
    (
        IDHabilitacion,
        LegajoGuia,
        IDParque,
        FechaComienzo,
        FechaFin
    )
    VALUES
    (
        @IDHabilitacion,
        @LegajoGuia,
        @IDParque,
        @FechaComienzo,
        @FechaFin
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.ModificarHabilitacionGuia
(
    @IDHabilitacionGuia INT,
    @IDHabilitacion INT,
    @LegajoGuia INT,
    @IDParque INT,
    @FechaComienzo DATE,
    @FechaFin DATE
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.HabilitacionesGuias
        WHERE IDHabilitacionGuia = @IDHabilitacionGuia
    )
    BEGIN
        RAISERROR('La habilitación del guía no existe.',16,1);
        RETURN;
    END;

    IF @FechaFin < @FechaComienzo
    BEGIN
        RAISERROR('La fecha fin no puede ser menor a la fecha comienzo.',16,1);
        RETURN;
    END;

    UPDATE Personal.HabilitacionesGuias
    SET
        IDHabilitacion = @IDHabilitacion,
        LegajoGuia = @LegajoGuia,
        IDParque = @IDParque,
        FechaComienzo = @FechaComienzo,
        FechaFin = @FechaFin
    WHERE IDHabilitacionGuia = @IDHabilitacionGuia;

END;
GO

---------------------------------------------------------
-- BAJA HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.BajaHabilitacionGuia
(
    @IDHabilitacionGuia INT
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.HabilitacionesGuias
        WHERE IDHabilitacionGuia = @IDHabilitacionGuia
    )
    BEGIN
        RAISERROR('La habilitación del guía no existe.',16,1);
        RETURN;
    END;

    DELETE FROM Personal.HabilitacionesGuias
    WHERE IDHabilitacionGuia = @IDHabilitacionGuia;

END;
GO
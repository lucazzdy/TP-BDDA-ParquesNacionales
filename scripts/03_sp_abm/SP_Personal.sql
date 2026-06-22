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


CREATE OR ALTER PROCEDURE Personal.altaGuardaparques
(
    @documento CHAR(8),
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @fechaNacimiento DATE,
    @estado VARCHAR(10)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('El nombre es obligatorio.',16,1);
        RETURN;
    END;

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
    BEGIN
        RAISERROR('El apellido es obligatorio.',16,1);
        RETURN;
    END;

    IF @documento IS NULL OR LTRIM(RTRIM(@documento)) = ''
    BEGIN
        RAISERROR('El documento es obligatorio.',16,1);
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM Personal.guardaparques
        WHERE documento = @documento
    )
    BEGIN
        RAISERROR('Ya existe un guardaparque con ese documento.',16,1);
        RETURN;
    END;

    IF @fechaNacimiento >= DATEADD(YEAR, -18, GETDATE())
    BEGIN
        RAISERROR('La fecha de nacimiento es inválida. Debe ser mayor de 18 años.',16,1);
        RETURN;
    END;

    -- Inserción
    INSERT INTO Personal.guardaparques
    (
        documento,
        nombre,
        apellido,
        fechaNacimiento,
        estado
    )
    VALUES
    (
        @documento,
        @nombre,
        @apellido,
        @fechaNacimiento,
        @estado
    );
END;
GO

---------------------------------------------------------
-- MODIFICACION DE GUARDAPARQUES POR LEGAJO
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.modificarGuardaparque
(
    @legajo INT,
    @nuevoDocumento VARCHAR(20) = NULL,
    @nuevoNombre VARCHAR(50) = NULL,
    @nuevoApellido VARCHAR(50) = NULL,
    @nuevaFechaNacimiento DATE = NULL,
    @nuevoEstado VARCHAR(10) = NULL
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.guardaparques
        WHERE legajo = @legajo
    )
    BEGIN
        RAISERROR('El legajo no existe.',16,1);
        RETURN;
    END;

    IF @nuevoDocumento IS NOT NULL
       AND EXISTS
       (
           SELECT 1
           FROM Personal.guardaparques
           WHERE documento = @nuevoDocumento
             AND legajo <> @legajo
       )
    BEGIN
        RAISERROR('Ya existe otro guardaparque con ese documento.',16,1);
        RETURN;
    END;

    UPDATE Personal.guardaparques
    SET
        documento = ISNULL(@nuevoDocumento, documento),
        nombre = ISNULL(@nuevoNombre, nombre),
        apellido = ISNULL(@nuevoApellido, apellido),
        fechaNacimiento = ISNULL(@nuevaFechaNacimiento, fechaNacimiento),
        estado = ISNULL(@nuevoEstado, estado)
    WHERE legajo = @legajo;

    PRINT 'Guardaparque modificado correctamente.';

END;
GO

---------------------------------------------------------
-- BAJA DE GUARDAPARQUES
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.bajaGuardaparque
(
    @legajo INT
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.guardaparques
        WHERE legajo = @legajo
    )
    BEGIN
        RAISERROR('El legajo no existe.',16,1);
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM Personal.guardaparques
        WHERE legajo = @legajo
          AND estado = 'INACTIVO'
    )
    BEGIN
        RAISERROR('El guardaparque ya se encuentra inactivo.',16,1);
        RETURN;
    END;

    UPDATE Personal.guardaparques
    SET estado = 'INACTIVO'
    WHERE legajo = @legajo;

    PRINT 'Guardaparque dado de baja correctamente.';

END;
GO

/*=======================================================
STORE PROCEDURE TABLA HISTORIAL GUARDAPARQUES
=======================================================*/

---------------------------------------------------------
-- ASIGNACION DE GUARDAPARQUES A UN PARQUE
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.asignarGuardaparqueParque
(
    @legajo INT,
    @idParque INT,
    @fechaIngreso DATE
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.guardaparques
        WHERE legajo = @legajo
    )
    BEGIN
        RAISERROR('El guardaparque no existe.',16,1);
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Gestion.parque
        WHERE idParque = @idParque
    )
    BEGIN
        RAISERROR('El parque no existe.',16,1);
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM Personal.historialGuardaParques
        WHERE legajoGuardaparques = @legajo
        AND fechaEgreso IS NULL
    )
    BEGIN
        RAISERROR('El guardaparque ya posee una asignacion activa.',16,1);
        RETURN;
    END;

    INSERT INTO Personal.historialGuardaparques
    (
        legajoGuardaparques,
        idParque,
        fechaIngreso
    )
    VALUES
    (
        @legajo,
        @idParque,
        @fechaIngreso
    );

    PRINT 'Asignacion realizada correctamente.';

END;
GO

---------------------------------------------------------
-- REASIGNACION DE GUARDAPARQUES A UN PARQUE
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.reasignarGuardaparque
(
    @legajo INT,
    @nuevoParque INT,
    @fechaCambio DATE,
    @motivoEgreso VARCHAR(200) = NULL
)
AS
BEGIN

    BEGIN TRY

        IF NOT EXISTS
        (
            SELECT 1
            FROM Personal.guardaparques
            WHERE legajo = @legajo
        )
        BEGIN
            RAISERROR('El guardaparque no existe.',16,1);
            RETURN;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Gestion.parque
            WHERE idParque = @nuevoParque
        )
        BEGIN
            RAISERROR('El parque no existe.',16,1);
            RETURN;
        END;

        BEGIN TRANSACTION;

        UPDATE Personal.historialGuardaparques
        SET
            fechaEgreso = @fechaCambio,
            motivoEgreso = @motivoEgreso
        WHERE legajoGuardaParques = @legajo
          AND fechaEgreso IS NULL;

        INSERT INTO Personal.historialGuardaparques
        (
            legajoGuardaparques,
            idParque,
            fechaIngreso
        )
        VALUES
        (
            @legajo,
            @nuevoParque,
            @fechaCambio
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

CREATE OR ALTER PROCEDURE Personal.altaGuia
(
    @documento CHAR(8),
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @fechaNacimiento DATE,
    @codTitulo INT,
    @codEspecialidad INT
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.guias
        WHERE documento = @documento
    )
    BEGIN
        RAISERROR('El documento ya existe.',16,1);
        RETURN;
    END;

    INSERT INTO Personal.guias
    (
        documento,
        nombre,
        apellido,
        fechaNacimiento,
        codTitulo,
        codEspecialidad
    )
    VALUES
    (
        @documento,
        @nombre,
        @apellido,
        @fechaNacimiento,
        @codTitulo,
        @codEspecialidad
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION GUIA
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.modificarGuia
(
    @legajo INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @fechaNacimiento DATE,
    @codTitulo INT,
    @codEspecialidad INT
)
AS
BEGIN

    UPDATE Personal.guias
    SET
        nombre = @nombre,
        apellido = @apellido,
        fechaNacimiento = @fechaNacimiento,
        codTitulo = @codTitulo,
        codEspecialidad = @codEspecialidad
    WHERE legajo = @legajo;

END;
GO

---------------------------------------------------------
-- BAJA GUIA
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.bajaGuia
(
    @legajo INT
)
AS
BEGIN

    DELETE FROM Personal.guias
    WHERE legajo = @legajo;

END;
GO

/*=======================================================
STORE PROCEDURE TABLA TITULOS GUIAS
=======================================================*/

---------------------------------------------------------
-- ALTA TITULOS GUIA
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.altaTitulo
(
    @nombre VARCHAR(50),
    @descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.titulos
        WHERE nombre = @nombre
    )
    BEGIN
        RAISERROR('Ya existe un título con ese nombre.',16,1);
        RETURN;
    END

    INSERT INTO Personal.titulos
    (
        nombre,
        descripcion
    )
    VALUES
    (
        @nombre,
        @descripcion
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION TITULOS GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.modificarTitulo
(
    @codTitulo INT,
    @nombre VARCHAR(50),
    @descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.titulos
        WHERE codTitulo = @codTitulo
    )
    BEGIN
        RAISERROR('El titulo no existe.',16,1);
        RETURN;
    END;

    UPDATE Personal.Titulos
    SET
        nombre = @nombre,
        descripcion = @descripcion
    WHERE codTitulo = @codTitulo;

END;
GO

---------------------------------------------------------
-- BAJA TITULOS GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.bajaTitulo
(
    @codTitulo INT
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.guias
        WHERE codTitulo = @codTitulo
    )
    BEGIN
        RAISERROR('No se puede eliminar el titulo porque está asignado a uno o más guias.',16,1);
        RETURN;
    END;

    DELETE FROM Personal.titulos
    WHERE codTitulo = @codTitulo;

END;
GO

/*=======================================================
STORE PROCEDURE TABLA ESPECIALIDAD GUIAS
=======================================================*/

---------------------------------------------------------
-- ALTA ESPECIALIDAD GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.altaEspecialidad
(
    @nombre VARCHAR(50),
    @descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.especialidad
        WHERE nombre = @nombre
    )
    BEGIN
        RAISERROR('La especialidad ya existe.',16,1);
        RETURN;
    END

    INSERT INTO Personal.especialidad
    (
        nombre,
        descripcion
    )
    VALUES
    (
        @nombre,
        @descripcion
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION ESPECIALIDAD GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.modificarEspecialidad
(
    @codEspecialidad INT,
    @nombre VARCHAR(50),
    @descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.especialidad
        WHERE codEspecialidad = @codEspecialidad
    )
    BEGIN
        RAISERROR('La especialidad no existe.',16,1);
        RETURN;
    END;

    UPDATE Personal.especialidad
    SET
        nombre = @nombre,
        descripcion = @descripcion
    WHERE codEspecialidad = @codEspecialidad;

END;
GO

---------------------------------------------------------
-- BAJA ESPECIALIDAD GUIAS
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.bajaEspecialidad
(
    @codEspecialidad INT
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Personal.guias
        WHERE codEspecialidad = @codEspecialidad
    )
    BEGIN
        RAISERROR('No se puede eliminar la especialidad porque está asignada a uno o más guias.',16,1);
        RETURN;
    END;

    DELETE FROM Personal.especialidad
    WHERE codEspecialidad = @codEspecialidad;

END;
GO

/*=======================================================
STORE PROCEDURE TABLA HABILITACIONES
=======================================================*/
---------------------------------------------------------
-- ALTA HABILITACIONES
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.altaHabilitacion
(
    @nombre VARCHAR(50),
    @descripcion VARCHAR(200)=NULL
)
AS
BEGIN

    INSERT INTO Personal.Habilitaciones
    (
        nombre,
        descripcion
    )
    VALUES
    (
        @nombre,
        @descripcion
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION HABILITACIONES
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.modificarHabilitacion
(
    @idHabilitacion INT,
    @nombre VARCHAR(50),
    @descripcion VARCHAR(200) = NULL
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.habilitaciones
        WHERE idHabilitaciones = @idHabilitacion
    )
    BEGIN
        RAISERROR('La habilitación no existe.',16,1);
        RETURN;
    END;

    UPDATE Personal.habilitaciones
    SET
        nombre = @nombre,
        descripcion = @descripcion
    WHERE idHabilitaciones = @idHabilitacion;

END;
GO

---------------------------------------------------------
-- BAJA HABILITACIONES
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.bajaHabilitacion
(
    @idHabilitacion INT
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.habilitaciones
        WHERE idHabilitaciones = @idHabilitacion
    )
    BEGIN
        RAISERROR('La habilitación no existe.',16,1);
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM Personal.habilitacionesGuias
        WHERE idHabilitacion = @idHabilitacion
    )
    BEGIN
        RAISERROR('No se puede eliminar la habilitación porque está asociada a guias.',16,1);
        RETURN;
    END;

    DELETE FROM Personal.habilitaciones
    WHERE idHabilitaciones = @idHabilitacion;

END;
GO

/*=======================================================
STORE PROCEDURE TABLA HABILITACIONES GUIAS POR PARQUE
=======================================================*/
---------------------------------------------------------
-- ALTA HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.altaHabilitacionGuia
(
    @idHabilitacion INT,
    @legajoGuia INT,
    @idParque INT,
    @fechaComienzo DATE,
    @fechaFin DATE
)
AS
BEGIN

    IF @fechaFin < @fechaComienzo
    BEGIN
        RAISERROR('La fecha fin no puede ser menor a la fecha inicio.',16,1);
        RETURN;
    END

    INSERT INTO Personal.habilitacionesGuias
    (
        idHabilitacion,
        legajoGuia,
        idParque,
        fechaComienzo,
        fechaFin
    )
    VALUES
    (
        @idHabilitacion,
        @legajoGuia,
        @idParque,
        @fechaComienzo,
        @fechaFin
    );

END;
GO

---------------------------------------------------------
-- MODIFICACION HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Personal.modificarHabilitacionGuia
(
    @idHabilitacionGuia INT,
    @idHabilitacion INT,
    @legajoGuia INT,
    @idParque INT,
    @fechaComienzo DATE,
    @fechaFin DATE
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.habilitacionesGuias
        WHERE idHabilitacionGuia = @idHabilitacionGuia
    )
    BEGIN
        RAISERROR('La habilitación del guía no existe.',16,1);
        RETURN;
    END;

    IF @fechaFin < @fechaComienzo
    BEGIN
        RAISERROR('La fecha fin no puede ser menor a la fecha comienzo.',16,1);
        RETURN;
    END;

    UPDATE Personal.habilitacionesGuias
    SET
        idHabilitacion = @idHabilitacion,
        legajoGuia = @legajoGuia,
        idParque = @idParque,
        fechaComienzo = @fechaComienzo,
        fechaFin = @fechaFin
    WHERE idHabilitacionGuia = @idHabilitacionGuia;

END;
GO

---------------------------------------------------------
-- BAJA HABILITACIONES GUIAS POR PARQUE
---------------------------------------------------------
CREATE OR ALTER PROCEDURE Personal.bajaHabilitacionGuia
(
    @idHabilitacionGuia INT
)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.habilitacionesGuias
        WHERE idHabilitacionGuia = @idHabilitacionGuia
    )
    BEGIN
        RAISERROR('La habilitación del guía no existe.',16,1);
        RETURN;
    END;

    DELETE FROM Personal.habilitacionesGuias
    WHERE idHabilitacionGuia = @idHabilitacionGuia;

END;
GO
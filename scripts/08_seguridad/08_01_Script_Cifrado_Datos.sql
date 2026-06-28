/* 
    Script generado el 13/06/26

Grupo n�7
Integrantes:    - Acu�a, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leonel
                - Zambrana, Mijael

Descripci�n del Script: Este script crea la encriptaicon de datos sensibles en la base de datos
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO


/*=======================================================
CREACION MASTER KEY DE LA BASE DE DATOS
=======================================================*/
-- La Master Key es la llave principal de la base de datos. SQL Server la usa para proteger certificados y otras llaves.

IF NOT EXISTS (
    SELECT *
    FROM sys.symmetric_keys
    WHERE name = '##MS_DatabaseMasterKey##'
)
BEGIN
    CREATE MASTER KEY
    ENCRYPTION BY PASSWORD = 'TpBDDA_Grupo7';
END;
GO

/*=======================================================
CREACION CERTIFICADO DEL DNI
=======================================================*/
-- El certificado protege la clave sim�trica.
-- No cifra el DNI.
-- Protege la llave que s� lo har�.

IF NOT EXISTS (
    SELECT *
    FROM sys.certificates
    WHERE name = 'CertificadoDNI'
)
BEGIN
    CREATE CERTIFICATE CertificadoDNI
    WITH SUBJECT = 'Certificado para cifrado de documentos';
END;
GO

/*=======================================================
CREACION CLAVE SIMETRICA
=======================================================*/
-- llave que se utilizara para cifrar los DNI.
-- AES_256 es el algoritmo que se utilizara para cifrar
--      es muy seguro;
--      es el algoritmo recomendado por Microsoft;
--      es est�ndar en la industria.

IF NOT EXISTS (
    SELECT *
    FROM sys.symmetric_keys
    WHERE name = 'ClaveDNI'
)
BEGIN
    CREATE SYMMETRIC KEY ClaveDNI
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CertificadoDNI;
END;
GO

/*=======================================================
CIFRAR GUARDAPARQUES DNI
=======================================================*/
-- ver los datos antes
-- select * from Personal.guardaparques

-- Agregamos una columna temporal para cifrar el DNI

ALTER TABLE Personal.guardaparques
ADD documentoTemporal VARBINARY(MAX);
GO

-- Cargamos la columna con los DNI Cifrados

OPEN SYMMETRIC KEY ClaveDNI
DECRYPTION BY CERTIFICATE CertificadoDNI;
GO

UPDATE Personal.guardaparques
SET documentoTemporal = EncryptByKey(Key_GUID('ClaveDNI'), documento);
GO

CLOSE SYMMETRIC KEY ClaveDNI;
GO

-- VEMOS LAS CONSTRAINT RELACIONADAS CON DOCUMENTO
/*
SELECT name, type_desc
FROM sys.objects
WHERE parent_object_id = OBJECT_ID('Personal.guardaparques');
*/

-- Eliminamos los constraint y la columna documento

ALTER TABLE Personal.guardaparques
DROP CONSTRAINT CK_documentos_Guardaparques;
GO

ALTER TABLE Personal.guardaparques
DROP CONSTRAINT UQ_documento_Guardaparques;
GO

ALTER TABLE Personal.guardaparques
DROP COLUMN documento;
GO

-- renombramos la columna documento Temporal a documento

EXEC sp_rename 'Personal.guardaparques.documentoTemporal', 'documento', 'COLUMN';
GO

-- agregamos un hash del documento para verificar que no se repitan

ALTER TABLE Personal.guardaparques
ADD documentoHash VARBINARY(32);
GO

-- CARGAMOS EL HASH

UPDATE Personal.guardaparques
SET documentoHash = HASHBYTES('SHA2_256', documento);

-- CREAMOS LOS CONSTRAINT

ALTER TABLE Personal.guardaparques
ALTER COLUMN documentoHash VARBINARY(32) NOT NULL;
GO

ALTER TABLE Personal.guardaparques
ADD CONSTRAINT UQ_guardaparques_documentoHash
UNIQUE (documentoHash);
GO

-- ALTERAR LOS SP
-- dar de alta guardaparques

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

    DECLARE @errorMsg VARCHAR(MAX) = '';


    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errorMsg += '- El nombre es obligatorio.' + CHAR(13) + CHAR(10);

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errorMsg += '- El apellido es obligatorio.' + CHAR(13) + CHAR(10);

    IF @documento IS NULL OR LTRIM(RTRIM(@documento)) = ''
        SET @errorMsg += '- El documento es obligatorio.' + CHAR(13) + CHAR(10);

    IF @documento IS NOT NULL
       AND @documento NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        SET @errorMsg += '- El documento debe contener exactamente 8 d�gitos num�ricos.' + CHAR(13) + CHAR(10);

    IF @fechaNacimiento >= DATEADD(YEAR,-18,GETDATE())
        SET @errorMsg += '- La fecha de nacimiento es inv�lida. Debe ser mayor de 18 a�os.' + CHAR(13) + CHAR(10);

    IF @estado NOT IN ('ACTIVO','INACTIVO','SUSPENDIDO','LICENCIA')
        SET @errorMsg += '- El estado es inv�lido.' + CHAR(13) + CHAR(10);

    IF LEN(@errorMsg) > 0
        THROW 50401,@errorMsg,1;

    BEGIN TRY

        OPEN SYMMETRIC KEY ClaveDNI
        DECRYPTION BY CERTIFICATE CertificadoDNI;

        INSERT INTO Personal.guardaparques
        (
            documento,
            documentoHash,
            nombre,
            apellido,
            fechaNacimiento,
            estado
        )
        VALUES
        (
            EncryptByKey(Key_GUID('ClaveDNI'), @documento),
            HASHBYTES('SHA2_256', @documento),
            @nombre,
            @apellido,
            @fechaNacimiento,
            @estado
        );

        CLOSE SYMMETRIC KEY ClaveDNI;

    END TRY
    BEGIN CATCH

        IF EXISTS (
            SELECT *
            FROM sys.openkeys
            WHERE key_name = 'ClaveDNI'
        )
            CLOSE SYMMETRIC KEY ClaveDNI;

        IF ERROR_NUMBER() IN (2601,2627)
            THROW 50402,'Ya existe un guardaparque con ese documento.',1;

        THROW;

    END CATCH
END;
GO

-- modificacion guardaparques

CREATE OR ALTER PROCEDURE Personal.modificarGuardaparque
(
    @legajo INT,
    @nuevoDocumento CHAR(8) = NULL,
    @nuevoNombre VARCHAR(50) = NULL,
    @nuevoApellido VARCHAR(50) = NULL,
    @nuevaFechaNacimiento DATE = NULL,
    @nuevoEstado VARCHAR(10) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errorMsg VARCHAR(MAX) = '';

 
    -- Validaciones
   

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.guardaparques
        WHERE legajo = @legajo
    )
        SET @errorMsg += '- El legajo no existe.' + CHAR(13) + CHAR(10);

    IF @nuevoDocumento IS NOT NULL
       AND @nuevoDocumento NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        SET @errorMsg += '- El documento debe contener exactamente 8 d�gitos.' + CHAR(13) + CHAR(10);

    IF @nuevaFechaNacimiento IS NOT NULL
       AND @nuevaFechaNacimiento >= DATEADD(YEAR,-18,GETDATE())
        SET @errorMsg += '- La fecha de nacimiento es inv�lida. Debe ser mayor de 18 a�os.' + CHAR(13) + CHAR(10);

    IF @nuevoEstado IS NOT NULL
       AND @nuevoEstado NOT IN ('ACTIVO','INACTIVO','SUSPENDIDO','LICENCIA')
        SET @errorMsg += '- El estado es inv�lido.' + CHAR(13) + CHAR(10);

    IF LEN(@errorMsg) > 0
        THROW 50403,@errorMsg,1;

   
    -- Modificaci�n
  

    BEGIN TRY

        OPEN SYMMETRIC KEY ClaveDNI
        DECRYPTION BY CERTIFICATE CertificadoDNI;

        UPDATE Personal.guardaparques
        SET
            documento =
                CASE
                    WHEN @nuevoDocumento IS NULL
                        THEN documento
                    ELSE EncryptByKey(Key_GUID('ClaveDNI'), @nuevoDocumento)
                END,

            documentoHash =
                CASE
                    WHEN @nuevoDocumento IS NULL
                        THEN documentoHash
                    ELSE HASHBYTES('SHA2_256', @nuevoDocumento)
                END,

            nombre = ISNULL(@nuevoNombre,nombre),
            apellido = ISNULL(@nuevoApellido,apellido),
            fechaNacimiento = ISNULL(@nuevaFechaNacimiento,fechaNacimiento),
            estado = ISNULL(@nuevoEstado,estado)

        WHERE legajo = @legajo;

        CLOSE SYMMETRIC KEY ClaveDNI;

    END TRY
    BEGIN CATCH

        IF EXISTS
        (
            SELECT *
            FROM sys.openkeys
            WHERE key_name='ClaveDNI'
        )
            CLOSE SYMMETRIC KEY ClaveDNI;

        IF ERROR_NUMBER() IN (2601,2627)
            THROW 50404,'Ya existe otro guardaparque con ese documento.',1;

        THROW;

    END CATCH

END;
GO

/*=======================================================
CIFRAR GUIAS DNI
=======================================================*/
-- ver los datos antes
-- select * from Personal.guias

-- Agregamos una columna temporal para cifrar el DNI

ALTER TABLE Personal.guias
ADD documentoTemporal VARBINARY(MAX);

-- Cargamos la columna con los DNI Cifrados

OPEN SYMMETRIC KEY ClaveDNI
DECRYPTION BY CERTIFICATE CertificadoDNI;
GO

UPDATE Personal.guias
SET documentoTemporal = EncryptByKey(Key_GUID('ClaveDNI'), documento);
GO

CLOSE SYMMETRIC KEY ClaveDNI;
GO

-- VEMOS LAS CONSTRAINT RELACIONADAS CON DOCUMENTO
/*
SELECT name, type_desc
FROM sys.objects
WHERE parent_object_id = OBJECT_ID('Personal.guias');
*/

-- Eliminamos los constraint y la columna documento

ALTER TABLE Personal.guias
DROP CONSTRAINT CK_documentos_Guias;
GO

ALTER TABLE Personal.guias
DROP CONSTRAINT UQ_documento_Guias;
GO

ALTER TABLE Personal.guias
DROP COLUMN documento;
GO

-- renombramos la columna documento Temporal a documento

EXEC sp_rename 'Personal.guias.documentoTemporal', 'documento', 'COLUMN';

-- agregamos un hash del documento para verificar que no se repitan

ALTER TABLE Personal.guias
ADD documentoHash VARBINARY(32);
GO

-- CARGAMOS EL HASH

UPDATE Personal.guias
SET documentoHash = HASHBYTES('SHA2_256', documento);

-- creamos los constraint del hash

ALTER TABLE Personal.guias
ALTER COLUMN documentoHash VARBINARY(32) NOT NULL;
GO

ALTER TABLE Personal.guias
ADD CONSTRAINT UQ_guias_documentoHash
UNIQUE (documentoHash);
GO



--Alterar los SP de guias

-- ALTA GUIAS

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
    SET NOCOUNT ON;

    DECLARE @errorMsg VARCHAR(MAX) = '';

    ---------------------------------------------------------
    -- Validaciones
    ---------------------------------------------------------

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errorMsg += '- El nombre es obligatorio.' + CHAR(13) + CHAR(10);

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errorMsg += '- El apellido es obligatorio.' + CHAR(13) + CHAR(10);

    IF @documento IS NULL OR LTRIM(RTRIM(@documento)) = ''
        SET @errorMsg += '- El documento es obligatorio.' + CHAR(13) + CHAR(10);

    IF @documento IS NOT NULL
       AND @documento NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        SET @errorMsg += '- El documento debe contener exactamente 8 d�gitos.' + CHAR(13) + CHAR(10);

    IF @fechaNacimiento >= DATEADD(YEAR,-18,GETDATE())
        SET @errorMsg += '- La fecha de nacimiento es inv�lida. Debe ser mayor de 18 a�os.' + CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Personal.titulos WHERE codTitulo = @codTitulo)
        SET @errorMsg += '- El t�tulo indicado no existe.' + CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Personal.especialidad WHERE codEspecialidad = @codEspecialidad)
        SET @errorMsg += '- La especialidad indicada no existe.' + CHAR(13) + CHAR(10);

    IF LEN(@errorMsg) > 0
        THROW 50410, @errorMsg, 1;

    ---------------------------------------------------------
    -- Inserci�n
    ---------------------------------------------------------

    BEGIN TRY

        OPEN SYMMETRIC KEY ClaveDNI
        DECRYPTION BY CERTIFICATE CertificadoDNI;

        INSERT INTO Personal.guias
        (
            documento,
            documentoHash,
            nombre,
            apellido,
            fechaNacimiento,
            codTitulo,
            codEspecialidad
        )
        VALUES
        (
            EncryptByKey(Key_GUID('ClaveDNI'), @documento),
            HASHBYTES('SHA2_256', @documento),
            @nombre,
            @apellido,
            @fechaNacimiento,
            @codTitulo,
            @codEspecialidad
        );

        CLOSE SYMMETRIC KEY ClaveDNI;

    END TRY
    BEGIN CATCH

        IF EXISTS (SELECT * FROM sys.openkeys WHERE key_name = 'ClaveDNI')
            CLOSE SYMMETRIC KEY ClaveDNI;

        IF ERROR_NUMBER() IN (2601,2627)
            THROW 50411,'Ya existe un gu�a con ese documento.',1;

        THROW;

    END CATCH

END;
GO

-- MODIFICACION GUIAS

CREATE OR ALTER PROCEDURE Personal.modificarGuia
(
    @legajo INT,
    @nuevoDocumento CHAR(8) = NULL,
    @nombre VARCHAR(50) = NULL,
    @apellido VARCHAR(50) = NULL,
    @fechaNacimiento DATE = NULL,
    @codTitulo INT = NULL,
    @codEspecialidad INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errorMsg VARCHAR(MAX)='';

    ---------------------------------------------------------
    -- Validaciones
    ---------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM Personal.guias
        WHERE legajo = @legajo
    )
        SET @errorMsg += '- El legajo no existe.' + CHAR(13)+CHAR(10);

    IF @nuevoDocumento IS NOT NULL
       AND @nuevoDocumento NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        SET @errorMsg += '- El documento debe contener exactamente 8 d�gitos.' + CHAR(13)+CHAR(10);

    IF @fechaNacimiento IS NOT NULL
       AND @fechaNacimiento >= DATEADD(YEAR,-18,GETDATE())
        SET @errorMsg += '- La fecha de nacimiento es inv�lida. Debe ser mayor de 18 a�os.' + CHAR(13)+CHAR(10);

    IF @codTitulo IS NOT NULL
       AND NOT EXISTS(SELECT 1 FROM Personal.titulos WHERE codTitulo=@codTitulo)
        SET @errorMsg += '- El t�tulo indicado no existe.' + CHAR(13)+CHAR(10);

    IF @codEspecialidad IS NOT NULL
       AND NOT EXISTS(SELECT 1 FROM Personal.especialidad WHERE codEspecialidad=@codEspecialidad)
        SET @errorMsg += '- La especialidad indicada no existe.' + CHAR(13)+CHAR(10);

    IF LEN(@errorMsg)>0
        THROW 50412,@errorMsg,1;

    ---------------------------------------------------------
    -- Actualizaci�n
    ---------------------------------------------------------

    BEGIN TRY

        OPEN SYMMETRIC KEY ClaveDNI
        DECRYPTION BY CERTIFICATE CertificadoDNI;

        UPDATE Personal.guias
        SET
            documento =
                CASE
                    WHEN @nuevoDocumento IS NULL THEN documento
                    ELSE EncryptByKey(Key_GUID('ClaveDNI'), @nuevoDocumento)
                END,

            documentoHash =
                CASE
                    WHEN @nuevoDocumento IS NULL THEN documentoHash
                    ELSE HASHBYTES('SHA2_256', @nuevoDocumento)
                END,

            nombre = ISNULL(@nombre,nombre),
            apellido = ISNULL(@apellido,apellido),
            fechaNacimiento = ISNULL(@fechaNacimiento,fechaNacimiento),
            codTitulo = ISNULL(@codTitulo,codTitulo),
            codEspecialidad = ISNULL(@codEspecialidad,codEspecialidad)

        WHERE legajo=@legajo;

        CLOSE SYMMETRIC KEY ClaveDNI;

    END TRY
    BEGIN CATCH

        IF EXISTS (SELECT * FROM sys.openkeys WHERE key_name='ClaveDNI')
            CLOSE SYMMETRIC KEY ClaveDNI;

        IF ERROR_NUMBER() IN (2601,2627)
            THROW 50413,'Ya existe un gu�a con ese documento.',1;

        THROW;

    END CATCH

END;
GO
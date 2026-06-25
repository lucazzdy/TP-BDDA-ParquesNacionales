/* 
    Script generado el 19/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Tablas auxiliares para importacion masiva
                            de datos desde SIB (XLSX) y CIAM (CSV).
                            Staging tables + log de errores.
*/

USE GestionParquesNacionales;
GO

-- Staging para el dataset SIB (areas protegidas con datos completos)
IF OBJECT_ID('Gestion.stagingSib', 'U') IS NULL
BEGIN
    -- Todas las columnas en VARCHAR para que BULK INSERT no falle por tipos.
    -- La conversion a INT/DECIMAL se hace despues en el SP de procesamiento
    -- usando TRY_CAST, que devuelve NULL si no puede convertir.
    CREATE TABLE Gestion.stagingSib (
        provincia VARCHAR(100) NULL,
        nombreCompleto VARCHAR(200) NULL,
        anioCreacion VARCHAR(20) NULL,
        region VARCHAR(100) NULL,
        superficie VARCHAR(30) NULL,
        latitud VARCHAR(30) NULL,
        longitud VARCHAR(30) NULL,
        leyCreacion VARCHAR(100) NULL,
        ecorregiones VARCHAR(200) NULL,
        categoriaInternacional VARCHAR(200) NULL,
        especiesRegistradas VARCHAR(20) NULL,
        animales VARCHAR(20) NULL,
        bacterias VARCHAR(20) NULL,
        hongos VARCHAR(20) NULL,
        plantas VARCHAR(20) NULL
    );
END
GO

-- Staging para el dataset CIAM (actualizacion de superficies)
IF OBJECT_ID('Gestion.stagingCiam', 'U') IS NULL
BEGIN
    CREATE TABLE Gestion.stagingCiam (
        region VARCHAR(100) NULL,
        nombreCompleto VARCHAR(200) NULL,
        hectareas VARCHAR(30) NULL,
        categoriaInternacional VARCHAR(200) NULL
    );
END
GO

-- Log de importacion: registra el resultado de cada fila procesada
IF OBJECT_ID('Gestion.logImportacion', 'U') IS NULL
BEGIN
    CREATE TABLE Gestion.logImportacion (
        idLog INT IDENTITY(1, 1) NOT NULL,
        fechaProceso DATETIME NOT NULL DEFAULT GETDATE(),
        origen VARCHAR(20) NOT NULL,           -- 'SIB' o 'CIAM'
        nombreCompleto VARCHAR(200) NULL,
        estado VARCHAR(20) NOT NULL,           -- 'OK', 'ERROR', 'SALTADO'
        mensaje VARCHAR(500) NULL,
        CONSTRAINT PK_logImportacion PRIMARY KEY (idLog)
    );
END
GO

DROP TABLE Personal.stagingCsvGuias
DROP TABLE Personal.stagingTitulos
DROP TABLE Personal.stagingGuias
IF OBJECT_ID('Personal.stagingCsvGuias') IS NULL
BEGIN
    CREATE TABLE Personal.stagingCsvGuias (
        leg VARCHAR(50),
        apellidoYNombre VARCHAR(150),
        domicilio VARCHAR(150),
        localidad VARCHAR(100),
        telefonos VARCHAR(100),
        titulo VARCHAR(100),
        doc VARCHAR(50),
        resol VARCHAR(50),
        actualizac VARCHAR(50),
        anoInscri VARCHAR(50),
        resolReinscrip VARCHAR(50),
        email VARCHAR(100)
    );
    END;
GO

IF OBJECT_ID('Personal.stagingTitulos') IS NULL
    BEGIN
    CREATE TABLE Personal.stagingTitulos (
        nombre VARCHAR(100)
    );
    END
GO

IF OBJECT_ID('Personal.stagingGuias') IS NULL
BEGIN
    CREATE TABLE Personal.stagingGuias (
        documento CHAR(8),
        nombre VARCHAR(50),
        apellido VARCHAR(50),
        fechaNacimiento DATE,
        nombreTitulo VARCHAR(100),
        codEspecialidad INT
    )
END;
GO
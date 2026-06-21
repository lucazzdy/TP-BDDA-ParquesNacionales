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
    CREATE TABLE Gestion.stagingSib (
        provincia VARCHAR(100) NULL,
        nombreCompleto VARCHAR(200) NULL,
        anioCreacion INT NULL,
        region VARCHAR(100) NULL,
        superficie DECIMAL(12, 2) NULL,
        latitud DECIMAL(9, 6) NULL,
        longitud DECIMAL(9, 6) NULL,
        leyCreacion VARCHAR(100) NULL,
        ecorregiones VARCHAR(200) NULL,
        categoriaInternacional VARCHAR(200) NULL,
        especiesRegistradas INT NULL,
        animales INT NULL,
        bacterias INT NULL,
        hongos INT NULL,
        plantas INT NULL
    );
END
GO

-- Staging para el dataset CIAM (actualizacion de superficies)
IF OBJECT_ID('Gestion.stagingCiam', 'U') IS NULL
BEGIN
    CREATE TABLE Gestion.stagingCiam (
        region VARCHAR(100) NULL,
        nombreCompleto VARCHAR(200) NULL,
        hectareas DECIMAL(12, 2) NULL,
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

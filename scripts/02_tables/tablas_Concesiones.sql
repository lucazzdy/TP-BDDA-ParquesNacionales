/* 
    Script generado el 18/06/26
 
Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael
 
Descripción del Script: Este script genera todas las tablas del esquema Concesiones
*/

USE GestionParquesNacionales;
GO
 
-- Tipos de concesion: comercio, restaurante, empresa de turismo, etc.
IF OBJECT_ID('Concesiones.TipoConcesion', 'U') IS NULL
BEGIN
    CREATE TABLE Concesiones.TipoConcesion (
        idTipoConcesion INT IDENTITY(1,1) NOT NULL,
        descripcion VARCHAR(100) NOT NULL UNIQUE,
        CONSTRAINT PK_TipoConcesion PRIMARY KEY (idTipoConcesion)
    );
END
GO
 
-- Empresas concesionarias
IF OBJECT_ID('Concesiones.Empresa', 'U') IS NULL
BEGIN
    CREATE TABLE Concesiones.Empresa (
        idEmpresa INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL UNIQUE,
        CONSTRAINT PK_Empresa PRIMARY KEY (idEmpresa)
    );
END
GO
 
-- Contrato de concesion entre una empresa y un parque
IF OBJECT_ID('Concesiones.Concesion', 'U') IS NULL
BEGIN
    CREATE TABLE Concesiones.Concesion (
        idConcesion INT IDENTITY(1,1) NOT NULL,
        idEmpresa INT NOT NULL,
        idParque INT NOT NULL,
        idTipoConcesion INT NOT NULL,
        fechaInicio DATE NOT NULL,
        fechaFin DATE NOT NULL,
        montoCanonMensual DECIMAL(12, 2) NOT NULL,
        CONSTRAINT PK_Concesion PRIMARY KEY (idConcesion),
        -- FK a la empresa concesionaria
        CONSTRAINT FK_Concesion_Empresa FOREIGN KEY (idEmpresa) REFERENCES Concesiones.Empresa(idEmpresa),
        -- FK al parque donde opera
        CONSTRAINT FK_Concesion_Parque FOREIGN KEY (idParque) REFERENCES Gestion.Parque(idParque),
        -- FK al tipo de concesion
        CONSTRAINT FK_Concesion_TipoConcesion FOREIGN KEY (idTipoConcesion) REFERENCES Concesiones.TipoConcesion(idTipoConcesion)
    );
END
GO
 
-- Pagos mensuales del canon de cada concesion
IF OBJECT_ID('Concesiones.PagoCanon', 'U') IS NULL
BEGIN
    CREATE TABLE Concesiones.PagoCanon (
        idPagoCanon INT IDENTITY(1,1) NOT NULL,
        idConcesion INT NOT NULL,
        fecha DATE NOT NULL,
        monto DECIMAL(12, 2) NOT NULL,
        periodo CHAR(7) NOT NULL,
        estado VARCHAR(20) NOT NULL,
        CONSTRAINT PK_PagoCanon PRIMARY KEY (idPagoCanon),
        -- FK a la concesion
        CONSTRAINT FK_PagoCanon_Concesion FOREIGN KEY (idConcesion) REFERENCES Concesiones.Concesion(idConcesion)
    );
END
GO

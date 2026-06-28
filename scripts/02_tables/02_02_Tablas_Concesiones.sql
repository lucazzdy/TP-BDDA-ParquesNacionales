/* 
    Script generado el 18/06/26
 
Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael
 
Descripción del Script: Este script genera todas las tablas del esquema Concesiones
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO
 
-- Tipos de concesion: comercio, restaurante, empresa de turismo, etc.
IF OBJECT_ID('Concesiones.tipoConcesion', 'U') IS NULL
BEGIN
    CREATE TABLE Concesiones.tipoConcesion (
        idTipoConcesion INT IDENTITY(1,1) NOT NULL,
        descripcion VARCHAR(100) NOT NULL UNIQUE,
        CONSTRAINT PK_tipoConcesion PRIMARY KEY (idTipoConcesion)
    );
END
GO
 
-- Empresas concesionarias
IF OBJECT_ID('Concesiones.empresa', 'U') IS NULL
BEGIN
    CREATE TABLE Concesiones.empresa (
        idEmpresa INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL UNIQUE,
        CONSTRAINT PK_empresa PRIMARY KEY (idEmpresa)
    );
END
GO
 
-- Contrato de concesion entre una empresa y un parque
IF OBJECT_ID('Concesiones.concesion', 'U') IS NULL
BEGIN
    CREATE TABLE Concesiones.concesion (
        idConcesion INT IDENTITY(1,1) NOT NULL,
        idEmpresa INT NOT NULL,
        idParque INT NOT NULL,
        idTipoConcesion INT NOT NULL,
        fechaInicio DATE NOT NULL,
        fechaFin DATE NOT NULL,
        montoCanonMensual DECIMAL(12, 2) NOT NULL,
        CONSTRAINT PK_concesion PRIMARY KEY (idConcesion),
        -- FK a la empresa concesionaria
        CONSTRAINT FK_concesion_empresa FOREIGN KEY (idEmpresa) REFERENCES Concesiones.empresa(idEmpresa),
        -- FK al parque donde opera
        CONSTRAINT FK_concesion_parque FOREIGN KEY (idParque) REFERENCES Gestion.parque(idParque),
        -- FK al tipo de concesion
        CONSTRAINT FK_concesion_tipoConcesion FOREIGN KEY (idTipoConcesion) REFERENCES Concesiones.tipoConcesion(idTipoConcesion)
    );
END
GO
 
-- Pagos mensuales del canon de cada concesion
IF OBJECT_ID('Concesiones.pagoCanon', 'U') IS NULL
BEGIN
    CREATE TABLE Concesiones.pagoCanon (
        idPagoCanon INT IDENTITY(1,1) NOT NULL,
        idConcesion INT NOT NULL,
        fecha DATE NOT NULL,
        monto DECIMAL(12, 2) NOT NULL,
        periodo CHAR(7) NOT NULL,
        estado VARCHAR(20) NOT NULL,
        CONSTRAINT PK_pagoCanon PRIMARY KEY (idPagoCanon),
        -- FK a la concesion
        CONSTRAINT FK_pagoCanon_concesion FOREIGN KEY (idConcesion) REFERENCES Concesiones.concesion(idConcesion)
    );
END
GO
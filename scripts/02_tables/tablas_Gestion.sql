/* 
    Script generado el 18/06/26
 
Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael
 
Descripción del Script: Este script genera todas las tablas del esquema Gestion
*/


USE GestionParquesNacionales;
GO

-- Tipos de parque: nacional, reserva, monumento, etc
IF OBJECT_ID('Gestion.tipoParque', 'U') IS NULL
BEGIN
    CREATE TABLE Gestion.tipoParque (
        idTipoParque INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(50) NOT NULL UNIQUE,
        descripcion VARCHAR(200) NULL,
        CONSTRAINT PK_tipoParque PRIMARY KEY (idTipoParque)
    );
END
GO

-- Datos del parque y su ubicacion
IF OBJECT_ID('Gestion.parque', 'U') IS NULL
BEGIN
    CREATE TABLE Gestion.parque (
        idParque INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL UNIQUE,
        superficie DECIMAL(12, 2) NOT NULL,
        idTipoParque INT NOT NULL,
        provincia VARCHAR(50) NOT NULL,
        codigoPostal VARCHAR(10) NULL,
        calle VARCHAR(100) NULL,
        nro VARCHAR(10) NULL,
        CONSTRAINT PK_parque PRIMARY KEY (idParque),
        -- FK al tipo de parque
        CONSTRAINT FK_parque_tipoParque FOREIGN KEY (idTipoParque) REFERENCES Gestion.tipoParque(idTipoParque)
    );
END
GO
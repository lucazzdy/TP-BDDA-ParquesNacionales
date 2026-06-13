USE GestionParquesNacionales;
GO

-- Tipos de parque: nacional, reserva, monumento, etc
IF OBJECT_ID('Gestion.TipoParque', 'U') IS NULL
BEGIN
    CREATE TABLE Gestion.TipoParque (
        idTipoParque INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(50) NOT NULL UNIQUE,
        descripcion VARCHAR(200) NULL,
        CONSTRAINT PK_TipoParque PRIMARY KEY (idTipoParque)
    );
END
GO

-- Datos del parque y su ubicacion
IF OBJECT_ID('Gestion.Parque', 'U') IS NULL
BEGIN
    CREATE TABLE Gestion.Parque (
        idParque INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL UNIQUE,
        superficie DECIMAL(12, 2) NOT NULL,
        idTipoParque INT NOT NULL,
        provincia VARCHAR(50) NOT NULL,
        codigoPostal VARCHAR(10) NULL,
        calle VARCHAR(100) NULL,
        nro VARCHAR(10) NULL,
        CONSTRAINT PK_Parque PRIMARY KEY (idParque),
        -- FK al tipo de parque
        CONSTRAINT FK_Parque_TipoParque FOREIGN KEY (idTipoParque) REFERENCES Gestion.TipoParque(idTipoParque)
    );
END
GO
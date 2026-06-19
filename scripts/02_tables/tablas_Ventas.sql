/* 
    Script generado el 18/06/2026

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Este script genera todas las tablas del esquema Ventas
*/

USE GestionParquesNacionales;
GO

-- VALIDACION Y ELIMINACION DE TABLAS PREVIAS (en orden inverso por las FK)
IF OBJECT_ID('Ventas.EntradaActividad', 'U') IS NOT NULL DROP TABLE Ventas.EntradaActividad;
IF OBJECT_ID('Ventas.Entrada', 'U') IS NOT NULL DROP TABLE Ventas.Entrada;
IF OBJECT_ID('Ventas.Pago', 'U') IS NOT NULL DROP TABLE ventas.Pago;
IF OBJECT_ID('Ventas.ItemVenta', 'U') IS NOT NULL DROP TABLE ventas.ItemVenta;
IF OBJECT_ID('Ventas.Venta', 'U') IS NOT NULL DROP TABLE ventas.Venta;
IF OBJECT_ID('Ventas.PreciosParque', 'U') IS NOT NULL DROP TABLE ventas.PreciosParque;
IF OBJECT_ID('Ventas.FormaPago', 'U') IS NOT NULL DROP TABLE ventas.FormaPago;
IF OBJECT_ID('Ventas.Visitante', 'U') IS NOT NULL DROP TABLE ventas.Visitante;
IF OBJECT_ID('Ventas.TipoVisitante', 'U') IS NOT NULL DROP TABLE ventas.TipoVisitante;
GO


-- CREACION DE TABLAS

IF OBJECT_ID('Ventas.TipoVisitante', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.TipoVisitante(
        IDTipoVisitante INT IDENTITY(1,1),
        Descripcion VARCHAR (20) NOT NULL,
        CONSTRAINT PK_TipoVisitante PRIMARY KEY (IDTipoVisitante)
    )
END
GO

IF OBJECT_ID('Ventas.Visitante', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.Visitante(
        IDVisitante INT IDENTITY(1,1),
        IDTipoVisitante INT NOT NULL,
        Nombre VARCHAR(50) NOT NULL,
        Apellido VARCHAR (50) NOT NULL,
        FechaNacimiento DATE NOT NULL CHECK (FechaNacimiento <= GETDATE()),
        TipoDocumento VARCHAR (20) NOT NULL,
        NumeroDocumento INT NOT NULL CHECK (NumeroDocumento > 0),
        CONSTRAINT PK_Visitante PRIMARY KEY (IDVisitante),
        CONSTRAINT FK_Visitante_TipoVisitante FOREIGN KEY (IDTipoVisitante) REFERENCES Ventas.TipoVisitante (IDTipoVisitante),
        CONSTRAINT UQ_Visitante_TipoDocumento_NumeroDocumento UNIQUE (TipoDocumento, NumeroDocumento)
    );
END
GO


IF OBJECT_ID('Ventas.FormaPago', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.FormaPago(
        IDFormaPago INT IDENTITY(1,1),
        Descripcion VARCHAR(30) NOT NULL,
        CONSTRAINT PK_FormaPago PRIMARY KEY (IDFormaPago) 
    );
END
GO

IF OBJECT_ID('Ventas.PreciosParque', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.PreciosParque(
        IDParque INT NOT NULL,
        IDTipoVisitante INT NOT NULL,
        FechaDesde DATE NOT NULL DEFAULT GETDATE(),
        Precio DECIMAL(10,2) CHECK( Precio >= 0),
        CONSTRAINT PK_PreciosParque PRIMARY KEY (IDParque, IDTipoVisitante, FechaDesde),
        CONSTRAINT FK_PreciosParque_TipoVisitante FOREIGN KEY (IDTipoVisitante) REFERENCES Ventas.TipoVisitante(IDTipoVisitante),
        CONSTRAINT FK_PreciosParque_Parque FOREIGN KEY (IDParque) REFERENCES Gestion.Parque(idParque)
    );
END
GO

IF OBJECT_ID('Ventas.Venta', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.Venta(
        IDVenta INT IDENTITY(1,1),
        IDParque INT NOT NULL,
        NumeroFactura INT NOT NULL CHECK (NumeroFactura > 0),
        PuntoVenta INT NOT NULL CHECK (PuntoVenta > 0),
        Total DECIMAL(10,2) NOT NULL,
        CONSTRAINT PK_Venta PRIMARY KEY (IDVenta),
        CONSTRAINT FK_Venta_Parque FOREIGN KEY (IDParque) REFERENCES Gestion.Parque (idParque),
        CONSTRAINT UQ_Venta_PuntoVenta_NumeroFactura UNIQUE (PuntoVenta, NumeroFactura)
    );
END
GO

IF OBJECT_ID('Ventas.ItemVenta', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.ItemVenta(
        IDVenta INT NOT NULL,
        IDItemVenta INT NOT NULL CHECK(IDItemVenta > 0),
        TipoItem VARCHAR(20) NOT NULL CHECK (TipoItem IN ('Entrada', 'Actividad')),
        Cantidad INT NOT NULL CHECK (Cantidad > 0),
        PrecioUnitario DECIMAL (10,2) NOT NULL CHECK(PrecioUnitario >= 0),
        CONSTRAINT PK_ItemVenta PRIMARY KEY (IDItemVenta, IDVenta),
        CONSTRAINT FK_ItemVenta_Venta FOREIGN KEY (IDVenta) REFERENCES Ventas.Venta (IDVenta)
    );
END
GO

IF OBJECT_ID('Ventas.Pago', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.Pago(
        IDPago INT IDENTITY(1,1),
        IDVenta INT NOT NULL,
        IDFormaPago INT NOT NULL,
        Fecha DATETIME DEFAULT GETDATE(),
        Estado NVARCHAR(9) NOT NULL,
        Importe DECIMAL (10,2) CHECK(Importe > 0),
        CONSTRAINT PK_Pago PRIMARY KEY (IDPago),
        CONSTRAINT FK_Pago_Venta FOREIGN KEY (IDVenta) REFERENCES Ventas.Venta (IDVenta),
        CONSTRAINT FK_Pago_FormaPago FOREIGN KEY (IDFormaPago) REFERENCES Ventas.FormaPago (IDFormaPago)
    );
END
GO

IF OBJECT_ID('Ventas.Entrada', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.Entrada (
        CodigoEntrada CHAR(10) NOT NULL CHECK (CodigoEntrada LIKE '[A-Z]-[0-9][0-9][0-9][0-9][0-9][0-9]-[A-Z]'),
        FechaAcceso DATE NOT NULL,              
        FechaCompra DATETIME NOT NULL DEFAULT GETDATE(),
        IDVisitante INT NOT NULL,               
        IDParque INT NOT NULL,                  
        IDTipoVisitante INT NOT NULL,
        Precio DECIMAL (10,2) NOT NULL CHECK (Precio >= 0)     
        CONSTRAINT PK_Entrada PRIMARY KEY (CodigoEntrada),
        CONSTRAINT FK_Entrada_Visitante FOREIGN KEY (IDVisitante) REFERENCES Ventas.Visitante(IDVisitante),
        CONSTRAINT FK_Entrada_Parque FOREIGN KEY (IDParque)  REFERENCES Gestion.Parque(idParque),
        CONSTRAINT FK_Entrada_TipoVisitante FOREIGN KEY (IDTipoVisitante) REFERENCES Ventas.TipoVisitante(IDTipoVisitante)
    );
END
GO

--Esta tabla surge de la relacion N a N entre entrada y actividad
IF OBJECT_ID('Ventas.EntradaActividad', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.EntradaActividad (
        CodigoEntrada CHAR(10) NOT NULL,
        IDActividad INT NOT NULL,
        CONSTRAINT PK_Entrada_Actividad PRIMARY KEY (CodigoEntrada, IDActividad),
        CONSTRAINT FK_Entrada_Actividad_Ent FOREIGN KEY (CodigoEntrada) REFERENCES Ventas.entrada(CodigoEntrada),
        CONSTRAINT FK_Entrada_Actividad_Act FOREIGN KEY (IDActividad) REFERENCES Actividades.Actividad(idActividad)
    );
END
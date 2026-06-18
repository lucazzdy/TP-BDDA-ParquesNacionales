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
IF OBJECT_ID('Ventas.Pago', 'U') IS NOT NULL DROP TABLE ventas.Pago;
IF OBJECT_ID('Ventas.ItemVenta', 'U') IS NOT NULL DROP TABLE ventas.Item_Venta;
IF OBJECT_ID('Ventas.Venta', 'U') IS NOT NULL DROP TABLE ventas.Venta;
IF OBJECT_ID('Ventas.PreciosParque', 'U') IS NOT NULL DROP TABLE ventas.Precios_Parque;
IF OBJECT_ID('Ventas.FormaPago', 'U') IS NOT NULL DROP TABLE ventas.Forma_Pago;
IF OBJECT_ID('Ventas.Visitante', 'U') IS NOT NULL DROP TABLE ventas.Visitante;
IF OBJECT_ID('Ventas.TipoVisitante', 'U') IS NOT NULL DROP TABLE ventas.Tipo_Visitante;
GO


-- CREACION DE TABLAS

IF OBJECT_ID('Ventas.TipoVisitante', 'U') IS NOT NULL
BEGIN
    CREATE TABLE Ventas.TipoVisitante(
        IDTipoVisitante INT IDENTITY(1,1),
        Descripcion VARCHAR (15) NOT NULL,
        CONSTRAINT PK_TipoVisitante PRIMARY KEY (IDTipoVisitante)
    )
END
GO

IF OBJECT_ID('Ventas.Visitante', 'U') IS NOT NULL
BEGIN
    CREATE TABLE Ventas.Visitante(
        IDVisitante INT IDENTITY(1,1),
        Descripcion VARCHAR(50) NOT NULL,
        IDTipoVisitante INT NOT NULL,
        CONSTRAINT PK_Visitante PRIMARY KEY (IDVisitante),
        CONSTRAINT FK_Visitante_TipoVisitante FOREIGN KEY (IDTipoVisitante) REFERENCES Ventas.TipoVisitante (IDTipoVisitante)
    );
END
GO


IF OBJECT_ID('Ventas.FormaPago', 'U') IS NOT NULL
BEGIN
    CREATE TABLE Ventas.FormaPago(
        IDFormaPago INT IDENTITY(1,1),
        Decripcion VARCHAR(30) NOT NULL,
        CONSTRAINT PK_FormaPago PRIMARY KEY (IDFormaPago) 
    );
END
GO

IF OBJECT_ID('Ventas.PreciosParque', 'U') IS NOT NULL
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

IF OBJECT_ID('Ventas.Venta', 'U') IS NOT NULL
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

IF OBJECT_ID('Ventas.ItemVenta', 'U') IS NOT NULL
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

IF OBJECT_ID('Ventas.Pago', 'U') IS NOT NULL
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
        CONSTRAINT FK_Pago_FormaPago FOREIGN KEY (IDFormaPago) REFERENCES Ventas.FormaPago (IDFormaPago),
    );
END
GO
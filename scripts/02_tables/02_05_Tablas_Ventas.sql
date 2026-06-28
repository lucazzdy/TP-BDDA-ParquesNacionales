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
IF OBJECT_ID('Ventas.entradaActividad', 'U') IS NOT NULL DROP TABLE Ventas.entradaActividad;
IF OBJECT_ID('Ventas.entrada', 'U') IS NOT NULL DROP TABLE Ventas.entrada;
IF OBJECT_ID('Ventas.pago', 'U') IS NOT NULL DROP TABLE ventas.pago;
IF OBJECT_ID('Ventas.ticketFactura', 'U') IS NOT NULL DROP TABLE ventas.ticketFactura;
IF OBJECT_ID('Ventas.itemVenta', 'U') IS NOT NULL DROP TABLE ventas.itemVenta;
IF OBJECT_ID('Ventas.venta', 'U') IS NOT NULL DROP TABLE ventas.venta;
IF OBJECT_ID('Ventas.preciosParque', 'U') IS NOT NULL DROP TABLE ventas.preciosParque;
IF OBJECT_ID('Ventas.formaPago', 'U') IS NOT NULL DROP TABLE ventas.formaPago;
IF OBJECT_ID('Ventas.visitante', 'U') IS NOT NULL DROP TABLE ventas.visitante;
IF OBJECT_ID('Ventas.tipoVisitante', 'U') IS NOT NULL DROP TABLE ventas.tipoVisitante;
GO


-- CREACION DE TABLAS

IF OBJECT_ID('Ventas.tipoVisitante', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.tipoVisitante(
        idTipoVisitante INT IDENTITY(1,1),
        descripcion VARCHAR (20) NOT NULL,
        CONSTRAINT PK_TipoVisitante PRIMARY KEY (idTipoVisitante)
    )
END
GO

IF OBJECT_ID('Ventas.visitante', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.visitante(
        idVisitante INT IDENTITY(1,1),
        idTipoVisitante INT NOT NULL,
        nombre VARCHAR(50) NOT NULL,
        apellido VARCHAR (50) NOT NULL,
        fechaNacimiento DATE NOT NULL CHECK (fechaNacimiento <= GETDATE()),
        tipoDocumento VARCHAR (20) NOT NULL,
        numeroDocumento INT NOT NULL CHECK (numeroDocumento > 0),
        CONSTRAINT PK_Visitante PRIMARY KEY (idVisitante),
        CONSTRAINT FK_Visitante_TipoVisitante FOREIGN KEY (idTipoVisitante) REFERENCES Ventas.TipoVisitante (idTipoVisitante),
        CONSTRAINT UQ_Visitante_TipoDocumento_NumeroDocumento UNIQUE (tipoDocumento, numeroDocumento)
    );
END
GO


IF OBJECT_ID('Ventas.formaPago', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.formaPago(
        idFormaPago INT IDENTITY(1,1),
        descripcion VARCHAR(30) NOT NULL,
        CONSTRAINT PK_FormaPago PRIMARY KEY (idFormaPago) 
    );
END
GO

IF OBJECT_ID('Ventas.preciosParque', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.preciosParque(
        idParque INT NOT NULL,
        idTipoVisitante INT NOT NULL,
        fechaDesde DATE NOT NULL DEFAULT GETDATE(),
        precio DECIMAL(10,2) CHECK( precio >= 0),
        CONSTRAINT PK_PreciosParque PRIMARY KEY (idParque, idTipoVisitante, fechaDesde),
        CONSTRAINT FK_PreciosParque_TipoVisitante FOREIGN KEY (idTipoVisitante) REFERENCES Ventas.tipoVisitante(idTipoVisitante),
        CONSTRAINT FK_PreciosParque_Parque FOREIGN KEY (idParque) REFERENCES Gestion.parque(idParque)
    );
END
GO

IF OBJECT_ID('Ventas.venta', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.venta(
        idVenta INT IDENTITY(1,1),
        idParque INT NOT NULL,
        fechaVenta DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Venta PRIMARY KEY (idVenta),
        CONSTRAINT FK_Venta_Parque FOREIGN KEY (idParque) REFERENCES Gestion.parque (idParque)
    );
END
GO

IF OBJECT_ID('Ventas.itemVenta', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.itemVenta(
        idVenta INT NOT NULL,
        idItemVenta INT NOT NULL CHECK(idItemVenta > 0),
        idTipoVisitante INT NULL,
        idActividad INT NULL,
        tipoItem VARCHAR(20) NOT NULL,
        cantidad INT NOT NULL CHECK (cantidad > 0),
        precioUnitario DECIMAL (10,2) NOT NULL CHECK(precioUnitario >= 0),
        CONSTRAINT PK_ItemVenta PRIMARY KEY (idItemVenta, idVenta),
        CONSTRAINT FK_ItemVenta_Venta FOREIGN KEY (idVenta) REFERENCES Ventas.Venta (idVenta),
        CONSTRAINT FK_ItemVenta_TipoVisitante FOREIGN KEY (idTipoVisitante) REFERENCES Ventas.TipoVisitante(idTipoVisitante),
        CONSTRAINT FK_ItemVenta_Actividad FOREIGN KEY (idActividad) REFERENCES Actividades.actividad (idActividad),
        CONSTRAINT CK_ItemVenta_Actividad_TipoVisitante CHECK ((tipoItem = 'Entrada' AND idTipoVisitante IS NOT NULL AND idActividad IS NULL) OR 
                                                               (tipoItem = 'Actividad' AND idTipoVisitante IS NULL AND idActividad IS NOT NULL)),
    );
END
GO

IF OBJECT_ID('Ventas.ticketFactura', 'U') IS NULL
BEGIN
CREATE TABLE Ventas.ticketFactura (
    idTicket INT IDENTITY(1,1),
    idVenta INT NOT NULL UNIQUE, 
    puntoVenta INT NOT NULL,
    numeroFactura INT NOT NULL,
    tipoFactura CHAR(1) NOT NULL DEFAULT 'B',
    fechaEmision DATETIME NOT NULL DEFAULT GETDATE(),
    montoTotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_TicketFactura PRIMARY KEY (idTicket),
    CONSTRAINT FK_TicketFactura_Venta FOREIGN KEY (idVenta) REFERENCES Ventas.venta(idVenta),
    CONSTRAINT UQ_TicketFactura_Venta UNIQUE (puntoVenta,numeroFactura)
);
END
GO

IF OBJECT_ID('Ventas.pago', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.pago(
        idPago INT IDENTITY(1,1),
        idVenta INT NOT NULL,
        idFormaPago INT NOT NULL,
        fecha DATETIME DEFAULT GETDATE(),
        estado VARCHAR(9) NOT NULL,
        importe DECIMAL (10,2) CHECK(importe >= 0),
        CONSTRAINT PK_Pago PRIMARY KEY (idPago),
        CONSTRAINT FK_Pago_Venta FOREIGN KEY (idVenta) REFERENCES Ventas.Venta (idVenta),
        CONSTRAINT FK_Pago_FormaPago FOREIGN KEY (idFormaPago) REFERENCES Ventas.FormaPago (idFormaPago)
    );
END
GO

IF OBJECT_ID('Ventas.entrada', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.entrada (
        codigoEntrada CHAR(10) NOT NULL CHECK (codigoEntrada LIKE '[A-Z]-[0-9][0-9][0-9][0-9][0-9][0-9]-[A-Z]'),
        idVenta INT NOT NULL, CHECK(idVenta > 0),
        fechaAcceso DATE NOT NULL,              
        fechaCompra DATETIME NOT NULL DEFAULT GETDATE(),
        idVisitante INT NOT NULL,               
        idParque INT NOT NULL,                  
        idTipoVisitante INT NOT NULL,
        precio DECIMAL (10,2) NOT NULL CHECK (precio >= 0)     
        CONSTRAINT PK_Entrada PRIMARY KEY (codigoEntrada),
        CONSTRAINT FK_Entrada_Venta FOREIGN KEY (idVenta) REFERENCES Ventas.venta (idVenta),
        CONSTRAINT FK_Entrada_Visitante FOREIGN KEY (idVisitante) REFERENCES Ventas.Visitante(idVisitante),
        CONSTRAINT FK_Entrada_Parque FOREIGN KEY (idParque)  REFERENCES Gestion.Parque(idParque),
        CONSTRAINT FK_Entrada_TipoVisitante FOREIGN KEY (idTipoVisitante) REFERENCES Ventas.TipoVisitante(idTipoVisitante)
    );
END
GO

--Esta tabla surge de la relacion N a N entre entrada y actividad
IF OBJECT_ID('Ventas.entradaActividad', 'U') IS NULL
BEGIN
    CREATE TABLE Ventas.entradaActividad (
        codigoEntrada CHAR(10) NOT NULL,
        idActividad INT NOT NULL,
        CONSTRAINT PK_Entrada_Actividad PRIMARY KEY (codigoEntrada, idActividad),
        CONSTRAINT FK_Entrada_Actividad_Ent FOREIGN KEY (codigoEntrada) REFERENCES Ventas.entrada(codigoEntrada),
        CONSTRAINT FK_Entrada_Actividad_Act FOREIGN KEY (idActividad) REFERENCES Actividades.actividad(idActividad)
    );
END
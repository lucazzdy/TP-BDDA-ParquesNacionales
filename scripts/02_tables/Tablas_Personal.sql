USE GestionParquesNacionales;
GO

/*=========================================================
TABLA GUARDAPARQUE
=========================================================*/

IF OBJECT_ID('Personal.Guardaparque','U') IS NOT NULL
    DROP TABLE Personal.Guardaparque;
GO

CREATE TABLE Personal.Guardaparque
(
    Legajo INT IDENTITY(1,1),

    TipoDocumento VARCHAR(15) NOT NULL,
    Documento VARCHAR(20) NOT NULL,

    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,

    FechaNacimiento DATE NOT NULL,

    Estado VARCHAR(10) NOT NULL,

    CONSTRAINT PK_Guardaparque
        PRIMARY KEY (Legajo),

    CONSTRAINT UQ_Guardaparque_Documento
        UNIQUE (Documento),

    CONSTRAINT CK_Guardaparque_Estado
        CHECK
        (
            Estado IN
            (
                'ACTIVO',
                'INACTIVO',
                'SUSPENDIDO',
                'LICENCIA'
            )
        )
);
GO

/*=========================================================
TABLA HISTORIAL GUARDAPARQUE
=========================================================*/

IF OBJECT_ID('Personal.HistorialGuardaparque','U') IS NOT NULL
    DROP TABLE Personal.HistorialGuardaparque;
GO

CREATE TABLE Personal.HistorialGuardaparque
(
    IDHistorial INT IDENTITY(1,1),

    Legajo INT NOT NULL,

    IDParque INT NOT NULL,

    FechaIngreso DATE NOT NULL,

    FechaEgreso DATE NULL,

    MotivoEgreso VARCHAR(200) NULL,

    CONSTRAINT PK_HistorialGuardaparque
        PRIMARY KEY (IDHistorial),

    CONSTRAINT FK_Historial_Guardaparque
        FOREIGN KEY (Legajo)
        REFERENCES Personal.Guardaparque(Legajo),

    CONSTRAINT FK_Historial_Parque
        FOREIGN KEY (IDParque)
        REFERENCES Gestion.Parque(IDParque),

    CONSTRAINT CK_Historial_Fechas
        CHECK
        (
            FechaEgreso IS NULL
            OR FechaEgreso >= FechaIngreso
        )
);
GO

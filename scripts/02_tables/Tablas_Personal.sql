/*=======================================================
    Script generado el 15/06/26

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Este script genera todas las tablas del esquema Personal
=======================================================*/

USE GestionParquesNacionales;
GO

/*=======================================================
CREACION DE TABLAS PERSONAL
=======================================================*/
-- Primero crear las tablas de Parque



/*=======================================================
GuardaParques
=======================================================*/

---------------------------------------------------------
-- Eliminar Tablas (GuardaParques)
---------------------------------------------------------

DROP TABLE IF EXISTS Personal.HistorialGuardaParques;
GO

DROP TABLE IF EXISTS Personal.GuardaParques;
GO

---------------------------------------------------------
-- Crear Tabla GuardaParques
---------------------------------------------------------

CREATE TABLE Personal.GuardaParques(
	Legajo INT IDENTITY(1,1),
	Documento CHAR(8) UNIQUE NOT NULL,

	Nombre VARCHAR(50) NOT NULL,
	Apellido VARCHAR(50) NOT NULL,

	FechaNacimiento DATE NOT NULL,

	Estado VARCHAR(10) NOT NULL,

	CONSTRAINT PK_GuardaParques PRIMARY KEY ( Legajo ),

	CONSTRAINT CK_Documentos_GuardaParques CHECK ( Documento LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' ),

	CONSTRAINT CK_FechaNacimiento_GuardaParques CHECK ( FechaNacimiento <= DATEADD( YEAR, -18, GETDATE() ) ),

	CONSTRAINT CK_Estado_GuardaParques CHECK ( Estado IN ( 'ACTIVO', 'INACTIVO', 'SUSPENDIDO', 'LICENCIA' ) )
);
GO

---------------------------------------------------------
-- Crear Tabla Historial de los GuardaParques
---------------------------------------------------------

CREATE TABLE Personal.HistorialGuardaParques(
	IDHistorial INT IDENTITY(1,1),
	LegajoGuardaParques INT NOT NULL,
	IDParque INT NOT NULL,

	FechaIngreso DATE NOT NULL,
	FechaEgreso DATE NULL,

	MotivoEgreso VARCHAR(200) NULL,

	CONSTRAINT PK_ID_Historial_GuardaParques PRIMARY KEY ( IDHistorial ),

	CONSTRAINT FK_Legajo_GuardaParques_Histoial_GuardaParques FOREIGN KEY (LegajoGuardaParques)
		REFERENCES Personal.GuardaParques(Legajo),

	CONSTRAINT FK_ID_Parque_Histoial_GuardaParques FOREIGN KEY (IDParque)
		REFERENCES Gestion.Parque(idParque),

	CONSTRAINT CK_FechaEgreso_Historial_GuardaParques CHECK (FechaEgreso IS NULL OR  FechaEgreso >= FechaIngreso)
);
GO

/*=======================================================
Guias
=======================================================*/

---------------------------------------------------------
-- Eliminar tablas (Guias)
---------------------------------------------------------

DROP TABLE IF EXISTS Personal.Titulos;
GO

DROP TABLE IF EXISTS Personal.Especialidad;
GO

DROP TABLE IF EXISTS Personal.Guias;
GO

DROP TABLE IF EXISTS Personal.Habilitaciones;
GO

DROP TABLE IF EXISTS Personal.HabilitacionesGuias;
GO

---------------------------------------------------------
-- Crear tabla Titulos
---------------------------------------------------------

CREATE TABLE Personal.Titulos(
	CodTitulo INT IDENTITY(1,1),
	Nombre VARCHAR(50) UNIQUE NOT NULL,
	Descripcion VARCHAR(200) NULL,

	CONSTRAINT PK_Titulos_Guia  PRIMARY KEY (CodTitulo)
);
GO

---------------------------------------------------------
-- Crear tabla Especialidades
---------------------------------------------------------

CREATE TABLE Personal.Especialidad(
	CodEspecialidad INT IDENTITY(1,1),
	Nombre VARCHAR(50) UNIQUE NOT NULL,
	Descripcion VARCHAR(200) NULL,

	CONSTRAINT PK_Especialidad_Guia  PRIMARY KEY (CodEspecialidad)
);
GO

---------------------------------------------------------
-- Crear tabla Guias
---------------------------------------------------------

CREATE TABLE Personal.Guias(
	Legajo INT IDENTITY(1,1),
	Documento CHAR(8) UNIQUE NOT NULL,

	Nombre VARCHAR(50) NOT NULL,
	Apellido VARCHAR(50) NOT NULL,

	FechaNacimiento DATE NOT NULL,

	CodTitulo INT NOT NULL,
	CodEspecialidad INT NOT NULL,

	CONSTRAINT PK_Guias  PRIMARY KEY (Legajo),

	CONSTRAINT CK_Documentos_Guias CHECK ( Documento LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' ),

	CONSTRAINT FK_Guias_Titulos FOREIGN KEY (CodTitulo)
		REFERENCES Personal.Titulos(CodTitulo),

	CONSTRAINT FK_Guias_Especialidad FOREIGN KEY (CodEspecialidad)
		REFERENCES Personal.Especialidad(CodEspecialidad),
);
GO

---------------------------------------------------------
-- Crear tabla Habilitaciones
---------------------------------------------------------

CREATE TABLE Personal.Habilitaciones(
	IDHabilitaciones INT IDENTITY(1,1),

	Nombre VARCHAR(50) NOT NULL,
	Descripcion VARCHAR(200) NULL,

	CONSTRAINT PK_ID_Habilitaciones  PRIMARY KEY (IDHabilitaciones)
);
GO

---------------------------------------------------------
-- Crear tabla Habilitaciones que tiene cada Guia en cada Parque
---------------------------------------------------------

CREATE TABLE Personal.HabilitacionesGuias(
	IDHabilitacionGuia INT IDENTITY (1,1),
	IDHabilitacion INT NOT NULL,
	LegajoGuia INT NOT NULL,
	IDParque INT NOT NULL,

	FechaComienzo DATE NOT NULL,
	FechaFin DATE NOT NULL,

	CONSTRAINT PK_ID_Habilitaciones_Guias PRIMARY KEY (IDHabilitacionGuia),

	CONSTRAINT FK_HabilitacionesGuias_Habilitaciones FOREIGN KEY (IDHabilitacion)
		REFERENCES Personal.Habilitaciones(IDHabilitaciones),

	CONSTRAINT FK_HabilitacionesGuias_Guias FOREIGN KEY (LegajoGuia)
		REFERENCES Personal.Guias(Legajo),

	CONSTRAINT FK_HabilitacionesGuias_Parques FOREIGN KEY (IDParque)
		REFERENCES Gestion.Parque(idParque),

	CONSTRAINT CK_FechaFin_HabilitacionesGuias CHECK ( FechaFin >= FechaComienzo )
);
GO
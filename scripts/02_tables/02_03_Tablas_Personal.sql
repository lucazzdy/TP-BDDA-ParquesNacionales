/*=======================================================
    Script generado el 15/06/26

Grupo n�7
Integrantes:    - Acu�a, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripci�n del Script: Este script genera todas las tablas del esquema Personal
=======================================================*/

USE GestionParquesNacionales_Com5600_Grupo07;
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

DROP TABLE IF EXISTS Personal.historialGuardaparques;
GO

DROP TABLE IF EXISTS Personal.guardaparques;
GO

---------------------------------------------------------
-- Crear Tabla GuardaParques
---------------------------------------------------------

CREATE TABLE Personal.guardaparques(
	legajo INT IDENTITY(1,1),
	documento CHAR(8) NOT NULL,

	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,

	fechaNacimiento DATE NOT NULL,

	estado VARCHAR(10) NOT NULL,

	CONSTRAINT PK_guardaparques PRIMARY KEY ( legajo ),

	CONSTRAINT CK_documentos_Guardaparques CHECK ( documento LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' ),

	CONSTRAINT UQ_documento_Guardaparques UNIQUE (documento),

	CONSTRAINT CK_fechaNacimiento_Guardaparques CHECK ( fechaNacimiento <= DATEADD( YEAR, -18, GETDATE() ) ),

	CONSTRAINT CK_estado_Guardaparques CHECK ( estado IN ( 'ACTIVO', 'INACTIVO', 'SUSPENDIDO', 'LICENCIA' ) )
);
GO

---------------------------------------------------------
-- Crear Tabla Historial de los GuardaParques
---------------------------------------------------------

CREATE TABLE Personal.historialGuardaparques(
	idHistorial INT IDENTITY(1,1),
	legajoGuardaparques INT NOT NULL,
	idParque INT NOT NULL,

	fechaIngreso DATE NOT NULL,
	fechaEgreso DATE NULL,

	motivoEgreso VARCHAR(200) NULL,

	CONSTRAINT PK_id_historialGuardaparques PRIMARY KEY ( idHistorial ),

	CONSTRAINT FK_legajoGuardaparques_histoialGuardaparques FOREIGN KEY (legajoGuardaparques)
		REFERENCES Personal.guardaparques(legajo),

	CONSTRAINT FK_idParqueHistoial_guardaParques FOREIGN KEY (idParque)
		REFERENCES Gestion.Parque(idParque),

	CONSTRAINT CK_FechaEgreso_Historial_GuardaParques CHECK (fechaEgreso IS NULL OR  fechaEgreso >= fechaIngreso)
);
GO

/*=======================================================
Guias
=======================================================*/

---------------------------------------------------------
-- Eliminar tablas (Guias)
---------------------------------------------------------

DROP TABLE IF EXISTS Personal.titulos;
GO

DROP TABLE IF EXISTS Personal.especialidad;
GO

DROP TABLE IF EXISTS Personal.guias;
GO

DROP TABLE IF EXISTS Personal.habilitaciones;
GO

DROP TABLE IF EXISTS Personal.habilitacionesGuias;
GO

---------------------------------------------------------
-- Crear tabla Titulos
---------------------------------------------------------

CREATE TABLE Personal.titulos(
	codTitulo INT IDENTITY(1,1),
	nombre VARCHAR(100) UNIQUE NOT NULL,
	descripcion VARCHAR(200) NULL,

	CONSTRAINT PK_Titulos_Guia  PRIMARY KEY (codTitulo)
);
GO

---------------------------------------------------------
-- Crear tabla Especialidades
---------------------------------------------------------

CREATE TABLE Personal.especialidad(
	codEspecialidad INT IDENTITY(1,1),
	nombre VARCHAR(50) UNIQUE NOT NULL,
	descripcion VARCHAR(200) NULL,

	CONSTRAINT PK_Especialidad_Guia  PRIMARY KEY (codEspecialidad)
);
GO

---------------------------------------------------------
-- Crear tabla Guias
---------------------------------------------------------

CREATE TABLE Personal.guias(
	legajo INT IDENTITY(1,1),
	documento CHAR(8) NOT NULL,

	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,

	fechaNacimiento DATE NOT NULL,

	codTitulo INT NOT NULL,
	codEspecialidad INT NOT NULL,

	CONSTRAINT PK_Guias  PRIMARY KEY (legajo),

	CONSTRAINT CK_documentos_Guias CHECK ( documento LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' ),

	CONSTRAINT UQ_documento_Guias UNIQUE (documento),

	CONSTRAINT FK_Guias_Titulos FOREIGN KEY (codTitulo)
		REFERENCES Personal.Titulos(codTitulo),

	CONSTRAINT FK_Guias_Especialidad FOREIGN KEY (codEspecialidad)
		REFERENCES Personal.Especialidad(codEspecialidad),
);
GO

---------------------------------------------------------
-- Crear tabla Habilitaciones
---------------------------------------------------------

CREATE TABLE Personal.habilitaciones(
	idHabilitaciones INT IDENTITY(1,1),

	nombre VARCHAR(50) NOT NULL,
	descripcion VARCHAR(200) NULL,

	CONSTRAINT PK_ID_Habilitaciones  PRIMARY KEY (idHabilitaciones)
);
GO

---------------------------------------------------------
-- Crear tabla Habilitaciones que tiene cada Guia en cada Parque
---------------------------------------------------------

CREATE TABLE Personal.habilitacionesGuias(
	idHabilitacionGuia INT IDENTITY (1,1),
	idHabilitacion INT NOT NULL,
	legajoGuia INT NOT NULL,
	idParque INT NOT NULL,

	fechaComienzo DATE NOT NULL,
	fechaFin DATE NOT NULL,

	CONSTRAINT PK_ID_Habilitaciones_Guias PRIMARY KEY (idHabilitacionGuia),

	CONSTRAINT FK_HabilitacionesGuias_Habilitaciones FOREIGN KEY (idHabilitacion)
		REFERENCES Personal.habilitaciones(idHabilitaciones),

	CONSTRAINT FK_HabilitacionesGuias_Guias FOREIGN KEY (legajoGuia)
		REFERENCES Personal.guias(legajo),

	CONSTRAINT FK_HabilitacionesGuias_Parques FOREIGN KEY (idParque)
		REFERENCES Gestion.parque(idParque),

	CONSTRAINT CK_FechaFin_HabilitacionesGuias CHECK ( fechaFin >= fechaComienzo )
);
GO
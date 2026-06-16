/* 
    Script generado el 15/06/26

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Este script genera los stored procedures ABM 
                        para el esquema de Actividades y sus tablas.
*/

USE GestionParquesNacionales;
GO

--- Este script crea/regenera todas las tablas de actividades ---
--- CUIDADO al ejecutarlo completo ---
--- Antes de crear una nueva tabla se dropean todas las que tienen dependencia de FK ---

-- Tipos de actividades: visita guiada, kayak, pesca, etc
IF OBJECT_ID('Actividades.TipoActividad','U') IS NOT NULL
BEGIN
    DROP TABLE IF EXISTS Actividades.Tour
    DROP TABLE IF EXISTS Actividades.Actividad
    DROP TABLE IF EXISTS Actividades.TipoActividad
END
go

CREATE TABLE Actividades.TipoActividad (
        idTipoActividad INT IDENTITY(1,1) NOT NULL,
        descripcion VARCHAR(200) NULL,
        CONSTRAINT PK_TipoActividad PRIMARY KEY (idTipoActividad)
    );

-- Datos de actividades con su costo y duracion
IF OBJECT_ID('Actividades.Actividad') IS NOT NULL
BEGIN
    DROP TABLE IF EXISTS Actividades.Tour
    DROP TABLE IF EXISTS Actividades.Actividad
END
go

CREATE TABLE Actividades.Actividad (
        idActividad INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL UNIQUE,
        costo DECIMAL(8,2) NULL,
        duracion DECIMAL(3,1) NULL,
        idTipoActividad INT NOT NULL,
        CONSTRAINT PK_Actividad PRIMARY KEY (idActividad),
        -- FK al tipo de Actividad
        CONSTRAINT FK_Actividad_TipoActividad FOREIGN KEY (idTipoActividad) REFERENCES Actividades.TipoActividad(idTipoActividad)
    );


-- Inlcuyo datos de guias junto con titulos y especialidades 
-- por la relacion con los tours, hay que discutir si va aca o en personal.

-- Datos de Especialidades

IF OBJECT_ID('Actividades.Especialidad','U') IS NOT NULL
BEGIN
    DROP TABLE IF EXISTS Actividades.Tour
    DROP TABLE IF EXISTS Actividades.Titulo
    DROP TABLE IF EXISTS Actividades.Guia
    DROP TABLE IF EXISTS Actividades.Especialidad
END
go

CREATE TABLE Actividades.Especialidad (
        codEspecialidad INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(200) NULL,
        CONSTRAINT PK_Especialidad PRIMARY KEY (codEspecialidad)
    );

-- Datos de guias

IF OBJECT_ID('Actividades.Guia','U') IS NOT NULL
BEGIN
    DROP TABLE IF EXISTS Actividades.Tour
    DROP TABLE IF EXISTS Actividades.Titulo
    DROP TABLE IF EXISTS Actividades.Guia
END
go

CREATE TABLE Actividades.Guia (
        idGuia INT IDENTITY(1,1) NOT NULL,
        fecha DATE NULL,
        codEspecialidad INT NOT NULL,
        CONSTRAINT PK_Guia PRIMARY KEY (idGuia),
        CONSTRAINT FK_Guia_Especialidad FOREIGN KEY (codEspecialidad) REFERENCES Actividades.Especialidad(codEspecialidad),
    );

-- Datos de los titulos de los guias
DROP TABLE IF EXISTS Actividades.Titulo
go

CREATE TABLE Actividades.Titulo (
        codTitulo INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(200) NULL,
        idGuia INT NOT NULL,
        CONSTRAINT PK_Titulo PRIMARY KEY (codTitulo),
        CONSTRAINT FK_Titulo_Guia FOREIGN KEY (idGuia) REFERENCES Actividades.Guia(idGuia)
    );


-- Datos de tours con fechas segun actividad y guia/s asignado/s
DROP TABLE IF EXISTS Actividades.Tour
go

CREATE TABLE Actividades.Tour (
        idActividad INT NOT NULL,
        idGuia INT NOT NULL,
        fechaInicio DATE NOT NULL,
        fechaDesde DATE NULL,
        
        CONSTRAINT FK_Tour_Actividad FOREIGN KEY (idActividad) REFERENCES Actividades.Actividad(idActividad),
        CONSTRAINT FK_Tour_Guia FOREIGN KEY (idGuia) REFERENCES Actividades.Guia(idGuia)
    );

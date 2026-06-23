/* 
    Script generado el 14/06/26

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Este script genera todas las tablas del esquema Actividades
*/

USE GestionParquesNacionales;
GO

--- Este script crea/regenera todas las tablas de actividades ---
--- CUIDADO al ejecutarlo completo ---
--- Antes de crear una nueva tabla se dropean todas las que tienen dependencia de FK ---

-- Tipos de actividades: visita guiada, kayak, pesca, etc
IF OBJECT_ID('Actividades.tipoActividad','U') IS NOT NULL
BEGIN
    DROP TABLE IF EXISTS Actividades.tour
    DROP TABLE IF EXISTS Actividades.actividad
    DROP TABLE IF EXISTS Actividades.tipoActividad
END
go

CREATE TABLE Actividades.tipoActividad (
        idTipoActividad INT IDENTITY(1,1) NOT NULL,
        descripcion VARCHAR(200) NULL,
        CONSTRAINT PK_tipoActividad PRIMARY KEY (idtipoActividad)
    );

-- Datos de actividades con su costo y duracion
IF OBJECT_ID('Actividades.actividad') IS NOT NULL
BEGIN
    DROP TABLE IF EXISTS Actividades.tour
    DROP TABLE IF EXISTS Actividades.actividad
END
go

CREATE TABLE Actividades.actividad (
        idActividad INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL UNIQUE,
        costo DECIMAL(8,2) NULL CHECK(costo >= 0),
        duracion DECIMAL(3,1) NULL CHECK(Duracion > 0), 
        idTipoActividad INT NOT NULL,
        CONSTRAINT PK_Actividad PRIMARY KEY (idActividad),
        -- FK al tipo de actividad
        CONSTRAINT FK_Actividad_tipoActividad FOREIGN KEY (idTipoActividad) REFERENCES Actividades.tipoActividad(idTipoActividad)
    );


-- Datos de tours con fechas segun actividad y guia/s asignado/s
DROP TABLE IF EXISTS Actividades.tour
go

CREATE TABLE Actividades.tour (
        idActividad INT NOT NULL,
        legajo INT NOT NULL,
        fechaInicio DATE NOT NULL,
        fechaDesde DATE NULL,
        cupoMaximo TINYINT NOT NULL CHECK(cupoMaximo > 0),
        
        CONSTRAINT PK_Tour PRIMARY KEY (idActividad, legajo, fechaInicio),
        CONSTRAINT FK_Tour_Actividad FOREIGN KEY (idActividad) REFERENCES Actividades.actividad(idActividad),
        CONSTRAINT FK_Tour_Guia FOREIGN KEY (legajo) REFERENCES Personal.guias(legajo)
    );

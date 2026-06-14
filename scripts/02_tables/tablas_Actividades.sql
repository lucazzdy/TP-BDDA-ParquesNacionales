USE GestionParquesNacionales;
GO

-- Tipos de actividades: visita guiada, kayak, pesca, etc
IF OBJECT_ID('Actividades.TipoActividad', 'U') IS NULL
BEGIN
    CREATE TABLE Actividades.TipoActividad (
        idTipoActividad INT IDENTITY(1,1) NOT NULL,
        descripcion VARCHAR(200) NULL,
        CONSTRAINT PK_TipoActividad PRIMARY KEY (idTipoActividad)
    );
END
GO

-- Datos de actividades con su costo y duracion
IF OBJECT_ID('Actividades.Actividad', 'U') IS NULL
BEGIN
    CREATE TABLE Actividades.Actividad (
        idActividades INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL UNIQUE,
        costo DECIMAL(8,2) NULL,
        duracion DECIMAL(3,1) NULL,
        idTipoActividad INT NOT NULL,
        CONSTRAINT PK_Actividades PRIMARY KEY (idActividades),
        -- FK al tipo de Actividad
        CONSTRAINT FK_Actividades_TipoActividad FOREIGN KEY (idTipoActividad) REFERENCES Actividades.TipoActividad(idTipoActividad)
    );
END
GO


-- Inlcuyo datos de guias junto con titulos y especialidades 
-- por la relacion con los tours, hay que discutir si va aca o en personal.

-- Datos de Especialidades
IF OBJECT_ID('Actividades.Especialidad', 'U') IS NULL
BEGIN
    CREATE TABLE Actividades.Especialidad (
        codEspecialidad INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(200) NULL,
        CONSTRAINT PK_Especialidad PRIMARY KEY (codEspecialidad)
    );
END
GO

-- Datos de guias
IF OBJECT_ID('Actividades.Guia', 'U') IS NULL
BEGIN
    CREATE TABLE Actividades.Guia (
        idGuia INT IDENTITY(1,1) NOT NULL,
        fecha DATE NULL,
        idEspecialidad INT NOT NULL,
        CONSTRAINT PK_Tour PRIMARY KEY (idGuia),
        CONSTRAINT FK_Guia_Especialidad FOREIGN KEY (idEspecialidad) REFERENCES Actividades.Especialidad(codEspecialidad),
        CONSTRAINT FK_Tour_Guia FOREIGN KEY (idGuia) REFERENCES Actividades.Guia(idGuia)
    );
END
GO

-- Datos de los titulos de los guias
IF OBJECT_ID('Actividades.Titulo', 'U') IS NULL
BEGIN
    CREATE TABLE Actividades.Titulo (
        codTitulo INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(200) NULL,
        idGuia INT NOT NULL,
        CONSTRAINT PK_Tour PRIMARY KEY (codTitulo),
        CONSTRAINT FK_Titulo_Guia FOREIGN KEY (idGuia) REFERENCES Actividades.Guia(idGuia)
    );
END
GO

-- Datos de tours con fechas segun actividad y guia/s asignado/s
IF OBJECT_ID('Actividades.Tour', 'U') IS NULL
BEGIN
    CREATE TABLE Actividades.Tour (
        idActividades INT NOT NULL,
        idGuia INT NOT NULL,
        fechaInicio DATE NOT NULL,
        fechaDesde DATE NULL,
        
        CONSTRAINT FK_Tour_Actividad FOREIGN KEY (idActividad) REFERENCES Actividades.Actividad(idActividad),
        CONSTRAINT FK_Tour_Guia FOREIGN KEY (idGuia) REFERENCES Actividades.Guia(idGuia)
    );
END
GO
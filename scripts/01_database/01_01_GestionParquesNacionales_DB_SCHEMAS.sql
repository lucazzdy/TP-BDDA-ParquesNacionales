/* 
    Script generado el 13/06/26

Grupo n°7
Integrantes:    - Acuña, Lucas Daniel
                - Alesina, Alan
                - Gutierrez, Lucas Leone
                - Zambrana, Mijael

Descripción del Script: Este script crea la base de datos y los esquemas 
						Personal, Actividades, Gestion, Ventas y Concesiones
*/

USE master;
GO

IF DB_ID('GestionParquesNacionales_Com5600_Grupo07') IS NULL
	CREATE DATABASE GestionParquesNacionales_Com5600_Grupo07 COLLATE Latin1_GENERAL_CI_AS
go

USE GestionParquesNacionales_Com5600_Grupo07
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Personal')
BEGIN
	EXEC('CREATE SCHEMA Personal')
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Actividades')
BEGIN
	EXEC('CREATE SCHEMA Actividades')
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Gestion')
BEGIN
	EXEC('CREATE SCHEMA Gestion')
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Ventas')
BEGIN
	EXEC('CREATE SCHEMA Ventas')
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Concesiones')
BEGIN
	EXEC('CREATE SCHEMA Concesiones')
END

/*=========================================================
CONFIGURACIÓN FÍSICA PROPUESTA (ENTREGA 4)
=========================================================

Esta configuración no se ejecuta debido a que requiere
la existencia física de los discos configurados para el
entorno productivo.

Distribución propuesta:

Datos MDF/NDF:
D:\SQLData\

Logs:
F:\SQLLogs\

Backups:
E:\SQLBackups\

TempDB:
G:\TempDB\

Script propuesto:

CREATE DATABASE TP_BDA_ParquesNacionales
ON PRIMARY
(
    NAME = TP_BDA_ParquesNacionales_Data,
    FILENAME = 'D:\SQLData\TP_BDA_ParquesNacionales.mdf',
    SIZE = 100GB,
    MAXSIZE = 200GB,
    FILEGROWTH = 10GB
),
FILEGROUP FG_ExtraData
(
    NAME = TP_BDA_ParquesNacionales_Extra,
    FILENAME = 'D:\SQLData\TP_BDA_ParquesNacionales_Extra.ndf',
    SIZE = 50GB,
    MAXSIZE = 100GB,
    FILEGROWTH = 10GB
)
LOG ON
(
    NAME = TP_BDA_ParquesNacionales_Log,
    FILENAME = 'F:\SQLLogs\TP_BDA_ParquesNacionales.ldf',
    SIZE = 30GB,
    MAXSIZE = 60GB,
    FILEGROWTH = 5GB
);

Ejemplo de Backup:

BACKUP DATABASE TP_BDA_ParquesNacionales
TO DISK = 'E:\SQLBackups\BackupCompleto.bak';

=========================================================
FIN DEL SCRIPT
=======================================================*/

-- Comando para Eliminar la Base de Datos
/*
USE master;
GO

ALTER DATABASE GestionParquesNacionales
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE GestionParquesNacionales;
GO
*/
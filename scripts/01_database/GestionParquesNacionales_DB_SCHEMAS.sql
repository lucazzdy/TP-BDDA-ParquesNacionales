
IF DB_ID('GestionParquesNacionales') IS NULL
	CREATE DATABASE GestionParquesNacionales COLLATE Latin1_GENERAL_CI_AS
go

USE GestionParquesNacionales
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Personal')
BEGIN
	EXEC('CREATE SCHEMA Personal')
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Actividad')
BEGIN
	EXEC('CREATE SCHEMA Actividad')
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Gestion')
BEGIN
	EXEC('CREATE SCHEMA Gestion')
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Ventas')
BEGIN
	EXEC('CREATE SCHEMA Ventas')
END


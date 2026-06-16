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

IF DB_ID('GestionParquesNacionales') IS NULL
	CREATE DATABASE GestionParquesNacionales COLLATE Latin1_GENERAL_CI_AS
go

USE GestionParquesNacionales
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

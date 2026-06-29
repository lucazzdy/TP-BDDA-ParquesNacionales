/* 
    Script generado el 25/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Crea los 4 roles de seguridad del sistema
                            (admin, operador, importador, consultor)
                            y otorga permisos granulares a cada uno.
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO


-- ====================================================================
-- CREACION DE LOS ROLES
-- ====================================================================

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_admin')
    CREATE ROLE rol_admin;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_operador')
    CREATE ROLE rol_operador;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_importador')
    CREATE ROLE rol_importador;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_consultor')
    CREATE ROLE rol_consultor;
GO


-- ====================================================================
-- ROL_ADMIN: control total sobre todos los esquemas
-- ====================================================================
GRANT CONTROL ON SCHEMA::Gestion TO rol_admin;
GRANT CONTROL ON SCHEMA::Concesiones TO rol_admin;
GRANT CONTROL ON SCHEMA::Personal TO rol_admin;
GRANT CONTROL ON SCHEMA::Actividades TO rol_admin;
GRANT CONTROL ON SCHEMA::Ventas TO rol_admin;
GO


-- ====================================================================
-- ROL_CONSULTOR: SELECT en todo + ejecucion de reportes y consultas
-- ====================================================================
GRANT SELECT ON SCHEMA::Gestion TO rol_consultor;
GRANT SELECT ON SCHEMA::Concesiones TO rol_consultor;
GRANT SELECT ON SCHEMA::Personal TO rol_consultor;
GRANT SELECT ON SCHEMA::Actividades TO rol_consultor;
GRANT SELECT ON SCHEMA::Ventas TO rol_consultor;

-- Reportes
GRANT EXECUTE ON Gestion.reporteParquesConConcesiones TO rol_consultor;
GRANT EXECUTE ON Gestion.reporteIngresos TO rol_consultor;
GRANT EXECUTE ON Gestion.reporteVisitas TO rol_consultor;
GRANT EXECUTE ON Gestion.reporteVisitasPorPeriodo TO rol_consultor;
GRANT EXECUTE ON Concesiones.reporteDeudores TO rol_consultor;

-- SPs de consulta (no modifican datos)
GRANT EXECUTE ON Gestion.consultarParqueConConcesiones TO rol_consultor;
GRANT EXECUTE ON Gestion.consultarClimaParque TO rol_consultor;
GRANT EXECUTE ON Concesiones.consultarProximasAVencer TO rol_consultor;
GRANT EXECUTE ON Concesiones.consultarAtrasadas TO rol_consultor;
GO


-- ====================================================================
-- ROL_IMPORTADOR: solo ejecuta SPs de importacion
-- ====================================================================
GRANT EXECUTE ON Gestion.procesarImportacionSib TO rol_importador;
GRANT EXECUTE ON Gestion.procesarImportacionCiam TO rol_importador;
GRANT EXECUTE ON Gestion.parsearNombreParque TO rol_importador;
GRANT EXECUTE ON Gestion.importarParque TO rol_importador;
GRANT EXECUTE ON Personal.procesarImportacionGuiasCsv TO rol_importador;
GRANT EXECUTE ON Actividades.importarActividad TO rol_importador;

-- Necesita escribir en staging y log
GRANT INSERT, DELETE, SELECT ON Gestion.stagingSib TO rol_importador;
GRANT INSERT, DELETE, SELECT ON Gestion.stagingCiam TO rol_importador;
GRANT INSERT, DELETE, SELECT ON Personal.stagingCsvGuias TO rol_importador;
GRANT INSERT, SELECT ON Gestion.logImportacion TO rol_importador;

-- Lectura para ver resultados de la importacion
GRANT SELECT ON SCHEMA::Gestion TO rol_importador;
GRANT SELECT ON SCHEMA::Personal TO rol_importador;
GRANT SELECT ON SCHEMA::Actividades TO rol_importador;
GO


-- ====================================================================
-- ROL_OPERADOR: operacion diaria (ventas, pagos, asignaciones)
-- ====================================================================

-- Lectura general (necesita ver parques, empresas, etc. para operar)
GRANT SELECT ON SCHEMA::Gestion TO rol_operador;
GRANT SELECT ON SCHEMA::Concesiones TO rol_operador;
GRANT SELECT ON SCHEMA::Personal TO rol_operador;
GRANT SELECT ON SCHEMA::Actividades TO rol_operador;
GRANT SELECT ON SCHEMA::Ventas TO rol_operador;

-- Ventas (operacion principal del operador)
GRANT EXECUTE ON Ventas.procesarVentaIndividual TO rol_operador;
GRANT EXECUTE ON Ventas.procesarVentaMasiva TO rol_operador;
GRANT EXECUTE ON Ventas.visitanteAlta TO rol_operador;
GRANT EXECUTE ON Ventas.visitanteModificar TO rol_operador;
GRANT EXECUTE ON Ventas.entradaAlta TO rol_operador;
GRANT EXECUTE ON Ventas.entradaModificar TO rol_operador;
GRANT EXECUTE ON Ventas.ticketFacturaAlta TO rol_operador;
GRANT EXECUTE ON Ventas.ticketFacturaModificar TO rol_operador;
GRANT EXECUTE ON Ventas.entradaActividadAlta TO rol_operador;
GRANT EXECUTE ON Ventas.pagoAlta TO rol_operador;

-- Concesiones (gestion comercial)
GRANT EXECUTE ON Concesiones.registrarConcesionConPagos TO rol_operador;
GRANT EXECUTE ON Concesiones.registrarPagoCanon TO rol_operador;
GRANT EXECUTE ON Concesiones.marcarPagosAtrasados TO rol_operador;
GRANT EXECUTE ON Concesiones.cerrarConcesion TO rol_operador;
GRANT EXECUTE ON Concesiones.consultarProximasAVencer TO rol_operador;
GRANT EXECUTE ON Concesiones.consultarAtrasadas TO rol_operador;
GRANT EXECUTE ON Concesiones.empresaAlta TO rol_operador;
GRANT EXECUTE ON Concesiones.empresaModificar TO rol_operador;

-- Personal (asignacion de guardaparques y guias)
GRANT EXECUTE ON Personal.asignarGuardaparqueParque TO rol_operador;
GRANT EXECUTE ON Personal.reasignarGuardaparque TO rol_operador;
GRANT EXECUTE ON Personal.altaHabilitacionGuia TO rol_operador;
GRANT EXECUTE ON Personal.modificarHabilitacionGuia TO rol_operador;

-- Reportes basicos
GRANT EXECUTE ON Gestion.consultarParqueConConcesiones TO rol_operador;
GO


-- ====================================================================
-- VERIFICACION
-- ====================================================================
/*
SELECT 
    p.name AS rol,
    p.type_desc AS tipo
FROM sys.database_principals p
WHERE p.name LIKE 'rol_%'
ORDER BY p.name;

PRINT '=== Roles creados y permisos otorgados ===';
GO
*/
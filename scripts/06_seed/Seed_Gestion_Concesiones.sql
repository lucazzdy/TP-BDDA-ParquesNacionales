/* 
    Script generado el 22/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Seed data del esquema Concesiones.
                            
    IMPORTANTE: este seed NO carga parques ni 
    tipos de parque. Esos vienen de la importacion
    del dataset SIB (script_importacion.sql).
                                                      
    Incluye:
    - Concesion vigente y vencida
    - Pagos atrasados

*/

USE GestionParquesNacionales;
GO


-- ====================================================================
-- VERIFICACION: deben existir los parques antes de seguir
-- ====================================================================
IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE nombre = 'Iguazú')
BEGIN
    ;THROW 50800, 'No hay parques cargados. Ejecutar primero script_importacion.sql para importar desde SIB.', 1;
END
GO


-- ====================================================================
-- TIPOS DE CONCESION
-- ====================================================================
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Restaurante';
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Tienda de souvenirs';
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Empresa de turismo';
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Cabañas';
EXEC Concesiones.tipoConcesion_Alta @descripcion = 'Camping';


-- ====================================================================
-- EMPRESAS CONCESIONARIAS
-- ====================================================================
EXEC Concesiones.empresa_Alta @nombre = 'Aventuras del Sur SA';
EXEC Concesiones.empresa_Alta @nombre = 'La Posta Restaurante SRL';
EXEC Concesiones.empresa_Alta @nombre = 'Tienda Pachamama';
EXEC Concesiones.empresa_Alta @nombre = 'Cabañas El Refugio';
EXEC Concesiones.empresa_Alta @nombre = 'Camping Los Pinos SA';
EXEC Concesiones.empresa_Alta @nombre = 'Turismo Patagonia SA';
EXEC Concesiones.empresa_Alta @nombre = 'Souvenirs Iguazú';
EXEC Concesiones.empresa_Alta @nombre = 'Parrilla del Glaciar';
EXEC Concesiones.empresa_Alta @nombre = 'EcoTurismo Norte';
EXEC Concesiones.empresa_Alta @nombre = 'Aventura Total SA';


-- ====================================================================
-- CONCESIONES (10 concesiones, mix de vigentes y vencidas)
-- Las referencias al parque se hacen por NOMBRE via subquery
-- ====================================================================

DECLARE @idParque INT;

-- Concesion 1: Iguazú, restaurante VIGENTE
SELECT @idParque = idParque FROM Gestion.parque WHERE nombre = 'Iguazú';
EXEC Concesiones.concesion_Alta 
    @idEmpresa=2, @idParque=@idParque, @idTipoConcesion=1, 
    @fechaInicio='2024-01-01', @fechaFin='2028-12-31', @montoCanonMensual=250000;

-- Concesion 2: Iguazú, tienda VIGENTE (mismo parque)
EXEC Concesiones.concesion_Alta 
    @idEmpresa=7, @idParque=@idParque, @idTipoConcesion=2, 
    @fechaInicio='2023-06-01', @fechaFin='2027-05-31', @montoCanonMensual=120000;

-- Concesion 3: Nahuel Huapi, turismo VIGENTE
SELECT @idParque = idParque FROM Gestion.parque WHERE nombre = 'Nahuel Huapi';
EXEC Concesiones.concesion_Alta 
    @idEmpresa=6, @idParque=@idParque, @idTipoConcesion=3, 
    @fechaInicio='2025-01-01', @fechaFin='2029-12-31', @montoCanonMensual=350000;

-- Concesion 4: Nahuel Huapi, cabañas VIGENTE (mismo parque)
EXEC Concesiones.concesion_Alta 
    @idEmpresa=4, @idParque=@idParque, @idTipoConcesion=4, 
    @fechaInicio='2024-03-01', @fechaFin='2027-02-28', @montoCanonMensual=180000;

-- Concesion 5: Los Glaciares, restaurante VENCIDA
SELECT @idParque = idParque FROM Gestion.parque WHERE nombre = 'Los Glaciares';
EXEC Concesiones.concesion_Alta 
    @idEmpresa=8, @idParque=@idParque, @idTipoConcesion=1, 
    @fechaInicio='2020-01-01', @fechaFin='2023-12-31', @montoCanonMensual=200000;

-- Concesion 6: Los Glaciares, turismo VIGENTE (mismo parque)
EXEC Concesiones.concesion_Alta 
    @idEmpresa=1, @idParque=@idParque, @idTipoConcesion=3, 
    @fechaInicio='2024-06-01', @fechaFin='2028-05-31', @montoCanonMensual=280000;

-- Concesion 7: Lanín, camping VIGENTE
SELECT @idParque = idParque FROM Gestion.parque WHERE nombre = 'Lanín';
EXEC Concesiones.concesion_Alta 
    @idEmpresa=5, @idParque=@idParque, @idTipoConcesion=5, 
    @fechaInicio='2025-09-01', @fechaFin='2028-08-31', @montoCanonMensual=90000;

-- Concesion 8: Los Alerces, turismo VIGENTE
SELECT @idParque = idParque FROM Gestion.parque WHERE nombre = 'Los Alerces';
EXEC Concesiones.concesion_Alta 
    @idEmpresa=10, @idParque=@idParque, @idTipoConcesion=3, 
    @fechaInicio='2024-11-01', @fechaFin='2027-10-31', @montoCanonMensual=220000;

-- Concesion 9: Tierra del Fuego, restaurante VENCIDA
SELECT @idParque = idParque FROM Gestion.parque WHERE nombre = 'Tierra del Fuego';
EXEC Concesiones.concesion_Alta 
    @idEmpresa=2, @idParque=@idParque, @idTipoConcesion=1, 
    @fechaInicio='2019-01-01', @fechaFin='2024-12-31', @montoCanonMensual=150000;

-- Concesion 10: Calilegua, turismo VIGENTE
SELECT @idParque = idParque FROM Gestion.parque WHERE nombre = 'Calilegua';
EXEC Concesiones.concesion_Alta 
    @idEmpresa=9, @idParque=@idParque, @idTipoConcesion=3, 
    @fechaInicio='2025-04-01', @fechaFin='2028-03-31', @montoCanonMensual=130000;


-- ====================================================================
-- PAGOS DE CANON
-- Mix de estados: Pagado, Pendiente y Atrasado
-- ====================================================================

-- Concesion 1: 6 meses pagados al dia
EXEC Concesiones.pagoCanon_Alta @idConcesion=1, @fecha='2025-01-10', @monto=250000, @periodo='2025-01', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=1, @fecha='2025-02-08', @monto=250000, @periodo='2025-02', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=1, @fecha='2025-03-12', @monto=250000, @periodo='2025-03', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=1, @fecha='2025-04-10', @monto=250000, @periodo='2025-04', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=1, @fecha='2025-05-09', @monto=250000, @periodo='2025-05', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=1, @fecha='2025-06-11', @monto=250000, @periodo='2025-06', @estado='Pagado';

-- Concesion 2: 3 pagados y 2 atrasados
EXEC Concesiones.pagoCanon_Alta @idConcesion=2, @fecha='2024-09-05', @monto=120000, @periodo='2024-09', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=2, @fecha='2024-10-07', @monto=120000, @periodo='2024-10', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=2, @fecha='2024-11-08', @monto=120000, @periodo='2024-11', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=2, @fecha='2024-12-15', @monto=120000, @periodo='2024-12', @estado='Atrasado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=2, @fecha='2025-01-15', @monto=120000, @periodo='2025-01', @estado='Atrasado';

-- Concesion 3: pagos al dia
EXEC Concesiones.pagoCanon_Alta @idConcesion=3, @fecha='2025-01-05', @monto=350000, @periodo='2025-01', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=3, @fecha='2025-02-04', @monto=350000, @periodo='2025-02', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=3, @fecha='2025-03-06', @monto=350000, @periodo='2025-03', @estado='Pagado';

-- Concesion 4: 1 pagado y 2 pendientes
EXEC Concesiones.pagoCanon_Alta @idConcesion=4, @fecha='2025-03-08', @monto=180000, @periodo='2025-03', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=4, @fecha='2025-04-01', @monto=180000, @periodo='2025-04', @estado='Pendiente';
EXEC Concesiones.pagoCanon_Alta @idConcesion=4, @fecha='2025-05-01', @monto=180000, @periodo='2025-05', @estado='Pendiente';

-- Concesion 5 (vencida): historial de pagos
EXEC Concesiones.pagoCanon_Alta @idConcesion=5, @fecha='2023-10-10', @monto=200000, @periodo='2023-10', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=5, @fecha='2023-11-12', @monto=200000, @periodo='2023-11', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=5, @fecha='2023-12-15', @monto=200000, @periodo='2023-12', @estado='Pagado';

-- Concesion 6: pagos al dia
EXEC Concesiones.pagoCanon_Alta @idConcesion=6, @fecha='2024-06-10', @monto=280000, @periodo='2024-06', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=6, @fecha='2024-07-09', @monto=280000, @periodo='2024-07', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=6, @fecha='2024-08-08', @monto=280000, @periodo='2024-08', @estado='Pagado';

-- Concesion 8: 1 atrasado
EXEC Concesiones.pagoCanon_Alta @idConcesion=8, @fecha='2024-11-05', @monto=220000, @periodo='2024-11', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=8, @fecha='2024-12-20', @monto=220000, @periodo='2024-12', @estado='Atrasado';

-- Concesion 10: pagos al dia
EXEC Concesiones.pagoCanon_Alta @idConcesion=10, @fecha='2025-04-08', @monto=130000, @periodo='2025-04', @estado='Pagado';
EXEC Concesiones.pagoCanon_Alta @idConcesion=10, @fecha='2025-05-07', @monto=130000, @periodo='2025-05', @estado='Pagado';


-- ====================================================================
-- VERIFICACION RAPIDA
-- ====================================================================
SELECT 'Parques (vienen del SIB)' AS tabla, COUNT(*) AS cantidad FROM Gestion.parque
UNION ALL SELECT 'Tipos de concesion', COUNT(*) FROM Concesiones.tipoConcesion
UNION ALL SELECT 'Empresas', COUNT(*) FROM Concesiones.empresa
UNION ALL SELECT 'Concesiones', COUNT(*) FROM Concesiones.concesion
UNION ALL SELECT 'Pagos de canon', COUNT(*) FROM Concesiones.pagoCanon;
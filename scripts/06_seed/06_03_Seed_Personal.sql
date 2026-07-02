/* 
    Script generado el 24/06/26

    Grupo n�7
    Integrantes:    - Acu�a, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripci�n del Script: Seed data del esquema Personal.
                            
    IMPORTANTE: este seed carga datos del schema personal, 
    Primero se deberan cargar al menos 10 parques.
                                                      
    Incluye:
    - Guardaparques Activos, Inactivos, Suspendidos y con Licencia
    - Historial Guardaparques (a que parques esta asignados cada Guardaparques)
    - Guias
    - Titulos de los guias
    - Especialidades de los Guias
    - Habilitaciones
    - Habilitaciones de los guias en cada parque

*/

-- no usar los testing del personal

USE GestionParquesNacionales_Com5600_Grupo07;
GO

/*=======================================================
VERIFICACION DE LA EXISTENCIA DE LOS PARQUES
=======================================================*/

IF (SELECT COUNT(*) FROM Gestion.Parque) < 10
BEGIN
    ;THROW 50800,
    'No hay suficientes parques cargados. Ejecute primero el script de importacion o cargue al menos 10 parques.',
    1;
END
GO

/*=======================================================
SEED GUARDAPARQUES
=======================================================*/

---------------------------------------------------------
-- Activos
---------------------------------------------------------

EXEC Personal.guardaparquesAlta '10000001','Juan','Perez','1985-01-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000002','Pedro','Gomez','1984-02-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000003','Luis','Lopez','1983-03-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000004','Carlos','Martinez','1982-04-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000005','Diego','Suarez','1981-05-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000006','Martin','Ruiz','1980-06-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000007','Pablo','Diaz','1985-07-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000008','Jorge','Molina','1984-08-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000009','Nicolas','Ramos','1983-09-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000010','Tomas','Silva','1982-10-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000011','Lucas','Fernandez','1981-11-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000012','Matias','Torres','1980-12-10','ACTIVO';
EXEC Personal.guardaparquesAlta '10000013','Emanuel','Castro','1985-01-20','ACTIVO';
EXEC Personal.guardaparquesAlta '10000014','Gaston','Vega','1984-02-20','ACTIVO';
EXEC Personal.guardaparquesAlta '10000015','Facundo','Acosta','1983-03-20','ACTIVO';
GO


---------------------------------------------------------
-- Inactivos
---------------------------------------------------------

EXEC Personal.guardaparquesAlta '10000016','Miguel','Navarro','1980-01-01','INACTIVO';
EXEC Personal.guardaparquesAlta '10000017','Sergio','Godoy','1981-01-01','INACTIVO';
EXEC Personal.guardaparquesAlta '10000018','Raul','Paz','1982-01-01','INACTIVO';
GO

---------------------------------------------------------
-- Suspendidos
---------------------------------------------------------

EXEC Personal.guardaparquesAlta '10000019','Mario','Luna','1983-01-01','SUSPENDIDO';
GO

---------------------------------------------------------
-- De Licencia
---------------------------------------------------------

EXEC Personal.guardaparquesAlta '10000020','Ricardo','Mendez','1984-01-01','LICENCIA';
GO

/*=======================================================
SEED HISTORIAL DE LOS GUARDAPARQUES
=======================================================*/

EXEC Personal.guardaparqueParqueAsignar 1,1,'2024-01-01';
EXEC Personal.guardaparqueParqueAsignar 2,2,'2024-01-02';
EXEC Personal.guardaparqueParqueAsignar 3,3,'2024-01-03';
EXEC Personal.guardaparqueParqueAsignar 4,4,'2024-01-04';
EXEC Personal.guardaparqueParqueAsignar 5,5,'2024-01-05';

EXEC Personal.guardaparqueParqueAsignar 6,6,'2024-01-06';
EXEC Personal.guardaparqueParqueAsignar 7,7,'2024-01-07';
EXEC Personal.guardaparqueParqueAsignar 8,8,'2024-01-08';
EXEC Personal.guardaparqueParqueAsignar 9,9,'2024-01-09';
EXEC Personal.guardaparqueParqueAsignar 10,10,'2024-01-10';

EXEC Personal.guardaparqueParqueAsignar 11,1,'2024-02-01';
EXEC Personal.guardaparqueParqueAsignar 12,2,'2024-02-02';
EXEC Personal.guardaparqueParqueAsignar 13,3,'2024-02-03';
EXEC Personal.guardaparqueParqueAsignar 14,4,'2024-02-04';
EXEC Personal.guardaparqueParqueAsignar 15,5,'2024-02-05';
GO

/*=======================================================
SEED TITULOS GUIAS
=======================================================*/

EXEC Personal.tituloAlta 'Lic. Turismo', 'Licenciatura en Turismo';
EXEC Personal.tituloAlta 'Lic. Biologia', 'Licenciatura en Biologia';
EXEC Personal.tituloAlta 'Lic. Ciencias Ambientales', 'Ciencias Ambientales';
EXEC Personal.tituloAlta 'Tec. Conservacion', 'Tecnico en Conservacion';
EXEC Personal.tituloAlta 'Lic. Geografia', 'Licenciatura en Geografia';
GO

/*=======================================================
SEED ESPECIALIDADES
=======================================================*/

EXEC Personal.especialidadAlta 'Avistaje de Aves', 'Especialista en aves';
EXEC Personal.especialidadAlta 'Senderismo', 'Recorridos terrestres';
EXEC Personal.especialidadAlta 'Flora Nativa', 'Identificacion de flora';
EXEC Personal.especialidadAlta 'Fauna Nativa', 'Identificacion de fauna';
EXEC Personal.especialidadAlta 'Educacion Ambiental', 'Charlas educativas';
GO

/*=======================================================
SEED HABILITACIONES
=======================================================*/

EXEC Personal.habilitacionAlta 'Trekking';
EXEC Personal.habilitacionAlta 'Montañismo';
EXEC Personal.habilitacionAlta 'Kayak';
EXEC Personal.habilitacionAlta 'Cabalgata';
EXEC Personal.habilitacionAlta 'Avistaje';
GO

/*=======================================================
SEED GUIAS
=======================================================*/

EXEC Personal.guiaAlta '20000001','Ana','Sosa','1990-01-01',1,1;
EXEC Personal.guiaAlta '20000002','Maria','Perez','1991-01-01',2,2;
EXEC Personal.guiaAlta '20000003','Laura','Gomez','1992-01-01',3,3;
EXEC Personal.guiaAlta '20000004','Sofia','Lopez','1990-02-01',4,4;
EXEC Personal.guiaAlta '20000005','Julieta','Ruiz','1991-02-01',5,5;

EXEC Personal.guiaAlta '20000006','Valeria','Diaz','1992-02-01',1,2;
EXEC Personal.guiaAlta '20000007','Carla','Silva','1990-03-01',2,3;
EXEC Personal.guiaAlta '20000008','Paula','Castro','1991-03-01',3,4;
EXEC Personal.guiaAlta '20000009','Florencia','Ramos','1992-03-01',4,5;
EXEC Personal.guiaAlta '20000010','Natalia','Torres','1990-04-01',5,1;

EXEC Personal.guiaAlta '20000011','Camila','Suarez','1991-04-01',1,3;
EXEC Personal.guiaAlta '20000012','Lucia','Fernandez','1992-04-01',2,4;
EXEC Personal.guiaAlta '20000013','Micaela','Acosta','1990-05-01',3,5;
EXEC Personal.guiaAlta '20000014','Rocio','Vega','1991-05-01',4,1;
EXEC Personal.guiaAlta '20000015','Milagros','Paz','1992-05-01',5,2;

EXEC Personal.guiaAlta '20000016','Brenda','Luna','1990-06-01',1,4;
EXEC Personal.guiaAlta '20000017','Agustina','Mendez','1991-06-01',2,5;
EXEC Personal.guiaAlta '20000018','Daniela','Godoy','1992-06-01',3,1;
EXEC Personal.guiaAlta '20000019','Melina','Navarro','1990-07-01',4,2;
EXEC Personal.guiaAlta '20000020','Victoria','Martinez','1991-07-01',5,3;
GO


/*=======================================================
SEED HABILITACIONES DE CADA GUIA
=======================================================*/

EXEC Personal.habilitacionGuiaAlta 1,1,1,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 2,2,2,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 3,3,3,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 4,4,4,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 5,5,5,'2025-01-01','2025-12-31';

EXEC Personal.habilitacionGuiaAlta 1,6,6,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 2,7,7,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 3,8,8,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 4,9,9,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 5,10,10,'2025-01-01','2025-12-31';

EXEC Personal.habilitacionGuiaAlta 1,11,1,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 2,12,2,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 3,13,3,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 4,14,4,'2025-01-01','2025-12-31';
EXEC Personal.habilitacionGuiaAlta 5,15,5,'2025-01-01','2025-12-31';
GO

/*=======================================================
VERIFICACION RAPIDA
=======================================================*/
/*
SELECT 'Guardaparques' AS concepto, COUNT(*) AS cantidad
FROM Personal.guardaparques

UNION ALL

SELECT 'Activos', COUNT(*)
FROM Personal.guardaparques
WHERE estado = 'ACTIVO'

UNION ALL

SELECT 'Inactivos', COUNT(*)
FROM Personal.guardaparques
WHERE estado = 'INACTIVO'

UNION ALL

SELECT 'Suspendidos', COUNT(*)
FROM Personal.guardaparques
WHERE estado = 'SUSPENDIDO'

UNION ALL

SELECT 'Licencia', COUNT(*)
FROM Personal.guardaparques
WHERE estado = 'LICENCIA'

UNION ALL

SELECT 'Historial', COUNT(*)
FROM Personal.HistorialGuardaparques

UNION ALL

SELECT 'Guias', COUNT(*)
FROM Personal.Guias

UNION ALL

SELECT 'Titulos', COUNT(*)
FROM Personal.Titulos

UNION ALL

SELECT 'Especialidades', COUNT(*)
FROM Personal.Especialidad

UNION ALL

SELECT 'Habilitaciones', COUNT(*)
FROM Personal.Habilitaciones

UNION ALL

SELECT 'HabilitacionesGuia', COUNT(*)
FROM Personal.HabilitacionesGuias;
GO
*/


/*

---------------------------------------------------------
-- CREACION DE 10 PARQUES PARA EJEMPLO
---------------------------------------------------------


USE GestionParquesNacionales;
GO


---------------------------------------------------------
-- LIMPIEZA (SOLO PARA PRUEBAS)
---------------------------------------------------------


DELETE FROM Gestion.parque;
DELETE FROM Gestion.tipoParque;

DBCC CHECKIDENT ('Gestion.parque', RESEED, 0);
DBCC CHECKIDENT ('Gestion.tipoParque', RESEED, 0);
GO


---------------------------------------------------------
-- TIPOS DE PARQUE
---------------------------------------------------------


EXEC Gestion.tipoParqueAlta
    @nombre = 'Parque Nacional',
    @descripcion = 'Area protegida nacional';

EXEC Gestion.tipoParqueAlta
    @nombre = 'Reserva Natural',
    @descripcion = 'Reserva de conservacion';

EXEC Gestion.tipoParqueAlta
    @nombre = 'Monumento Natural',
    @descripcion = 'Proteccion de patrimonio natural';
GO


---------------------------------------------------------
-- 10 PARQUES DE PRUEBA
---------------------------------------------------------


EXEC Gestion.parqueAlta
    'Parque Los Alerces', 259822.00, 1,
    'Chubut', '9200', 'Ruta Provincial 71', '100',
    -42.832000, -71.625000;

EXEC Gestion.parqueAlta
    'Parque Nahuel Huapi', 717261.00, 1,
    'Rio Negro', '8400', 'Av Bustillo', '1500',
    -41.133000, -71.310000;

EXEC Gestion.parqueAlta
    'Parque Iguazu', 67289.00, 1,
    'Misiones', '3370', 'Ruta 101', '200',
    -25.695000, -54.436000;

EXEC Gestion.parqueAlta
    'Parque Talampaya', 215000.00, 1,
    'La Rioja', '5300', 'Ruta Nacional 76', '300',
    -29.790000, -67.846000;

EXEC Gestion.parqueAlta
    'Parque El Palmar', 8213.00, 1,
    'Entre Rios', '3287', 'Ruta Nacional 14', '400',
    -31.857000, -58.286000;

EXEC Gestion.parqueAlta
    'Reserva Laguna Blanca', 11250.00, 2,
    'Neuquen', '8340', 'Ruta Provincial 46', '500',
    -39.034000, -70.356000;

EXEC Gestion.parqueAlta
    'Reserva Otamendi', 3000.00, 2,
    'Buenos Aires', '2804', 'Camino Otamendi', '600',
    -34.230000, -58.890000;

EXEC Gestion.parqueAlta
    'Monumento Bosques Petrificados', 13700.00, 1,
    'Santa Cruz', '9011', 'Ruta Nacional 49', '700',
    -47.974000, -68.089000;

EXEC Gestion.parqueAlta
    'Parque Quebrada del Condorito', 37000.00, 1,
    'Cordoba', '5155', 'Ruta Provincial 34', '800',
    -31.650000, -64.760000;

EXEC Gestion.parqueAlta
    'Parque Copo', 114250.00, 1,
    'Santiago del Estero', '4300', 'Ruta Provincial 4', '900',
    -25.950000, -62.050000;
GO


---------------------------------------------------------
-- VERIFICACION
---------------------------------------------------------


SELECT
    idParque,
    nombre,
    provincia,
    idTipoParque
FROM Gestion.parque
ORDER BY idParque;
GO

*/

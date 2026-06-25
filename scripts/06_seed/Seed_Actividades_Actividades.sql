/* 
    Script generado el 24/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Seed data del esquema Actividades.
                                                      
    Incluye:
    - Tipos de actividades
    - Actividades de varios tipos
*/


USE GestionParquesNacionales
GO

/* =========================
   Tipos de actividad
   ========================= */


EXEC Actividades.tipoActividadAlta 'Visita Guiada';
EXEC Actividades.tipoActividadAlta 'Aventura';
EXEC Actividades.tipoActividadAlta 'Educativa';
EXEC Actividades.tipoActividadAlta 'Nautica';
EXEC Actividades.tipoActividadAlta 'Cultural';

EXEC Actividades.tipoActividadAlta 'Senderismo';
EXEC Actividades.tipoActividadAlta 'Observacion de Fauna';
EXEC Actividades.tipoActividadAlta 'Observacion de Flora';
EXEC Actividades.tipoActividadAlta 'Fotografia';

EXEC Actividades.tipoActividadAlta 'Interpretacion Ambiental';
EXEC Actividades.tipoActividadAlta 'Recreativa';
EXEC Actividades.tipoActividadAlta 'Historica';

EXEC Actividades.tipoActividadAlta 'Deportiva';
EXEC Actividades.tipoActividadAlta 'Nocturna';
EXEC Actividades.tipoActividadAlta 'Investigacion';


/* =========================
   ACTIVIDADES
   ========================= */

EXEC Actividades.actividadAlta
    @nombre = 'Recorrido Historico',
    @costo = 0,
    @duracion = 2.0,
    @idTipoActividad = 1;

EXEC Actividades.actividadAlta
    @nombre = 'Senderismo por la Reserva',
    @costo = 25.00,
    @duracion = 3.5,
    @idTipoActividad = 2;

EXEC Actividades.actividadAlta
    @nombre = 'Observacion de Aves',
    @costo = 15.00,
    @duracion = 2.5,
    @idTipoActividad = 3;

EXEC Actividades.actividadAlta
    @nombre = 'Paseo en Kayak',
    @costo = 45.00,
    @duracion = 2.0,
    @idTipoActividad = 4;

EXEC Actividades.actividadAlta
    @nombre = 'Visita al Centro Cultural',
    @costo = 10.00,
    @duracion = 1.5,
    @idTipoActividad = 5;

EXEC Actividades.actividadAlta
    @nombre = 'Circuito Fotografico',
    @costo = 20.00,
    @duracion = 3.0,
    @idTipoActividad = 1;

EXEC Actividades.actividadAlta
    @nombre = 'Exploracion Nocturna',
    @costo = 35.00,
    @duracion = 2.5,
    @idTipoActividad = 2;

EXEC Actividades.actividadAlta
    @nombre = 'Taller de Flora Autoctona',
    @costo = 12.00,
    @duracion = 2.0,
    @idTipoActividad = 3;

EXEC Actividades.actividadAlta
    @nombre = 'Navegacion Interpretativa',
    @costo = 40.00,
    @duracion = 2.5,
    @idTipoActividad = 4;

EXEC Actividades.actividadAlta
    @nombre = 'Museo del Parque',
    @costo = 8.00,
    @duracion = 1.0,
    @idTipoActividad = 5;

EXEC Actividades.actividadAlta
    @nombre = 'Trekking de Montana',
    @costo = 55.00,
    @duracion = 4.5,
    @idTipoActividad = 2;

EXEC Actividades.actividadAlta
    @nombre = 'Interpretacion de Ecosistemas',
    @costo = 18.00,
    @duracion = 2.0,
    @idTipoActividad = 3;

EXEC Actividades.actividadAlta
    @nombre = 'Avistaje de Mamiferos',
    @costo = 22.00,
    @duracion = 3.0,
    @idTipoActividad = 1;

EXEC Actividades.actividadAlta
    @nombre = 'Patrimonio y Tradiciones Locales',
    @costo = 15.00,
    @duracion = 1.5,
    @idTipoActividad = 5;

EXEC Actividades.actividadAlta
    @nombre = 'Travesia en Canoa',
    @costo = 50.00,
    @duracion = 3.5,
    @idTipoActividad = 4;

/* =========================
   Verificacion
   ========================= */


SELECT * FROM Actividades.tipoActividad
SELECT * FROM Actividades.actividad

/* 
    Script generado el 24/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Seed data de los titulos y habilitaciones de guias del esquema de personal
                            
    IMPORTANTE: este seed NO carga titulos ni guias, estos vienen de la importacion.
*/
USE GestionParquesNacionales
GO


EXEC Personal.altaEspecialidad
    'Fauna',
    'Interpretacion y observacion de fauna silvestre';

EXEC Personal.altaEspecialidad
    'Flora',
    'Interpretacion botanica y ecosistemas vegetales';

EXEC Personal.altaEspecialidad
    'Historia',
    'Patrimonio historico y cultural';

EXEC Personal.altaEspecialidad
    'Aventura',
    'Actividades de trekking y turismo aventura';

EXEC Personal.altaEspecialidad
    'Educacion Ambiental',
    'Programas educativos para visitantes';

SELECT * FROM Personal.especialidad


/* =====================================
   HABILITACIONES
   ===================================== */

EXEC Personal.altaHabilitacion
    'Primeros Auxilios',
    'Atencion primaria de emergencias';

EXEC Personal.altaHabilitacion
    'Senderismo de Montana',
    'Excursiones en senderos de dificultad media y alta';

EXEC Personal.altaHabilitacion
    'Observacion de Fauna',
    'Interpretacion de especies animales';

EXEC Personal.altaHabilitacion
    'Educacion Ambiental',
    'Actividades educativas y talleres';

EXEC Personal.altaHabilitacion
    'Guia Nocturno',
    'Recorridos durante horario nocturno';

EXEC Personal.altaHabilitacion
    'Turismo Aventura',
    'Actividades recreativas de aventura';

EXEC Personal.altaHabilitacion
    'Idioma Ingles',
    'Visitas guiadas en idioma ingles';


SELECT * FROM Personal.habilitaciones
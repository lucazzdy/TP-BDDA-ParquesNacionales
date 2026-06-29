/* 
    Script generado el 22/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Testing de los SP de reportes del modulo
                            Gestion + Concesiones (Entrega 7).
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO


-- reporteDeudores

-- OK: ejecutar el reporte y verificar que devuelve XML
EXEC Concesiones.reporteDeudores;

-- OK: el contenido del XML debe coincidir con esta query
SELECT 
    c.idConcesion,
    e.nombre AS empresa,
    p.nombre AS parque,
    COUNT(pc.idPagoCanon) AS mesesAtrasados,
    SUM(pc.monto) AS montoAdeudado
FROM Concesiones.concesion c
INNER JOIN Concesiones.empresa e ON e.idEmpresa = c.idEmpresa
INNER JOIN Gestion.parque p ON p.idParque = c.idParque
INNER JOIN Concesiones.pagoCanon pc ON pc.idConcesion = c.idConcesion
WHERE pc.estado = 'Atrasado'
GROUP BY c.idConcesion, e.nombre, p.nombre;


-- reporteParquesConConcesiones

-- OK: ejecutar el reporte y verificar que devuelve XML
EXEC Gestion.reporteParquesConConcesiones;

-- OK: el XML debe incluir TODOS los parques (con y sin concesiones)
SELECT COUNT(*) AS totalParques FROM Gestion.parque;

-- OK: los parques con concesiones deben tener nodo <Concesiones>; los demas no
SELECT 
    p.nombre AS parque,
    COUNT(c.idConcesion) AS cantidadConcesiones
FROM Gestion.parque p
LEFT JOIN Concesiones.concesion c ON c.idParque = p.idParque
GROUP BY p.nombre
ORDER BY cantidadConcesiones DESC;

-- OK: las concesiones se clasifican correctamente como Vigente o Vencida
SELECT 
    c.idConcesion,
    c.fechaInicio,
    c.fechaFin,
    CASE 
        WHEN CAST(GETDATE() AS DATE) BETWEEN c.fechaInicio AND c.fechaFin 
            THEN 'Vigente'
        ELSE 'Vencida'
    END AS estado
FROM Concesiones.concesion c
ORDER BY c.idConcesion;
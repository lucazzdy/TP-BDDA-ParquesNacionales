/* 
    Script generado el 02/07/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leonel
                    - Zambrana, Mijael

    Descripción del Script: Testing de los SP de reportes del modulo VisitasParques 
*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO


-- reporteVisitas

-- OK: ejecutar el reporte y verificar que devuelve todas las visitas agrupadas por parque y fecha
EXEC Gestion.reporteVisitas;

-- OK: el resultado debe coincidir con esta query (misma cantidad de filas y totales por parque/fecha)
SELECT 
    p.nombre AS Parque,
    COUNT(e.codigoEntrada) AS TotalVisitas,
    e.fechaAcceso AS FechaAcceso
FROM Ventas.entrada e
INNER JOIN Gestion.parque p ON e.idParque = p.idParque
GROUP BY p.nombre, e.fechaAcceso
ORDER BY e.fechaAcceso;

-- OK: la suma de TotalVisitas del reporte debe coincidir con el total de entradas registradas
SELECT COUNT(*) AS totalEntradas FROM Ventas.entrada;


-- reporteIngresos

-- OK: ejecutar el reporte y verificar que devuelve ingresos por parque y fecha (ventas + canon de concesiones)
EXEC Gestion.reporteIngresos;

-- OK: la suma de ingresos por ventas aprobadas debe estar incluida en el reporte
SELECT SUM(v.total) AS totalVentasAprobadas
FROM Ventas.venta v
INNER JOIN Ventas.pago pg ON v.idVenta = pg.idVenta
WHERE pg.estado = 'Aprobado';

-- OK: la suma de canon cobrado debe estar incluida en el reporte
SELECT SUM(pc.monto) AS totalCanonCobrado
FROM Concesiones.pagoCanon pc
WHERE pc.estado = 'Pagado';

-- OK: la suma total de TotalIngresos del reporte debe ser (totalVentasAprobadas + totalCanonCobrado)


-- reporteVisitasPorPeriodo

-- OK: ejecutar el reporte y verificar la matriz pivot (parques en filas, periodos MM-yyyy en columnas)
EXEC Gestion.reporteVisitasPorPeriodo;

-- OK: la cantidad de columnas del pivot debe coincidir con la cantidad de periodos MM-yyyy distintos existentes
SELECT COUNT(DISTINCT FORMAT(fechaAcceso, 'MM-yyyy')) AS periodosDistintos 
FROM Ventas.entrada;

-- OK: la cantidad de filas del pivot debe coincidir con la cantidad de parques con al menos una entrada
SELECT COUNT(DISTINCT idParque) AS parquesConVisitas 
FROM Ventas.entrada;

-- OK: la suma de todas las celdas del pivot debe coincidir con el total de entradas
SELECT COUNT(*) AS totalEntradas FROM Ventas.entrada;


-- reporteActividadesMasDemandadas

-- OK: ejecutar el reporte y verificar que devuelve actividades ordenadas por demanda descendente
EXEC Gestion.reporteActividadesMasDemandadas;

-- OK: la actividad mas contratada del reporte debe coincidir con esta query
SELECT TOP 1 
    a.nombre AS actividad,
    COUNT(ea.codigoEntrada) AS vecesContratada
FROM Actividades.actividad a
LEFT JOIN Ventas.entradaActividad ea ON ea.idActividad = a.idActividad
GROUP BY a.nombre
ORDER BY vecesContratada DESC;

-- OK: la suma de VecesContratada del reporte debe coincidir con el total de entradaActividad
SELECT COUNT(*) AS totalEntradasActividad FROM Ventas.entradaActividad;

-- OK: la cantidad de filas del reporte debe coincidir con el total de actividades (incluye las de 0 contrataciones)
SELECT COUNT(*) AS totalActividades FROM Actividades.actividad;
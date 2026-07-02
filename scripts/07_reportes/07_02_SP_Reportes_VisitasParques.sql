/* 
    Script generado el 24/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures de reportes visitas e ingresos
                            de los parques.
                            

*/

USE GestionParquesNacionales_Com5600_Grupo07;
GO

/*=========================================================
REPORTE:  visitas por semana, mes y año, por parque.
Lista las visitas que tienen cada parques por dia, mes, y año.
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.reporteVisitas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.nombre AS Parque,
        COUNT(e.codigoEntrada) AS TotalVisitas,
        e.fechaAcceso AS FechaAcceso
    FROM 
        Ventas.entrada e
        INNER JOIN Gestion.parque p ON e.idParque = p.idParque
    GROUP BY p.nombre, e.fechaAcceso
    ORDER BY e.fechaAcceso;
END
GO

/*=========================================================
REPORTE: Ingresos por parque por semana, mes y año.
Suma total de entradas, tours y canon de concesiones cobradas.
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.reporteIngresos
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Ventas AS
    (
        SELECT
            p.idParque,
            p.nombre AS Parque,
            CAST(pg.fecha AS DATE) AS Fecha,
            SUM(tf.montoTotal) AS TotalVentas
        FROM Ventas.venta v
        INNER JOIN Gestion.parque p ON p.idParque = v.idParque
        INNER JOIN Ventas.pago pg ON pg.idVenta = v.idVenta
        INNER JOIN Ventas.ticketFactura tf ON tf.idVenta = v.idVenta
        WHERE pg.estado = 'Aprobado'
        GROUP BY p.idParque, p.nombre, CAST(pg.fecha AS DATE)
    ),
    Canones AS
    (
        SELECT
            c.idParque,
            p.nombre AS Parque,
            CAST(pc.fecha AS DATE) AS Fecha,
            SUM(pc.monto) AS TotalCanon
        FROM Concesiones.pagoCanon pc
        INNER JOIN Concesiones.concesion c ON c.idConcesion = pc.idConcesion
        INNER JOIN Gestion.parque p ON p.idParque = c.idParque
        WHERE pc.estado IN  ('Pagado', 'Atrasado')
        GROUP BY c.idParque, p.nombre, CAST(pc.fecha AS DATE)
    )

    SELECT
        COALESCE(v.parque, c.parque) AS Parque,
        COALESCE(v.fecha, c.fecha) AS Fecha,
        ISNULL(v.TotalVentas, 0) AS TotalVentas,
        ISNULL(c.TotalCanon, 0) AS TotalCanon,
        ISNULL(v.TotalVentas, 0) + ISNULL(c.TotalCanon, 0) AS TotalIngresos
    FROM Ventas v
    FULL OUTER JOIN Canones c ON v.idParque = c.idParque AND v.Fecha = c.Fecha
    ORDER BY fecha, parque;
END;
GO


/*=========================================================
  REPORTE: Matriz de visitas: Tabla cruzada (Pivot) mostrando 
  visitas por mes y parque.
  =========================================================*/

CREATE OR ALTER PROCEDURE Gestion.reporteVisitasPorPeriodo
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @columnasPeriodos NVARCHAR(MAX) = '';
    DECLARE @queryDinamica NVARCHAR(MAX) = '';

    -- 1. Obtenemos de forma dinámica todos los períodos (MM-yyyy) existentes cronológicamente
    SELECT @columnasPeriodos = STRING_AGG(QUOTENAME(Periodo), ', ') WITHIN GROUP (ORDER BY Anio ASC, Mes ASC)
    FROM (
        SELECT DISTINCT 
            FORMAT(fechaAcceso, 'MM-yyyy') AS Periodo,
            YEAR(fechaAcceso) AS Anio,
            MONTH(fechaAcceso) AS Mes
        FROM Ventas.entrada
    ) AS PeriodosExistentes;

    -- Validación preventiva por si la tabla de entradas está vacía
    IF @columnasPeriodos IS NULL OR @columnasPeriodos = ''
    BEGIN
        ;THROW 60004, 'No se encontraron entradas registradas para armar las columnas cronológicas del PIVOT.', 1;
    END

    -- 2. Armamos la consulta dinámica utilizando un CTE intermedio
    SET @queryDinamica = '
        ;WITH datosOrigen AS (
            SELECT 
                p.Nombre AS [Parque Nacional],
                FORMAT(e.fechaAcceso, ''MM-yyyy'') AS Periodo,
                e.idVisitante
            FROM Ventas.entrada e
            INNER JOIN Gestion.Parque p ON e.idParque = p.idParque
        )
        SELECT 
            [Parque Nacional],
            ' + @columnasPeriodos + '
        FROM datosOrigen
        PIVOT (COUNT(idVisitante) FOR Periodo IN (' + @columnasPeriodos + ')) AS p ORDER BY [Parque Nacional] ASC;
    ';
    -- 3. Ejecutamos el bloque SQL generado en memoria
    EXEC sp_executesql @queryDinamica;
END;
GO


/*=========================================================
REPORTE: Actividades mas demandadas.
Lista las actividades y tours ordenados por cantidad de veces contratados.
Cumple con el punto G de la seccion II del enunciado.
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.reporteActividadesMasDemandadas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        a.nombre AS Actividad,
        ta.descripcion AS Tipo,
        COUNT(ea.codigoEntrada) AS VecesContratada
    FROM Actividades.actividad a
    INNER JOIN Actividades.tipoActividad ta ON ta.idTipoActividad = a.idTipoActividad
    LEFT JOIN Ventas.entradaActividad ea ON ea.idActividad = a.idActividad
    GROUP BY a.nombre, ta.descripcion
    ORDER BY VecesContratada DESC;
END
GO
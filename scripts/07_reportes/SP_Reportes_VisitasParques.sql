/* 
    Script generado el 24/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures de reportes visitas e ingresos
                            de los parques.
                            
                            Cumple los requisitos de la entrega de 
                            retornar XML en algunos reportes.
*/

USE GestionParquesNacionales;
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
        WHERE e.fechaAcceso <= DATEADD(DAY, +1, GETDATE())
    GROUP BY p.nombre, e.fechaAcceso
    ORDER BY e.fechaAcceso;
END
GO

/*=========================================================
REPORTE: Ingresos por parque por semana, mes y año.
Lista los ingresos que tienen cada parque por dia, mes, y año.
=========================================================*/

CREATE OR ALTER PROCEDURE Gestion.reporteIngresos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.nombre AS Parque,
        SUM(v.total) AS TotalIngresos,
        pg.fecha AS FechaPago
    FROM 
        Ventas.venta v
        INNER JOIN Gestion.parque p ON v.idParque = p.idParque
        INNER JOIN Ventas.pago pg ON v.idVenta = pg.idVenta
        WHERE pg.fecha <= DATEADD(DAY, +1, GETDATE()) AND pg.estado = 'Aprobado'
    GROUP BY p.nombre, pg.fecha
    ORDER BY pg.fecha;
END
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

SELECT * FROM Ventas.venta
EXEC Gestion.reporteVisitas;
EXEC Gestion.reporteIngresos;
EXEC Gestion.reporteVisitasPorPeriodo;

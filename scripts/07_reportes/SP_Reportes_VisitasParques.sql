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
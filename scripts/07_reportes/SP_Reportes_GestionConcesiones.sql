/* 
    Script generado el 22/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures de reportes del modulo
                            Gestion + Concesiones
                            
                            Cumple los requisitos de la entrega de 
                            retornar XML en algunos reportes.
*/

USE GestionParquesNacionales;
GO


/*=========================================================
REPORTE: DEUDORES
Lista las concesiones que tienen al menos un pago en estado
Atrasado, con el detalle de meses y montos especificos.
=========================================================*/
CREATE OR ALTER PROCEDURE Concesiones.reporte_deudores
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.idConcesion           AS '@idConcesion',
        e.nombre                AS '@empresa',
        p.nombre                AS '@parque',
        tc.descripcion          AS '@tipoConcesion',
        COUNT(pc.idPagoCanon)   AS '@mesesAtrasados',
        SUM(pc.monto)           AS '@montoAdeudado',
        -- detalles de cada mes atrasado
        (
            SELECT 
                periodo AS '@periodo',
                monto   AS '@monto'
            FROM Concesiones.pagoCanon
            WHERE idConcesion = c.idConcesion
              AND estado = 'Atrasado'
            ORDER BY periodo
            FOR XML PATH('PagoAtrasado'), TYPE
        )
    FROM Concesiones.concesion c
    INNER JOIN Concesiones.empresa e        ON e.idEmpresa = c.idEmpresa
    INNER JOIN Gestion.parque p             ON p.idParque = c.idParque
    INNER JOIN Concesiones.tipoConcesion tc ON tc.idTipoConcesion = c.idTipoConcesion
    INNER JOIN Concesiones.pagoCanon pc     ON pc.idConcesion = c.idConcesion
    WHERE pc.estado = 'Atrasado'
    GROUP BY c.idConcesion, e.nombre, p.nombre, tc.descripcion
    ORDER BY SUM(pc.monto) DESC
    FOR XML PATH('Concesion'), ROOT('Deudores');
END
GO

/*=========================================================
REPORTE: PARQUES Y CONCESIONES
Lista todos los parques con sus concesiones anidadas.
Si un parque no tiene concesiones, el nodo Concesiones no aparece.
El estado de cada concesion (Vigente/Vencida) se calcula comparando con la fecha actual.
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.reporte_parquesConConcesiones
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.idParque      AS '@idParque',
        p.nombre        AS '@nombre',
        p.provincia     AS '@provincia',
        p.superficie    AS '@superficie',
        tp.nombre       AS '@tipoParque',
        p.latitud       AS '@latitud',
        p.longitud      AS '@longitud',
        -- Contador rapido para no tener que contar manualmente en el XML
        (SELECT COUNT(*) FROM Concesiones.concesion 
         WHERE idParque = p.idParque) AS '@cantidadConcesiones',
        -- Subquery anidada con las concesiones del parque
        (
            SELECT 
                c.idConcesion                AS '@idConcesion',
                e.nombre                     AS '@empresa',
                tc.descripcion               AS '@servicio',
                c.fechaInicio                AS '@fechaInicio',
                c.fechaFin                   AS '@fechaFin',
                c.montoCanonMensual          AS '@canonMensual',
                CASE 
                    WHEN CAST(GETDATE() AS DATE) BETWEEN c.fechaInicio AND c.fechaFin 
                        THEN 'Vigente'
                    ELSE 'Vencida'
                END AS '@estado'
            FROM Concesiones.concesion c
            INNER JOIN Concesiones.empresa e        ON e.idEmpresa = c.idEmpresa
            INNER JOIN Concesiones.tipoConcesion tc ON tc.idTipoConcesion = c.idTipoConcesion
            WHERE c.idParque = p.idParque
            ORDER BY c.fechaInicio DESC
            FOR XML PATH('Concesion'), ROOT('Concesiones'), TYPE
        )
    FROM Gestion.parque p
    INNER JOIN Gestion.tipoParque tp ON tp.idTipoParque = p.idTipoParque
    ORDER BY p.nombre
    FOR XML PATH('Parque'), ROOT('Parques');
END
GO
/* 
    Script generado el 21/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures de logica de negocio
                            del esquema Gestion.
*/

USE GestionParquesNacionales;
GO


/*=========================================================
IMPORTAR PARQUE
Upsert: si existe un parque con el mismo nombre, actualiza
sus datos. Si no existe, lo crea. Delega las validaciones
y la persistencia a los SPs ABM (parque_Alta, parque_Modificar).
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.importarParque
    @nombre VARCHAR(100),
    @superficie DECIMAL(12, 2),
    @idTipoParque INT,
    @provincia VARCHAR(50),
    @codigoPostal VARCHAR(10) = NULL,
    @calle VARCHAR(100) = NULL,
    @nro VARCHAR(10) = NULL,
    @latitud DECIMAL(9, 6) = NULL,
    @longitud DECIMAL(9, 6) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @idParqueExistente INT;

    -- Verifico si el parque ya existe (matchea por nombre)
    SELECT @idParqueExistente = idParque
    FROM Gestion.parque
    WHERE nombre = @nombre;

    IF @idParqueExistente IS NULL
    BEGIN
        -- No existe: alta delegada al SP ABM
        EXEC Gestion.parque_Alta 
            @nombre = @nombre,
            @superficie = @superficie,
            @idTipoParque = @idTipoParque,
            @provincia = @provincia,
            @codigoPostal = @codigoPostal,
            @calle = @calle,
            @nro = @nro,
            @latitud = @latitud,
            @longitud = @longitud;
    END
    ELSE
    BEGIN
        -- Ya existe: modificacion delegada al SP ABM
        EXEC Gestion.parque_Modificar
            @idParque = @idParqueExistente,
            @superficie = @superficie,
            @idTipoParque = @idTipoParque,
            @provincia = @provincia,
            @codigoPostal = @codigoPostal,
            @calle = @calle,
            @nro = @nro,
            @latitud = @latitud,
            @longitud = @longitud;
    END
END
GO


/*=========================================================
CONSULTAR PARQUE CON CONCESIONES
Devuelve los datos del parque y sus concesiones activas
(las que tienen fecha actual entre fechaInicio y fechaFin).
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.consultarParqueConConcesiones
    @idParque INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Gestion.parque WHERE idParque = @idParque)
    BEGIN
        SET @errorMsg = @errorMsg + '- No existe un parque con id: ' + CAST(@idParque AS VARCHAR(10)) + '.' + @saltoLinea;
        ;THROW 50151, @errorMsg, 1;
    END

    -- Datos del parque
    SELECT 
        p.idParque,
        p.nombre AS parque,
        tp.nombre AS tipoParque,
        p.superficie,
        p.provincia,
        p.latitud,
        p.longitud
    FROM Gestion.parque p
    INNER JOIN Gestion.tipoParque tp ON tp.idTipoParque = p.idTipoParque
    WHERE p.idParque = @idParque;

    -- Concesiones activas
    SELECT 
        c.idConcesion,
        e.nombre AS empresa,
        tc.descripcion AS tipoConcesion,
        c.fechaInicio,
        c.fechaFin,
        c.montoCanonMensual
    FROM Concesiones.concesion c
    INNER JOIN Concesiones.empresa e ON e.idEmpresa = c.idEmpresa
    INNER JOIN Concesiones.tipoConcesion tc ON tc.idTipoConcesion = c.idTipoConcesion
    WHERE c.idParque = @idParque
      AND CAST(GETDATE() AS DATE) BETWEEN c.fechaInicio AND c.fechaFin
    ORDER BY c.fechaFin;
END
GO
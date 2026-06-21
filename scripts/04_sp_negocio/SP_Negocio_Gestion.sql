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
sus datos. Si no existe, lo crea.
Soporta los campos que traen los datasets de SIB y CIAM.
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.importarParque
    @nombre VARCHAR(100),
    @superficie DECIMAL(12, 2),
    @idTipoParque INT,
    @provincia VARCHAR(50),
    @codigoPostal VARCHAR(10) = NULL,
    @calle VARCHAR(100) = NULL,
    @nro VARCHAR(10) = NULL,
    @anioCreacion INT = NULL,
    @latitud DECIMAL(9, 6) = NULL,
    @longitud DECIMAL(9, 6) = NULL,
    @leyCreacion VARCHAR(100) = NULL,
    @categoriaInternacional VARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errorMsg VARCHAR(500) = '';
    DECLARE @saltoLinea CHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @idParqueExistente INT;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errorMsg = @errorMsg + '- El nombre del parque es obligatorio.' + @saltoLinea;

    IF @provincia IS NULL OR LTRIM(RTRIM(@provincia)) = ''
        SET @errorMsg = @errorMsg + '- La provincia es obligatoria.' + @saltoLinea;

    IF @superficie IS NULL OR @superficie <= 0
        SET @errorMsg = @errorMsg + '- La superficie debe ser mayor a 0.' + @saltoLinea;

    IF NOT EXISTS (SELECT 1 FROM Gestion.tipoParque WHERE idTipoParque = @idTipoParque)
        SET @errorMsg = @errorMsg + '- No existe un tipo de parque con id: ' + CAST(@idTipoParque AS VARCHAR(10)) + '.' + @saltoLinea;

    IF @latitud IS NOT NULL AND (@latitud < -90 OR @latitud > 90)
        SET @errorMsg = @errorMsg + '- La latitud debe estar entre -90 y 90.' + @saltoLinea;

    IF @longitud IS NOT NULL AND (@longitud < -180 OR @longitud > 180)
        SET @errorMsg = @errorMsg + '- La longitud debe estar entre -180 y 180.' + @saltoLinea;

    IF LEN(@errorMsg) > 0
    BEGIN
        ;THROW 50150, @errorMsg, 1;
    END

    -- Verifico si el parque ya existe
    SELECT @idParqueExistente = idParque
    FROM Gestion.parque
    WHERE nombre = @nombre;

    IF @idParqueExistente IS NULL
    BEGIN
        -- No existe: alta
        INSERT INTO Gestion.parque (nombre, superficie, idTipoParque, provincia, codigoPostal, calle, nro,
                                    anioCreacion, latitud, longitud, leyCreacion, categoriaInternacional)
        VALUES (@nombre, @superficie, @idTipoParque, @provincia, @codigoPostal, @calle, @nro,
                @anioCreacion, @latitud, @longitud, @leyCreacion, @categoriaInternacional);
    END
    ELSE
    BEGIN
        -- Ya existe: actualizo solo los campos que vienen no nulos
        UPDATE Gestion.parque
        SET superficie = ISNULL(@superficie, superficie),
            idTipoParque = ISNULL(@idTipoParque, idTipoParque),
            provincia = ISNULL(@provincia, provincia),
            codigoPostal = ISNULL(@codigoPostal, codigoPostal),
            calle = ISNULL(@calle, calle),
            nro = ISNULL(@nro, nro),
            anioCreacion = ISNULL(@anioCreacion, anioCreacion),
            latitud = ISNULL(@latitud, latitud),
            longitud = ISNULL(@longitud, longitud),
            leyCreacion = ISNULL(@leyCreacion, leyCreacion),
            categoriaInternacional = ISNULL(@categoriaInternacional, categoriaInternacional)
        WHERE idParque = @idParqueExistente;
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
        p.anioCreacion,
        p.latitud,
        p.longitud,
        p.leyCreacion,
        p.categoriaInternacional
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

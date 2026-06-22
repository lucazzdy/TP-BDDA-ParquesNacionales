/* 
    Script generado el 19/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Stored procedures de logica de importacion
                            masiva. Procesan las tablas staging y llaman
                            a importarParque por cada fila.
                            
                            Crean automaticamente los tipos de parque
                            que detecten en los datos si no existen.
                            
                            Cumplen el requisito de importacion parcial:
                            si una fila falla, las demas siguen.
*/

USE GestionParquesNacionales;
GO


/*=========================================================
PARSEAR NOMBRE PARQUE
Recibe el nombre completo del dataset 
ej: Parque Nacional Iguazu, y devuelve a traves de 
variables OUTPUT:
- tipoParque: "Parque Nacional"
- nombreLimpio: "Iguazu"

Uso REPLACE para sacar el prefijo del nombre completo.
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.parsearNombreParque
    @nombreCompleto VARCHAR(200),
    @tipoParque VARCHAR(50) OUTPUT,
    @nombreLimpio VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @nombreCompleto = LTRIM(RTRIM(@nombreCompleto));

    IF @nombreCompleto LIKE 'Parque Interjurisdiccional Marino Costero %'
    BEGIN
        SET @tipoParque = 'Parque Interjurisdiccional Marino Costero';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Parque Interjurisdiccional Marino Costero ', ''));
    END
    ELSE IF @nombreCompleto LIKE 'Parque Interjurisdiccional Marino %'
    BEGIN
        SET @tipoParque = 'Parque Interjurisdiccional Marino';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Parque Interjurisdiccional Marino ', ''));
    END
    ELSE IF @nombreCompleto LIKE 'Reserva Natural Estricta %'
    BEGIN
        SET @tipoParque = 'Reserva Natural Estricta';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Reserva Natural Estricta ', ''));
    END
    ELSE IF @nombreCompleto LIKE 'Reserva Natural Educativa %'
    BEGIN
        SET @tipoParque = 'Reserva Natural Educativa';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Reserva Natural Educativa ', ''));
    END
    ELSE IF @nombreCompleto LIKE 'Reserva Natural Silvestre %'
    BEGIN
        SET @tipoParque = 'Reserva Natural Silvestre';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Reserva Natural Silvestre ', ''));
    END
    ELSE IF @nombreCompleto LIKE 'Reserva Nacional %'
    BEGIN
        SET @tipoParque = 'Reserva Nacional';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Reserva Nacional ', ''));
    END
    ELSE IF @nombreCompleto LIKE 'Parque Nacional %'
    BEGIN
        SET @tipoParque = 'Parque Nacional';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Parque Nacional ', ''));
    END
    ELSE IF @nombreCompleto LIKE 'Monumento Natural %'
    BEGIN
        SET @tipoParque = 'Monumento Natural';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Monumento Natural ', ''));
    END
    ELSE IF @nombreCompleto LIKE 'Area Marina Protegida %'
    BEGIN
        SET @tipoParque = 'Area Marina Protegida';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Area Marina Protegida ', ''));
    END
    ELSE IF @nombreCompleto LIKE N'Área Marina Protegida %'
    BEGIN
        SET @tipoParque = 'Area Marina Protegida';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, N'Área Marina Protegida ', ''));
    END
    ELSE
    BEGIN
        -- No matchea ningun prefijo conocido
        SET @tipoParque = NULL;
        SET @nombreLimpio = @nombreCompleto;
    END
END
GO


/*=========================================================
PROCESAR IMPORTACION SIB
Recorre la staging del SIB y por cada fila:
1. Parsea el nombre para obtener tipo y nombre limpio
2. Si el tipoParque no existe en la BD, lo crea automaticamente
3. Si la provincia esta vacia, usa la region
4. Llama a importarParque (upsert)
5. Registra el resultado en logImportacion

La importacion es parcial: si una fila falla, las demas siguen.
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.procesarImportacionSib
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @nombreCompleto VARCHAR(200), @provincia VARCHAR(100);
    DECLARE @region VARCHAR(100), @superficie DECIMAL(12, 2);
    DECLARE @latitud DECIMAL(9, 6), @longitud DECIMAL(9, 6);
    DECLARE @tipoParque VARCHAR(50), @nombreLimpio VARCHAR(100);
    DECLARE @idTipoParque INT, @errorMsg VARCHAR(500);
    DECLARE @ok INT = 0, @err INT = 0;

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT nombreCompleto, provincia, region, superficie, latitud, longitud
        FROM Gestion.stagingSib
        WHERE nombreCompleto IS NOT NULL;

    OPEN c;
    FETCH NEXT FROM c INTO @nombreCompleto, @provincia, @region,
                           @superficie, @latitud, @longitud;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Parseo del nombre
            EXEC Gestion.parsearNombreParque 
                @nombreCompleto = @nombreCompleto,
                @tipoParque = @tipoParque OUTPUT,
                @nombreLimpio = @nombreLimpio OUTPUT;

            IF @tipoParque IS NULL
            BEGIN
                INSERT INTO Gestion.logImportacion (origen, nombreCompleto, estado, mensaje)
                VALUES ('SIB', @nombreCompleto, 'ERROR', 'No se pudo identificar el tipo de parque desde el nombre.');
                SET @err = @err + 1;
                GOTO NextRow;
            END

            -- Buscar idTipoParque, si no existe crearlo
            SELECT @idTipoParque = idTipoParque 
            FROM Gestion.tipoParque 
            WHERE nombre = @tipoParque;

            IF @idTipoParque IS NULL
            BEGIN
                EXEC Gestion.tipoParque_Alta @nombre = @tipoParque;

                SELECT @idTipoParque = idTipoParque 
                FROM Gestion.tipoParque 
                WHERE nombre = @tipoParque;
            END

            -- Si la provincia esta vacia, usar la region (caso de areas marinas)
            IF @provincia IS NULL OR LTRIM(RTRIM(@provincia)) = ''
                SET @provincia = ISNULL(@region, 'Sin definir');

            -- Llamar al SP de importacion (upsert)
            EXEC Gestion.importarParque
                @nombre = @nombreLimpio,
                @superficie = @superficie,
                @idTipoParque = @idTipoParque,
                @provincia = @provincia,
                @latitud = @latitud,
                @longitud = @longitud;

            INSERT INTO Gestion.logImportacion (origen, nombreCompleto, estado, mensaje)
            VALUES ('SIB', @nombreCompleto, 'OK', NULL);
            SET @ok = @ok + 1;

            SET @idTipoParque = NULL;
        END TRY
        BEGIN CATCH
            SET @errorMsg = ERROR_MESSAGE();
            INSERT INTO Gestion.logImportacion (origen, nombreCompleto, estado, mensaje)
            VALUES ('SIB', @nombreCompleto, 'ERROR', LEFT(@errorMsg, 500));
            SET @err = @err + 1;
        END CATCH

        NextRow:
        FETCH NEXT FROM c INTO @nombreCompleto, @provincia, @region,
                               @superficie, @latitud, @longitud;
    END

    CLOSE c;
    DEALLOCATE c;

    -- Resumen del proceso
    SELECT @ok AS importadosOk, @err AS importadosConError, (@ok + @err) AS total;
END
GO


/*=========================================================
PROCESAR IMPORTACION CIAM
Actualiza la superficie y la categoria internacional de los
parques que ya existen en la BD. Si no encuentra el parque, 
lo registra como SALTADO.
=========================================================*/
CREATE OR ALTER PROCEDURE Gestion.procesarImportacionCiam
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @nombreCompleto VARCHAR(200), @hectareas DECIMAL(12, 2);
    DECLARE @tipoParque VARCHAR(50), @nombreLimpio VARCHAR(100);
    DECLARE @idParque INT, @errorMsg VARCHAR(500);
    DECLARE @ok INT = 0, @err INT = 0, @saltados INT = 0;

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT nombreCompleto, hectareas
        FROM Gestion.stagingCiam
        WHERE nombreCompleto IS NOT NULL;

    OPEN c;
    FETCH NEXT FROM c INTO @nombreCompleto, @hectareas;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Parseo del nombre para obtener nombre limpio
            EXEC Gestion.parsearNombreParque 
                @nombreCompleto = @nombreCompleto,
                @tipoParque = @tipoParque OUTPUT,
                @nombreLimpio = @nombreLimpio OUTPUT;

            -- Buscar el parque por nombre exacto
            SELECT @idParque = idParque 
            FROM Gestion.parque 
            WHERE nombre = @nombreLimpio;

            IF @idParque IS NULL
            BEGIN
                INSERT INTO Gestion.logImportacion (origen, nombreCompleto, estado, mensaje)
                VALUES ('CIAM', @nombreCompleto, 'SALTADO', 'El parque no existe en la BD. Importarlo primero desde SIB.');
                SET @saltados = @saltados + 1;
                GOTO NextRow;
            END

            -- Actualizar via parque_Modificar
            EXEC Gestion.parque_Modificar
                @idParque = @idParque,
                @superficie = @hectareas;

            INSERT INTO Gestion.logImportacion (origen, nombreCompleto, estado, mensaje)
            VALUES ('CIAM', @nombreCompleto, 'OK', NULL);
            SET @ok = @ok + 1;

            SET @idParque = NULL;
        END TRY
        BEGIN CATCH
            SET @errorMsg = ERROR_MESSAGE();
            INSERT INTO Gestion.logImportacion (origen, nombreCompleto, estado, mensaje)
            VALUES ('CIAM', @nombreCompleto, 'ERROR', LEFT(@errorMsg, 500));
            SET @err = @err + 1;
        END CATCH

        NextRow:
        FETCH NEXT FROM c INTO @nombreCompleto, @hectareas;
    END

    CLOSE c;
    DEALLOCATE c;

    -- Resumen
    SELECT @ok AS actualizadosOk, @err AS conError, @saltados AS saltados, 
           (@ok + @err + @saltados) AS total;
END
GO
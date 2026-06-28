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

USE GestionParquesNacionales_Com5600_Grupo07;
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
    ELSE IF @nombreCompleto LIKE 'Reserva Natural %'
    BEGIN
        SET @tipoParque = 'Reserva Natural';
        SET @nombreLimpio = LTRIM(REPLACE(@nombreCompleto, 'Reserva Natural ', ''));
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

    DECLARE @rows TABLE (
        id INT IDENTITY(1,1),
        nombreCompleto VARCHAR(200),
        provincia VARCHAR(100),
        region VARCHAR(100),
        superficie DECIMAL(12, 2),
        latitud DECIMAL(9, 6),
        longitud DECIMAL(9, 6)
    );

    INSERT INTO @rows (nombreCompleto, provincia, region, superficie, latitud, longitud)
        SELECT nombreCompleto, 
               provincia, 
               region, 
               TRY_CAST(TRY_CAST(superficie AS FLOAT) AS DECIMAL(12, 2)),
               TRY_CAST(latitud AS DECIMAL(9, 6)),
               TRY_CAST(longitud AS DECIMAL(9, 6))
        FROM Gestion.stagingSib
        WHERE nombreCompleto IS NOT NULL;

    DECLARE @i INT = 1, @max INT;
    SELECT @max = COUNT(*) FROM @rows;

    WHILE @i <= @max
    BEGIN
        SELECT @nombreCompleto = nombreCompleto, @provincia = provincia, @region = region,
               @superficie = superficie, @latitud = latitud, @longitud = longitud
        FROM @rows WHERE id = @i;
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
        SET @i = @i + 1;
    END

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

    DECLARE @rows TABLE (
        id INT IDENTITY(1,1),
        nombreCompleto VARCHAR(200),
        hectareas DECIMAL(12, 2)
    );

    INSERT INTO @rows (nombreCompleto, hectareas)
        SELECT REPLACE(REPLACE(nombreCompleto, '"', ''), CHAR(13), ''),
               TRY_CAST(REPLACE(hectareas, '"', '') AS DECIMAL(12, 2))
        FROM Gestion.stagingCiam
        WHERE nombreCompleto IS NOT NULL;

    DECLARE @i INT = 1, @max INT;
    SELECT @max = COUNT(*) FROM @rows;

    WHILE @i <= @max
    BEGIN
        SELECT @nombreCompleto = nombreCompleto, @hectareas = hectareas
        FROM @rows WHERE id = @i;
        BEGIN TRY
            -- Parseo del nombre para obtener nombre limpio
            EXEC Gestion.parsearNombreParque 
                @nombreCompleto = @nombreCompleto,
                @tipoParque = @tipoParque OUTPUT,
                @nombreLimpio = @nombreLimpio OUTPUT;

            -- Buscar el parque por nombre exacto
            SELECT @idParque = idParque 
            FROM Gestion.parque 
            WHERE nombre = @nombreLimpio COLLATE Modern_Spanish_CI_AI;

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
        SET @i = @i + 1;
    END

    -- Resumen
    SELECT @ok AS actualizadosOk, @err AS conError, @saltados AS saltados, 
           (@ok + @err + @saltados) AS total;
END
GO


CREATE OR ALTER PROCEDURE Personal.procesarImportacionGuiasCsv
AS
BEGIN
    SET NOCOUNT ON;

    -- Garantizar que exista la especialidad por defecto
    DECLARE @codEspecialidadDefault INT;
    SELECT @codEspecialidadDefault = codEspecialidad 
    FROM Personal.especialidad WHERE nombre = 'General';

    IF @codEspecialidadDefault IS NULL
    BEGIN
        EXEC Personal.altaEspecialidad @nombre = 'General', @descripcion = 'Especialidad por defecto';
        SELECT @codEspecialidadDefault = codEspecialidad 
        FROM Personal.especialidad WHERE nombre = 'General';
    END

    DECLARE @origen VARCHAR(20) = 'CSV_GUIAS';

    
    DECLARE @tituloNombre VARCHAR(100);
    DECLARE @vCodTitulo INT;

    
    DECLARE @guiaDocumento CHAR(8);
    DECLARE @guiaNombre VARCHAR(50);
    DECLARE @guiaApellido VARCHAR(50);
    DECLARE @guiaFechaNac DATE;
    DECLARE @guiaNombreTitulo VARCHAR(100);
    DECLARE @guiaCodEspecialidad INT;
    DECLARE @vLegajo INT;

    
    DECLARE @nombreCompletoLog VARCHAR(200);
    DECLARE @estadoLog VARCHAR(20);
    DECLARE @mensajeLog VARCHAR(500);

    -- aseguramos que las tablas de staging interno estén vacías
    TRUNCATE TABLE Personal.stagingTitulos;
    TRUNCATE TABLE Personal.stagingGuias;

    -- 1. PROCESAMIENTO Y TRASPASO EN STAGING

    INSERT INTO Personal.stagingTitulos (nombre)
    SELECT DISTINCT RTRIM(LTRIM(titulo))
    FROM Personal.stagingCsvGuias
    WHERE titulo IS NOT NULL AND titulo <> '';

    INSERT INTO Personal.stagingGuias (documento, nombre, apellido, fechaNacimiento, nombreTitulo, codEspecialidad)
    SELECT 
        RIGHT('00000000' + LTRIM(RTRIM(doc)), 8) AS documento, --normalizo el documento
        LTRIM(RTRIM(SUBSTRING(apellidoYNombre, CHARINDEX(',', apellidoYNombre) + 1, LEN(apellidoYNombre)))) AS nombre,
        LTRIM(RTRIM(SUBSTRING(apellidoYNombre, 1, CHARINDEX(',', apellidoYNombre) - 1))) AS apellido,
        '1900-01-01' AS fechaNacimiento,
        RTRIM(LTRIM(titulo)) AS nombreTitulo,
        @codEspecialidadDefault AS codEspecialidad
    FROM Personal.stagingCsvGuias
    WHERE apellidoYNombre LIKE '%,%';

    -- 2. PROCESAMIENTO FILA POR FILA: TITULOS
    
    DECLARE @rowsTitulos TABLE (id INT IDENTITY(1,1), nombre VARCHAR(100));
    INSERT INTO @rowsTitulos (nombre)
        SELECT nombre FROM Personal.stagingTitulos WHERE nombre IS NOT NULL;

    DECLARE @iT INT = 1, @maxT INT;
    SELECT @maxT = COUNT(*) FROM @rowsTitulos;

    WHILE @iT <= @maxT
    BEGIN
        SELECT @tituloNombre = nombre FROM @rowsTitulos WHERE id = @iT;

        SELECT @vCodTitulo = codTitulo FROM Personal.titulos WHERE nombre = @tituloNombre;

        BEGIN TRY
            IF @vCodTitulo IS NOT NULL
            BEGIN
                -- Si ya existe, lo modificamos
                EXEC Personal.modificarTitulo @codTitulo = @vCodTitulo, @nombre = @tituloNombre, @descripcion = 'Actualizado vía SP';
            END
            ELSE
            BEGIN
                -- Si no existe, lo damos de alta
                EXEC Personal.altaTitulo @nombre = @tituloNombre, @descripcion = 'Alta vía SP';
            END
        END TRY
        BEGIN CATCH
            -- Si falla un título individual, se registra en el log pero el proceso continúa
            SET @mensajeLog = 'Error procesando título ' + @tituloNombre + ': ' + SUBSTRING(ERROR_MESSAGE(), 1, 400);
            INSERT INTO Gestion.logImportacion (origen, nombreCompleto, estado, mensaje)
            VALUES (@origen, @tituloNombre, 'ERROR', @mensajeLog);
        END CATCH;

        SET @iT = @iT + 1;
    END;

    -- 3. PROCESAMIENTO FILA POR FILA: GUIAS (CON LOGS INDIVIDUALES)

    DECLARE @rowsGuias TABLE (
        id INT IDENTITY(1,1),
        documento CHAR(8),
        nombre VARCHAR(50),
        apellido VARCHAR(50),
        fechaNacimiento DATE,
        nombreTitulo VARCHAR(100),
        codEspecialidad INT
    );
    INSERT INTO @rowsGuias (documento, nombre, apellido, fechaNacimiento, nombreTitulo, codEspecialidad)
        SELECT documento, nombre, apellido, fechaNacimiento, nombreTitulo, codEspecialidad
        FROM Personal.stagingGuias;

    DECLARE @iG INT = 1, @maxG INT;
    SELECT @maxG = COUNT(*) FROM @rowsGuias;

    WHILE @iG <= @maxG
    BEGIN
        SELECT @guiaDocumento = documento, @guiaNombre = nombre, @guiaApellido = apellido,
               @guiaFechaNac = fechaNacimiento, @guiaNombreTitulo = nombreTitulo, @guiaCodEspecialidad = codEspecialidad
        FROM @rowsGuias WHERE id = @iG;

        SET @nombreCompletoLog = @guiaApellido + ', ' + @guiaNombre;
        SET @vCodTitulo = NULL;
        SET @vLegajo = NULL;

        -- Resolvemos el id del título para pasarlo como parámetro
        SELECT @vCodTitulo = codTitulo FROM Personal.titulos WHERE nombre = @guiaNombreTitulo;

        IF @vCodTitulo IS NOT NULL
        BEGIN
            -- Verificamos si el guía ya existe por documento para obtener su legajo
            SELECT @vLegajo = legajo FROM Personal.guias WHERE documento = @guiaDocumento;

            -- Cada operación individual corre bajo su propia transacción atómica
            BEGIN TRANSACTION;
            BEGIN TRY
                IF @vLegajo IS NOT NULL
                BEGIN
                    -- UPDATE usando tu SP modificarGuia
                    EXEC Personal.modificarGuia 
                        @legajo = @vLegajo, 
                        @nombre = @guiaNombre, 
                        @apellido = @guiaApellido, 
                        @fechaNacimiento = @guiaFechaNac, 
                        @codTitulo = @vCodTitulo, 
                        @codEspecialidad = @guiaCodEspecialidad;

                    SET @mensajeLog = 'Guía actualizado correctamente. Legajo: ' + CAST(@vLegajo AS VARCHAR(10));
                    SET @estadoLog = 'OK';
                END
                ELSE
                BEGIN
                    -- INSERT usando tu SP altaGuia
                    EXEC Personal.altaGuia 
                        @documento = @guiaDocumento, 
                        @nombre = @guiaNombre, 
                        @apellido = @guiaApellido, 
                        @fechaNacimiento = @guiaFechaNac, 
                        @codTitulo = @vCodTitulo, 
                        @codEspecialidad = @guiaCodEspecialidad;

                    SET @mensajeLog = 'Guía dado de alta correctamente. Doc: ' + @guiaDocumento;
                    SET @estadoLog = 'OK';
                END

                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                ROLLBACK TRANSACTION;
                SET @mensajeLog = 'Fallo al procesar guía: ' + SUBSTRING(ERROR_MESSAGE(), 1, 400);
                SET @estadoLog = 'ERROR';
            END CATCH;
        END
        ELSE
        BEGIN
            SET @mensajeLog = 'Saltado: No se encontró un ID válido para el título: ' + ISNULL(@guiaNombreTitulo, 'NULO');
            SET @estadoLog = 'SALTADO';
        END

        -- Escribimos el resultado de la fila en tu tabla de logs
        INSERT INTO Gestion.logImportacion (origen, nombreCompleto, estado, mensaje)
        VALUES (@origen, @nombreCompletoLog, @estadoLog, @mensajeLog);

        SET @iG = @iG + 1;
    END;

    -- 4. LIMPIEZA FINAL DE LAS TABLAS DE STAGING
    TRUNCATE TABLE Personal.stagingCsvGuias;
    TRUNCATE TABLE Personal.stagingTitulos;
    TRUNCATE TABLE Personal.stagingGuias;

    INSERT INTO Gestion.logImportacion (origen, nombreCompleto, estado, mensaje)
    VALUES (@origen, 'PROCESO_GLOBAL', 'OK', 'Finalizó la ejecución completa del Stored Procedure.');
END;
GO
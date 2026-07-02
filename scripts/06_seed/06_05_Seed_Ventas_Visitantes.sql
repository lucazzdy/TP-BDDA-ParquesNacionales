/* 
    Script generado el 24/06/26

    Grupo n°7
    Integrantes:    - Acuña, Lucas Daniel
                    - Alesina, Alan
                    - Gutierrez, Lucas Leone
                    - Zambrana, Mijael

    Descripción del Script: Seed data del esquema Ventas de visitantes.
                                                      
    Incluye:
    - Tipos de visitantes
    - Visitantes de varios tipos
*/

USE GestionParquesNacionales_Com5600_Grupo07
GO

-- ====================================================================
-- TIPOS DE VISITANTES
-- ====================================================================
IF NOT EXISTS (SELECT 1 FROM Ventas.tipoVisitante)
BEGIN
    EXEC Ventas.tipoVisitanteAlta @descripcion = 'Nacional';
    EXEC Ventas.tipoVisitanteAlta @descripcion = 'Residente Provincial';
    EXEC Ventas.tipoVisitanteAlta @descripcion = 'Extranjero';
    EXEC Ventas.tipoVisitanteAlta @descripcion = 'No Residente';
    EXEC Ventas.tipoVisitanteAlta @descripcion = 'Estudiante';
    EXEC Ventas.tipoVisitanteAlta @descripcion = 'Jubilado';
    EXEC Ventas.tipoVisitanteAlta @descripcion = 'Menor';
END

/*
SELECT * FROM Ventas.tipoVisitante
*/

-- ====================================================================
-- FORMAS DE PAGO
-- ====================================================================

IF NOT EXISTS (SELECT 1 FROM Ventas.formaPago)
BEGIN
    EXEC Ventas.formaPagoAlta @descripcion = 'Efectivo';
    EXEC Ventas.formaPagoAlta @descripcion = 'Tarjeta Debito';
    EXEC Ventas.formaPagoAlta @descripcion = 'Tarjeta Credito';
    EXEC Ventas.formaPagoAlta @descripcion = 'Transferencia';
    EXEC Ventas.formaPagoAlta @descripcion = 'Mercado Pago';
END

/*
SELECT * FROM Ventas.formaPago
*/

-- ====================================================================
-- VISITANTES
-- ====================================================================

IF NOT EXISTS (SELECT 1 FROM Ventas.visitante)
BEGIN
    DECLARE @i INT = 1;

    DECLARE @Nombres TABLE(nombre VARCHAR(50));
    DECLARE @ApellidosNacionales TABLE(
    apellido VARCHAR(50));
    DECLARE @ApellidosExtranjeros TABLE(
    apellido VARCHAR(50));

    INSERT INTO @Nombres VALUES
    ('Juan'),('Ana'),('Carlos'),('Mariana'),('Pedro'),
    ('Lucia'),('Roberto'),('Sofia'),('Martin'),('Valeria'),
    ('Diego'),('Camila'),('Fernando'),('Julieta'),('Nicolas'),
    ('Mateo'),('Agustina'),('Joaquin'),('Milagros'),('Tomás'),
    ('Emma'),('Lautaro'),('Renata'),('Thiago'),('Catalina');

    INSERT INTO @ApellidosNacionales VALUES
    ('Perez'),('Gomez'),('Lopez'),('Ruiz'),('Fernandez'),
    ('Diaz'),('Martinez'),('Sanchez'),('Rodriguez'),
    ('Torres'),('Acosta'),('Benitez'),('Romero'),
    ('Castro'),('Alvarez'),('Suarez'),('Vega'),
    ('Molina'),('Herrera'),('Rojas');

    INSERT INTO @ApellidosExtranjeros VALUES
    ('Smith'),('Brown'),('Johnson'),('Wilson'),
    ('Muller'),('Schmidt'),('Rossi'),
    ('Moretti'),('Dubois'),('Ivanov'),
    ('Petrov'),('Kowalski');

    WHILE @i <= 1000
    BEGIN

        DECLARE @nombre VARCHAR(50);
        DECLARE @apellido VARCHAR(50);
        DECLARE @fechaNacimiento DATE;
        DECLARE @edad INT;
        DECLARE @idTipoVisitante INT;
        DECLARE @numeroDocumento INT;
        DECLARE @rnd INT;
        DECLARE @categoria INT;

        -- Nombre aleatorio

        SELECT TOP 1
            @nombre = nombre
        FROM @Nombres
        ORDER BY NEWID();

        -- 15% de apellidos extranjeros

        IF ABS(CHECKSUM(NEWID())) % 100 < 15
        BEGIN
            SELECT TOP 1
                @apellido = apellido
            FROM @ApellidosExtranjeros
            ORDER BY NEWID();
        END
        ELSE
        BEGIN
            SELECT TOP 1
                @apellido = apellido
            FROM @ApellidosNacionales
            ORDER BY NEWID();
        END

        -- la distribución de edades seria:
        -- 15% menores
        -- 20% jubilados
        -- 65% adultos

        SET @rnd = ABS(CHECKSUM(NEWID())) % 100;

        IF @rnd < 15
        BEGIN
            -- Menores (0-17)
            SET @fechaNacimiento =
                DATEADD( DAY, -(ABS(CHECKSUM(NEWID())) % (18 * 365)), GETDATE());
        END
        ELSE IF @rnd < 35
        BEGIN
            -- Jubilados (65-90)
            SET @fechaNacimiento =
                DATEADD(DAY, -((65 * 365) + ABS(CHECKSUM(NEWID())) % (25 * 365)), GETDATE());
        END
        ELSE
        BEGIN
            -- Adultos (18-64)
            SET @fechaNacimiento =
                DATEADD( DAY, -((18 * 365) + ABS(CHECKSUM(NEWID())) % (47 * 365)), GETDATE());
        END

        -- cálculo de edad

        SET @edad = DATEDIFF(YEAR, @fechaNacimiento, GETDATE());

        -- determinacion del tipo visitante

        IF @edad < 18
        BEGIN
            SET @idTipoVisitante = 7; -- Menor
        END
        ELSE IF @edad >= 65
        BEGIN
            SET @idTipoVisitante = 6; -- Jubilado
        END
        ELSE IF EXISTS (SELECT 1 FROM @ApellidosExtranjeros WHERE apellido = @apellido)
        BEGIN
            SET @idTipoVisitante = 3; -- Extranjero
        END
        ELSE IF @edad BETWEEN 18 AND 25
        BEGIN
            SET @idTipoVisitante = 5; -- Estudiante
        END
        ELSE
        BEGIN

            SET @categoria = ABS(CHECKSUM(NEWID())) % 3;

            IF @categoria = 0
                SET @idTipoVisitante = 1; -- Nacional

            ELSE IF @categoria = 1
                SET @idTipoVisitante = 2; -- Residente Provincial

            ELSE
                SET @idTipoVisitante = 4; -- No Residente

        END

        SET @numeroDocumento = 20000000 + @i;

        EXEC Ventas.visitanteAlta
            @idTipoVisitante = @idTipoVisitante,
            @nombre = @nombre,
            @apellido = @apellido,
            @fechaNacimiento = @fechaNacimiento,
            @tipoDocumento = 'DNI',
            @numeroDocumento = @numeroDocumento;

        SET @i = @i + 1;

    END
END
GO

/*
SELECT * FROM ventas.visitante
*/
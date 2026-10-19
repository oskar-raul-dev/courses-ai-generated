USE [ALAMEDA]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ExtraerDNI]    Script Date: 10/10/2026 01:47:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Matias
-- Create date: 2016-10-14
-- Description: copia del ExtraerDNI del Access (ModParser) para usar en los reportes.
--              Mismo comportamiento que el VBA a la fecha.
--              Si se cambia el VBA hay que cambiar esto tambien.
-- =============================================
CREATE FUNCTION [dbo].[fn_ExtraerDNI] (@crudo nvarchar(255))
RETURNS nvarchar(50)
AS
BEGIN
    DECLARE @resto nvarchar(255) = LTRIM(RTRIM(ISNULL(@crudo, N'')))
    DECLARE @t nvarchar(255), @u nvarchar(255), @sig nvarchar(255), @sig2 nvarchar(255)
    DECLARE @dni nvarchar(50) = N'', @primero bit = 1, @p int

    WHILE LEN(@resto) > 0
    BEGIN
        SET @p = CHARINDEX(N' ', @resto)
        IF @p = 0 BEGIN SET @t = @resto; SET @resto = N'' END
        ELSE BEGIN SET @t = LEFT(@resto, @p - 1); SET @resto = LTRIM(SUBSTRING(@resto, @p + 1, 255)) END
        SET @u = UPPER(@t)

        -- el token que sigue, sin consumirlo
        SET @p = CHARINDEX(N' ', @resto)
        SET @sig = CASE WHEN @p = 0 THEN @resto ELSE LEFT(@resto, @p - 1) END

        IF @u IN (N'DNI', N'LE', N'LC') AND @dni = N'' AND LEN(@resto) > 0
        BEGIN
            SET @dni = REPLACE(@sig, N'.', N'')
            SET @resto = LTRIM(SUBSTRING(@resto, LEN(@sig) + 2, 255))
        END
        ELSE IF @u IN (N'P', N'PASAP') AND @dni = N'' AND CHARINDEX(N' ', @resto) > 0
        BEGIN
            -- pasaporte: el pais y despues el numero
            SET @resto = LTRIM(SUBSTRING(@resto, LEN(@sig) + 2, 255))
            SET @p = CHARINDEX(N' ', @resto)
            SET @sig2 = CASE WHEN @p = 0 THEN @resto ELSE LEFT(@resto, @p - 1) END
            SET @dni = @sig2
            SET @resto = LTRIM(SUBSTRING(@resto, LEN(@sig2) + 2, 255))
        END
        ELSE IF @u = N'RN' AND @primero = 1
        BEGIN
            SET @dni = @dni   -- recien nacido: el DNI que venga es el de la madre
        END
        ELSE IF CHARINDEX(N'/', @t) > 0 AND TRY_CONVERT(date, @t, 3) IS NOT NULL
        BEGIN
            SET @dni = @dni   -- una fecha: el reporte usa dbo.fn_ExtraerFecha
        END
        ELSE IF @dni = N'' AND @t NOT LIKE N'%[^0-9.]%' AND LEN(REPLACE(@t, N'.', N'')) >= 7
        BEGIN
            SET @dni = REPLACE(@t, N'.', N'')
        END
        SET @primero = 0
    END
    RETURN @dni
END
GO

-- =============================================
-- Author:      Matias
-- Create date: 2016-10-14
-- Description: la fecha que viene en el nombre (dd/mm/aa o dd/mm/aaaa), para la edad del reporte.
-- =============================================
CREATE FUNCTION [dbo].[fn_ExtraerFecha] (@crudo nvarchar(255))
RETURNS date
AS
BEGIN
    DECLARE @resto nvarchar(255) = LTRIM(RTRIM(ISNULL(@crudo, N''))), @t nvarchar(255), @p int
    WHILE LEN(@resto) > 0
    BEGIN
        SET @p = CHARINDEX(N' ', @resto)
        IF @p = 0 BEGIN SET @t = @resto; SET @resto = N'' END
        ELSE BEGIN SET @t = LEFT(@resto, @p - 1); SET @resto = LTRIM(SUBSTRING(@resto, @p + 1, 255)) END
        IF CHARINDEX(N'/', @t) > 0
        BEGIN
            -- estilo 103 si trae el anio con cuatro cifras; si no, el 3 (dd/mm/yy)
            IF @t LIKE N'%/%/[0-9][0-9][0-9][0-9]'
                RETURN TRY_CONVERT(date, @t, 103)
            RETURN TRY_CONVERT(date, @t, 3)
        END
    END
    RETURN NULL
END
GO

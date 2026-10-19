USE ss04;
SET QUOTED_IDENTIFIER ON;
GO
-- ej9: cuántas versiones hay ahora
SELECT COUNT(*) AS versiones FROM dbo.resultado FOR SYSTEM_TIME ALL WHERE IdItem = 12123358;
SELECT Valor, ModificadoPor FROM dbo.resultado FOR SYSTEM_TIME ALL WHERE IdItem = 12123358 ORDER BY ValidoDesde;
GO
-- ej5: las cuatro subcláusulas con el período de Lucía
DECLARE @d datetime2(3), @h datetime2(3);
SELECT @d = ValidoDesde, @h = ValidoHasta FROM dbo.resultado_historia WHERE IdItem = 12123358 AND ModificadoPor = N'lucia2';
SELECT 'AS OF' AS cl, Valor, ModificadoPor FROM dbo.resultado FOR SYSTEM_TIME AS OF @d WHERE IdItem = 12123358
UNION ALL SELECT 'FROM TO', Valor, ModificadoPor FROM dbo.resultado FOR SYSTEM_TIME FROM @d TO @h WHERE IdItem = 12123358
UNION ALL SELECT 'BETWEEN', Valor, ModificadoPor FROM dbo.resultado FOR SYSTEM_TIME BETWEEN @d AND @h WHERE IdItem = 12123358
UNION ALL SELECT 'CONTAINED', Valor, ModificadoPor FROM dbo.resultado FOR SYSTEM_TIME CONTAINED IN (@d, @h) WHERE IdItem = 12123358;
GO
-- ej10: la vista en hora de Córdoba
CREATE OR ALTER VIEW dbo.resultado_historia_cordoba AS
SELECT IdItem, Valor, ModificadoPor,
       CAST((ValidoDesde AT TIME ZONE 'UTC') AT TIME ZONE 'Argentina Standard Time' AS datetime2(3)) AS desde_cordoba,
       CASE WHEN ValidoHasta = '9999-12-31 23:59:59.999' THEN NULL
            ELSE CAST((ValidoHasta AT TIME ZONE 'UTC') AT TIME ZONE 'Argentina Standard Time' AS datetime2(3)) END AS hasta_cordoba
FROM dbo.resultado FOR SYSTEM_TIME ALL;
GO
SELECT TOP (2) Valor, ModificadoPor, desde_cordoba, hasta_cordoba FROM dbo.resultado_historia_cordoba WHERE IdItem = 12123358 ORDER BY desde_cordoba;
GO
-- ej8: el disparador que exige el quién
CREATE OR ALTER TRIGGER dbo.resultado_exige_quien ON dbo.resultado AFTER UPDATE AS
IF EXISTS (SELECT 1 FROM inserted AS i JOIN deleted AS d ON d.IdItem = i.IdItem
           WHERE i.ModificadoPor = d.ModificadoPor AND i.ModificadoPor <> CAST(SESSION_CONTEXT(N'usuario') AS nvarchar(50)))
    THROW 50001, N'ModificadoPor tiene que ser el usuario de la sesión', 1;
GO
EXEC sp_set_session_context @key = N'usuario', @value = N'lucia2';
UPDATE dbo.resultado SET Valor = N'158' WHERE IdItem = 12123358;
GO
SELECT Valor FROM dbo.resultado WHERE IdItem = 12123358;
DROP TRIGGER dbo.resultado_exige_quien;
GO
-- ej11: dos claves
DROP TABLE IF EXISTS dbo.order_dos_claves;
CREATE TABLE dbo.order_dos_claves (
    order_id int IDENTITY(1,1) NOT NULL CONSTRAINT order_dos_claves_pk PRIMARY KEY CLUSTERED,
    public_id uniqueidentifier NOT NULL CONSTRAINT order_dos_claves_public UNIQUE NONCLUSTERED,
    legacy_order_id int NOT NULL, patient_id int NULL, ordered_on datetime NULL, site_code nvarchar(1) NULL);
INSERT INTO dbo.order_dos_claves (public_id, legacy_order_id, patient_id, ordered_on, site_code)
SELECT NEWID(), legacy_order_id, patient_id, ordered_on, site_code FROM dbo.order_int;
SELECT COUNT(*) AS filas FROM dbo.order_dos_claves;
GO
